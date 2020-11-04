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
    
    override func post(_ notification: Notification) {
        storedNotificationPosts.append(notification)
    }
    
}
