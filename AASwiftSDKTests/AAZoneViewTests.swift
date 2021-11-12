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

    private let mockConnector = MockAAConnector()
    private var mockNotificationCenter = MockNotificationCenter()
    private var mockObserver: MockAASDKObserver?
    private var urlSession: URLSession!

    override func setUp() {
        ReportManager.createInstance(connector: mockConnector)
        NotificationCenterWrapper.createInstance(notificationCenter: mockNotificationCenter)
        mockObserver = MockAASDKObserver()
    }

    func testZoneViewVisibility() throws {
        let options = [
            AASDK.OPTION_TEST_MODE: true,
            AASDK.OPTION_KEYWORD_INTERCEPT: true]
            as [String: Any]

        AASDK.startSession(withAppID: "007420", registerListenersFor: mockObserver, options: options)

        let viewController = MockViewController()
        viewController.zoneView = AdAdaptedZoneView(frame: CGRect(), forZone: "101942", delegate: viewController.self)

        XCTAssertNotNil(viewController.zoneView)
        XCTAssertEqual(viewController.zoneView?.adProvider()?.zoneId, "101942")
        XCTAssertEqual(viewController.zoneView?.isAdVisible, true)
        XCTAssertEqual(viewController.zoneView?.isAdVisible, viewController.zoneView?.adProvider()?.zoneView?.isAdVisible)

        if let currentAd = viewController.zoneView?.adProvider()?.getCurrentAd {
            XCTAssertEqual(AASDK.ad(forZone: "101942", withAltImage: nil)?.adID, currentAd()?.adID)
        }

        viewController.zoneView?.setAdZoneVisibility(isViewable: false)
        XCTAssertEqual(viewController.zoneView?.isAdVisible, false)
        XCTAssertEqual(viewController.zoneView?.adProvider()?.zoneView?.isAdVisible, false)
    }

    func testInitWithCoder() {
        let object = AAZoneView()
            let data = try! NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: false)
            let coder = try! NSKeyedUnarchiver.init(forReadingFrom: data)
            let sut = AAZoneView(coder: coder)
            XCTAssertNotNil(sut)
    }
}

class MockViewController: UIViewController, AAZoneViewOwner, AASDKContentDelegate {

    var zoneView: AdAdaptedZoneView?

    override func viewDidLoad() {
        super.viewDidLoad()
        zoneView?.setZoneOwner(self)
        AASDK.registerContentListeners(for: self)
    }

    func viewControllerForPresentingModalView() -> UIViewController? {
        return self
    }
}
