//
//  AAReportableEventV2.h
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//


import Foundation

@objcMembers
class AAReportableAnomalyEvent: NSObject {
    class func reportableEventOf(_ type: AAEventType, for ad: AAAd?, payload: [AnyHashable : Any]?, optionalDetails details: String?) -> AAReportableAnomalyEvent? {
        return AAReportableAnomalyEvent(eventType: type, for: ad, payload: payload, optionalDetails: details)
    }

    func asDictionary() -> [AnyHashable : Any]? {
        return params
    }

    /// connector needs to set session and app
    func setParamValue(_ value: NSObject?, forKey param: String?) {
        params?[param ?? ""] = value
    }

    private var type: AAEventType?
    private var ad: AAAd?
    private var params: [AnyHashable : Any]?

    init(eventType: AAEventType, for ad: AAAd?, payload: [AnyHashable : Any]?, optionalDetails details: String?) {
        super.init()
        params = [:]
        
        setParamValue(AAHelper.string(for: eventType) as NSObject?, forKey: AA_KEY_EVENT_TYPE)
        setParamValue(AAHelper.nowAsUTC() as NSObject?, forKey: AA_KEY_DATETIME)
        setParamValue(AASDK.sessionId() as NSObject?, forKey: AA_KEY_SESSION_ID)
        setParamValue(AASDK.appId() as NSObject?, forKey: AA_KEY_APP_ID)
        setParamValue(AAHelper.udid() as NSObject?, forKey: AA_KEY_UDID)
        setParamValue(AAHelper.buildVersion() as NSObject?, forKey: AA_KEY_SDK_BUNDLE_VERSION)

        setParamValue(AAHelper.bundleID() as NSObject?, forKey: AA_KEY_BUNDLE_ID)
        setParamValue(AAHelper.bundleVersion() as NSObject?, forKey: AA_KEY_BUNDLE_VERSION)
        setParamValue(AAHelper.deviceOS() as NSObject?, forKey: AA_KEY_OS_NAME)
        setParamValue(AAHelper.deviceOSVersion() as NSObject?, forKey: AA_KEY_OS_VERSION)
        setParamValue(AAHelper.deviceLocale() as NSObject?, forKey: AA_KEY_LOCALE)
        setParamValue(AAHelper.deviceWidth() as NSObject?, forKey: AA_KEY_DEVICE_WIDTH)
        setParamValue(AAHelper.deviceHeight() as NSObject?, forKey: AA_KEY_DEVICE_HEIGHT)
        setParamValue(AAHelper.deviceModelName() as NSObject?, forKey: AA_KEY_DEVICE_MODEL)

        setParamValue(NSNumber(value: AAHelper.isAdTrackingEnabled()), forKey: AA_KEY_ALLOW_RETARGETING)
        setParamValue(AAHelper.currentTimezone() as NSObject?, forKey: AA_KEY_TIMEZONE)

        // optional
        let loc = AASDK.deviceLocationOrNil()
        if let loc = loc {
            setParamValue(NSNumber(value: loc.coordinate.longitude), forKey: AA_KEY_LONGITUDE)
            setParamValue(NSNumber(value: loc.coordinate.latitude), forKey: AA_KEY_LATITUDE)
        }

        if ad != nil {
            var dic : [String: Any] = [:]
            dic[AA_KEY_AD_ID] = ad?.adID
            dic[AA_KEY_EVENT_PATH] = ad?.actionPath?.absoluteString != "" ? ad?.actionPath?.absoluteString : ""
            dic[AA_KEY_IMPRESSION_ID] = AASDK.impressionString(forId: ad?.impressionID ?? "", forImpressionType: eventType)
            dic[AA_KEY_ACTION_TYPE] = ad?.actionType
            
            setParamValue(dic as NSObject, forKey: AA_KEY_AD)
        }
        if let payload = payload {
            let err: Error? = nil
            do {
                try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
            } catch let err {
                AASDK.trackAnomalyGenericErrorMessage(err.localizedDescription, optionalAd: nil)
            }
            if err == nil {
                setParamValue(payload as NSObject, forKey: AA_KEY_PAYLOAD)
            } else {
                print("reporting \(String(describing: AAHelper.string(for: eventType))) failed to attach payload - error from NSJSONSerialization")
            }
        }
        if let details = details {
            setParamValue(details as NSObject, forKey: AA_KEY_EVENT_NAME)
        }
    }
}
