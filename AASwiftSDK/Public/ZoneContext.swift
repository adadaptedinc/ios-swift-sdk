//
//  ZoneContext.swift
//  AASwiftSDK
//
//  Created by Brett Clifton on 5/4/23.
//  Copyright © 2023 AdAdapted. All rights reserved.
//

import Foundation

@objc public class ZoneContext: NSObject {
    private var zoneIds = [String]()
    private var contextId = ""
    
    func addZone(_ zoneID: String, _ contextID: String) {
        if !zoneIds.contains(zoneID) {
            zoneIds.append(zoneID)
        }
        contextId = contextID
    }
    
    func removeZone(_ zoneID: String) {
        zoneIds.removeAll { $0 == zoneID }
        if zoneIds.isEmpty {
            contextId = ""
        }
    }
    
    func clearContext() {
        self.zoneIds = [String]()
        self.contextId = ""
    }
    
    func getZoneIdsAsString() -> String {
        return zoneIds.joined(separator: ",")
    }
    
    func getContextId() -> String {
        return contextId
    }
}
