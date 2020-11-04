//
//  MockAAConnector.swift
//  AASwiftSDKTests
//
//  Created by Brett Clifton on 11/2/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation
@testable import AASwiftSDK

class MockAAConnector: AAConnector {
    var storedCollectableEvents = [AACollectableEvent?]()
    var storedCollectableErrors = [AACollectableError?]()
    var storedRequests = [AAGenericRequest?]()
    
    override func addCollectableEvent(forDispatch event: AACollectableEvent?) {
        storedCollectableEvents.append(event)
    }
    
    override func enqueueRequest(_ aaRequest: AAGenericRequest?, responseWasErrorBlock: @escaping AAResponseWasErrorBlock, responseWasReceivedBlock: @escaping AAResponseWasReceivedBlock) {
        storedRequests.append(aaRequest)
    }
    
    override func addCollectableError(forDispatch event: AACollectableError?) {
        storedCollectableErrors.append(event)
    }
    
}
