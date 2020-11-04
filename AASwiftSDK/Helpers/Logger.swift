//
//  Logger.swift
//  AASwiftSDK
//
//  Created by Brett Clifton on 10/28/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//


import Foundation

class Logger {
    class func consoleLogError(_ error: Error?, withMessage message: String?, suppressTracking suppress: Bool) {
        var output: String?
        if error == nil {
            output = "(\(message ?? ""))"
        } else {
            output = "\(message ?? ""):\n\((error?.localizedDescription ?? "") )\n\(((error as NSError?)?.localizedFailureReason ?? "") )\nERROR END"
        }

        if !suppress {
            AASDK.trackAnomalyGenericErrorMessage(output, optionalAd: nil)
        }
    }
    
    class func dispatchMessage(_ message: String?, ofType type: String?) {
        var payload = [AnyHashable : Any](minimumCapacity: 2)

        payload[AASDK_KEY_TYPE] = type
        payload[AASDK_KEY_MESSAGE] = message
        let notification = Notification(
            name: Notification.Name(rawValue: AASDK_NOTIFICATION_DEBUG_MESSAGE),
            object: nil,
            userInfo: payload)

        NotificationCenterWrapper.notifier.post(notification)
    }
}
