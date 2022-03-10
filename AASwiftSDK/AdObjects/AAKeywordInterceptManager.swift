//
//  AAKeywordInterceptManager.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation
import WebKit

let DISPATCH_TIMER_INTERVAL = 5.0

@objcMembers
class AAKeywordInterceptManager: NSObject, WKUIDelegate {

    var events: [AnyHashable]?
    var keywordIntercepts: [AnyHashable]?
    var lastUserInput: String?
    private var dispatchTimer: Timer?
    private var lastKeywordIntercept: AAKeywordIntercept?
    private var minMatchLength = 0
    private weak var connector: AAConnector?

    init(connector: AAConnector?, minMatchLength minMatch: Int) {
        super.init()
        events = []
        minMatchLength = minMatch
        self.connector = connector
    }
    
    func loadKeywordIntercepts(_ keywordIntercepts: [AnyHashable]?) {
        if let keywordIntercepts = keywordIntercepts {
            self.keywordIntercepts = keywordIntercepts
        }
        compileCachableAssetsAndNotify()
    }
    
    func matchUserInput(_ userInput: String?) -> [AnyHashable: Any]? {
        if (userInput?.count ?? 0) < minMatchLength {
            lastKeywordIntercept = nil
            return nil
        }
        
        lastUserInput = userInput
        lastKeywordIntercept = matchKeywordIntercept(withUserInput: userInput)
        if lastKeywordIntercept != nil {
            fileEvent(forUserInput: lastUserInput, with: lastKeywordIntercept, andType: AASDK_KI_EVENT_TYPE_MATCHED)
            return getMatchFor(lastKeywordIntercept)
        } else {
            return handleNoMatch(forUserInput: userInput)
        }
    }
    
    func reportPresented() {
        AASDK.logDebugMessage("Regeistered KI event: presented", type: AASDK.DEBUG_GENERAL)
        fileEvent(forUserInput: lastUserInput, with: lastKeywordIntercept, andType: AASDK_KI_EVENT_TYPE_PRESENTED)
    }
    
    func reportSelected() {
        AASDK.logDebugMessage("Regeistered KI event: selected", type: AASDK.DEBUG_GENERAL)
        fileEvent(forUserInput: lastUserInput, with: lastKeywordIntercept, andType: AASDK_KI_EVENT_TYPE_SELECTED)
    }
    
    // MARK: - PRIVATE
    func matchKeywordIntercept(withUserInput userInput: String?) -> AAKeywordIntercept? {
        print("userInput 1: \(String(describing: userInput))")
        for intercept in keywordIntercepts ?? [] {
            print("intercept 1: \(intercept)")
            guard let intercept = intercept as? AAKeywordIntercept else {
                continue
            }
            if (intercept.term as NSString?)?.range(of: userInput ?? "", options: [.anchored, .caseInsensitive]).location != NSNotFound {
                return intercept
            }
        }
        return nil
    }
    
    func getMatchFor(_ keywordIntercept: AAKeywordIntercept?) -> [AnyHashable: Any]? {
        print("getMatchFor intercept: \(String(describing: keywordIntercept))")
        return [
            AASDK_KEY_KI_REPLACEMENT_ID: keywordIntercept?.hashValue ?? "",
            AASDK.KEY_KI_REPLACEMENT_TEXT: keywordIntercept?.replacementText ?? "",
            AASDK_KEY_KI_REPLACEMENT_ICON_URL: keywordIntercept?.iconURL ?? "",
            AASDK_KEY_KI_REPLACEMENT_TAGLINE: keywordIntercept?.taglineText ?? ""
        ] as [String : Any]
    }
    
    func handleNoMatch(forUserInput userInput: String?) -> [AnyHashable: Any]? {
        fileEvent(forUserInput: userInput, with: nil, andType: AASDK_KI_EVENT_TYPE_NOT_MATCHED)
        return nil
    }
    
    func fileEvent(forUserInput userInput: String?, with keywordIntercept: AAKeywordIntercept?, andType type: String?) {
        if (type == AASDK_KI_EVENT_TYPE_MATCHED) || (type == AASDK_KI_EVENT_TYPE_NOT_MATCHED) || (type == AASDK_KI_EVENT_TYPE_PRESENTED) {
            for event in events ?? [] {
                guard let event = event as? AAKeywordInterceptEvent else {
                    continue
                }
                if (type == event.eventType()) && (userInput?.hasPrefix(event.getUserInput() ?? "") ?? false) {
                    events?.removeAll { $0 as AnyObject === event as AnyObject }
                    break
                }
            }
        }
        
        let event = AAKeywordInterceptEvent(type: type, userInput: userInput, with: keywordIntercept)
        events?.append(event)
        
        fireDispatchTimer()
    }
    
    func fireDispatchTimer() {
        if dispatchTimer != nil {
            dispatchTimer?.invalidate()
            dispatchTimer = nil
        }
        
        
        dispatchTimer = Timer.scheduledTimer(
            timeInterval: TimeInterval(DISPATCH_TIMER_INTERVAL),
            target: self,
            selector: #selector(timerFired),
            userInfo: nil,
            repeats: false)
    }
    
    @objc func timerFired() {
        if dispatchTimer != nil {
            dispatchTimer?.invalidate()
            dispatchTimer = nil
        }
        
        
        let request = AAKeywordInterceptBatchEventRequest(events: events)
        connector?.enqueueRequest(request, responseWasErrorBlock: { response, forRequest, error in
            Logger.consoleLogError(error, withMessage: "AASDK KI events reporting FAILED", suppressTracking: false)
        }, responseWasReceivedBlock: { response, forRequest in
            self.events?.removeAll()
        })
    }
    
    func compileCachableAssetsAndNotify() {
        var mdic: [AnyHashable: Any] = [:]
        for ki in keywordIntercepts ?? [] {
            guard let ki = ki as? AAKeywordIntercept else {
                continue
            }
            var dic = [
                AASDK_KEY_KI_REPLACEMENT_ID: ki.termID ?? "" ,
                AASDK.KEY_KI_REPLACEMENT_TEXT: ki.replacementText ?? "",
                AASDK_KEY_KI_REPLACEMENT_TAGLINE: ki.taglineText ?? ""
            ] as [String : Any]
            if ki.iconURL != nil && (ki.iconURL?.count ?? 0) > 0 {
                dic[AASDK_KEY_KI_REPLACEMENT_ICON_URL] = ki.iconURL ?? ""
            }
            mdic[ki.hashValue] = dic
        }
        AASDK.reportKeywordInterceptInitComplete(mdic)
    }
}
