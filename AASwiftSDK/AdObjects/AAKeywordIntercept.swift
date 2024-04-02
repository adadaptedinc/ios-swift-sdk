//
//  AAKeywordIntercept.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation

class AAKeywordIntercept: NSObject {
    var searchId: String?
    var refreshTime = 0
    var termID: String?
    var term: String?
    var replacementText: String?
    var iconURL: String?
    var taglineText: String?
    var priority = 0

    class func keywordIntercepts(fromJSONDic dic: [AnyHashable]?, withSearchId searchId: String?) -> [AnyHashable]? {
        var array = [AnyHashable]()
        
        for term in dic ?? [] {
            guard let term = term as? [AnyHashable : Any] else {
                continue
            }
           
            let intercept = AAKeywordIntercept()

            intercept.searchId = searchId
            intercept.termID = term[AA_KEY_KI_TERM_ID] as? String
            intercept.term = term[AA_KEY_KI_TERM] as? String
            intercept.replacementText = term[AA_KEY_KI_REPLACEMENT] as? String
            intercept.iconURL = term[AA_KEY_KI_ICON] as? String
            intercept.taglineText = term[AA_KEY_KI_TAGLINE] as? String
            intercept.priority = (term[AA_KEY_KI_PRIORITY] as? NSNumber)?.intValue ?? 0
            
            array.append(intercept)
        }
        return array
    }
}
