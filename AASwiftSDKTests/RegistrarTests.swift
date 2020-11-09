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
    let mockNotificationCenter = MockNotificationCenter()
    
    override func setUp() {
        NotificationCenterWrapper.createInstance(notificationCenter: mockNotificationCenter)
    }
    
    func testAddListeners() {
        Registrar.addListeners(observer: MockAASDKObserver())
        let listeningEvents = mockNotificationCenter.storedEvents
        
        XCTAssert(listeningEvents.contains("AASDK_INIT_COMPLETE"))
        XCTAssert(listeningEvents.count == 3)
    }
    
}
