//
//  NotificationCenterWrapper.swift
//  AASwiftSDK
//
//  Created by Brett Clifton on 11/5/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation

class NotificationCenterWrapper {
    private static var instance: NotificationCenterWrapper? =  nil
    private var _notificationCenter: NotificationCenter = NotificationCenter()
    
    static var notifier = instance!._notificationCenter
    
    class func createInstance(notificationCenter: NotificationCenter) {
        instance = NotificationCenterWrapper(notificationCenter: notificationCenter)
    }
    
    private init(notificationCenter: NotificationCenter) {
        _notificationCenter = notificationCenter
    }
}
