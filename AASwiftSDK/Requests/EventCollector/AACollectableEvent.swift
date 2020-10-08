//  Converted to Swift 5.2 by Swiftify v5.2.23024 - https://swiftify.com/
//
//  AACollectableEvent.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation

@objcMembers
class AACollectableEvent: NSObject {
    func asDictionary() -> [AnyHashable : Any]? {
        return params == nil ? [:] : params
    }

    class func appEvent(withName name: String?, andPayload payload: [AnyHashable : Any]?) -> AACollectableEvent? {
        return AACollectableEvent(name: name, internal: false, trackingId: nil, payloadId: nil, andPayload: payload)
    }

    class func appEvent(withName name: String?, trackingId: String?, payloadId: String?, andPayload payload: [AnyHashable : Any]?) -> AACollectableEvent? {
        return AACollectableEvent(name: name, internal: false, trackingId: trackingId, payloadId: payloadId, andPayload: payload)
    }

    class func internalEvent(withName name: String?, andPayload payload: [AnyHashable : Any]?) -> AACollectableEvent? {
        return AACollectableEvent(name: name, internal: true, trackingId: nil, payloadId: nil, andPayload: payload)
    }

    class func internalEvent(withName name: String?, trackingId: String?, payloadId: String?, andPayload payload: [AnyHashable : Any]?) -> AACollectableEvent? {
        return AACollectableEvent(name: name, internal: true, trackingId: trackingId, payloadId: nil, andPayload: payload)
    }

    private var params: [AnyHashable : Any]?

    init(name: String?, `internal`: Bool, trackingId: String?, payloadId: String?, andPayload payload: [AnyHashable : Any]?) {
        super.init()
        var dic: [AnyHashable : Any]?
        if let payload = payload {
            dic = payload
        } else {
            dic = [AnyHashable : Any](minimumCapacity: trackingId == nil ? 0 : 1)
        }

        params = [AnyHashable : Any](minimumCapacity: 10)
        setParamValue(AAHelper.nowAsUTCNumber(), forKey: AA_KEY_EVENT_TIMESTAMP)
        setParamValue(name as NSObject?, forKey: AA_KEY_EVENT_NAME)

        if `internal` {
            setParamValue("sdk" as NSObject, forKey: AA_KEY_EVENT_SOURCE)
        } else {
            setParamValue("app" as NSObject, forKey: AA_KEY_EVENT_SOURCE)
        }

        if trackingId != nil && (trackingId?.count ?? 0) > 0 {
            dic?[AA_KEY_TRACKING_ID] = trackingId
        }

        if payloadId != nil && (payloadId?.count ?? 0) > 0 {
            dic?[AA_KEY_PAYLOAD_ID] = payloadId
        }

        if (dic?.count ?? 0) > 0 {
            setParamValue(dic as NSObject?, forKey: AA_KEY_EVENT_PARAMS)
        }
    }

    func setParamValue(_ value: NSObject?, forKey param: String?) {
        params?[param ?? ""] = value
    }
}
