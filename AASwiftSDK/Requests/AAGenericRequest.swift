//
//  AARequest.h
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation

@objcMembers
class AAGenericRequest: NSObject, NSCopying {
    func setParamValue(_ value: NSObject?, forKey param: String?) {
        if value == nil || param == nil {
            return
        }
        params?[param ?? ""] = value
    }

    func removeParamValue(forKey param: String?) {
        params?.removeValue(forKey: param)
    }

    override func value(forKey key: String) -> Any? {
        return params?[key]
    }

    func asJSON() -> String? {
        if let data = asData() {
            return String(decoding: data, as: UTF8.self)
        } else {
            return nil
        }
    }

    func asData() -> Data? {
        if let params = params {
            if !JSONSerialization.isValidJSONObject(params) {
                Logger.consoleLogError(nil, withMessage: "AARequest not valid json object \(params )", suppressTracking: true)
                return nil
            }
        }

        var data: Data? = nil
        do {
            if let params = params {
                data = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            }
        } catch let error {
            Logger.consoleLogError(error, withMessage: "asJSON data error for AARequest", suppressTracking: true)
        }
        return data
    }

    func asDictionary() -> [AnyHashable : Any]? {
        return params
    }

    func url(forEndpoint endpoint: String = "") -> URL? {
        return URL(string: String(AASDK.serverRoot() + "/" + endpoint))
    }

    /// call urlForEndpoint: when implementing this method
    func targetURL() throws -> URL? {
        throw NSError(domain: "AAResponse - You must override targetURL: and call urlForEndpoint: in subclass", code: 42, userInfo: nil)
    }

    /// I really like this pattern - it puts all the logic in the request object, which is convenient.
    func parseResponse(fromJSON json: Any?) throws -> AAGenericResponse? {
        throw NSError(domain: "AAResponse - You must override parseResponseFromJSON: in subclass", code: 42, userInfo: nil)
    }

// MARK: - <NSCopying>
    func copy(with zone: NSZone? = nil) -> Any {
        let request = self
        request.params = params
        return request
    }

    private var params: [AnyHashable : Any]? = nil

// MARK: - Private
    override init() {
        super.init()
        params = [:]
        setParamValue(AAHelper.nowAsUTCNumber() as NSNumber?, forKey: AA_KEY_DATETIME)
        setParamValue(AAHelper.udid() as NSObject?, forKey: AA_KEY_UDID)
        setParamValue(AAHelper.buildVersion() as NSObject?, forKey: AA_KEY_SDK_BUNDLE_VERSION)
    }
}
