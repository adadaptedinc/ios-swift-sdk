//
//  ReportManagerTests.swift
//  AASwiftSDKTests
//
//  Created by Brett Clifton on 11/2/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import XCTest
@testable import AASwiftSDK

final class ReportManagerTests: XCTestCase {
    private let mockConnector = MockAAConnector()
    
    override func setUp() {
        ReportManager.createInstance(connector: mockConnector)
    }
    
    func testReportItemInteraction() {
        ReportManager.getInstance().reportItemInteraction("testName", itemList: "testList", eventName: "testEvent")
        let result = mockConnector.storedCollectableEvents.first??.asDictionary()
        XCTAssertEqual("testEvent", result!["event_name"] as! String)
    }
    
    func testReportItemInteractionFromPayload() {
        let testPayload = AAContentPayload()
        testPayload.payloadType = "test"
        
        ReportManager.getInstance().reportItemInteractionFromPayload("testName", from: testPayload, eventName: "testEvent")
        let result = mockConnector.storedCollectableEvents.first??.asDictionary()
        let eventParams = result!["event_params"] as! [AnyHashable: Any]?
        let payloadSource = eventParams!["source"]
        XCTAssertEqual("testEvent", result!["event_name"] as! String)
        XCTAssertEqual("test", payloadSource as! String)
    }
    
    func testReportAcknowledgeItem() {
        let testAd = AAAd()
        testAd.adID = "testAdId"
        ReportManager.getInstance().reportAcknowledgeItem("testName", addedToList: "testList", from: testAd, eventName: "testEvent")
        let result = mockConnector.storedCollectableEvents.first??.asDictionary()
        let eventParams = result!["event_params"] as! [AnyHashable: Any]?
        let adId = eventParams!["ad_id"]
        XCTAssertEqual("testEvent", result!["event_name"] as! String)
        XCTAssertEqual("testAdId", adId as! String)
    }
    
    func testReportPayloadReceived() {
        let testContentPayload = AAContentPayload()
        testContentPayload.payloadId = "testPayloadId"
        ReportManager.getInstance().reportPayloadReceived(testContentPayload)
        let result = (mockConnector.storedRequests.first as! AAPayloadTrackingRequest).asDictionary()
        let params = result!["tracking"] as! [[String: Any?]]?
        let payloadId = (params?.last?["payload_id"])! as! String
        XCTAssertEqual("testPayloadId", payloadId)
    }
    
    func testReportPayloadRejected() {
        let testContentPayload = AAContentPayload()
        testContentPayload.payloadId = "testPayloadId"
        ReportManager.getInstance().reportPayloadRejected(testContentPayload)
        let result = (mockConnector.storedRequests.first as! AAPayloadTrackingRequest).asDictionary()
        let params = result!["tracking"] as! [[String: Any?]]?
        let payloadId = (params?.last?["payload_id"])! as! String
        XCTAssertEqual("testPayloadId", payloadId)
    }
    
    func testReportAnomaly() {
        ReportManager.getInstance().reportAnomaly(withCode: "testErrorCode", message: "testErrorMessage", params: nil)
        let result = mockConnector.storedCollectableErrors.first??.asDictionary()
        let errorCode = result!["error_code"] as! String
        XCTAssertEqual("testErrorCode", errorCode)
    }
    
    func testReportInternalEvent() {
        ReportManager.getInstance().reportInternalEvent(eventName: "testEvent", payload: ["test": "testValue"])
        let result = mockConnector.storedCollectableEvents.first??.asDictionary()
        let eventParams = result!["event_params"] as! [AnyHashable: Any]?
        let payload = eventParams!["test"] as! String
        XCTAssertEqual("testValue", payload)
    }
}
