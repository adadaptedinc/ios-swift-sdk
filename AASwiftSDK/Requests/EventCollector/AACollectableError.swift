//  Converted to Swift 5.2 by Swiftify v5.2.23024 - https://swiftify.com/
//
//  AACollectableError.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation

@objcMembers
class AACollectableError: NSObject {
    func asDictionary() -> [AnyHashable : Any]? {
        return params == nil ? [:] : params
    }
    
    class func error(withCode errorCode: String?, message: String?, params: [AnyHashable : Any]?) -> AACollectableError? {
        return AACollectableError(code: errorCode, message: message, params: params)
    }
    
    private var params: [AnyHashable : Any]?
    
    init(code: String?, message: String?, params: [AnyHashable : Any]?) {
        super.init()
        self.params = [:]
        setParamValue(AAHelper.nowAsUTCNumber(), forKey: AA_KEY_ERROR_TIMESTAMP)
        setParamValue(code as NSObject?, forKey: AA_KEY_ERROR_CODE)
        
        if let message = message {
            setParamValue(message as NSObject, forKey: AA_KEY_ERROR_MESSAGE)
        }
        
        if params != nil && (params?.count ?? 0) > 0 {
            setParamValue(params as NSObject?, forKey: AA_KEY_ERROR_PARAMS)
        }
        
    }
    
    func setParamValue(_ value: NSObject?, forKey param: String?) {
        params?[param ?? ""] = value
    }
}
