//
//  AASDKTests.swift
//  AASwiftSDKTests
//
//  Created by Brett Clifton on 11/2/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

@testable import AASwiftSDK
import XCTest

class AASDKTests: XCTestCase {
    private var mockConnector: MockAAConnector?
    private var mockNotificationCenter: MockNotificationCenter?
    private var mockObserver: MockAASDKObserver?

    override func setUp() {
        super.setUp()
        mockConnector = MockAAConnector()
        mockNotificationCenter = MockNotificationCenter()
        mockObserver = MockAASDKObserver()

        ReportManager.createInstance(connector: mockConnector!)
        NotificationCenterWrapper.createInstance(notificationCenter: mockNotificationCenter!)
    }
    
    func testConstatns() {
        XCTAssertEqual(AASDK.OPTION_TEST_MODE, "TEST_MODE")
        XCTAssertEqual(AASDK.OPTION_KEYWORD_INTERCEPT, "KEYWORD_INTERCEPT")
        XCTAssertEqual(AASDK.OPTION_CUSTOM_ID, "CUSTOM_ID")
        XCTAssertEqual(AASDK.KEY_CONTENT_PAYLOADS, "CONTENT_PAYLOADS")
        XCTAssertEqual(AASDK.KEY_AD_CONTENT, "AD_CONTENT")
        XCTAssertEqual(AASDK.KEY_KI_REPLACEMENT_TEXT, "KI_REPLACEMENT_TEXT")
        XCTAssertEqual(AASDK.KEY_ZONE_VIEW, "ZONE_VIEW")
        XCTAssertEqual(AASDK.DEBUG_GENERAL, "GENERAL")
        XCTAssertEqual(AASDK.DEBUG_NETWORK, "NETWORK")
        XCTAssertEqual(AASDK.DEBUG_NETWORK_DETAILED, "NETWORK_DETAILED")
        XCTAssertEqual(AASDK.DEBUG_USER_INTERACTION, "USER_INTERACTION")
        XCTAssertEqual(AASDK.DEBUG_AD_LAYOUT, "AD_LAYOUT")
        XCTAssertEqual(AASDK.DEBUG_ALL, "ALL")
        XCTAssertEqual(AASDK.KEY_ZONE_ID, "ZONE_ID")
        XCTAssertEqual(AASDK.KEY_ZONE_IDS, "ZONE_IDS")
        XCTAssertEqual(AASDK.KEY_ZONE_COUNT, "ZONE_COUNT")
        XCTAssertEqual(AASDK.KEY_MESSAGE, "MESSAGE")
        XCTAssertEqual(AASDK.KEY_TYPE, "TYPE")
        XCTAssertEqual(AASDK.KEY_RECOVERY_SUGGESTION, "RECOVERY_SUGGESTION")
    }

    func testErrorState() {
        let options = [
            AASDK.OPTION_TEST_MODE:true,
            AASDK.OPTION_KEYWORD_INTERCEPT:true]
            as [String : Any]

        AASDK.startSession(withAppID: "007420", registerListenersFor: mockObserver, options: options)

        _currentState = .kIdle
        XCTAssert(AASDK.isReadyForUse())

        _currentState = .kOffline
        XCTAssertFalse(AASDK.isReadyForUse())

        _currentState = .kUninitialized
        XCTAssertFalse(AASDK.isReadyForUse())

        _currentState = .kErrorState
        XCTAssertFalse(AASDK.isReadyForUse())

        // nil app id
        AASDK.startSession(withAppID: "", registerListenersFor: mockObserver, options: options)
        _currentState = .kIdle
        XCTAssertFalse(AASDK.isReadyForUse())
    }

    func testCustomId() {
        let options = [
            AASDK.OPTION_TEST_MODE:true,
            AASDK.OPTION_KEYWORD_INTERCEPT:true,
            AASDK.OPTION_CUSTOM_ID: "48648-6443-54315"]
            as [String : Any]

        AASDK.startSession(withAppID: "007420", registerListenersFor: mockObserver, options: options)

        if let udid = AASDK.getUdid() {
            XCTAssertEqual(udid, "48648-6443-54315")
        }
    }

    override func tearDown() {
        super.tearDown()
        mockConnector = nil
        mockNotificationCenter = nil
        mockObserver = nil
    }
}
