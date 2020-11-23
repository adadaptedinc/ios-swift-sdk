//
//  ReportManager.swift
//  AASwiftSDK
//
//  Created by Brett Clifton on 10/28/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation

class ReportManager {
    private static var instance: ReportManager? =  nil
    private var connector: AAConnector
    
    class func getInstance() -> ReportManager {
        return instance!
    }
    
    class func createInstance(connector: AAConnector) {
        instance = ReportManager(aaConnector: connector)
    }
    
    private init(aaConnector: AAConnector) {
        connector = aaConnector
    }

    func reportItemInteraction(_ itemName: String, itemList: String?, eventName: String?) {
        var payload = [AnyHashable : Any](minimumCapacity: 2)
        payload["item_name"] = itemName

        if let list = itemList {
            payload["list_name"] = list
        }

        let item = AASDK.cachedItem(matching: itemName)
        if let item = item {
            payload[AA_KEY_TRACKING_ID] = item.trackingId
            payload[AA_KEY_PAYLOAD_ID] = item.payloadId
        }

        let logitem = "ListManager: item interacted: \(itemName)" + " -For Event: " + (eventName ?? "")
        AASDK.logDebugMessage(logitem, type: AASDK.DEBUG_GENERAL)
        connector.addCollectableEvent(forDispatch: AACollectableEvent.appEvent(withName: eventName, andPayload: payload))
    }
    
    func reportItemInteractionFromPayload(_ itemName: String?, from contentPayload: AAContentPayload?, eventName: String?) {
        var payload = [AnyHashable : Any](minimumCapacity: 4)
        payload["item_name"] = itemName ?? ""
        if let payloadType = contentPayload?.payloadType {
            payload["source"] = payloadType
        }

        let item = AASDK.cachedItem(matching: itemName ?? "")
        if let item = item {
            payload[AA_KEY_TRACKING_ID] = item.trackingId
            payload[AA_KEY_PAYLOAD_ID] = item.payloadId
        }

        connector.addCollectableEvent(forDispatch: AACollectableEvent.internalEvent(withName: eventName, andPayload: payload))
    }
    
    func reportAcknowledgeItem(_ item: String?, addedToList list: String?, from ad: AAAd?, eventName: String?) {
        var payload: [AnyHashable : Any]?
        if list == nil {
            if let adID = ad?.adID {
                payload = [
                    "item_name": item ?? "",
                    "ad_id": adID
                ]
            }
        } else {
            if let adID = ad?.adID {
                payload = [
                    "item_name": item ?? "",
                    "ad_id": adID,
                    "list_name": list ?? ""
                ]
            }
        }
        connector.addCollectableEvent(forDispatch: AACollectableEvent.internalEvent(withName: eventName, andPayload: payload))
    }
    
    func reportPayloadReceived(_ payload: AAContentPayload) {
        let worked = { response, forRequest in
            AASDK.logDebugMessage("Payload Service Tracked delivery", type: AASDK.DEBUG_GENERAL)
        } as AAResponseWasReceivedBlock

        let failed = { response, forRequest, error in
        } as AAResponseWasErrorBlock

        let request = AAPayloadTrackingRequest(payloadDelivered: payload)
        connector.enqueueRequest(request, responseWasErrorBlock: failed, responseWasReceivedBlock: worked)
    }
    
    func reportPayloadRejected(_ payload: AAContentPayload) {
        let worked = { response, forRequest in
            AASDK.logDebugMessage("Payload Service Tracked delivery REJECTION", type: AASDK.DEBUG_GENERAL)
        } as AAResponseWasReceivedBlock

        let failed = { response, forRequest, error in
        } as AAResponseWasErrorBlock

        let request = AAPayloadTrackingRequest(payloadRejected: payload)
        connector.enqueueRequest(request, responseWasErrorBlock: failed, responseWasReceivedBlock: worked)
    }
    
    func reportAnomaly(withCode errorCode: String?, message: String?, params: [AnyHashable : Any]?) {
        connector.addCollectableError(forDispatch: AACollectableError(code: errorCode, message: message, params: params))
    }
    
    func reportInternalEvent(eventName: String?, payload: [AnyHashable : Any]?) {
        connector.addCollectableEvent(forDispatch: AACollectableEvent.internalEvent(withName: eventName, andPayload: payload))
    }
}
