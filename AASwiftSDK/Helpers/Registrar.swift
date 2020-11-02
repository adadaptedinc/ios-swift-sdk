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
            removeObserver(observerName: observer, notificationName: AASDK_NOTIFICATION_INIT_COMPLETE_NAME)
            addObserver(observerName: observer, selectorName: #selector(AASDKObserver.aaSDKInitComplete(_:)), notificationName: AASDK_NOTIFICATION_INIT_COMPLETE_NAME)
        }

        if observer.responds(to: #selector(AASDKObserver.aaSDKError(_:))) {
            removeObserver(observerName: observer, notificationName: AASDK_NOTIFICATION_ERROR)
            addObserver(observerName: observer, selectorName: #selector(AASDKObserver.aaSDKError(_:)), notificationName: AASDK_NOTIFICATION_ERROR)
        }

        if observer.responds(to: #selector(AASDKObserver.aaSDKOnline(_:))) {
            removeObserver(observerName: observer, notificationName: AASDK_NOTIFICATION_IS_ONLINE_NAME)
            addObserver(observerName: observer, selectorName: #selector(AASDKObserver.aaSDKOnline(_:)), notificationName: AASDK_NOTIFICATION_IS_ONLINE_NAME)
        }

        if observer.responds(to: #selector(AASDKObserver.aaSDKKeywordInterceptInitComplete(_:))) {
            removeObserver(observerName: observer, notificationName: AASDK_NOTIFICATION_KEYWORD_INTERCEPT_INIT_COMPLETE)
            addObserver(observerName: observer, selectorName: #selector(AASDKObserver.aaSDKKeywordInterceptInitComplete(_:)), notificationName: AASDK_NOTIFICATION_KEYWORD_INTERCEPT_INIT_COMPLETE)
        }

        if observer.responds(to: #selector(AASDKObserver.aaSDKGetAdsComplete(_:))) {
            removeObserver(observerName: observer, notificationName: AASDK_NOTIFICATION_GET_ADS_COMPLETE_NAME)
            addObserver(observerName: observer, selectorName: #selector(AASDKObserver.aaSDKGetAdsComplete(_:)), notificationName: AASDK_NOTIFICATION_GET_ADS_COMPLETE_NAME)
        }

        if observer.responds(to: #selector(AASDKObserver.aaSDKCacheUpdated(_:))) {
            removeObserver(observerName: observer, notificationName: AASDK_CACHE_UPDATED)
            addObserver(observerName: observer, selectorName: #selector(AASDKObserver.aaSDKCacheUpdated(_:)), notificationName: AASDK_CACHE_UPDATED)
        }
    }
    
    class func clearListeners(observer: AASDKObserver) {
        removeObserver(observerName: observer, notificationName: AASDK_NOTIFICATION_INIT_COMPLETE_NAME)
        removeObserver(observerName: observer, notificationName: AASDK_NOTIFICATION_GET_ADS_COMPLETE_NAME)
        removeObserver(observerName: observer, notificationName: AASDK_NOTIFICATION_IS_ONLINE_NAME)
        removeObserver(observerName: observer, notificationName: AASDK_NOTIFICATION_ERROR)
        removeObserver(observerName: observer, notificationName: AASDK_CACHE_UPDATED)
        removeObserver(observerName: observer, notificationName: AASDK_NOTIFICATION_KEYWORD_INTERCEPT_INIT_COMPLETE)
    }
    
    class func addContentListeners(delegate: AASDKContentDelegate) {
        if delegate.responds(to: #selector(AASDKContentDelegate.aaContentNotification(_:))) {
            removeObserver(observerName: delegate, notificationName: AASDK_NOTIFICATION_CONTENT_DELIVERY)
            addObserver(observerName: delegate, selectorName: #selector(AASDKContentDelegate.aaContentNotification(_:)), notificationName: AASDK_NOTIFICATION_CONTENT_DELIVERY)
        }

        if delegate.responds(to: #selector(AASDKContentDelegate.aaPayloadNotification(_:))) {
            removeObserver(observerName: delegate, notificationName: AASDK_NOTIFICATION_CONTENT_PAYLOADS_INBOUND)
            addObserver(observerName: delegate, selectorName: #selector(AASDKContentDelegate.aaPayloadNotification(_:)), notificationName: AASDK_NOTIFICATION_CONTENT_PAYLOADS_INBOUND)
        }
    }
    
    class func clearContentListeners(delegate: AASDKContentDelegate) {
        removeObserver(observerName: delegate, notificationName: AASDK_NOTIFICATION_CONTENT_DELIVERY)
        removeObserver(observerName: delegate, notificationName: AASDK_NOTIFICATION_CONTENT_PAYLOADS_INBOUND)
    }
    
    class func addDebugListeners(observer: AASDKDebugObserver) {
        if observer.responds(to: #selector(AASDKDebugObserver.aaDebugNotification(_:))) {
            removeObserver(observerName: observer, notificationName: AASDK_NOTIFICATION_DEBUG_MESSAGE)
            addObserver(observerName: observer, selectorName: #selector(AASDKDebugObserver.aaDebugNotification(_:)), notificationName: AASDK_NOTIFICATION_DEBUG_MESSAGE)
        }
    }
    
    private class func removeObserver(observerName: Any, notificationName: String) {
        AASDK.notificationCenter().removeObserver(
            observerName,
            name: NSNotification.Name(rawValue: notificationName),
            object: nil)
    }
    
    private class func addObserver(observerName: Any, selectorName: Selector, notificationName: String) {
        AASDK.notificationCenter().addObserver(
            observerName,
            selector: selectorName,
            name: NSNotification.Name(rawValue: notificationName),
            object: nil)
    }
}
