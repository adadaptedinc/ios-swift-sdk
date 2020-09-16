//  Converted to Swift 5.2 by Swiftify v5.2.19227 - https://swiftify.com/
//
//  AAAdTimeline.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation

class AAAdTimeline: NSObject {
    
    private var entries: [AnyHashable]?
    
    func currentlyActiveAdIds() -> [AnyHashable]? {
        var array = [AnyHashable](repeating: 0, count: entries?.count ?? 0)
        for entry in entries ?? [] {
            guard let entry = entry as? AAAdTimelineEntry else {
                continue
            }
            if entry.isCurrentlyActive() {
                array.append(entry.adId ?? "")
            }
        }
        return array
    }

    func nextTimelineEvent() -> Date? {
        var lowest = Date(timeIntervalSinceNow: TimeInterval(INT32_MAX))
        let now = Date()
        for entry in entries ?? [] {
            guard let entry = entry as? AAAdTimelineEntry else {
                continue
            }
            if let start1 = entry.start {
                if (entry.start?.compare(lowest) == .orderedAscending) && now.compare(start1) == .orderedAscending {
                    // only grab ones in the future
                    lowest = start1
                }
            }
        }
        return lowest
    }

    class func timelineFromJSONArray(array: [AnyHashable]) -> AAAdTimeline {
        let timeline = AAAdTimeline.init()
        var temp : [AAAdTimelineEntry] = []
        for dic in array {
            if let dict = dic as? [String: Any] {
                temp.append(AAAdTimelineEntry.entryWithDict(dic: dict))
            }
        }
        timeline.entries = temp
        return timeline
    }
}
