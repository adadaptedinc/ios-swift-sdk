//
//  MockAd.swift
//  AASwiftSDKTests
//
//  Created by Matthew Kruk on 10/7/21.
//  Copyright © 2021 AdAdapted. All rights reserved.
//

@testable import AASwiftSDK
import Foundation

final class MockAd {

    private var mockConnector: MockAAConnector?
    private var mockNotificationCenter: MockNotificationCenter?
    private var mockObserver: MockAASDKObserver?


    func getMockAd() -> AAAd? {
        mockConnector = MockAAConnector()
        mockNotificationCenter = MockNotificationCenter()
        mockObserver = MockAASDKObserver()
        ReportManager.createInstance(connector: mockConnector!)
        NotificationCenterWrapper.createInstance(notificationCenter: mockNotificationCenter!)

        let mockAd = AAAd()
        mockAd.impressionID = "007007::5F225F6A607E3A4A"
        mockAd.trackingHTML = "<html></html>"
        mockAd.actionType = "c"
        mockAd.actionPath = URL(string: "")

        mockAd.popupHideBrowserNav = false
        mockAd.popupAltCloseButtonURL = ""
        mockAd.popupHideCloseButton = false
        mockAd.popupBackColor = ""
        mockAd.popupTitleText = ""
        mockAd.popupType = ""
        mockAd.popupHideBanner = false
        mockAd.popupTextColor = ""

        mockAd.creativeId = "https://sandy.adly.com/a/NWHATIZUPHOMMIE0;007007;45446?session_id=AEE91F45C7541A0ACF941D5878DE02B4607E3A4A&amp;udid=00000000-0000-0000-0000-000000000000"
        mockAd.jsonContentPayload = getMockPayload()
        mockAd.refreshIntervalSeconds = 60
        mockAd.hideAfterInteraction = false
        mockAd.type = .kAdAdaptedHTMLAd
        mockAd.adID = "45446"

        return mockAd
    }

    private func getMockPayload() -> [AnyHashable: Any] {
        var payload = [AnyHashable: Any]()
        payload[AA_KEY_PAYLOAD_ID] = "test_payloadId"
        payload["payload_message"] = "test_payload_message"
        payload["payload_image"] = "test_payload_image"

        var detailedListItems = [AnyHashable: Any]()
        detailedListItems["product_barcode"] = "041143510018"
        detailedListItems["product_brand"] = "Melange"
        detailedListItems["product_image"] = "https://images.adly.com/SmoresBites_Hero.png"
        detailedListItems["product_category"] = "Snacks"
        detailedListItems["product_sku"] = ""
        detailedListItems["product_discount"] = ""
        detailedListItems["product_title"] = "Spice"

        payload[DETAILED_LIST_ITEMS] = detailedListItems


        return payload
    }
}
