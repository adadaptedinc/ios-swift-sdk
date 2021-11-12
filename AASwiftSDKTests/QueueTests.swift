//
//  QueueTests.swift
//  AASwiftSDKTests
//
//  Created by Matthew Kruk on 10/28/21.
//  Copyright © 2021 AdAdapted. All rights reserved.
//

@testable import AASwiftSDK
import XCTest

final class QueueTests: XCTestCase {

    func testQueue() {
        var queue = Queue<String>()

        queue.enqueue("Hello")
        queue.enqueue("My")
        queue.enqueue("Name")
        queue.enqueue("is")
        queue.enqueue("Who")

        XCTAssertEqual(queue.size(), 5)
        XCTAssertEqual(queue.dequeue(), "Hello")

        XCTAssertEqual(queue.size(), 4)
        XCTAssertEqual(queue.dequeue(), "My")

        XCTAssertEqual(queue.dequeue(), "Name")
        XCTAssertEqual(queue.dequeue(), "is")
        XCTAssertEqual(queue.dequeue(), "Who")

        XCTAssert(queue.isEmpty)
        XCTAssertFalse(queue.hasItems())
    }
}
