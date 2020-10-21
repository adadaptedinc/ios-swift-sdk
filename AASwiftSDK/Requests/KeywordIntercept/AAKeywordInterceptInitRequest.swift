//
//  AAKeywordInterceptRequest.h
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

class AAKeywordInterceptInitRequest: AAGenericRequest {
    override init() {
        super.init()
        print("#D - KI INIT")
        setParamValue(AAHelper.bundleID() as NSObject?, forKey: AA_KEY_BUNDLE_ID)
        setParamValue(AAHelper.bundleVersion() as NSObject?, forKey: AA_KEY_BUNDLE_VERSION)
        setParamValue(AAHelper.deviceOS() as NSObject?, forKey: AA_KEY_OS_NAME)
        
        setParamValue(AAHelper.deviceOSVersion() as NSObject?, forKey: AA_KEY_OS_VERSION)
    }

// MARK: - <NSCopying>
    override func copy(with zone: NSZone? = nil) -> Any {
        let request = super.copy(with: zone) as? AAKeywordInterceptInitRequest
        return request!
    }

// MARK: - AARequest Overrides
    override func targetURL() -> URL? {
        return super.url(forEndpoint: "intercepts/retrieve") //#D - !request
    }

    override func parseResponse(fromJSON json: Any?) -> AAKeywordInterceptInitResponse? {
        print("#D - KI - parsing JSON")
        let response = AAKeywordInterceptInitResponse()
        do {
            if (json as? [AnyHashable : Any])?[AA_KEY_KI_TERMS] != nil {
                if (json as? [AnyHashable : Any])?[AA_KEY_KI_SEARCH_ID] != nil {
                    let terms = (json as? [AnyHashable : Any])?[AA_KEY_KI_TERMS]
                    let searchId = (json as? [AnyHashable : Any])?[AA_KEY_KI_SEARCH_ID]
                    response.keywordIntercepts = AAKeywordIntercept.keywordIntercepts(fromJSONDic: terms as? [AnyHashable], withSearchId: searchId as? String)
                } else {
                    print("#D - this is a big error that should never really happen")
                }
            }
            if (json as? [AnyHashable : Any])?[AA_KEY_KI_SEARCH_ID] != nil {
                response.searchId = (json as? [AnyHashable : Any])?[AA_KEY_KI_SEARCH_ID] as? String
            }
            if (json as? [AnyHashable : Any])?[AA_KEY_KI_MIN_MATCH_LENGTH] != nil {
                response.minMatchLength = ((json as? [AnyHashable : Any])?[AA_KEY_KI_MIN_MATCH_LENGTH] as? NSNumber)?.intValue ?? 0
            }
            if (json as? [AnyHashable : Any])?[AA_KEY_KI_REFRESH_TIME] != nil {
                response.refreshSeconds = ((json as? [AnyHashable : Any])?[AA_KEY_KI_REFRESH_TIME] as? NSNumber)?.intValue ?? 0
            }
        }
        return response
    }
}
