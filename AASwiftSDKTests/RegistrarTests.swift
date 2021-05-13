//
//  RegistrarTests.swift
//  AASwiftSDKTests
//
//  Created by Brett Clifton on 11/5/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation
import XCTest
@testable import AASwiftSDK

class RegistrarTests: XCTestCase {
    var mockNotificationCenter = MockNotificationCenter()
    
    override func setUp() {
        NotificationCenterWrapper.createInstance(notificationCenter: mockNotificationCenter)
    }
    
    func testAddAndClearAllListeners() {
        let testObserver = MockAASDKObserver()
        let testDelegate = MockAASDKContentDelegate()
        let testDebugObserver = MockAASDKDebugObserver()
        Registrar.addListeners(observer: testObserver)
        Registrar.addContentListeners(delegate: testDelegate)
        Registrar.addDebugListeners(observer: testDebugObserver)
        
        print(mockNotificationCenter.storedEvents)
        XCTAssert(mockNotificationCenter.storedEvents.contains("AASDK_INIT_COMPLETE"))
        XCTAssert(mockNotificationCenter.storedEvents.contains("AASDK_CONTENT_DELIVERY"))
        XCTAssert(mockNotificationCenter.storedEvents.contains("AASDK_UI_DEBUG_MESSAGE"))
        XCTAssert(mockNotificationCenter.storedEvents.count == 6)
        
        Registrar.clearListeners(observer: testObserver)
        
        XCTAssert(!mockNotificationCenter.storedEvents.contains("AASDK_INIT_COMPLETE"))
        XCTAssert(mockNotificationCenter.storedEvents.contains("AASDK_CONTENT_DELIVERY"))
        XCTAssert(mockNotificationCenter.storedEvents.count == 3)
        
        Registrar.clearContentListeners(delegate: testDelegate)
        XCTAssert(mockNotificationCenter.storedEvents.count == 1)
    }
}
