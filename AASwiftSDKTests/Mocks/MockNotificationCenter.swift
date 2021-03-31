//
//  MockNotificationCenter.swift
//  AASwiftSDKTests
//
//  Created by Brett Clifton on 11/5/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation

class MockNotificationCenter: NotificationCenter {
    var storedNotificationPosts = [Notification]()
    var storedEvents = [String]()
    
    override func post(_ notification: Notification) {
        storedNotificationPosts.append(notification)
    }
    
    override func addObserver(_ observer: Any, selector aSelector: Selector, name aName: NSNotification.Name?, object anObject: Any?) {
        storedEvents.append(aName.map { $0.rawValue }!)
    }
    
    override func removeObserver(_ observer: Any, name aName: NSNotification.Name?, object anObject: Any?) {
        let rawValue = aName.map { $0.rawValue } ?? ""
        storedEvents = storedEvents.filter(){ $0 != rawValue }
    }
}
