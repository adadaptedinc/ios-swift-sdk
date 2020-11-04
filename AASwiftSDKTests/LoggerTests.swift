//
//  LoggerTests.swift
//  AASwiftSDKTests
//
//  Created by Brett Clifton on 11/4/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import XCTest
@testable import AASwiftSDK

class LoggerTests: XCTestCase {
    let mockConnector = MockAAConnector()
    let mockNotificationCenter = MockNotificationCenter()
    
    override func setUp() {
        ReportManager.createInstance(connector: mockConnector)
        NotificationCenterWrapper.createInstance(notificationCenter: mockNotificationCenter)
    }
    
    func testConsoleLogsError() {
        Logger.consoleLogError(NSCocoaErrorDomain, withMessage: "testMessage", suppressTracking: false)
        let result = mockConnector.storedCollectableErrors.first??.asDictionary()
        let errorMessage = result!["error_message"] as! String
        XCTAssert(errorMessage.contains("testMessage"))
    }
    
    func testConsoleLogsNilError() {
        Logger.consoleLogError(nil, withMessage: "testMessage", suppressTracking: false)
        let result = mockConnector.storedCollectableErrors.first??.asDictionary()
        let errorMessage = result!["error_message"] as! String
        XCTAssert(errorMessage.contains("testMessage"))
    }
    
    func testConsoleDoesNotLogError() {
        Logger.consoleLogError(NSCocoaErrorDomain, withMessage: "testMessageSuppressed", suppressTracking: true)
        XCTAssert(mockConnector.storedCollectableErrors.isEmpty)
    }
    
    
    func testDispatchMessage() {
        Logger.dispatchMessage("testDispatchMessage", ofType: "testDispatchType")
        let result = mockNotificationCenter.storedNotificationPosts.first
        XCTAssertEqual("testDispatchMessage", result?.userInfo![AASDK_KEY_MESSAGE] as! String)
        XCTAssertEqual("testDispatchType", result?.userInfo![AASDK_KEY_TYPE] as! String)
    }
    
}
