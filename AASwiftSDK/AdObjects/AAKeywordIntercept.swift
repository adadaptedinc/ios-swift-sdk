//  Converted to Swift 5.2 by Swiftify v5.2.19227 - https://swiftify.com/
//
//  AAKeywordIntercept.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation

var hashValue: String?
var injectedZones: [AnyHashable]?
var injectedAds: [AnyHashable]?

class AAKeywordIntercept: NSObject {
    var searchId: String?
 /*#D - moved to root of response */    var refreshTime = 0
 /*#D - moved to root of response */    var termID: String?
    var term: String?
    var replacementText: String?
    var iconURL: String?
    var taglineText: String?
    var priority = 0
    var triggeredAdIds: [AnyHashable]?
    var injectedZones: [AnyHashable]?
    var injectedAds: [AnyHashable]?

    class func keywordIntercepts(fromJSONDic dic: [AnyHashable]?, withSearchId searchId: String?) -> [AnyHashable]? {
        print("#D - KI JSON DICT")
        var array = [AnyHashable](repeating: 0, count: 10)
        
        for term in dic ?? [] {
            guard let term = term as? [AnyHashable : Any] else {
                continue
            }
            //#D - NEED TO THROW ALL OF THESE INTO AAHELPER
            let intercept = AAKeywordIntercept()

            //#D need to include search id and refresh here, need to pull in from response somehow

            //            intercept.searchId = dic[@"search_id"]; //#D - from response root
            //            intercept.refreshTime = [dic[@"refresh_time"] longValue];
            //            intercept.searchId = @"search_id"; //#D - from response root
            //            intercept.refreshTime = 0; //#D - from response root

            //            for (NSString *term in dic[@"terms"]) {
            //            NSDictionary *autofillDic = dic[@"terms"][autofillName];

            intercept.searchId = searchId
            intercept.termID = term[AA_KEY_KI_TERM_ID] as? String
            intercept.term = term[AA_KEY_KI_TERM] as? String
            intercept.replacementText = term[AA_KEY_KI_REPLACEMENT] as? String
            intercept.iconURL = term[AA_KEY_KI_ICON] as? String
            intercept.taglineText = term[AA_KEY_KI_TAGLINE] as? String
            intercept.priority = (term[AA_KEY_KI_PRIORITY] as? NSNumber)!.intValue
            intercept.triggeredAdIds = []

            //          NSString *str = [NSString stringWithFormat:@"%@%@%@", intercept.replacementText, intercept.taglineText, intercept.iconURL];
            //          intercept.hashValue = [str md5];
            //let str = "\(intercept.term ?? "") - \(intercept.replacementText ?? "") - \(intercept.taglineText ?? "") - \(intercept.iconURL ?? "")"
            //            NSLog(@"intercept info\n%@",str);
            array.append(intercept)
        }
        return array
    }

    func hasTriggeredAds() -> Bool {
        if triggeredAdIds == nil {
            print("#D - no triggered ads!")
            return false
        } else {
            return triggeredAdIds?.count ?? 0 > 0
        }
    }
}
