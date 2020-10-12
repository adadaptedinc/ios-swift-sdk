//
//  AAGetAdRequest.h
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

@objcMembers
class AAGetAdsRequest: AAGenericRequest {
    init(zones: [AnyHashable]?) {
        super.init()
        setParamValue(zones?[0] as NSObject?, forKey: AA_KEY_ZONE_ID)
    }

// MARK: - AARequest Overrides
    override func targetURL() -> URL? {
        return super.url(forEndpoint: "ad/getAd") //not called?
    }

    override func parseResponse(fromJSON json: Any?) -> AAGetAdsResponse? {
        let response = AAGetAdsResponse()
        response.ads = AAAd.dicOfZonesWithAds(fromJSONDic: (json as? NSObject)?.value(forKey: AA_KEY_ZONES) as? [AnyHashable : Any] ?? [:])
        return response
    }

// MARK: - <NSCopying>
    override func copy(with zone: NSZone? = nil) -> Any {
        let request = super.copy(with: zone) as? AAGetAdsRequest
        return request!
    }
}
