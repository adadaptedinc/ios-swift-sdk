import XCTest
@testable import AASwiftSDK

class AACollectableEventRequestTests: XCTestCase {
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

    func testInitParams() {
        let options = [
            AASDK.OPTION_TEST_MODE:true,
            AASDK.OPTION_KEYWORD_INTERCEPT:true]
            as [String : Any]

        AASDK.startSession(withAppID: "007420", registerListenersFor: mockObserver, options: options)

        let event1 = AACollectableEvent.appEvent(withName: AA_EC_USER_ADDED_TO_LIST, andPayload: nil)

        let requests = AACollectableEventRequest(events: [event1])
        let requestsJson = requests.asJSON()

        print(requestsJson as Any)

        guard let requestsJson = requestsJson else { return }

        XCTAssertFalse(requestsJson.contains("device_"))
        XCTAssertEqual(requests.url()?.absoluteString, "https://sandec.adadapted.com/v/1/ios/")
        XCTAssertEqual(requests.targetURL()?.absoluteString, "https://sandec.adadapted.com/v/1/ios/events")

    }
}
