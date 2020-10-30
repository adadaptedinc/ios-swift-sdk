//
//  Registrar.swift
//  AASwiftSDK
//
//  Created by Brett Clifton on 10/27/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation

class Registrar {
    class func addListeners(observer: AASDKObserver) {
        if observer.responds(to: #selector(AASDKObserver.aaSDKInitComplete(_:))) {
            
            AASDK.notificationCenter().removeObserver(
                observer,
                name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_INIT_COMPLETE_NAME),
                object: nil)
            
            AASDK.notificationCenter().addObserver(
                observer,
                selector: #selector(AASDKObserver.aaSDKInitComplete(_:)),
                name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_INIT_COMPLETE_NAME),
                object: nil)
        }

        if observer.responds(to: #selector(AASDKObserver.aaSDKError(_:))) {
            AASDK.notificationCenter().removeObserver(
                observer,
                name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_ERROR),
                object: nil)
            
            AASDK.notificationCenter().addObserver(
                observer,
                selector: #selector(AASDKObserver.aaSDKError(_:)),
                name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_ERROR),
                object: nil)
        }

        if observer.responds(to: #selector(AASDKObserver.aaSDKOnline(_:))) {
            AASDK.notificationCenter().removeObserver(
                observer,
                name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_IS_ONLINE_NAME),
                object: nil)
            
            AASDK.notificationCenter().addObserver(
                observer,
                selector: #selector(AASDKObserver.aaSDKOnline(_:)),
                name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_IS_ONLINE_NAME),
                object: nil)
        }

        if observer.responds(to: #selector(AASDKObserver.aaSDKKeywordInterceptInitComplete(_:))) {
            AASDK.notificationCenter().removeObserver(
                observer,
                name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_KEYWORD_INTERCEPT_INIT_COMPLETE),
                object: nil)
            
            AASDK.notificationCenter().addObserver(
                observer,
                selector: #selector(AASDKObserver.aaSDKKeywordInterceptInitComplete(_:)),
                name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_KEYWORD_INTERCEPT_INIT_COMPLETE),
                object: nil)
        }

        if observer.responds(to: #selector(AASDKObserver.aaSDKGetAdsComplete(_:))) {
            AASDK.notificationCenter().removeObserver(
                observer,
                name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_GET_ADS_COMPLETE_NAME),
                object: nil)
            
            AASDK.notificationCenter().addObserver(
                observer,
                selector: #selector(AASDKObserver.aaSDKGetAdsComplete(_:)),
                name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_GET_ADS_COMPLETE_NAME),
                object: nil)
        }

        if observer.responds(to: #selector(AASDKObserver.aaSDKCacheUpdated(_:))) {
            AASDK.notificationCenter().removeObserver(
                observer,
                name: NSNotification.Name(rawValue: AASDK_CACHE_UPDATED),
                object: nil)
            
            AASDK.notificationCenter().addObserver(
                observer,
                selector: #selector(AASDKObserver.aaSDKCacheUpdated(_:)),
                name: NSNotification.Name(rawValue: AASDK_CACHE_UPDATED),
                object: nil)
        }
    }
    
    class func clearListeners(observer: AASDKObserver) {
        AASDK.notificationCenter().removeObserver(
            observer,
            name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_INIT_COMPLETE_NAME),
            object: nil)

        AASDK.notificationCenter().removeObserver(
            observer,
            name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_GET_ADS_COMPLETE_NAME),
            object: nil)

        AASDK.notificationCenter().removeObserver(
            observer,
            name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_IS_ONLINE_NAME),
            object: nil)

        AASDK.notificationCenter().removeObserver(
            observer,
            name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_ERROR),
            object: nil)

        AASDK.notificationCenter().removeObserver(
            observer,
            name: NSNotification.Name(rawValue: AASDK_CACHE_UPDATED),
            object: nil)

        AASDK.notificationCenter().removeObserver(
            observer,
            name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_KEYWORD_INTERCEPT_INIT_COMPLETE),
            object: nil)
    }
    
    class func addContentListeners(delegate: AASDKContentDelegate) {
        if delegate.responds(to: #selector(AASDKContentDelegate.aaContentNotification(_:))) {
            AASDK.notificationCenter().removeObserver(
                delegate,
                name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_CONTENT_DELIVERY),
                object: nil)
            
            AASDK.notificationCenter().addObserver(
                delegate,
                selector: #selector(AASDKContentDelegate.aaContentNotification(_:)),
                name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_CONTENT_DELIVERY),
                object: nil)
        }

        if delegate.responds(to: #selector(AASDKContentDelegate.aaPayloadNotification(_:))) {
            AASDK.notificationCenter().removeObserver(
                delegate,
                name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_CONTENT_PAYLOADS_INBOUND),
                object: nil)
            
            AASDK.notificationCenter().addObserver(
                delegate,
                selector: #selector(AASDKContentDelegate.aaPayloadNotification(_:)),
                name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_CONTENT_PAYLOADS_INBOUND),
                object: nil)
        }
    }
    
    class func clearContentListeners(delegate: AASDKContentDelegate) {
        AASDK.notificationCenter().removeObserver(
            delegate,
            name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_CONTENT_DELIVERY),
            object: nil)

        AASDK.notificationCenter().removeObserver(
            delegate,
            name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_CONTENT_PAYLOADS_INBOUND),
            object: nil)
    }
    
    class func addDebugListeners(observer: AASDKDebugObserver) {
        if observer.responds(to: #selector(AASDKDebugObserver.aaDebugNotification(_:))) {
            AASDK.notificationCenter().removeObserver(
                observer,
                name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_DEBUG_MESSAGE),
                object: nil)
           
            AASDK.notificationCenter().addObserver(
                observer,
                selector: #selector(AASDKDebugObserver.aaDebugNotification(_:)),
                name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_DEBUG_MESSAGE),
                object: nil)
        }
    }
}
