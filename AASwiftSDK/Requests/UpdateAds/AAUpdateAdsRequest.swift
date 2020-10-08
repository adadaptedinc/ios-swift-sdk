//  Converted to Swift 5.2 by Swiftify v5.2.23024 - https://swiftify.com/
//
//  AAGetAdRequest.h
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

@objcMembers
class AAUpdateAdsRequest: AAGenericRequest {
// MARK: - AARequest Overrides
    override func targetURL() -> URL? {
        return super.url(forEndpoint: "ads/retrieve")
    }
    
    override func parseResponse(fromJSON json: Any?) -> AAUpdateAdsResponse? {
        let response = AAUpdateAdsResponse()
        response.zones = AAAd.dicOfZonesWithAds(fromJSONDic: ((json as? [AnyHashable : Any])?[AA_KEY_ZONES]) as? [AnyHashable : Any] ?? [:])
        response.pollingIntervalInMS = ((json as? [AnyHashable : Any])?[AA_KEY_POLLING_INTERVAL] as? NSNumber)?.intValue ?? 0
        return response
    }

// MARK: - <NSCopying>
    override func copy(with zone: NSZone? = nil) -> Any {
        let request = super.copy(with: zone) as? AAUpdateAdsRequest
        return request!
    }
}
