//
//  RegistrarTests.swift
//  AASwiftSDKTests
//
//  Created by Brett Clifton on 11/5/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

@testable import AASwiftSDK
import XCTest

final class RegistrarTests: XCTestCase {
    private let mockConnector = MockAAConnector()
    private let mockNotificationCenter = MockNotificationCenter.init()

    private let testObserver = MockAASDKObserver()
    private let testDelegate = MockAASDKContentDelegate()
    private let testDebugObserver = MockAASDKDebugObserver()

    override func setUp() {
        ReportManager.createInstance(connector: mockConnector)
        NotificationCenterWrapper.createInstance(notificationCenter: mockNotificationCenter)
    }
    
    func testAddAndClearAllListeners() {
        Registrar.addListeners(observer: testObserver)
        Registrar.addContentListeners(delegate: testDelegate)
        Registrar.addDebugListeners(observer: testDebugObserver)
        
        if let storedEvents = mockNotificationCenter.storedEvents {
            print(storedEvents)
            XCTAssert(storedEvents.contains("AASDK_INIT_COMPLETE"))
            XCTAssert(storedEvents.contains("AASDK_CONTENT_DELIVERY"))
            XCTAssert(storedEvents.contains("AASDK_UI_DEBUG_MESSAGE"))
            XCTAssertEqual(storedEvents.count, 6)
        }

        Registrar.clearListeners(observer: testObserver)

        if let storedEvents = mockNotificationCenter.storedEvents {
            print(storedEvents)
            XCTAssertFalse(storedEvents.contains("AASDK_INIT_COMPLETE"))
            XCTAssert(storedEvents.contains("AASDK_CONTENT_DELIVERY"))
            XCTAssertEqual(storedEvents.count, 3)
        }

        Registrar.clearContentListeners(delegate: testDelegate)

        if let storedEvents = mockNotificationCenter.storedEvents {
            print(storedEvents)
            XCTAssertEqual(storedEvents.count, 1)
        }
    }
}
