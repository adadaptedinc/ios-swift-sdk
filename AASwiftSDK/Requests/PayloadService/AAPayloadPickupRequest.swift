//  Converted to Swift 5.2 by Swiftify v5.2.23024 - https://swiftify.com/
//
//  AAPayloadPickupRequest.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

@objcMembers
class AAPayloadPickupRequest: AAGenericRequest {
    override init() {
        super.init()

        removeParamValue(forKey: AA_KEY_DATETIME)
        if AASDK.sessionId() != nil {
            setParamValue(AASDK.sessionId() as NSObject?, forKey: AA_KEY_SESSION_ID)
        }
        setParamValue(AASDK.appId() as NSObject?, forKey: AA_KEY_APP_ID)
        setParamValue(AAHelper.udid() as NSObject?, forKey: AA_KEY_UDID)
        setParamValue(AAHelper.bundleID() as NSObject?, forKey: AA_KEY_BUNDLE_ID)
        setParamValue(AAHelper.bundleVersion() as NSObject?, forKey: AA_KEY_BUNDLE_VERSION)
        setParamValue(AAHelper.deviceOS() as NSObject?, forKey: AA_KEY_OS_NAME)
        setParamValue(AAHelper.deviceOSVersion() as NSObject?, forKey: AA_KEY_OS_VERSION)

        setParamValue(AAHelper.currentTimezone() as NSObject?, forKey: AA_KEY_TIMEZONE)
        setParamValue(AAHelper.deviceLocale() as NSObject?, forKey: AA_KEY_LOCALE)
        setParamValue(AAHelper.deviceModelName() as NSObject?, forKey: AA_KEY_DEVICE_MODEL)
        setParamValue(AASDK.buildVersion() as NSObject?, forKey: AA_KEY_SDK_BUNDLE_VERSION)
        setParamValue(NSNumber(value: AAHelper.isAdTrackingEnabled() ? 1 : 0) as NSObject?, forKey: AA_KEY_ALLOW_RETARGETING)

        setParamValue(AAHelper.nowAsUTCNumber(), forKey: "timestamp")

        let loc = AASDK.deviceLocationOrNil()
        if let loc = loc {
            setParamValue(NSNumber(value: loc.coordinate.longitude), forKey: AA_KEY_LONGITUDE)
            setParamValue(NSNumber(value: loc.coordinate.latitude), forKey: AA_KEY_LATITUDE)
        }
    }

// MARK: - AARequest Overrides
    override func url(forEndpoint endpoint: String = "") -> URL? {
        return URL(string: String(AASDK.payloadServiceServerRoot() + "/" + endpoint))
    }

    override func targetURL() -> URL? {
        return url(forEndpoint: "pickup")
    }

    override func parseResponse(fromJSON json: Any?) -> AAPayloadPickupResponse? {
        var response: AAPayloadPickupResponse?
        response = AAPayloadPickupResponse()
            response?.result = "ok"
            response?.payloads = []

        if let jsonResponse = json as? [AnyHashable: Any] {
            if jsonResponse["payloads"] != nil {
                var retArray: [AnyHashable] = []
                if let payloads = jsonResponse["payloads"] as? [Any] {
                    for payload in payloads {
                        if let dic = payload as? [AnyHashable: Any] {
                            let item = AAContentPayload.parse(fromDictionary: dic)
                                                if let item = item {
                                                    retArray.append(item as AnyHashable)
                                                }
                        }
                    }
                }
                response?.payloads = retArray
            }
        } else {
            response?.result = "unknown"
        }

        return response
    }

// MARK: - <NSCopying>
    override func copy(with zone: NSZone? = nil) -> Any {
        let request = super.copy(with: zone) as? AAPayloadPickupRequest
        return request!
    }
}
