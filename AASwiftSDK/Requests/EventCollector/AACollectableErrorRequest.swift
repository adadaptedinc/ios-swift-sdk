//
//  AACollectableErrorRequest.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//
import Foundation

@objcMembers
class AACollectableErrorRequest: AAGenericRequest {
    init(events: [AnyHashable]?) {
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
        setParamValue(AAHelper.buildVersion() as NSObject?, forKey: AA_KEY_SDK_BUNDLE_VERSION)
        setParamValue(AAHelper.deviceOS() as NSObject?, forKey: AA_KEY_OS_NAME)
        setParamValue(AAHelper.deviceOSVersion() as NSObject?, forKey: AA_KEY_OS_VERSION)
        setParamValue(AAHelper.deviceWidthNumber() as NSObject?, forKey: AA_KEY_DEVICE_WIDTH)
        setParamValue(AAHelper.deviceHeightNumber() as NSObject?, forKey: AA_KEY_DEVICE_HEIGHT)
        setParamValue(AAHelper.deviceScreenDensity() as NSObject?, forKey: AA_KEY_DEVICE_DENSITY)
        setParamValue(AAHelper.currentTimezone() as NSObject?, forKey: AA_KEY_TIMEZONE)
        setParamValue(AAHelper.deviceLocale() as NSObject?, forKey: AA_KEY_LOCALE)
        setParamValue(AAHelper.deviceModelName() as NSObject?, forKey: AA_KEY_DEVICE_MODEL)
        setParamValue(AAHelper.buildVersion() as NSObject?, forKey: AA_KEY_SDK_BUNDLE_VERSION)
        setParamValue(NSNumber(value: AAHelper.isAdTrackingEnabled() ? 1 : 0) as NSObject?, forKey: AA_KEY_ALLOW_RETARGETING)

        let loc = AASDK.deviceLocationOrNil()
        if let loc = loc {
            setParamValue(NSNumber(value: loc.coordinate.longitude) as NSObject?, forKey: AA_KEY_LONGITUDE)
            setParamValue(NSNumber(value: loc.coordinate.latitude) as NSObject?, forKey: AA_KEY_LATITUDE)
        }
    }

    private var events: [AnyHashable]?

    override func asJSON() -> String? {
        if let bytes = asData() {
            return String(decoding: bytes, as: UTF8.self)
        }
        return nil
    }

    override func asData() -> Data? {
        var payload = super.asDictionary() ?? [:]

        var dics : [Any] = []
        for event in events ?? [] {
            guard let event = event as? AACollectableError else {
                continue
            }
            if let dictionary = event.asDictionary() {
                dics.append(dictionary)
            }
        }

        payload["errors"] = dics

        if !JSONSerialization.isValidJSONObject(payload) {
            Logger.consoleLogError(nil, withMessage: "not valid json object: \(payload)", suppressTracking: true)
            return nil
        }

        var err: Error?

        var data: Data? = nil
        do {
            data = try JSONSerialization.data(
                withJSONObject: payload,
                options: .prettyPrinted)
        } catch let error {
            err = error
        }
        if let err = err {
            Logger.consoleLogError(err, withMessage: "asJSON data error for error events", suppressTracking: true)
        }
        return data
    }

// MARK: - AARequest Overrides
    override func url(forEndpoint endpoint: String = "") -> URL? {
        return URL(string: String(AASDK.eventCollectionServerRoot() + "/" + endpoint))
    }

    override func targetURL() -> URL? {
        return url(forEndpoint: "errors")
    }

    override func parseResponse(fromJSON json: Any!) -> AAGenericResponse! {
        let response = AACollectableErrorResponse()
        if let result = (json as? NSObject)?.value(forKey: "Result") as? String {
            response.result = result
        } else {
            response.result = "unknown"
        }
        return response as AAGenericResponse
    }

// MARK: - <NSCopying>
    override func copy(with zone: NSZone? = nil) -> Any {
        let request = super.copy(with: zone) as? AACollectableErrorRequest
        return request!
    }
}
