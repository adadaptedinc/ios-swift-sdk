//
//  AACollectableEventRequest.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation

@objcMembers
class AACollectableEventRequest: AAGenericRequest {
    init(events: Set<AnyHashable>?) {
        super.init()
        if let events = events {
            self.events = events
        }
        
        removeParamValue(forKey: AA_KEY_DATETIME)
        if AASDK.sessionId() != nil {
            setParamValue(AASDK.sessionId() as NSObject?, forKey: AA_KEY_SESSION_ID)
        }
        setParamValue(AASDK.appId() as NSObject?, forKey: AA_KEY_APP_ID)
        setParamValue(AAHelper.udid() as NSObject?, forKey: AA_KEY_UDID)
        setParamValue(AAHelper.bundleID() as NSObject?, forKey: AA_KEY_BUNDLE_ID)
        setParamValue(AAHelper.sdkVersion() as NSObject?, forKey: AA_KEY_SDK_VERSION)
        setParamValue(AAHelper.bundleVersion() as NSObject?, forKey: AA_KEY_BUNDLE_VERSION)
        setParamValue(AAHelper.deviceOS() as NSObject?, forKey: AA_KEY_EVENT_OS_NAME)
        setParamValue(AAHelper.deviceOSVersion() as NSObject?, forKey: AA_KEY_EVENT_OS_VERSION)
        setParamValue(AAHelper.deviceWidthNumber() as NSObject?, forKey: AA_KEY_EVENT_DEVICE_WIDTH)
        setParamValue(AAHelper.deviceHeightNumber() as NSObject?, forKey: AA_KEY_EVENT_DEVICE_HEIGHT)
        setParamValue(AAHelper.deviceScreenDensity() as NSObject?, forKey: AA_KEY_EVENT_DEVICE_DENSITY)
        setParamValue(AAHelper.currentTimezone() as NSObject?, forKey: AA_KEY_EVENT_TIMEZONE)
        setParamValue(AAHelper.deviceLocale() as NSObject?, forKey: AA_KEY_EVENT_LOCALE)
        setParamValue(AAHelper.deviceModelName() as NSObject?, forKey: AA_KEY_EVENT_DEVICE_MODEL)
        setParamValue(NSNumber(value: 0) as NSObject?, forKey: AA_KEY_ALLOW_RETARGETING)
        
        let loc = AASDK.deviceLocationOrNil()
        if let loc = loc {
            setParamValue(NSNumber(value: loc.coordinate.longitude), forKey: AA_KEY_LONGITUDE)
            setParamValue(NSNumber(value: loc.coordinate.latitude), forKey: AA_KEY_LATITUDE)
        }
    }
    
    private var events: Set<AnyHashable>?
    
    override func asJSON() -> String? {
        if let data = asData() {
            return String(decoding: data, as: UTF8.self)
        }
        return nil
    }
    
    override func asData() -> Data? {
        var payload = super.asDictionary() ?? [:]
        
        var dics : [Any] = []
        for event in events ?? [] {
            guard let event = event as? AACollectableEvent else {
                continue
            }
            if let dictionary = event.asDictionary() {
                dics.append(dictionary)
            }
        }
        
        payload["events"] = dics
        
        if !JSONSerialization.isValidJSONObject(payload ) {
            Logger.consoleLogError(nil, withMessage: "not valid json object: \(String(describing: payload))", suppressTracking: true)
            return nil
        }
        
        var err: Error?
        
        var data: Data = Data.init()
        do {
            data = try JSONSerialization.data(
                withJSONObject: payload ,
                options: .prettyPrinted)
        } catch let error {
            err = error
        }
        if let err = err {
            Logger.consoleLogError(err, withMessage: "asJSON data error for batch events", suppressTracking: true)
        }
        return data
    }
    
    // MARK: - AARequest Overrides
    override func url(forEndpoint endpoint: String = "") -> URL? {
        return URL(string: String(AASDK.eventCollectionServerRoot() + "/" + endpoint))
    }
    
    override func targetURL() -> URL? {
        return url(forEndpoint: "events")
    }
    
    override func parseResponse(fromJSON json: Any!) -> AAGenericResponse! {
        let response = AACollectableEventResponse()
        if let result = (json as? NSObject)?.value(forKey: "Result") as? String {
            response.result = result
        } else {
            response.result = "unknown"
        }
        return (response as AAGenericResponse)
    }
    
    // MARK: - <NSCopying>
    override func copy(with zone: NSZone? = nil) -> Any {
        let request = super.copy(with: zone) as? AACollectableEventRequest
        return request!
    }
}
