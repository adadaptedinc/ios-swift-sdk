//
//  AAConnector.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation
import UIKit

class AAConnector: NSObject, URLSessionDelegate {
    let kDefaultBatchDispatchIntervalSeconds = 10.0
    
    var inTestMode = false
    private var isOnline = false
    private var udid: String?
    private var appID: String?
    private var sessionID: String?
    private var immediateQueue = Queue<AARequestBlockHolder>()
    private var events = [AnyHashable]()
    private var eventsV2 = [AnyHashable]()
    private var collectableEvents = [AnyHashable]()
    private var collectableErrorEvents = [AnyHashable]()
    private var backgroundUpdateTask: UIBackgroundTaskIdentifier! = .invalid
    private var timer: Timer?
    private var session: URLSession?

    override init() {
        super.init()

        let sessionConfig = URLSessionConfiguration.default
        session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)

        timer = Timer.scheduledTimer(
            timeInterval: TimeInterval(kDefaultBatchDispatchIntervalSeconds),
            target: self,
            selector: #selector(timerFired(_:)),
            userInfo: nil,
            repeats: true)
    }
    
    func dispatchCachedMessages() {
        sendNextMessage()
    }

    func enqueueRequest(
        _ aaRequest: AAGenericRequest?,
        responseWasErrorBlock: @escaping AAResponseWasErrorBlock,
        responseWasReceivedBlock: @escaping AAResponseWasReceivedBlock
    ) {
        if let aaRequest = aaRequest {
            let holder = AARequestBlockHolder()
            holder.request = aaRequest
            holder.responseWasReceivedBlock = responseWasReceivedBlock
            holder.requestWasErrorBlock = responseWasErrorBlock
            immediateQueue.enqueue(holder)
            sendNextMessage()
        }
    }

    func addEvent(forBatchDispatch event: AAReportableSessionEvent?) {
        if let event = event {
            events.append(event)
        }
    }

    func addAnomalyEvent(forDispatch event: AAReportableAnomalyEvent?) {
        if let sessionID = sessionID {
            event?.setParamValue(sessionID as NSObject, forKey: AA_KEY_SESSION_ID)
        }

        if let appID = appID {
            event?.setParamValue(appID as NSObject, forKey: AA_KEY_APP_ID)
        }

        if let event = event {
            eventsV2.append(event)
        }
    }

    func addCollectableEvent(forDispatch event: AACollectableEvent?) {
        if let event = event {
            collectableEvents.append(event)
        }
    }

    func addCollectableError(forDispatch event: AACollectableError?) {
        if let event = event {
            collectableErrorEvents.append(event)
        }
    }

    func sessionId() -> String? {
        return sessionID
    }

