//
//  AAAdTimelineEntry.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation

class AAAdTimelineEntry: NSObject {
    var start: Date!
    var finish: Date!
    var adId: String?

    func isCurrentlyActive() -> Bool {
        let now = Date()
        if start?.compare(now) == .orderedAscending {
            // we're after the start time
            if now.compare(finish) == .orderedAscending {
                // we're before the finish time
                return true
            } else {
                // it's past the finish time
                return false
            }
        } else {
            // we're before the start time
            return false
        }
    }

    class func entryWithDict(dic: [String: Any]?) -> AAAdTimelineEntry {
        let entry = AAAdTimelineEntry.init()
        entry.start = AAAdTimelineEntry.date(fromUTCStringOrStar: dic?[AA_KEY_START_TIME] as? String, isStart: true)
        entry.finish = AAAdTimelineEntry.date(fromUTCStringOrStar: dic?[AA_KEY_END_TIME] as? String, isStart: false)
        entry.adId = dic?[AA_KEY_AD_ID] as? String
        return entry
    }
    
// MARK: - Private
    class func date(fromUTCStringOrStar str: String?, isStart start: Bool) -> Date? {
        if str == "*" {
            if start {
                return Date(timeIntervalSince1970: 0)
            } else {
                return Date(timeIntervalSinceNow: TimeInterval(INT32_MAX)) // WARNING - this breaks Mon Jan 18 2038 20:14:07 GMT-0700 (MST) ;-)
            }
        }

        return Date(timeIntervalSince1970: TimeInterval(Int(str ?? "") ?? 0))
    }
}
