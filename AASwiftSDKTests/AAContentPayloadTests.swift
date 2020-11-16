//
//  AAContentPayloadTest.swift
//  AASwiftSDKTests
//
//  Created by Brett Clifton on 11/10/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import XCTest
@testable import AASwiftSDK

class AAContentPayloadTests: XCTestCase {

    func testParseAAContentPayload() {
        let resultPayload = buildTestPayload()
        XCTAssertEqual("test_payload_message", resultPayload.payloadMessage)
        XCTAssertEqual("test_payloadId", resultPayload.payloadId)
        XCTAssertEqual("test_payload_image", resultPayload.payloadImageURL?.absoluteString)
    }
    
    func testParseAAContentPayloadWithNoDetailItems() {
        var parsable = [AnyHashable : Any]()
        parsable[AA_KEY_PAYLOAD_ID] = "test_payloadId"
        parsable["payload_message"] = "test_payload_message"
        parsable["payload_image"] = "test_payload_image"
        
        let resultPayload = AAContentPayload.parse(fromDictionary: parsable)
        XCTAssertEqual(nil, resultPayload)
    }
    
    func testToDictionaryReturnsNil() {
        let testContentPayload = AAContentPayload()
        let dictionary = testContentPayload.toDictionary()
        XCTAssert(dictionary == nil)
    }
    
    func testAcknowledgePayloadReceived() {
        let resultPayload = buildTestPayload()
        let mockConnector = MockAAConnector()
        ReportManager.createInstance(connector: mockConnector)
        
        resultPayload.acknowledge()
        
        let result = mockConnector.storedCollectableEvents.first??.asDictionary()
        let eventParams = result!["event_params"] as! [AnyHashable : Any]?
        let itemTitle = eventParams!["item_name"]
        XCTAssertEqual(AA_EC_ADDIT_ADDED_TO_LIST, result!["event_name"] as! String)
        XCTAssertEqual("TestPayloadTitle", itemTitle as! String)
    }
    
    func testReportReceivedOntoList() {
        let resultPayload = buildTestPayload()
        let mockConnector = MockAAConnector()
        ReportManager.createInstance(connector: mockConnector)
        
        resultPayload.reportReceivedOntoList("testList")
        
        let result = (mockConnector.storedRequests.first as! AAPayloadTrackingRequest).asDictionary()
        let params = result!["items"] as! [[String : Any?]]?
        let payloadId = (params?.last?["payload_id"])! as! String
        XCTAssertEqual("test_payloadId", payloadId)
    }
    
    func testReportRejected() {
        let resultPayload = buildTestPayload()
        let mockConnector = MockAAConnector()
        ReportManager.createInstance(connector: mockConnector)
        
        resultPayload.reportRejected()
        
        let result = (mockConnector.storedRequests.first as! AAPayloadTrackingRequest).asDictionary()
        let params = result!["items"] as! [[String : Any?]]?
        let payloadId = (params?.last?["payload_id"])! as! String
        XCTAssertEqual("test_payloadId", payloadId)
    }
    
    private func buildTestPayload() -> AAContentPayload {
        var parsable = [AnyHashable : Any]()
        parsable[AA_KEY_PAYLOAD_ID] = "test_payloadId"
        parsable["payload_message"] = "test_payload_message"
        parsable["payload_image"] = "test_payload_image"
        parsable[DETAILED_LIST_ITEMS] = [AADetailedListItem()]
        
        let resultPayload = AAContentPayload.parse(fromDictionary: parsable)
        let testDetailItem = AADetailedListItem()
        testDetailItem.productTitle = "TestPayloadTitle"
        resultPayload?.detailedListItems.append(testDetailItem)
        
        return resultPayload!
    }
    
}