// MARK: - Private
    func sendingBlocked() -> Bool {
        if immediateQueue.isEmpty && !hasBatchEvents() {
            return true
        } else if (immediateQueue.size() > 0) {
            let holder = immediateQueue.peek()
            let aaRequest = holder?.request
            if aaRequest is AAInitRequest {
                return false
            }
        }
        return !AASDK.isReadyForUse()
    }

    func sendNextMessage() {
        if sendingBlocked() {
            return
        }

        if hasBatchEvents() {
            enqueueBatchEventRequests()
        }

        let holder = immediateQueue.dequeue()
        var aaRequest = holder?.request

        // Initializing request params
        var url: URL?
        var methodType: String?

        // Request is init POST request
        if aaRequest is AAInitRequest {
            appID = (aaRequest as? AAInitRequest)?.appID()
            udid = (aaRequest as? AAInitRequest)?.udid()
            url = (aaRequest as? AAInitRequest)?.targetURL()
            methodType = "POST"

            // Request is GET request
        } else if aaRequest is AAUpdateAdsRequest || aaRequest is AAKeywordInterceptInitRequest {
            let tURL = try! aaRequest?.targetURL()
            let qURL = "?aid=\(appID ?? "")&uid=\(udid ?? "")&sid=\(sessionID ?? "")&sdk=\(AAHelper.sdkVersion())"
            url = URL(string: (tURL?.absoluteString ?? "") + qURL)
            aaRequest = nil //drop request body
            methodType = "GET"

            // Request is other POST request
        } else {
            aaRequest?.setParamValue(sessionID as NSObject?, forKey: AA_KEY_SESSION_ID)
            aaRequest?.setParamValue(appID as NSObject?, forKey: AA_KEY_APP_ID)
            
            url = try! aaRequest?.targetURL()
            methodType = "POST"
        }
        
        if inTestMode && !(aaRequest is AACollectableEventRequest) {
            aaRequest?.setParamValue(NSNumber(value: true), forKey: AA_KEY_TEST_MODE)
        }
                
        let jsonMessage = aaRequest?.asData()
        var request: URLRequest?
        if let url = url {
            request = URLRequest(url: url)
        }
        request?.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request?.setValue(appID, forHTTPHeaderField: "X-API-KEY")
        request?.httpMethod = methodType ?? ""
        request?.httpBody = jsonMessage
        
        var task: URLSessionDataTask?
        if let request = request {
            task = session?.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                var JSON: Any?
                
                do {
                    // Check for HTTP error first
                    if response is HTTPURLResponse {
                        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                        if statusCode >= 400 {
                            ReportManager.getInstance().reportAnomaly(withCode: CODE_API_400, message: response.debugDescription, params: nil)
                            self.sendNextMessage()
                            return
                        }
                    }
                    do {
                        if let data = data {
                            JSON = try JSONSerialization.jsonObject(with: data)
                        }
                    } catch {
                        AASDK.trackAnomalyGenericErrorMessage(error.localizedDescription, optionalAd: nil)
                    }
                }

                if JSON == nil {
                    AASDK.logDebugMessage("JSON Empty", type: AASDK.DEBUG_NETWORK)
                } else if error == nil {
                    do {
                        // grab session ID and set it
                        if (aaRequest is AAInitRequest) && (JSON as AnyObject).value(forKeyPath: AA_KEY_SESSION_ID) != nil {
                            self.sessionID = (JSON as AnyObject).value(forKeyPath: AA_KEY_SESSION_ID) as? String
                            AAHelper.storeCurrentSessionId(sessionId: self.sessionID)
                        }

                        if JSON != nil {
                            let aaResponse = try! holder?.request!.parseResponse(fromJSON: JSON)
                            var jsonData: Data?
                            var text: String?

                            do {
                                if let JSON = JSON {
                                    jsonData = try JSONSerialization.data(withJSONObject: JSON, options: .prettyPrinted)
                                }
                            } catch {
                                AASDK.trackAnomalyGenericErrorMessage(error.localizedDescription, optionalAd: nil)
                            }

                            if let jsonData = jsonData {
                                text = String(decoding: jsonData, as: UTF8.self)
                            }

                            AASDK.logDebugMessage("RESPONSE JSON from \(request.url?.absoluteString ?? ""):\n\(text ?? "")", type: AASDK.DEBUG_NETWORK_DETAILED)
                            holder?.responseWasReceivedBlock!(aaResponse, holder?.request)
                        } else {
                            AASDK.logDebugMessage("RESPONSE w/ no BODY from \(request.url?.absoluteString ?? "")", type: AASDK.DEBUG_NETWORK_DETAILED)
                        }

                        if response is HTTPURLResponse {
                            let httpResponse = response as? HTTPURLResponse
                            let headers = httpResponse?.allHeaderFields
                            let choosenCamp = headers?["X-Chosen-Campaign"] as? String
                            if let choosenCamp = choosenCamp {
                                AASDK.logDebugMessage("Chosen Campaign: \(choosenCamp)", type: AASDK.DEBUG_GENERAL)
                            }
                        }
                    }
                } else {
                    AASDK.logDebugMessage("AASDK ERROR AAConnector Error response from \(request.url?.absoluteString ?? ""):\n\(self.description)\n", type: AASDK.DEBUG_NETWORK_DETAILED)
                    let aaResponse = AAErrorResponse()
                    aaResponse.error = error
                    aaResponse.aaRequest = holder?.request
                    aaResponse.json = JSON
                    if response is HTTPURLResponse {
                        let httpResponse = response as? HTTPURLResponse
                        aaResponse.nsHTTPURLResponse = httpResponse
                    }
                    holder?.requestWasErrorBlock!(aaResponse, holder?.request, error)
                    self.sendNextMessage()
                }
            })
        }
        
        task?.resume()
        sendNextMessage()
    }

    func hasBatchEvents() -> Bool {
        return (events.count) > 0 || (eventsV2.count) > 0 || (collectableEvents.count) > 0
    }

    func enqueueBatchEventRequests() {
        if !AASDK.isReadyForUse() {
            return
        }

        let responseWasReceivedBlock = { response, forRequest in
        } as AAResponseWasReceivedBlock

        let responseWasErrorBlock = { response, forRequest, error in
        } as AAResponseWasErrorBlock

        if (events.count) > 0 {
            let request = AABatchEventRequest(events: events)
            events.removeAll()
            enqueueRequest(request, responseWasErrorBlock: responseWasErrorBlock, responseWasReceivedBlock: responseWasReceivedBlock)
        }

        if (eventsV2.count) > 0 {
            let request = AABatchEventRequest(events: eventsV2, forVersion: 2)
            eventsV2.removeAll()
            enqueueRequest(request, responseWasErrorBlock: responseWasErrorBlock, responseWasReceivedBlock: responseWasReceivedBlock)
        }

        if (collectableEvents.count) > 0 {
            let request = AACollectableEventRequest(events: collectableEvents)
            collectableEvents.removeAll()
            enqueueRequest(request, responseWasErrorBlock: responseWasErrorBlock, responseWasReceivedBlock: responseWasReceivedBlock)
        }

        if (collectableErrorEvents.count) > 0 {
            let request = AACollectableErrorRequest(events: collectableErrorEvents)
            collectableErrorEvents.removeAll()
            enqueueRequest(request, responseWasErrorBlock: responseWasErrorBlock, responseWasReceivedBlock: responseWasReceivedBlock)
        }
    }

    @objc func timerFired(_ timer: Timer?) {
        sendNextMessage()
    }
}
