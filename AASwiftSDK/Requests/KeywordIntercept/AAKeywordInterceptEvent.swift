//  Converted to Swift 5.2 by Swiftify v5.2.23024 - https://swiftify.com/
//
//  AAKeywordInterceptEvent.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation

let AASDK_KI_EVENT_TYPE_NOT_MATCHED = "not_matched"
let AASDK_KI_EVENT_TYPE_MATCHED = "matched"
let AASDK_KI_EVENT_TYPE_PRESENTED = "presented"
let AASDK_KI_EVENT_TYPE_SELECTED = "selected"

@objcMembers
class AAKeywordInterceptEvent: NSObject {
    init(type: String?, userInput: String?, with keywordIntercept: AAKeywordIntercept?) {
        super.init()
        params = [AnyHashable : Any](minimumCapacity: 10)
        setParamValue(AAHelper.nowAsUTCNumber(), forKey: AA_KEY_DATETIME)

        self.type = type
        self.userInput = userInput
        setParamValue(self.type as NSObject?, forKey: AA_KEY_EVENT_TYPE)
        setParamValue(self.userInput as NSObject?, forKey: AA_KEY_KI_USER_INPUT)

        if let keywordIntercept = keywordIntercept {
            setParamValue(keywordIntercept.searchId as NSObject?, forKey: AA_KEY_KI_SEARCH_ID)
            setParamValue(keywordIntercept.termID as NSObject?, forKey: AA_KEY_KI_TERM_ID)
            setParamValue(keywordIntercept.term as NSObject?, forKey: AA_KEY_KI_TERM)
        }

        if type == AASDK_KI_EVENT_TYPE_NOT_MATCHED {
            setParamValue("NA" as NSObject, forKey: AA_KEY_KI_SEARCH_ID)
            setParamValue("" as NSObject, forKey: AA_KEY_KI_TERM_ID)
            setParamValue("NA" as NSObject, forKey: AA_KEY_KI_TERM)
        }
    }

    func asDictionary() -> [AnyHashable : Any]? {
        return params
    }

    func eventType() -> String? {
        return type
    }
    
    func getUserInput() -> String? {
        return userInput
    }

    private var params: [AnyHashable : Any]?
    private var type: String?
    private var userInput: String?
    private var keywordIntercept: AAKeywordIntercept?

// MARK: - PRIVATE
    func setParamValue(_ value: NSObject?, forKey param: String?) {
        params?[param ?? ""] = value
    }
}
