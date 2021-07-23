//
//  AAPayloadTrackingRequest.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//
import Foundation

public enum PayloadStatus {
    case delivered
    case rejected
}

@objcMembers
class AAPayloadTrackingRequest: AAGenericRequest {
    private var payload: AAContentPayload?

    init(payload: AAContentPayload?, status: PayloadStatus) {
        super.init()
        self.payload = payload
        
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
        setParamValue(AAHelper.sdkVersion() as NSObject?, forKey: AA_KEY_SDK_VERSION)
        setParamValue(AAHelper.bundleVersion() as NSObject?, forKey: AA_KEY_BUNDLE_VERSION)
        setParamValue(NSNumber(value: AAHelper.isAdTrackingEnabled() ? 1 : 0) as NSObject?, forKey: AA_KEY_ALLOW_RETARGETING)
        setParamValue(AAHelper.nowAsUTCNumber(), forKey: "timestamp")

        var array = [[String: Any]]()
        
        switch status {
        case .delivered:
            if let payloadId = payload?.payloadId {
                var items = [String: Any]()
                items[AA_KEY_PAYLOAD_ID] = payloadId
                items["status"] = "delivered"
                items["event_timestamp"] = AAHelper.nowAsUTCNumber()
                array.append(items)
            }
        case .rejected:
            if let payloadId = payload?.payloadId {
                var items = [String: Any]()
                items[AA_KEY_PAYLOAD_ID] = payloadId
                items ["status"] = "rejected"
                array.append(items)
            }
        }
        setParamValue(array as NSObject?, forKey: "tracking")
        print(self.params as Any)
    }

// MARK: - AARequest Overrides
    override func url(forEndpoint endpoint: String = "") -> URL? {
        return URL(string: "\(AASDK.payloadServiceServerRoot())/\(endpoint)")
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
