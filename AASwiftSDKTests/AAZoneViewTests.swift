//
//  AAZoneViewTests.swift
//  AASwiftSDKTests
//
//  Created by Matthew Kruk on 8/31/21.
//  Copyright © 2021 AdAdapted. All rights reserved.
//

@testable import AASwiftSDK
import XCTest

final class AAZoneViewTests: XCTestCase {

    let mockConnector = MockAAConnector()
    var mockNotificationCenter = MockNotificationCenter()

    override func setUp() {
        ReportManager.createInstance(connector: mockConnector)
        NotificationCenterWrapper.createInstance(notificationCenter: mockNotificationCenter)
    }

    func testSetVisibility() {
        let zoneView = AAZoneView()

        XCTAssert(zoneView.isAdVisible)
        zoneView.setAdZoneVisibility(isViewable: false)
        XCTAssertFalse(zoneView.isAdVisible)

    }
}
