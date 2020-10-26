//
//  Protocols.swift
//  AASwiftSDK
//
//  Created by Brett Clifton on 10/27/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

/// An informally used protocol to allow the internal
/// workings to have different exposure to the events dispatched
protocol AASDKObserverInternal: AASDKObserver {
    func aaSDKCacheUpdated(_ notification: Notification)
    func aaSDKGetAdsComplete(_ notification: Notification)
}

//H
/// \brief A protocol an application should implement to be aware of the high-level happenings of the SDK.
/// NOTE: only one AASDKObserver can exist at a time.
@objc public protocol AASDKObserver: NSObjectProtocol {
    /// \brief SDK init complete.
    /// \param notification with userInfo NSDictionary that includes info about the SDK start.
    /// Notifies the applicaion that the SDK has initialized correctly. Information in the `userInfo` param. Keys: `zoneCount` : NSNumber *and `zoneIds` : NSArray*.
    func aaSDKInitComplete(_ notification: Notification)
    /// \brief callback when errors are detected by AASDK.
    /// \param error notification with userIndo NSDictionary that includes error messaging.
    /// Error message is in the `userInfo` param with the keys `message` and `recoverySuggestion` included.
    /// See \ref errorhandling for more detailed usage.
    func aaSDKError(_ error: Notification)
    
    @objc optional func aaSDKCacheUpdated(_ notification: Notification)
    @objc optional func aaSDKGetAdsComplete(_ notification: Notification)

    /// optional elements
    /// \brief SDK is online. Helpful if you desire to know when SDK is back online after disconnect.
    /// \param notification with userInfo NSDictionary that includes info about the SDK start.
    /// Notifies the applicaion that the SDK has initialized correctly. Information in the `userInfo` param. Keys: AASDK_KEY_ZONE_COUNT : NSNumber *and AASDK_KEY_ZONE_IDS : NSArray* (of NSString *).
    @objc optional func aaSDKOnline(_ notification: Notification)
    /// \brief Keyword Intercepts have loaded - a list of assets to cache is available
    /// \param notification with userInfo NSDictionary that includes info about the assets to cache
    /// Notifies the applicaion that the SDK has initialized Keyword Intercept terms. Information in the `userInfo` param. Keys: AASDK_KEY_ASSET_URL_LIST : NSArray* (of NSString *)is an array of URL images you may cache.
    /// \ref keywordintercept Keyword Intercept for more details
    @objc optional func aaSDKKeywordInterceptInitComplete(_ notification: Notification)
}

/// \brief Content delivery delegate.
/// Supports the delivery of content to the clien application.
/// See: \ref ad_content for more details.
@objc public protocol AASDKContentDelegate: NSObjectProtocol {
    /// \brief Ad-based Content delivery notification
    /// \param notification The NSNotification has a `userInfo` dictionary with `AASDK_KEY_TYPE` and `AASDK_KEY_AD_CONTENT` keys.
    /// e.g. The data can be retrieved with: `NSDictionary *payload = [[notification userInfo] objectForKey:AASDK_KEY_AD_CONTENT];`
    /// See: \ref ad_content for more details.
    @objc optional func aaContentNotification(_ notification: Notification)
    /// \brief Payload Service Content Delivery
    /// \param notification The NSNotification has a `userInfo` dictionary with `AASDK_KEY_CONTENT_PAYLOADS` key.
    /// e.g. The data can be retrieved with: `NSDictionary *payload = [[notification userInfo] objectForKey:AASDK_KEY_CONTENT_PAYLOADS];`
    /// See: \ref payload_content for more details.
    @objc optional func aaPayloadNotification(_ notification: Notification)
}

/// \brief Debugging messaging from SDK.
/// Provides the developer with detailed messaging around what the SDK is doing.
/// NOTE: only one AASDKDebugObserver can exist at a time.
@objc protocol AASDKDebugObserver: NSObjectProtocol {
    /// \brief Debugging notification
    /// \param notification The NSNotification has a `userInfo` dictionary with `AASDK_KEY_MESSAGE` and `AASDK_KEY_TYPE` keys.
    /// e.g. Message can be retrieved with: `NSString *message = [[notification userInfo] objectForKey:AASDK_KEY_MESSAGE];`
    func aaDebugNotification(_ notification: Notification)
}

