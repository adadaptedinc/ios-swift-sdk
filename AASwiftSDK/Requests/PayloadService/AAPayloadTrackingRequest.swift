//
//  AAPayloadTrackingRequest.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

@objcMembers
class AAPayloadTrackingRequest: AAGenericRequest {
    init(payloadDelivered payload: AAContentPayload?) {
        super.init()
        self.payload = payload
        sharedInit()

        var a: [[String : Any?]]? = nil
        if let payloadId = payload?.payloadId {
            a = [
                [
                    AA_KEY_PAYLOAD_ID: payloadId,
                            "status": "delivered",
                            "event_timestamp": AAHelper.nowAsUTCNumber()
                        ]
            ]
        }
        setParamValue(a as NSObject?, forKey: "items")
    }

    init(payloadRejected payload: AAContentPayload?) {
        super.init()
        self.payload = payload
        sharedInit()

        var a: [[String : Any?]]? = nil
        if let payloadId = payload?.payloadId {
            a = [[
                AA_KEY_PAYLOAD_ID: payloadId,
                "status": "rejected"
            ]]
        }
        setParamValue(a as NSObject?, forKey: "items")
    }

    private var payload: AAContentPayload?

    func sharedInit() {

        removeParamValue(forKey: AA_KEY_DATETIME)
        if AASDK.sessionId() != nil {
            setParamValue(AASDK.sessionId() as NSObject?, forKey: AA_KEY_SESSION_ID)
        }
        setParamValue(AASDK.appId() as NSObject?, forKey: AA_KEY_APP_ID)
        setParamValue(AAHelper.udid() as NSObject?, forKey: AA_KEY_UDID)
        setParamValue(AAHelper.bundleID() as NSObject?, forKey: AA_KEY_BUNDLE_ID)
        setParamValue(AAHelper.deviceOS() as NSObject?, forKey: AA_KEY_OS_NAME)
        setParamValue(AAHelper.deviceOSVersion() as NSObject?, forKey: AA_KEY_OS_VERSION)
        setParamValue(AAHelper.currentTimezone() as NSObject?, forKey: AA_KEY_TIMEZONE)
        setParamValue(AAHelper.deviceLocale() as NSObject?, forKey: AA_KEY_LOCALE)
        setParamValue(AAHelper.deviceModelName() as NSObject?, forKey: AA_KEY_DEVICE_MODEL)
        setParamValue(AAHelper.buildVersion() as NSObject?, forKey: AA_KEY_SDK_BUNDLE_VERSION)
        setParamValue(NSNumber(value: AAHelper.isAdTrackingEnabled() ? 1 : 0) as NSObject?, forKey: AA_KEY_ALLOW_RETARGETING)

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
        return url(forEndpoint: "tracking")
    }

    override func parseResponse(fromJSON json: Any?) -> AAPayloadTrackingResponse? {
        var response: AAPayloadTrackingResponse?
        response = AAPayloadTrackingResponse()
        if let _result = (json as? NSObject)?.value(forKey: "Result") as? String {
            response?.result = _result
        } else {
            response?.result = "unknown"
        }
        return response
    }

// MARK: - <NSCopying>
    override func copy(with zone: NSZone? = nil) -> Any {
        let request = super.copy(with: zone) as? AAPayloadTrackingRequest
        return request!
    }
}
