//
//  ZoneContext.swift
//  AASwiftSDK
//
//  Created by Brett Clifton on 5/4/23.
//  Copyright © 2023 AdAdapted. All rights reserved.
//

import Foundation

@objc public class ZoneContext: NSObject {
    var zoneId = ""
    var contextId = ""
    
    func setProps(_ zoneID: String, _ contextID: String) {
        zoneId = zoneID
        contextId = contextID
    }
}
