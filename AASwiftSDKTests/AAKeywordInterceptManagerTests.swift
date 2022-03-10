//
//  AAKeywordInterceptManagerTests.swift
//  AASwiftSDKTests
//
//  Created by Matthew Kruk on 1/5/22.
//  Copyright © 2022 AdAdapted. All rights reserved.
//

@testable import AASwiftSDK
import XCTest

final class AAKeywordInterceptManagerTests: XCTestCase {

    let connector = MockAAConnector()
    let keywords = [["KI_REPLACEMENT_ID": "1392", "KI_REPLACEMENT_TAGLINE": "", "KI_REPLACEMENT_TEXT": "Cheesemonger\'s best cheese"], ["KI_REPLACEMENT_TEXT": "Vanilla Coke", "KI_REPLACEMENT_TAGLINE": "", "KI_REPLACEMENT_ID": "1388"], ["KI_REPLACEMENT_TEXT": "Vanilla Coke", "KI_REPLACEMENT_ID": "1387", "KI_REPLACEMENT_TAGLINE": ""], ["KI_REPLACEMENT_TEXT": "Columbia Coffee Crystals", "KI_REPLACEMENT_ID": "1379", "KI_REPLACEMENT_TAGLINE": ""], ["KI_REPLACEMENT_TAGLINE": "", "KI_REPLACEMENT_ID": "1404", "KI_REPLACEMENT_TEXT": "Toilet Super Bowl Cleaner"], ["KI_REPLACEMENT_ID": "1401", "KI_REPLACEMENT_TAGLINE": "", "KI_REPLACEMENT_TEXT": "Superior Garbage Disposal Cleaner"], ["KI_REPLACEMENT_TEXT": "Superior Garbage Disposal Cleaner", "KI_REPLACEMENT_TAGLINE": "", "KI_REPLACEMENT_ID": "1403"], ["KI_REPLACEMENT_TEXT": "Fancy Milk", "KI_REPLACEMENT_ID": "1380", "KI_REPLACEMENT_TAGLINE": ""], ["KI_REPLACEMENT_ID": "1386", "KI_REPLACEMENT_TEXT": "Vanilla Coke", "KI_REPLACEMENT_TAGLINE": ""], ["KI_REPLACEMENT_TAGLINE": "", "KI_REPLACEMENT_ID": "1402", "KI_REPLACEMENT_TEXT": "Superior Garbage Disposal Cleaner"]]

    var keywordInterceptManager: AAKeywordInterceptManager?

    override func setUp() {
        keywordInterceptManager = AAKeywordInterceptManager(connector: connector, minMatchLength: 3)
    }

    func testLoadKeywordIntercepts() {
        keywordInterceptManager?.loadKeywordIntercepts(keywords)
        XCTAssertEqual(keywordInterceptManager?.keywordIntercepts, keywords)
    }

    func testMatchUserInput() {
        keywordInterceptManager?.loadKeywordIntercepts(keywords)
        keywordInterceptManager?.matchUserInput("milk")
        XCTAssertEqual(keywordInterceptManager?.lastUserInput, "milk")
    }

    func testReports() {
        keywordInterceptManager?.reportSelected()
        XCTAssertEqual(keywordInterceptManager?.events?.count, 1)

        keywordInterceptManager?.reportPresented()
        XCTAssertEqual(keywordInterceptManager?.events?.count, 2)
    }
}
