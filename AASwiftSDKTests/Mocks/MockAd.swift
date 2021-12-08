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

    func getMockAds() -> [AAAd] {
        let ad1 = AAAd()
        ad1.impressionID = "007007::5F225F6A607E3A4A"
        ad1.trackingHTML = "<html></html>"
        ad1.actionType = "c"
        ad1.actionPath = URL(string: "")

        ad1.popupHideBrowserNav = false
        ad1.popupAltCloseButtonURL = ""
        ad1.popupHideCloseButton = false
        ad1.popupBackColor = ""
        ad1.popupTitleText = ""
        ad1.popupType = ""
        ad1.popupHideBanner = false
        ad1.popupTextColor = ""

        ad1.creativeId = "https://sandy.adly.com/a/NWHATIZUPHOMMIE0;007007;45446?session_id=AEE91F45C7541A0ACF941D5878DE02B4607E3A4A&amp;udid=00000000-0000-0000-0000-000000000000"
        ad1.jsonContentPayload = getMockPayload()
        ad1.refreshIntervalSeconds = 60
        ad1.hideAfterInteraction = false
        ad1.type = .kAdAdaptedHTMLAd
        ad1.adID = "45447"

        let ad2 = AAAd()
        ad2.impressionID = "007008::5F225F6A607E3A4A"
        ad2.trackingHTML = "<html></html>"
        ad2.actionType = "l"
        ad2.actionPath = URL(string: "")

        ad2.popupHideBrowserNav = false
        ad2.popupAltCloseButtonURL = ""
        ad2.popupHideCloseButton = false
        ad2.popupBackColor = ""
        ad2.popupTitleText = ""
        ad2.popupType = ""
        ad2.popupHideBanner = false
        ad2.popupTextColor = ""

        ad2.creativeId = "https://sandy.adly.com/a/NWHATIZUPHOMMIE0;007008;45446?session_id=AEE91F45C7541A0ACF941D5878DE02B4607E3A4A&amp;udid=00000000-0000-0000-0000-000000000000"
        ad2.jsonContentPayload = getMockPayload()
        ad2.refreshIntervalSeconds = 60
        ad2.hideAfterInteraction = false
        ad2.type = .kAdAdaptedHTMLAd
        ad2.adID = "45448"

        let ad3 = AAAd()
        ad3.impressionID = "007009::5F225F6A607E3A4A"
        ad3.trackingHTML = "<html></html>"
        ad3.actionType = "l"
        ad3.actionPath = URL(string: "")

        ad3.popupHideBrowserNav = false
        ad3.popupAltCloseButtonURL = ""
        ad3.popupHideCloseButton = false
        ad3.popupBackColor = ""
        ad3.popupTitleText = ""
        ad3.popupType = ""
        ad3.popupHideBanner = false
        ad3.popupTextColor = ""

        ad3.creativeId = "https://sandy.adly.com/a/NWHATIZUPHOMMIE0;007008;45446?session_id=AEE91F45C7541A0ACF941D5878DE02B4607E3A4A&amp;udid=00000000-0000-0000-0000-000000000000"
        ad3.jsonContentPayload = getMockPayload()
        ad3.refreshIntervalSeconds = 60
        ad3.hideAfterInteraction = false
        ad3.type = .kAdAdaptedHTMLAd
        ad3.adID = "45449"

        var ads = [AAAd]()
        ads.append(ad1)
        ads.append(ad2)
        ads.append(ad3)

        return ads
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
