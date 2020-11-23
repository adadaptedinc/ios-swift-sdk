//
//  AdContentTests.swift
//  AASwiftSDKTests
//
//  Created by Brett Clifton on 11/10/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import XCTest
@testable import AASwiftSDK

class AdContentTests: XCTestCase {
    var mockAAAd = AAAd()
    
    override func setUp() {
        mockAAAd.actionType = "test"
        mockAAAd.adID = "testAdId"
    }
    
    func testNilDictionaryAd() {
        XCTAssert((AdContent.parse(fromDictionary: nil, ad: mockAAAd) == nil))
    }
    
    func testParseBasicListItemsArray() {
        var itemsArray = [AnyHashable : Any]()
        var basicListItems = [AnyHashable]()
        basicListItems.append("testBasicItem")
        itemsArray["list-items"] = basicListItems
        
        let resultAdContent = AdContent.parse(fromDictionary: itemsArray, ad: mockAAAd)
        
        XCTAssertEqual("testBasicItem", resultAdContent?.detailedListItems.first?.productTitle)
        XCTAssertEqual(mockAAAd.actionType, (resultAdContent!.ad as! AAAd).actionType)
    }
    
    func testParseBasicListItemsDictionary() {
        var itemsArray = [AnyHashable : Any]()
        var basicListItemsDic = [AnyHashable : Any]()
        basicListItemsDic["product-title"] = "testDetailItemTitle"
        basicListItemsDic["product-image"] = "testDetailItemImage"
        basicListItemsDic["product-description"] = "testDetailItemImage"
        itemsArray["list-items"] = basicListItemsDic
        
        let resultAdContent = AdContent.parse(fromDictionary: itemsArray, ad: mockAAAd)
        
        XCTAssertEqual("testDetailItemTitle", resultAdContent?.detailedListItems.first?.productTitle)
        XCTAssertEqual(URL(string: "testDetailItemImage"), resultAdContent?.detailedListItems.first?.productImageURL)
        XCTAssertEqual("testDetailItemImage", resultAdContent?.detailedListItems.first?.productDescription)
    }
    
    func testParseRichListItemsDictionary() {
        var itemsArray = [AnyHashable : Any]()
        var basicListItems = [AnyHashable]()
        let richItem = ["product-title" : "testDetailItemTitle",
                        "product-image" : "testDetailItemImage",
                        "product-description" : "testDetailItemImage"]
        
        basicListItems.append(richItem)
        itemsArray["rich-list-items"] = basicListItems
        
        let resultAdContent = AdContent.parse(fromDictionary: itemsArray, ad: mockAAAd)
        
        XCTAssertEqual("testDetailItemTitle", resultAdContent?.detailedListItems.first?.productTitle)
        XCTAssertEqual(URL(string: "testDetailItemImage"), resultAdContent?.detailedListItems.first?.productImageURL)
        XCTAssertEqual("testDetailItemImage", resultAdContent?.detailedListItems.first?.productDescription)
    }
    
    func testParseDetailedListItemsDictionary() {
        var itemsArray = [AnyHashable : Any]()
        var basicListItems = [AnyHashable]()
        let richItem = ["product-title" : "testDetailItemTitle",
                        "product-image" : "testDetailItemImage",
                        "product-description" : "testDetailItemImage"]
        
        basicListItems.append(richItem)
        itemsArray[DETAILED_LIST_ITEMS] = basicListItems
        
        let resultAdContent = AdContent.parse(fromDictionary: itemsArray, ad: mockAAAd)
        
        XCTAssertEqual("testDetailItemTitle", resultAdContent?.detailedListItems.first?.productTitle)
        XCTAssertEqual(URL(string: "testDetailItemImage"), resultAdContent?.detailedListItems.first?.productImageURL)
        XCTAssertEqual("testDetailItemImage", resultAdContent?.detailedListItems.first?.productDescription)
    }
    
    func testAcknowledge() {
        let mockConnector = MockAAConnector()
        ReportManager.createInstance(connector: mockConnector)
        var itemsArray = [AnyHashable : Any]()
        var basicListItems = [AnyHashable]()
        basicListItems.append("testBasicItem")
        itemsArray["list-items"] = basicListItems
        
        let resultAdContent = AdContent.parse(fromDictionary: itemsArray, ad: mockAAAd)
        resultAdContent?.acknowledge()
        let result = mockConnector.storedCollectableEvents.first??.asDictionary()
        let eventParams = result!["event_params"] as! [AnyHashable : Any]?
        let adId = eventParams!["ad_id"] as! String
        
        XCTAssertEqual("testAdId", adId)
    }
    
    func testFailure() {
        let mockConnector = MockAAConnector()
        ReportManager.createInstance(connector: mockConnector)
        var itemsArray = [AnyHashable : Any]()
        var basicListItems = [AnyHashable]()
        basicListItems.append("testBasicItem")
        itemsArray["list-items"] = basicListItems
        
        let resultAdContent = AdContent.parse(fromDictionary: itemsArray, ad: mockAAAd)
        resultAdContent?.failure("testFailure")
        let result = mockConnector.storedCollectableErrors.first??.asDictionary()
        let errorMessage = result!["error_message"] as! String
        XCTAssertEqual("testFailure", errorMessage)
    }
}
