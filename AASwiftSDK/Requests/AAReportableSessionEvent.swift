//
//  AAReportableEvent.h
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation

@objcMembers
class AAReportableSessionEvent: NSObject {
    private var type: AAEventType?
    private var ad: AAAd?
    private var params: [AnyHashable : Any]?

    init(eventType: AAEventType, for ad: AAAd?, session: String?, eventPath: String?, detailedName: String?) {
        super.init()
        params = [AnyHashable: Any](minimumCapacity: 10)
        setParamValue(AAHelper.nowAsUTCNumber(), forKey: AA_KEY_DATETIME)
        setParamValue(AAHelper.string(for: eventType) as NSObject?, forKey: AA_KEY_EVENT_TYPE)

        if let ad = ad {
            setParamValue(ad.adID as NSObject?, forKey: AA_KEY_AD_ID)
            setParamValue(AASDK.impressionString(forId: ad.impressionID, forImpressionType: eventType) as NSObject?, forKey: AA_KEY_IMPRESSION_ID)
        }

        if let eventPath = eventPath {
            setParamValue(eventPath as NSObject, forKey: AA_KEY_EVENT_PATH)
        }

        if let detailedName = detailedName {
            setParamValue(detailedName as NSObject, forKey: AA_KEY_EVENT_NAME)
        }
    }
    
    class func reportableEventOf(_ type: AAEventType, for ad: AAAd?, session: String?) -> AAReportableSessionEvent? {
        return AAReportableSessionEvent(eventType: type, for: ad, session: session, eventPath: nil, detailedName: nil)
    }

    class func reportableEventOf(_ type: AAEventType, for ad: AAAd?, session: String?, eventPath: String?, detailedName: String?) -> AAReportableSessionEvent? {
        return AAReportableSessionEvent(eventType: type, for: ad, session: session, eventPath: eventPath, detailedName: detailedName)
    }

    func asDictionary() -> [AnyHashable: Any]? {
        return params
    }

    func setParamValue(_ value: NSObject?, forKey param: String?) {
        params?[param ?? ""] = value
    }
}
