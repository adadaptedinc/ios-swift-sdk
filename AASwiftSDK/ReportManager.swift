//
//  ReportManager.swift
//  AASwiftSDK
//
//  Created by Brett Clifton on 10/28/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation

class ReportManager {

    class func reportItemInteraction(_ itemName: String, itemList: String?, connector: AAConnector?, eventName: String?) {
        var payload = [AnyHashable : Any](minimumCapacity: 2)
        payload["item_name"] = itemName

        if let list = itemList {
            payload["list_name"] = list
        }

        let item = AASDK.cachedItem(matching: itemName)
        if let item = item {
            payload["tracking_id"] = item.trackingId
            payload["payload_id"] = item.payloadId
        }

        let logitem = "ListManager: item interacted: \(itemName)" + " -For Event: " + (eventName ?? "")
        AASDK.logDebugMessage(logitem, type: AASDK_DEBUG_GENERAL)
        connector?.addCollectableEvent(forDispatch: AACollectableEvent.appEvent(withName: eventName, andPayload: payload))
    }
    
    class func reportItemInteractionFromPayload(_ itemName: String?, from contentPayload: AAContentPayload?, connector: AAConnector?, eventName: String?) {
        var payload = [AnyHashable : Any](minimumCapacity: 4)
        payload["item_name"] = itemName ?? ""
        if let payloadType = contentPayload?.payloadType {
            payload["source"] = payloadType
        }

        let item = AASDK.cachedItem(matching: itemName ?? "")
        if let item = item {
            payload["tracking_id"] = item.trackingId
            payload["payload_id"] = item.payloadId
        }

        connector?.addCollectableEvent(forDispatch: AACollectableEvent.internalEvent(withName: eventName, andPayload: payload))
    }
    
    class func reportAcknowledgeItem(_ item: String?, addedToList list: String?, from ad: AAAd?, connector: AAConnector?, eventName: String?) {
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
        connector?.addCollectableEvent(forDispatch: AACollectableEvent.internalEvent(withName: eventName, andPayload: payload))
    }
    
    class func reportPayloadReceived(_ payload: AAContentPayload, connector: AAConnector?) {
        let worked = { response, forRequest in
            AASDK.logDebugMessage("Payload Service Tracked delivery", type: AASDK_DEBUG_GENERAL)
        } as AAResponseWasReceivedBlock

        let failed = { response, forRequest, error in
        } as AAResponseWasErrorBlock

        let request = AAPayloadTrackingRequest(payloadDelivered: payload)
        connector?.enqueueRequest(request, responseWasErrorBlock: failed, responseWasReceivedBlock: worked)
    }
    
    class func reportPayloadRejected(_ payload: AAContentPayload, connector: AAConnector?) {
        let worked = { response, forRequest in
            AASDK.logDebugMessage("Payload Service Tracked delivery REJECTION", type: AASDK_DEBUG_GENERAL)
        } as AAResponseWasReceivedBlock

        let failed = { response, forRequest, error in
        } as AAResponseWasErrorBlock

        let request = AAPayloadTrackingRequest(payloadRejected: payload)
        connector?.enqueueRequest(request, responseWasErrorBlock: failed, responseWasReceivedBlock: worked)
    }
    
    class func reportAnomaly(withCode errorCode: String?, message: String?, params: [AnyHashable : Any]?, connector: AAConnector?) {
        connector?.addCollectableError(forDispatch: AACollectableError(code: errorCode, message: message, params: params))
    }
}
