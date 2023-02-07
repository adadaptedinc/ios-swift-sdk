//
//  AppDelegate.swift
//  SwiftExampleApp
//
//  Created by Brett Clifton on 8/10/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import AASwiftSDK
import AppTrackingTransparency
import CoreData
import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AASDKObserver, AASDKDebugObserver {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // AASDK.disableAdTracking() turn on and off IDFA tracking
        let options = [
            AASDK.OPTION_TEST_MODE:true,
            AASDK.OPTION_KEYWORD_INTERCEPT:true,
            AASDK.OPTION_EXTERNAL_PAYLOADS:true,
            AASDK.OPTION_CUSTOM_ID:"CustomIdTest::\(Int.random(in: 100..<999))"]
            as [String : Any]

        // Ad tracking dialog
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .notDetermined:
                    break
                case .restricted:
                    break
                case .denied:
                    break
                case .authorized:
                    break
                @unknown default:
                    break
                }
            }
        } else {
            // Fallback on earlier versions
            return true
        }

         // iOS api key
        AASDK.startSession(withAppID: "7D58810X6333241C", registerListenersFor: self, options: options)

        var debug = [AnyHashable]()
        debug.append(AASDK.DEBUG_ALL)

        AASDK.registerDebugListeners(for: self, forMessageTypes: debug)
        
        return true
    }

    // MARK: AASDK Calls
    
    func aaSDKInitComplete(_ notification: Notification) {
        print("init complete")

        let ids = AASDK.availableZoneIDs()

        // Check for valid zone IDs
        if (ids.isEmpty) {
            print("No ad zones available")
            // Don't try to load any ads
        }
        else {
            // Check valid zone IDs for available ads
            for id in ids {
                if (AASDK.zoneAvailable(id as? String)) {
                    print("Zone \(id) is available")
                    // Try to load ads...
                }
            }
        }
    }
    
    func aaSDKCacheUpdated(_ notification: Notification) {
        print("ad cache updated")
        let ids = AASDK.availableZoneIDs()

        // Check for valid zone IDs
        if (ids.isEmpty) {
            print("No ad zones available after refresh")
            // Don't try to load any ads
        }
        else {
            // Check valid zone IDs for available ads
            for id in ids {
                if (AASDK.zoneAvailable(id as? String)) {
                    print("Zone \(id) is available after refresh")
                    // Show/Hide ads based on ad availability
                }
            }
        }
    }
    
    func aaDebugNotification(_ notification: Notification) {
        print("debug: " +  notification.debugDescription)
    }

    func aaSDKError(_ error: Notification) {
        print("error \(error.debugDescription)")
    }

    func aaSDKKeywordInterceptInitComplete(_ notification: Notification) {
        print(notification)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
                return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
