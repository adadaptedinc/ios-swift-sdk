//  Converted to Swift 5.2 by Swiftify v5.2.23024 - https://swiftify.com/
//
//  AAInitRequest.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation

@objcMembers
class AAInitRequest: AAGenericRequest {
    init(appId appID: String?, withAppInitParams params: [AnyHashable : Any]?) {
        super.init()
        // required
        
        setParamValue(appID as NSObject?, forKey: AA_KEY_APP_ID)
        setParamValue(AAHelper.bundleID() as NSObject?, forKey: AA_KEY_BUNDLE_ID)
        setParamValue(AAHelper.bundleVersion() as NSObject?, forKey: AA_KEY_BUNDLE_VERSION)
        setParamValue(AAHelper.deviceModelName() as NSObject, forKey: AA_KEY_DEVICE_MODEL)
        setParamValue(AAHelper.deviceIdentifier() as NSObject?, forKey: AA_KEY_DEVICE_ID)
        setParamValue(AAHelper.deviceOS() as NSObject?, forKey: AA_KEY_OS_NAME)
        setParamValue(AAHelper.deviceOSVersion() as NSObject?, forKey: AA_KEY_OS_VERSION)
        setParamValue(AAHelper.deviceLocale() as NSObject?, forKey: AA_KEY_LOCALE)
        setParamValue(AAHelper.currentTimezone() as NSObject?, forKey: AA_KEY_TIMEZONE)
        setParamValue(AAHelper.deviceCarrier() as NSObject?, forKey: AA_KEY_DEVICE_CARRIER_NAME)
        setParamValue(AAHelper.deviceHeightNumber(), forKey: AA_KEY_DEVICE_HEIGHT)
        setParamValue(AAHelper.deviceWidthNumber(), forKey: AA_KEY_DEVICE_WIDTH)
        setParamValue(AAHelper.deviceScreenDensity() as NSObject?, forKey: AA_KEY_DEVICE_DENSITY)
        setParamValue(NSNumber(value: AAHelper.isAdTrackingEnabled()), forKey: AA_KEY_ALLOW_RETARGETING)


        // optional
        let loc = AASDK.deviceLocationOrNil()
        if let loc = loc {
            setParamValue(NSNumber(value: loc.coordinate.longitude), forKey: AA_KEY_LONGITUDE)
            setParamValue(NSNumber(value: loc.coordinate.latitude), forKey: AA_KEY_LATITUDE)
        }

        if let params = params {
            setParamValue(params as NSObject, forKey: AA_KEY_APP_INIT_PARAMS)
        }
    }

    func appID() -> String? {
        return value(forKey: AA_KEY_APP_ID) as? String
    }
    
    func udid() -> String? {
        return value(forKey: AA_KEY_UDID) as? String
    }

    func sdKversion() -> String? {
        return value(forKey: AA_KEY_SDK_BUNDLE_VERSION) as? String
    }

// MARK: - <NSCopying>
    override func copy(with zone: NSZone? = nil) -> Any {
        let request = super.copy(with: zone) as? AAInitRequest
        return request!
    }

// MARK: - AARequest Overrides
    override func targetURL() -> URL! {
        return super.url(forEndpoint: "sessions/initialize")
    }
    
    override func parseResponse(fromJSON json: Any!) -> AAGenericResponse! {
        let response = AAInitResponse()
        if let json = json {
            response.zones = AAAd.dicOfZonesWithAds(fromJSONDic: (json as AnyObject).value(forKey: AA_KEY_ZONES) as? [AnyHashable: Any])
            response.pollingIntervalMS = ((json as AnyObject).value(forKey: AA_KEY_POLLING_INTERVAL) as? NSString)?.integerValue ?? 0
            if response.pollingIntervalMS < 1000 {
                response.pollingIntervalMS = 60000
            }
            response.sessionExpiresAt = ((json as AnyObject).value(forKey: AA_KEY_SESSION_EXPIRES) as? NSString)?.integerValue ?? 0
        }
        return response
    }
}
