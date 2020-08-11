//
//  AppDelegate.swift
//  SwiftExampleApp
//
//  Created by Brett Clifton on 8/10/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
//class AppDelegate: UIResponder, UIApplicationDelegate, AASDKObserver {
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        let options = [
//            AASDK_OPTION_TEST_MODE:true,
//            AASDK_OPTION_KEYWORD_INTERCEPT:true]
//            as [String : Any]

        // iOS api key
        //AASDK.startSession(withAppID: "NWYYODU1Y2JJOWU0", registerListenersFor: self, options: options)

        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        //AASDK.linkContentParser(userActivity)
        return true
    }

    // MARK: AASDK Calls
    
//    func aaSDKInitComplete(_ notification: Notification) {
//        print("init complete")
//
//        let ids = AASDK.availableZoneIDs()
//
//        // Check for valid zone IDs
//        if (ids.isEmpty) {
//            print("No ad zones available")
//            // Don't try to load any ads
//        }
//        else {
//            // Check valid zone IDs for available ads
//            for id in ids {
//                if (AASDK.zoneAvailable(id as! String)) {
//                    print("Zone \(id) is available")
//                    // Try to load ads...
//                }
//            }
//        }
//    }

//    func aaSDKError(_ error: Notification) {
//        print("error \(error.debugDescription)")
//    }
//
//    func aaSDKKeywordInterceptInitComplete(_ notification: Notification) {
//        print(notification)
//    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
                return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
