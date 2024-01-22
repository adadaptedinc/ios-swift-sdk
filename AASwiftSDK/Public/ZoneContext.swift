//
//  ZoneContext.swift
//  AASwiftSDK
//
//  Created by Brett Clifton on 5/4/23.
//  Copyright © 2023 AdAdapted. All rights reserved.
//

import Foundation

@objc public class ZoneContext: NSObject {
    private var zoneId = ""
    private var contextId = ""
    
    init(zoneId: String = "", contextId: String = "") {
        self.zoneId = zoneId
        self.contextId = contextId
    }
    
    func setValues(_ zoneID: String, _ contextID: String) {
        self.zoneId = zoneID
        self.contextId = contextID
    }
    
    func clearContext() {
        self.zoneId = ""
        self.contextId = ""
    }
    
    func getZoneId() -> String {
        return self.zoneId
    }
    
    func getContextId() -> String {
        return self.contextId
    }
}

extension Array where Element: ZoneContext {
    func getZoneIdsAsString(separator: String = ",") -> String {
        return map { $0.getZoneId() }.joined(separator: separator)
    }
}
