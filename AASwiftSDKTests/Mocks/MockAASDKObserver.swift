//
//  MockAASDKObserver.swift
//  AASwiftSDKTests
//
//  Created by Brett Clifton on 11/9/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation
@testable import AASwiftSDK

class MockAASDKObserver : NSObject, AASDKObserver {
    func aaSDKInitComplete(_ notification: Notification) {
        
    }
    
    func aaSDKError(_ error: Notification) {
        
    }

    func aaSDKKeywordInterceptInitComplete(_ notification: Notification) {
        
    }
}

class MockAASDKContentDelegate: NSObject, AASDKContentDelegate {
    func aaContentNotification(_ notification: Notification) {
        
    }
    
    func aaPayloadNotification(_ notification: Notification) {
        
    }
}

class MockAASDKDebugObserver: NSObject, AASDKDebugObserver {
    func aaDebugNotification(_ notification: Notification) {
        
    }
}
