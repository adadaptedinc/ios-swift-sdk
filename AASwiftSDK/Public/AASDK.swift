//
//  AASDK.swift
//  AASwiftSDK
//
//  Created by Brett Clifton on 8/12/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import CoreLocation
import Foundation
import UIKit
import WebKit

let AD_FADE_SECONDS = 0.2

/// the action type when a user clicks on an ad
enum AASDKActionType : Int {
    case kActionLink
    case kActionPopup
    case kActionAppDownload
    case kActionNone
    case kActionDelegate
    case kActionContent
}

enum AASDKState : Int {
    case kOffline
    case kUninitialized
    case kInitializing
    case kInitialized
    case kLoadingCache
    case kIdle
    case kRetrievingRequestedAsset
    case kErrorState
}

enum AAEventType : Int {
    case aa_EVENT_IMPRESSION_STARTED
    case aa_EVENT_INTERACTION
    case aa_EVENT_EVENT
    case aa_EVENT_IMPRESSION_END
    case aa_EVENT_POPUP_BEGIN
    case aa_EVENT_POPUP_END
    case aa_EVENT_APP_ENTER
    case aa_EVENT_APP_EXIT
    case aa_EVENT_CUSTOM_EVENT
    case aa_EVENT_ANOMALY
}

/// enumeration to describe the type and source of the ad data
enum AdTypeAndSource : Int {
    case kTypeUnsupportedAd = 0
    case kAdAdaptedJSONAd = 1
    case kAdAdaptedImageAd = 2
    case kAdAdaptedHTMLAd = 3
}

/// Keys for options NSDictionary
let AASDK_OPTION_USE_CACHED_IMAGES = "USE_CACHED_IMAGES"
let AASDK_OPTION_IGNORE_ZONES = "IGNORE_ZONES"
let AASDK_OPTION_TEST_MODE_API_VERSION = "TEST_MODE_API_VERSION"
let AASDK_OPTION_TEST_MODE_UNLOAD_AFTER_ONE = "TEST_MODE_UNLOAD_AFTER_ONE"
let AASDK_OPTION_DISABLE_ADVERTISING = "DISABLE_ADVERTISING"
let AASDK_OPTION_INIT_PARAMS = "INIT_PARAMS"

/// Log types to pass into registerDebugListenersFor:forMessageTypes:
let AASDK_DEBUG_GENERAL = "GENERAL"
let AASDK_DEBUG_NETWORK = "NETWORK"
let AASDK_DEBUG_NETWORK_DETAILED = "NETWORK_DETAILED"
let AASDK_DEBUG_USER_INTERACTION = "USER_INTERACTION"
let AASDK_DEBUG_AD_LAYOUT = "AD_LAYOUT"
let AASDK_DEBUG_ALL = "ALL"

/// keys used to report details in NSNotifications
let AASDK_KEY_ZONE_ID = "ZONE_ID"
let AASDK_KEY_ZONE_IDS = "ZONE_IDS"
let AASDK_KEY_ZONE_COUNT = "ZONE_COUNT"
let AASDK_KEY_MESSAGE = "MESSAGE"
let AASDK_KEY_TYPE = "TYPE"
let AASDK_KEY_RECOVERY_SUGGESTION = "RECOVERY_SUGGESTION"
let AASDK_KEY_ZONE_VIEW = "ZONE_VIEW"

/// keys used to report details in NSNotifications for Keyword Intercepts
let AASDK_KEY_KI_REPLACEMENT_ID = "KI_REPLACEMENT_ID"
let AASDK_KEY_KI_REPLACEMENT_ICON_URL = "KI_REPLACEMENT_ICON"
let AASDK_KEY_KI_REPLACEMENT_TAGLINE = "KI_REPLACEMENT_TAGLINE"
let AASDK_KEY_KI_TRIGGERED_ZONES = "KI_TRIGGERED_ZONES"

/// root of the server the framework talks to - don't allow them to pass in arbitrary ones
let AA_PROD_ROOT = "https://ads.adadapted.com/v"
let AA_SANDBOX_ROOT = "https://sandbox.adadapted.com/v"

/// version of the API. used in conjuntion with AA_SERVER_ROOT to build request base URLs.
let AA_API_VERSION = "0.9.5"
let AA_TEST_API_VERSION = "0.9.5"

let AA_CLOSE_IMAGE_URL = "https://assets.adadapted.com/round_close.png"
let AA_CLOSE_IMAGE_2X_URL = "https://assets.adadapted.com/round_close@2x.png"

let AASDK_NOTIFICATION_INIT_COMPLETE_NAME = "AASDK_INIT_COMPLETE"
let AASDK_NOTIFICATION_IS_ONLINE_NAME = "AASDK_IS_ONLINE"
let AASDK_NOTIFICATION_ERROR = "AASDK_ERROR"
let AASDK_NOTIFICATION_GET_ADS_COMPLETE_NAME = "AASDK_GET_AD_COMPLETE"
let AASDK_NOTIFICATION_POPUP_INTERNAL_TOUCH = "AASDK_INTERNAL_POPUP_TOUCH"
let AASDK_NOTIFICATION_WILL_LOAD_IMAGE = "AASDK_INTERNAL_WILL_LOAD_IMAGE"
let AASDK_NOTIFICATION_DID_LOAD_IMAGE = "AASDK_INTERNAL_DID_LOAD_IMAGE"
let AASDK_NOTIFICATION_FAILED_LOAD_IMAGE = "AASDK_INTERNAL_FAILED_LOAD_IMAGE"
let AASDK_DEBUG_MESSAGE = "AASDK_DEBUG_MESSAGE"
let AASDK_CACHE_UPDATED = "AASDK_CACHE_UPDATED"


let AASDK_NOTIFICATION_DEBUG_MESSAGE = "AASDK_UI_DEBUG_MESSAGE"
let AASDK_NOTIFICATION_CONTENT_DELIVERY = "AASDK_CONTENT_DELIVERY"
let AASDK_NOTIFICATION_KEYWORD_INTERCEPT_INIT_COMPLETE = "AASDK_NOTIFICATION_KEYWORD_INTERCEPT_INIT_COMPLETE"
let AASDK_NOTIFICATION_CONTENT_PAYLOADS_INBOUND = "AASDK_NOTIFICATION_CONTENT_PAYLOADS_INBOUND"

/// "secret" config params that can be passed in
let AASDK_OPTION_PRIVATE_CUSTOM_POPUP_TARGET = "PRIVATE_CUSTOM_POPUP_TARGET"
let AASDK_OPTION_PRIVATE_CUSTOM_WEBVIEW_AD = "PRIVATE_CUSTOM_WEBVIEW_AD"
let AASDK_OPTION_PRIVATE_TARGET_ENVIRONMENT = "TARGET_ENVIRONMENT"

/// set for AASDK_OPTION_TARGET_ENVIRONMENT
let AASDK_PRODUCTION = "PRODUCTION"
let AASDK_SANDBOX = "SANDBOX"

///
/// Codes for reporting back to the API
///*

let CODE_HIDDEN_INTERACTION = "HIDDEN_INTERACTION"
let CODE_AD_IMAGE_LOAD_FAILED = "AD_IMAGE_LOAD_FAILED"
let CODE_AD_URL_LOAD_FAILED = "AD_URL_LOAD_FAILED"
let CODE_POPUP_URL_LOAD_FAILED = "POPUP_URL_LOAD_FAILED"
let CODE_AD_CONFIG_ERROR = "AD_CONFIG_ERROR"
let CODE_ZONE_CONFIG_ERROR = "ZONE_CONFIG_ERROR"
let CODE_HTML_TRACKING_ERROR = "HTML_TRACKING_ERROR"
let CODE_ERROR = "ERROR"
let CODE_JSON_PARSING_EROR = "JSON_PARSING_ERROR"
let CODE_API_400 = "API_RETURNED_400_ERROR"
let CODE_ATL_FAILURE = "ATL_FAILED_TO_ADD_TO_LIST"
let CODE_UNIVERSAL_LINK_PARSE_ERROR = "UNIVERSAL_LINK_PARSE_ERROR"


/// \brief be notified of connection state changes
/// An optional protocol that communicates the connection state of the SDK by forwarding an enumeration from AFNetworking.
protocol AAConnectorObserver: NSObjectProtocol {
    /// \brief OPTIONAL - be notified of connection state changes
    /// This returns the ABH_Reachability enumeration
    func aaConnectionStateChanged(to status: Int)
}

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

/// /// \brief static accessors that are the primary public interface to AASDK and it's components
/// /// The AdAdapted iOS SDK's top-level class. Most interactions with AdAdapted (and MoPub) are through this class,
/// or the AAZoneView sub-classes.
/// /// A static access pattern is used, so client developers don't have to create or manange instances. It's design is to
/// "stay out of the developers way" as much as possible.
// MARK: - Static initializer enforces singleton
var _aasdk: AASDK?
var _currentState: AASDKState?
var _isConnected = false
var cacheEventName: String?
var imagesToLoad = 0
var imagesLoaded = 0
var lastCame: Date?

@objc public class AASDK: NSObject {
    @objc public static let AASDK_OPTION_TEST_MODE = "TEST_MODE"
    @objc public static let AASDK_OPTION_KEYWORD_INTERCEPT = "KEYWORD_INTERCEPT"
    @objc public static let AASDK_KEY_CONTENT_PAYLOADS = "CONTENT_PAYLOADS"
    @objc public static let AASDK_KEY_AD_CONTENT = "AD_CONTENT"
    @objc public static let AASDK_KEY_KI_REPLACEMENT_TEXT = "KI_REPLACEMENT_TEXT"
    
    private var appID: String?
    private var connector: AAConnector?
    private var closeImage: UIImageView?
    private var currentlyDisplayedAds: [AnyHashable]?
    private var zones: [AnyHashable : Any]?
    private var pollingIntervalInMS = 0
    private var updateTimer: Timer?
    private var zonesToIgnore: [AnyHashable]?
    private var inTestMode = false
    private var disableAdvertising = false
    private var serverRoot: String = ""
    private var serverVersion: String?
    /// settable options
    var shouldUseCachedImages = false
    private weak var observer: AASDKObserver?
    private var options: [AnyHashable : Any]?
    private weak var debugObserver: AASDKDebugObserver?
    private var sessionExpiresAtUTC = 0
    private var updateTimerLastFired = 0
    private var userDebugMessageTypes: [AnyHashable]?
    private var rootURLString: String?
    private var customPopupURL: String?
    private var customAdURL: String?
    private var deviceLocation: CLLocation?
    private var unloadAdAfterOne = false
    private var networkStateKnown = false
    private var isKeywordInterceptOn = false
    private var kiManager: AAKeywordInterceptManager?
    private var impressionCounters: [AnyHashable : Any]?
    var notificationCenter: NotificationCenter = NotificationCenter()
    private var payloadTrackers: [AnyHashable : Any]?
    private var lastPayloadCheck: Date?
    private var appInitParams: [AnyHashable : Any]?
// MARK: - notfications
    /// \brief add listeners to conforming object
    /// \param observer the object to add listeners to
    /// add listeners most commonly used for a loading screen to wait for caching to complete, if wanted, and highest-level of error reporting
    class func registerListeners(for observer: AASDKObserver?) {
        if observer == nil {
            return
        }

        if observer?.responds(to: #selector(AASDKObserver.aaSDKInitComplete(_:))) ?? false {
            if let observer = observer {
                AASDK.notificationCenter().removeObserver(
                    observer,
                    name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_INIT_COMPLETE_NAME),
                    object: nil)
            }
            if let observer = observer {
                AASDK.notificationCenter().addObserver(
                    observer,
                    selector: #selector(AASDKObserver.aaSDKInitComplete(_:)),
                    name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_INIT_COMPLETE_NAME),
                    object: nil)
            }
        }

        if observer?.responds(to: #selector(AASDKObserver.aaSDKError(_:))) ?? false {
            if let observer = observer {
                AASDK.notificationCenter().removeObserver(
                    observer,
                    name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_ERROR),
                    object: nil)
            }
            if let observer = observer {
                AASDK.notificationCenter().addObserver(
                    observer,
                    selector: #selector(AASDKObserver.aaSDKError(_:)),
                    name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_ERROR),
                    object: nil)
            }
        }

        if observer?.responds(to: #selector(AASDKObserver.aaSDKOnline(_:))) ?? false {
            if let observer = observer {
                AASDK.notificationCenter().removeObserver(
                    observer,
                    name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_IS_ONLINE_NAME),
                    object: nil)
            }
            if let observer = observer {
                AASDK.notificationCenter().addObserver(
                    observer,
                    selector: #selector(AASDKObserver.aaSDKOnline(_:)),
                    name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_IS_ONLINE_NAME),
                    object: nil)
            }
        }

        if observer?.responds(to: #selector(AASDKObserver.aaSDKKeywordInterceptInitComplete(_:))) ?? false {
            if let observer = observer {
                AASDK.notificationCenter().removeObserver(
                    observer,
                    name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_KEYWORD_INTERCEPT_INIT_COMPLETE),
                    object: nil)
            }
            if let observer = observer {
                AASDK.notificationCenter().addObserver(
                    observer,
                    selector: #selector(AASDKObserver.aaSDKKeywordInterceptInitComplete(_:)),
                    name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_KEYWORD_INTERCEPT_INIT_COMPLETE),
                    object: nil)
            }
        }

        /// these are defined in AASDK+Internal.h : <AASDKObserverInternal> - can likely be collapsed into one notification/protocol method
        if observer?.responds(to: #selector(AASDKObserver.aaSDKGetAdsComplete(_:))) ?? false {
            if let observer = observer {
                AASDK.notificationCenter().removeObserver(
                    observer,
                    name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_GET_ADS_COMPLETE_NAME),
                    object: nil)
            }
            if let observer = observer {
                AASDK.notificationCenter().addObserver(
                    observer,
                    selector: #selector(AASDKObserver.aaSDKGetAdsComplete(_:)),
                    name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_GET_ADS_COMPLETE_NAME),
                    object: nil)
            }
        }

        if observer?.responds(to: #selector(AASDKObserver.aaSDKCacheUpdated(_:))) ?? false {
            if let observer = observer {
                AASDK.notificationCenter().removeObserver(
                    observer,
                    name: NSNotification.Name(rawValue: AASDK_CACHE_UPDATED),
                    object: nil)
            }
            if let observer = observer {
                AASDK.notificationCenter().addObserver(
                    observer,
                    selector: #selector(AASDKObserver.aaSDKCacheUpdated(_:)),
                    name: NSNotification.Name(rawValue: AASDK_CACHE_UPDATED),
                    object: nil)
            }
        }
    }

    /// \brief removes all AASDKObserver notifications for object
    /// \param observer the object to remove listeners from
    /// does not remove debug listener, only ones added by registerListenersFor:
    class func removeListeners(for observer: AASDKObserver?) {
        if let observer = observer {
            AASDK.notificationCenter().removeObserver(
                observer,
                name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_INIT_COMPLETE_NAME),
                object: nil)
        }

        if let observer = observer {
            AASDK.notificationCenter().removeObserver(
                observer,
                name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_GET_ADS_COMPLETE_NAME),
                object: nil)
        }

        if let observer = observer {
            AASDK.notificationCenter().removeObserver(
                observer,
                name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_IS_ONLINE_NAME),
                object: nil)
        }

        if let observer = observer {
            AASDK.notificationCenter().removeObserver(
                observer,
                name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_ERROR),
                object: nil)
        }

        if let observer = observer {
            AASDK.notificationCenter().removeObserver(
                observer,
                name: NSNotification.Name(rawValue: AASDK_CACHE_UPDATED),
                object: nil)
        }

        if let observer = observer {
            AASDK.notificationCenter().removeObserver(
                observer,
                name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_KEYWORD_INTERCEPT_INIT_COMPLETE),
                object: nil)
        }
    }

    /// \brief add listeners to conforming object
    /// \param delegate the object to delegate to when content is received
    @objc public class func registerContentListeners(for delegate: AASDKContentDelegate?) {
        if delegate == nil {
            return
        }

        if delegate?.responds(to: #selector(AASDKContentDelegate.aaContentNotification(_:))) ?? false {
            if let delegate = delegate {
                AASDK.notificationCenter().removeObserver(
                    delegate,
                    name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_CONTENT_DELIVERY),
                    object: nil)
            }
            if let delegate = delegate {
                AASDK.notificationCenter().addObserver(
                    delegate,
                    selector: #selector(AASDKContentDelegate.aaContentNotification(_:)),
                    name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_CONTENT_DELIVERY),
                    object: nil)
            }
        }

        if delegate?.responds(to: #selector(AASDKContentDelegate.aaPayloadNotification(_:))) ?? false {
            if let delegate = delegate {
                AASDK.notificationCenter().removeObserver(
                    delegate,
                    name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_CONTENT_PAYLOADS_INBOUND),
                    object: nil)
            }
            if let delegate = delegate {
                AASDK.notificationCenter().addObserver(
                    delegate,
                    selector: #selector(AASDKContentDelegate.aaPayloadNotification(_:)),
                    name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_CONTENT_PAYLOADS_INBOUND),
                    object: nil)
            }
        }
    }

    /// \brief remove listeners for AASDKContentDelegate notifications
    /// \param delegate object to remove listeners from
    class func removeContentListeners(for delegate: AASDKContentDelegate?) {
        if let delegate = delegate {
            AASDK.notificationCenter().removeObserver(
                delegate,
                name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_CONTENT_DELIVERY),
                object: nil)
        }

        if let delegate = delegate {
            AASDK.notificationCenter().removeObserver(
                delegate,
                name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_CONTENT_PAYLOADS_INBOUND),
                object: nil)
        }
    }

// MARK: - questions
    /// \brief is SDK connected to internet
    /// must be called a bit after making the first static AASDK call - it takes time for it to notice it's online.
    /// \return YES if SDK is online and can reach API.
    class func isOnline() -> Bool {
        return _isConnected
    }

    /// \brief convieniance method to let you know if sdk has initialized cache and ready to go
    /// must be called after aaSDKInitComplete: is called
    /// \return YES if SDK is ready (init call to API is done)
    class func isReadyForUse() -> Bool {
        if _aasdk?.appID == nil || (_aasdk?.appID?.count ?? 0) == 0 {
            return false
        }
        return _currentState == AASDKState.kIdle
    }

// MARK: - start session w/ server
    /// \brief start session
    /// Starts a session by contacting the AdAdapted API. See \ref bootstrapping for more details.
    /// \param appID required, provided by AdAdapted
    /// \param observer optional, will let you know when cache has loaded (if used), and about errors.
    /// \param opDic optional, all values optional as well. Use the constants (top of this file) as keys.
    /// \code{.m}
    /// AASDK_OPTION_USE_CACHED_IMAGES - defaults to NO. By default images are loaded Just In Time.
    /// YES loads image cache first, so ads render instantly.
    /// AASDK_OPTION_DISABLE_WEBVIEW_CLOSE_BUTTON - defaults to NO.
    /// YES means the popup ad themselves must use web hook to dismiss the ad.
    /// AASDK_OPTION_SHOW_NAVIGATION_INSIDE_POPUP - defaults to NO.
    /// YES will forward and back buttons to all the pop-up webview.
    /// AASDK_OPTION_TARGET_ENVIRONMENT - AASDK_PRODUCTION is default
    /// AASDK_OPTION_INIT_PARAMS - NSDictionary of JSON-complaint key/value pairs
    /// \endcode
    @objc public class func startSession(
        withAppID appID: String?,
        registerListenersFor observer: AASDKObserver?,
        options opDic: [AnyHashable : Any]?
    ) {
        _aasdk?.observer = observer
        _aasdk?.options = opDic
        _aasdk?.appID = appID
        _aasdk?.zonesToIgnore = []
        _aasdk?.shouldUseCachedImages = false
        _aasdk?.inTestMode = false

        AASDK.registerListeners(for: observer)

        _aasdk?.zones?.removeAll()

        if let _aasdk = _aasdk {
            NotificationCenter.default.removeObserver(_aasdk)
        }

        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: OperationQueue.main,
            using: { note in
                _aasdk?.going(toBackground: note)
            })


        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: OperationQueue.main,
            using: { note in
                _aasdk?.coming(toForeground: note)
            })


        //NOTE: don't reset location, since they could have passed that in first.

        DispatchQueue.global(qos: .default).async(execute: { [self] in
            //Background Thread
            AASDK.privateStartSession(
                withAppID: appID,
                registerListenersFor: observer,
                options: opDic)
        })
    }

    /// \brief supports targeted ads
    /// \param location location to pass to API for more targeted ads
    /// note - this is not reset when init is called. to set to unknown pass in nil
    class func setDeviceLocation(_ location: CLLocation?) {
        if let location = location {
            AASDK.logDebugMessage("AASDK location set \(location.coordinate.latitude) \(location.coordinate.longitude)", type: AASDK_DEBUG_GENERAL)
            _aasdk?.deviceLocation = location
        } else {
            AASDK.logDebugMessage("Location set to nil", type: AASDK_DEBUG_GENERAL)
            _aasdk?.deviceLocation = nil
        }
    }

// MARK: - Public event reporting
    /// \brief not currently implemented - NOOP
    /// \param name the name of the event
    /// \param payload optional hash of data to send along
    class func reportEventNamed(_ name: String?, withPayload payload: [AnyHashable : Any]?) {
        _aasdk?.connector?.addCollectableEvent(forDispatch: AACollectableEvent.appEvent(withName: name, andPayload: payload))
    }

    /// \brief report item added to an optional list
    /// \param itemName the name of the item
    /// \param list the name of the list (optional)
    @objc public class func reportItem(_ itemName: String?, addedToList: String?) {
        var payload = [AnyHashable : Any](minimumCapacity: 2)
        payload["item_name"] = itemName ?? ""

        if let list = addedToList {
            payload["list_name"] = list
        }

        let item = AASDK.cachedItem(matching: itemName ?? "")
        if let item = item {
            payload["tracking_id"] = item.trackingId
            payload["payload_id"] = item.payloadId
        }

        let logitem = "ListManager: item added to list: \(itemName ?? "")"
        AASDK.logDebugMessage(logitem, type: AASDK_DEBUG_GENERAL)
        AASDK.sendEvent(AA_EC_USER_ADDED_TO_LIST, withPayload: payload)
    }

    /// \brief report item crossed off an optional list
    /// In the case your app only has one removal state, use this one. If your app has two states,
    /// use this one to mean "the user purchased this thing or completed this task".
    /// \param itemName the name of the item
    /// \param list the name of the list (optional)
    @objc public class func reportItem(_ itemName: String, crossedOffList: String?) {
        var payload = [AnyHashable : Any](minimumCapacity: 2)
        payload["item_name"] = itemName

        if let list = crossedOffList {
            payload["list_name"] = list
        }

        let item = AASDK.cachedItem(matching: itemName)
        if let item = item {
            payload["tracking_id"] = item.trackingId
            payload["payload_id"] = item.payloadId
            AASDK.uncacheItem(item)
        }

        let logitem = "ListManager: item crossed off list: \(itemName)"
        AASDK.logDebugMessage(logitem, type: AASDK_DEBUG_GENERAL)
        AASDK.sendEvent(AA_EC_USER_CROSSED_OFF_LIST, withPayload: payload)
    }

    /// \brief report item deleted from an optional list
    /// In the case your app only has one removal state, DO NOT use this one. If your app has two states,
    /// use this one to mean "the user deleted an item in a non-completed mannner".
    /// \param itemName the name of the item
    /// \param list the name of the list (optional)
    @objc public class func reportItem(_ itemName: String, deletedFromList list: String?) {
        var payload = [AnyHashable : Any](minimumCapacity: 2)
        payload["item_name"] = itemName

        if let list = list {
            payload["list_name"] = list
        }

        let item = AASDK.cachedItem(matching: itemName)
        if let item = item {
            payload["tracking_id"] = item.trackingId
            payload["payload_id"] = item.payloadId
            AASDK.uncacheItem(item)
        }

        let logitem = "ListManager: item deleted from list: \(itemName)"
        AASDK.logDebugMessage(logitem, type: AASDK_DEBUG_GENERAL)
        AASDK.sendEvent(AA_EC_USER_DELETED_FROM_LIST, withPayload: payload)
    }

    /// \brief report items added to an optional list
    /// \param items an array of NSStrings
    /// \param list the name of the list (optional)
    @objc public class func reportItems(_ items: [String]?, addedToList list: String?) {
        for string in items ?? [] {
            AASDK.reportItem(string, addedToList: list)
        }
        do {
            for string in items ?? [] {
                AASDK.reportItem(string, addedToList: list)
            }
        }
        //AASDK.trackAnomalyGenericErrorMessage("reportItems:addedToList", optionalAd: nil)
    }

    /// \brief report items crossed off an optional list
    /// In the case your app only has one removal state, use this one. If your app has two states,
    /// use this one to mean "the user purchased this thing or completed this task".
    /// \param items an array of NSStrings
    /// \param list the name of the list (optional)
    @objc public class func reportItems(_ items: [String], crossedOffList list: String?) {
        for itemName in items {
            AASDK.reportItem(itemName, crossedOffList: list)
        }
    }

    /// \brief report items deleted from an optional list
    /// In the case your app only has one removal state, DO NOT use this one. If your app has two states,
    /// use this one to mean "the user deleted an item in a non-completed mannner".
    /// \param items an array of NSStrings
    /// \param list the name of the list (optional)
    @objc public class func reportItems(_ items: [String], deletedFromList list: String?) {
        for itemName in items {
            AASDK.reportItem(itemName, deletedFromList: list)
        }
    }

// MARK: - programatic layout conveniences
    /// \brief the size of the zone in the CURRENT ORIENTATION
    /// - Returns: CGSizeMake(0, 0) if zone is unknown, or if not supported
    class func sizeOfZone(_ zoneId: String?) -> CGSize {
        return AASDK.sizeOfZone(zoneId, for: UIApplication.shared.statusBarOrientation)
    }

    /// \brief the size of the zone
    /// - Returns: CGSizeMake(0, 0) if zone is unknown, or if not supported
    class func sizeOfZone(_ zoneId: String?, for orientation: UIInterfaceOrientation) -> CGSize {
        let zone = _aasdk?.zones?[zoneId ?? ""] as? AAAdZone
        if let zone = zone {
            return zone.adSizeforOrientation(orientation)
        }
        return CGSize(width: 0, height: 0)
    }

    /// \brief a CGRect with origin 0,0 and the size of the zone
    /// - Returns: CGRectMake(0, 0, 0, 0) if zone is unknown, or if not supported
    class func boundsOfZone(_ zoneId: String?, for orientation: UIInterfaceOrientation) -> CGRect {
        let zone = _aasdk?.zones?[zoneId ?? ""] as? AAAdZone
        if let zone = zone {
            return zone.adBoundsforOrientation(orientation)
        }
        return CGRect(x: 0, y: 0, width: 0, height: 0)
    }

    /// \brief supported orientations for a given zone
    /// Use UIInterfaceOrientationIsLandscape(value) and UIInterfaceOrientationIsLandscape(value) for testing the return value
    /// - Returns: mask with UIInterfaceOrientationMaskPortrait and/or UIInterfaceOrientationMaskLandscape
    class func supportedInterfaceOrientations(forZone zoneId: String?) -> UIInterfaceOrientationMask {
        let zone = _aasdk?.zones?[zoneId ?? ""] as? AAAdZone
        if let zone = zone {
            return zone.supportedInterfaceOrientations()
        }
        return .portrait
    }

// MARK: - cacheInfo
    /// \brief convenience mechanism
    /// - Returns: array of strings representing the AdAdapted zones the SDK is aware of.
    /// If AASDK_OPTION_USE_CACHED_IMAGES:YES is set when starting the SDK, then these
    /// images are already downloaded. If NO, then these images are ready to render JIT.
    @objc public class func availableZoneIDs() -> [AnyHashable]? {
        let zones = _aasdk?.zones
        var zoneKeys = [AnyHashable]()
        if ((zones != nil) || zones!.isEmpty == false) {
            for key in zones!.keys {
                zoneKeys.append(key)
            }
        }
        return zoneKeys
    }

    /// \brief convenience mechanism
    /// \param zoneId a string value provided by AdAdapted staff.
    /// - Returns: YES if the SDK is ready to render the given AdAdapted ZoneId
    @objc public class func zoneAvailable(_ zoneId: String?) -> Bool {
        let zone = _aasdk?.zones?[zoneId ?? ""] as? AAAdZone
        if zone != nil && zone?.hasAdsAvailable != nil {
            return zone?.isCacheComplete ?? false
        } else {
            return false
        }
    }

    /// \brief convenience mechanism
    /// - Returns: array of strings representing the AdAdapted Keyword Intercept zones the SDK is aware of.
    /// MUST WAIT for KI_INIT_COMPLETE for this to return a non-empty list
    class func availableKIZoneIDs() -> [AnyHashable] {
        if _aasdk?.kiManager != nil {
            return _aasdk?.kiManager?.allAvailableZones() ?? []
        }
        return []
    }

    /// \brief convenience mechanism
    /// \param zoneId a string value provided by AdAdapted staff.
    /// - Returns: YES if the SDK is ready to render the given AdAdapted Keyword Intercept ZoneId
    /// MUST WAIT for KI_INIT_COMPLETE for this to ever return true
    class func kiZoneAvailable(_ zoneId: String?) -> Bool {
        if _aasdk?.kiManager != nil {
            return _aasdk?.kiManager?.hasZone(zoneId) ?? false
        }
        return false
    }

// MARK: - debugging
    /// \brief debugging support
    /// see \ref debugging for more details
    /// \param observer object implementing AASDKDebugObserver protocol
    /// \param types an array of debug messages you'd like to receive.
    class func registerDebugListeners(for observer: AASDKDebugObserver?, forMessageTypes types: [AnyHashable]?) {
        if observer == nil {
            return
        }

        _aasdk?.debugObserver = observer
        _aasdk?.userDebugMessageTypes = types

        if observer?.responds(to: #selector(AASDKDebugObserver.aaDebugNotification(_:))) ?? false {
            if let observer = observer {
                AASDK.notificationCenter().removeObserver(
                    observer,
                    name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_DEBUG_MESSAGE),
                    object: nil)
            }
            if let observer = observer {
                AASDK.notificationCenter().addObserver(
                    observer,
                    selector: #selector(AASDKDebugObserver.aaDebugNotification(_:)),
                    name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_DEBUG_MESSAGE),
                    object: nil)
            }
        }
    }

    /// \brief removes only the debug observer
    class func removeDebugListener() {
        if _aasdk?.debugObserver != nil {
            if let debugObserver1 = _aasdk?.debugObserver {
                AASDK.notificationCenter().removeObserver(
                    debugObserver1,
                    name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_DEBUG_MESSAGE),
                    object: nil)
            }
            _aasdk?.debugObserver = nil
            _aasdk?.userDebugMessageTypes = []
        }
    }

// MARK: - version info
    /// \brief returns "X.Y.Z"
    class func buildVersion() -> String? {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
    }

// MARK: - Keyword Intercept
    /// \brief Submit term Keyword Intercept
    /// see \ref keywordintercept for more details
    /// \param userInput the characters the user has typed in.
    /// This is generally called for each character the user enters in the "onChange" handler of a text field or
    /// area.
    /// If a term is matched, results will be returned in an NSDictionary.
    /// If no match is present, this returns nil.
    @objc public class func keywordIntercept(for userInput: String?) -> [AnyHashable : Any]? {
        if _aasdk?.kiManager != nil {
            return _aasdk?.kiManager?.matchUserInput(userInput)
        }
        return nil
    }

    /// \brief Record impression event
    /// see \ref keywordintercept for more details
    /// Call this when you present a result provided to you to the user.
    @objc public class func keywordInterceptPresented() {
        if _aasdk?.kiManager != nil {
            _aasdk?.kiManager?.reportPresented()
        }
    }

    /// \brief Record interaction event
    /// see \ref keywordintercept for more details
    /// Call this when the user interacts with a result provided to you.
    @objc public class func keywordInterceptSelected() {
        if _aasdk?.kiManager != nil {
            _aasdk?.kiManager?.reportSelected()
        }
    }

// MARK: - Universal Link
    /// \brief when delivering payload via universal links, pass object to SDK for processing
    /// \param userActivity object delivered to application:continueUserActivity:restorationHandler
    @objc public class func linkContentParser(_ userActivity: NSUserActivity?) {
        _aasdk?.connector?.addCollectableEvent(forDispatch: AACollectableEvent.internalEvent(withName: AA_EC_ADDIT_APP_OPENED, andPayload: [:]))

        var retArray = [AnyHashable](repeating: 0, count: 1)
        do {
            let url = userActivity?.webpageURL?.absoluteString
            let params = [
                "url": url ?? ""
            ]
            if url == nil {
                _aasdk?.connector?.addCollectableError(forDispatch: AACollectableError(code: "ADDIT_NO_DEEPLINK_RECEIVED", message: "Did not receive a universal link url.", params: params))
                return
            }

            _aasdk?.connector?.addCollectableEvent(forDispatch: AACollectableEvent.internalEvent(withName: AA_EC_ADDIT_URL_RECEIVED, andPayload: params))
            let components = NSURLComponents(string: url ?? "")
            for item in components?.queryItems ?? [] {
                guard let item = item as? NSURLQueryItem else {
                    continue
                }
                if item.name == "data" {
                    let decodedData = Data(base64Encoded: item.value ?? "", options: [])
                    var json: Any? = nil
                    do {
                        if let decodedData = decodedData {
                            json = try JSONSerialization.jsonObject(with: decodedData, options: [])
                        }
                    } catch {
                        AASDK.reportAnomaly(withCode: CODE_UNIVERSAL_LINK_PARSE_ERROR, message: url, params: nil)
                    }
                    let payload = AAContentPayload.parse(fromDictionary: json as! [AnyHashable : Any])
                    payload!.payloadType = "universal-link"
                    if let payload = payload {
                        retArray.append(payload as! AnyHashable)
                    }
                }
            }
        }

        let userInfo = [
            AASDK_KEY_MESSAGE: "Returning universal link payload item",
            AASDK.AASDK_KEY_CONTENT_PAYLOADS: retArray
        ] as [String : Any]
        let notification = Notification(name: Notification.Name(rawValue: AASDK_NOTIFICATION_CONTENT_PAYLOADS_INBOUND), object: nil, userInfo: userInfo)

        do {
            for payload in retArray {
                guard let payload = payload as? AAContentPayload else {
                    continue
                }
                for item in payload.detailedListItems {
                    AASDK.cacheItem(item)
                }
            }

            AASDK.notificationCenter().post(notification)
        }
    }

// MARK: - get Ad inside session from server

    static var initialized = false

    @objc public static func initializeSDK() {
        if !AASDK.initialized {
            AASDK.initialized = true
            _aasdk = AASDK()
            _aasdk?.appID = nil
            _aasdk?.connector = AAConnector()
            _aasdk?.connector?.delegate = _aasdk as? AAConnectorObserver
            _aasdk?.currentlyDisplayedAds = [AnyHashable](repeating: 0, count: 10)
            _aasdk?.zones = [AnyHashable : Any](minimumCapacity: 3)
            _aasdk?.impressionCounters = [AnyHashable : Any](minimumCapacity: 10)
            _aasdk?.userDebugMessageTypes = []
            _aasdk?.rootURLString = AA_PROD_ROOT
            _aasdk?.pollingIntervalInMS = 600000
            _aasdk?.updateTimerLastFired = AAHelper.nowAsUTCLong() / 1000
            _aasdk?.unloadAdAfterOne = false
            _currentState = .kUninitialized
            _isConnected = false
            _aasdk?.networkStateKnown = true // was false
            _aasdk?.disableAdvertising = false
            _aasdk?.isKeywordInterceptOn = false
            _aasdk?.serverRoot = AA_PROD_ROOT
            _aasdk?.serverVersion = AA_API_VERSION
            _aasdk?.payloadTrackers = [AnyHashable : Any](minimumCapacity: 0)
            _aasdk?.appInitParams = nil
        }
    }

// MARK: - Public start session
    // would like this to be the only thing customer facing
    /// here to be called via GCD above
    class func privateStartSession(
        withAppID appID: String?,
        registerListenersFor observer: AASDKObserver?,
        options opDic: [AnyHashable : Any]?
    ) {
        if !(_aasdk?.networkStateKnown ?? false) || _currentState == .kInitializing {
            return
        }

        if _currentState == .kOffline {
            _currentState = .kErrorState
            let userInfo = [
                AASDK_KEY_MESSAGE: "AASDK ERROR - internet connection not available. Aborting init() attempt.",
                AASDK_KEY_RECOVERY_SUGGESTION: "Re-connecting to internet will make SDK automatically come back online."
            ]

            let notification = Notification(name: Notification.Name(rawValue: AASDK_NOTIFICATION_ERROR), object: nil, userInfo: userInfo)
            AASDK.postDelayedNotification(notification)
            return
        }

        _currentState = .kInitializing

        // Extracting options
        if opDic is [AnyHashable : Any] {
            let useCached = opDic?[AASDK_OPTION_USE_CACHED_IMAGES] as? NSNumber
            if let useCached = useCached {
                _aasdk!.shouldUseCachedImages = useCached.boolValue
            }

            let testMode = opDic?[AASDK_OPTION_TEST_MODE] as? NSNumber
            if testMode != nil && testMode?.boolValue ?? false == true {
                _aasdk!.inTestMode = true
            } else {
                _aasdk!.inTestMode = false
            }

            let disableAdvertising = opDic?[AASDK_OPTION_DISABLE_ADVERTISING] as? NSNumber
            if disableAdvertising != nil && disableAdvertising?.boolValue ?? false == true {
                _aasdk?.disableAdvertising = true
            } else {
                _aasdk?.disableAdvertising = false
            }

            let version = opDic?[AASDK_OPTION_TEST_MODE_API_VERSION] as? String
            _aasdk?.setupTestMode(forOptionalVersion: version)

            let ignoreZones = opDic?[AASDK_OPTION_IGNORE_ZONES] as? [AnyHashable]
            if ignoreZones != nil && (ignoreZones?.count ?? 0) > 0 {
                if let ignoreZones = ignoreZones {
                    _aasdk?.zonesToIgnore = ignoreZones
                }
            }

            /// "PRIVATE" PARAMS
            let customPopupTarget = opDic?[AASDK_OPTION_PRIVATE_CUSTOM_POPUP_TARGET] as? String
            if customPopupTarget != nil && (customPopupTarget?.count ?? 0) > 0 {
                AASDK.logDebugMessage("PRIVATE - Using custom popup URL \(customPopupTarget ?? "")", type: AASDK_DEBUG_GENERAL)
                _aasdk?.customPopupURL = customPopupTarget
            }

            let customAdTarget = opDic?[AASDK_OPTION_PRIVATE_CUSTOM_WEBVIEW_AD] as? String
            if customAdTarget != nil && (customAdTarget?.count ?? 0) > 0 {
                AASDK.logDebugMessage("PRIVATE - Using custom Ad URL \(customAdTarget ?? "")", type: AASDK_DEBUG_GENERAL)
                _aasdk?.customAdURL = customAdTarget
            }

            let unloadAfterOne = opDic?[AASDK_OPTION_TEST_MODE_UNLOAD_AFTER_ONE] as? String
            if _aasdk?.inTestMode ?? false && unloadAfterOne != nil && (unloadAfterOne as NSString?)?.boolValue ?? false {
                _aasdk?.unloadAdAfterOne = true
            } else {
                _aasdk?.unloadAdAfterOne = false
            }

            let targetENV = opDic?[AASDK_OPTION_PRIVATE_TARGET_ENVIRONMENT] as? String
            if let targetENV = targetENV {
                if targetENV == AASDK_SANDBOX {
                    _aasdk?.rootURLString = AA_SANDBOX_ROOT
                }
            }

            let keywordIntercept = (opDic?[AASDK_OPTION_KEYWORD_INTERCEPT] ?? false) as! Bool
            if keywordIntercept == true {
                _aasdk?.isKeywordInterceptOn = true
            } else {
                _aasdk?.isKeywordInterceptOn = false
            }

            let initParams = opDic?[AASDK_OPTION_INIT_PARAMS] as? [AnyHashable : Any]
            if initParams != nil && (initParams is [AnyHashable : Any]) {
                _aasdk?.appInitParams = initParams
            } else {
                _aasdk?.appInitParams = nil
            }
        }

        // start setup work
        _aasdk?.stopUpdateTimer()

        // disable advertising flow
        if _aasdk?.disableAdvertising ?? false {
            _aasdk?.cacheAds(inAdsDic: [:], completeNotificationName: AASDK_NOTIFICATION_INIT_COMPLETE_NAME, shouldUseCachedImages: false, shouldReplaceCurrent: false)
            _currentState = .kIdle
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                AASDK.checkForPayloads()
            })
            return
        }

        _aasdk?.loadImages() // this is kinda a hack, but only 4K

        let request = AAInitRequest(appId: _aasdk?.appID, withAppInitParams: _aasdk?.appInitParams)

        let responseWasReceivedBlock =  { response, forRequest in
            let initResponse = response as! AAInitResponse
            _aasdk?.sessionExpiresAtUTC = initResponse.sessionExpiresAt 
            _aasdk?.pollingIntervalInMS = initResponse.pollingIntervalMS
            _aasdk?.cacheAds(inAdsDic: initResponse.zones, completeNotificationName: AASDK_NOTIFICATION_INIT_COMPLETE_NAME, shouldUseCachedImages: AASDK.shouldUseCachedImages() , shouldReplaceCurrent: true)
            _aasdk?.startUpdateTimer()
            AASDK.initKeywordIntercept()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                AASDK.checkForPayloads()
            })

            _currentState = .kIdle
        } as AAResponseWasReceivedBlock

        let responseWasErrorBlock = { response, forRequest, error in
            _currentState = .kErrorState

            if _aasdk?.observer == nil {
                AASDK.consoleLogError(error, withMessage: "init", suppressTracking: true)
            }

            var userInfo: [String : String]? = nil
            if let description = error?.localizedDescription {
                userInfo = [
                    AASDK_KEY_MESSAGE: "AASDK ERROR start session returned: \(description)",
                    AASDK_KEY_RECOVERY_SUGGESTION: "RECOVERY suggestion -> \((error! as NSError).localizedRecoverySuggestion ?? "")"
                ]
            }

            let notification = Notification(name: Notification.Name(rawValue: AASDK_NOTIFICATION_ERROR), object: nil, userInfo: userInfo)

            AASDK.postDelayedNotification(notification)
            _aasdk?.startUpdateTimer()
        } as AAResponseWasErrorBlock

        _aasdk?.connector?.enqueueRequest(request, responseWasErrorBlock: responseWasErrorBlock, responseWasReceivedBlock: responseWasReceivedBlock)
    }

    class func initKeywordIntercept() {
        if _aasdk?.isKeywordInterceptOn ?? false {
            let keywordInitRequest = AAKeywordInterceptInitRequest()

            let keywordInitResponseWasReceivedBlock = { response, forRequest in
                let initResponse = response as? AAKeywordInterceptInitResponse
                _aasdk?.kiManager = AAKeywordInterceptManager(connector: _aasdk?.connector, minMatchLength: initResponse!.minMatchLength, triggeredAds: initResponse?.triggeredAds)
                AASDK.logDebugMessage("Loading Keyword Intercepts", type: AASDK_DEBUG_GENERAL)
                _aasdk?.kiManager?.loadKeywordIntercepts(initResponse?.keywordIntercepts)
            } as AAResponseWasReceivedBlock

            let keywordInitResponseWasErrorBlock = { response, forRequest, error in
                var userInfo: [String : String]? = nil
                if let description = error?.localizedDescription {
                    userInfo = [
                        AASDK_KEY_MESSAGE: "AASDK ERROR keyword intercept / INIT returned: \(description)",
                        AASDK_KEY_RECOVERY_SUGGESTION: "RECOVERY suggestion -> \((error as NSError?)?.localizedRecoverySuggestion ?? "")"
                    ]
                }
                let notification = Notification(name: Notification.Name(rawValue: AASDK_NOTIFICATION_ERROR), object: nil, userInfo: userInfo)
                AASDK.postDelayedNotification(notification)
            } as AAResponseWasErrorBlock

            _aasdk?.connector?.enqueueRequest(keywordInitRequest, responseWasErrorBlock: keywordInitResponseWasErrorBlock, responseWasReceivedBlock: keywordInitResponseWasReceivedBlock)
        }
    }

// MARK: - Public event reporting

    class func sendEvent(_ eventName: String?, withPayload payload: [AnyHashable : Any]?) {
        _aasdk?.connector?.addCollectableEvent(forDispatch: AACollectableEvent.appEvent(withName: eventName, andPayload: payload))
    }

// MARK: - Public get Ad inside session
    class func getAdForZone(_ zoneId: String?) {
        let request = AAGetAdsRequest(zones: [zoneId])
        _aasdk?.getAdDispatch(request)
    }

    class func getAdForZone(_ zoneId: String?, withSize size: CGRect, count: Int, subject: String?, context: String?) {
        let request = AAGetAdsRequest(zones: [zoneId])
        _aasdk?.getAdDispatch(request)
    }

// MARK: - Private instance methods
    class func currentState() -> AASDKState {
        return _currentState!
    }

    func getAdDispatch(_ request: AAGetAdsRequest?) {
        let responseWasReceivedBlock = { response, forRequest in
            let getAdResponse = response as? AAGetAdsResponse

            let ads_count = getAdResponse?.ads?.count ?? 0

            AASDK.logDebugMessage(String(format: "get ad received response. #ads %lu", ads_count), type: AASDK_DEBUG_NETWORK)

            _aasdk?.cacheAds(inAdsDic: getAdResponse?.ads, completeNotificationName: AASDK_NOTIFICATION_GET_ADS_COMPLETE_NAME, shouldUseCachedImages: AASDK.shouldUseCachedImages() , shouldReplaceCurrent: false)
        } as AAResponseWasReceivedBlock

        let responseWasErrorBlock = { response, forRequest, error in
            _currentState = .kErrorState

            if _aasdk?.observer == nil {
                AASDK.consoleLogError(error, withMessage: "get/ad", suppressTracking: true)
            }

            var userInfo: [String : String]? = nil
            if let description = error?.localizedDescription {
                userInfo = [
                    AASDK_KEY_MESSAGE: "AASDK ERROR get ad returned: \(description)",
                    AASDK_KEY_RECOVERY_SUGGESTION: "RECOVERY suggestion -> \((error as NSError?)?.localizedRecoverySuggestion ?? "")"
                ]
            }

            let notification = Notification(name: Notification.Name(rawValue: AASDK_NOTIFICATION_ERROR), object: nil, userInfo: userInfo)

            AASDK.postDelayedNotification(notification)
        } as AAResponseWasErrorBlock

        _aasdk?.connector?.enqueueRequest(request, responseWasErrorBlock: responseWasErrorBlock, responseWasReceivedBlock: responseWasReceivedBlock)
    }

    func cacheAds(inAdsDic ads: [AnyHashable : Any]?, completeNotificationName name: String?, shouldUseCachedImages useCached: Bool, shouldReplaceCurrent shouldReplace: Bool) {
        cacheEventName = name
        AASDK.logDebugMessage("Caching ads for zones", type: AASDK_DEBUG_GENERAL)

        AASDK.resetImpressionCounters()

        _currentState = .kLoadingCache

        if shouldReplace {
            for zone in zones!.values {
                guard let zone = zone as? AAAdZone else {
                    continue
                }
                zone.reset()
            }
            zones = ads
        } else {
            for k in ads!.keys { zones!.removeValue(forKey: k) }
            for (k, v) in ads! { zones![k] = v }
        }

        if zonesToIgnore != nil && (zonesToIgnore?.count ?? 0) > 0 {
            for k in zonesToIgnore! { zones!.removeValue(forKey: k) }
        }

        if useCached {
            imagesToLoad = 0
            imagesLoaded = 0
            addCacheListeners()
        }

        for zone in zones!.values {
            guard let zone = zone as? AAAdZone else {
                continue
            }
            zone.setupZoneAndShouldUseCachedImages(useCached)
        }

        if !useCached || zones?.count == 0 {
            cacheComplete()
        } else if useCached && imagesToLoad == 0 {
            cacheComplete()
        }
    }

    func cacheComplete() {
        AASDK.logDebugMessage("Cache completed", type: AASDK_DEBUG_GENERAL)

        let info = [
            AASDK_KEY_ZONE_IDS: zones!,
            AASDK_KEY_ZONE_COUNT: NSNumber(value: zones?.count ?? 0)
        ] as [String : Any]

        let notification = Notification(name: NSNotification.Name(cacheEventName!), object: nil, userInfo: info)

        AASDK.postDelayedNotification(notification)
    }

// MARK: - Async loading Listeners
    func addCacheListeners() {
        AASDK.notificationCenter().addObserver(
            self,
            selector: #selector(startLoadingImage(_:)),
            name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_WILL_LOAD_IMAGE),
            object: nil)

        AASDK.notificationCenter().addObserver(
            self,
            selector: #selector(doneLoadingImage(_:)),
            name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_DID_LOAD_IMAGE),
            object: nil)

        AASDK.notificationCenter().addObserver(
            self,
            selector: #selector(failedLoadingImage(_:)),
            name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_FAILED_LOAD_IMAGE),
            object: nil)
    }

    func removeCacheListeners() {
        AASDK.notificationCenter().removeObserver(self, name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_WILL_LOAD_IMAGE), object: nil)
        AASDK.notificationCenter().removeObserver(self, name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_DID_LOAD_IMAGE), object: nil)
        AASDK.notificationCenter().removeObserver(self, name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_FAILED_LOAD_IMAGE), object: nil)
    }

    @objc func startLoadingImage(_ notification: Notification?) {
        imagesToLoad += 1
    }

    @objc func doneLoadingImage(_ notification: Notification?) {
        imagesLoaded += 1
        if imagesLoaded == imagesToLoad {
            removeCacheListeners()
            cacheComplete()
        }
    }

    @objc func failedLoadingImage(_ notification: Notification?) {
        imagesLoaded += 1
        if imagesLoaded == imagesToLoad {
            removeCacheListeners()
            cacheComplete()
        }
    }

    func setupTestMode(forOptionalVersion version: String?) {
        if inTestMode {
            serverRoot = AA_SANDBOX_ROOT
            serverVersion = version == nil ? AA_TEST_API_VERSION : version
        } else {
            serverRoot = AA_PROD_ROOT
            serverVersion = AA_API_VERSION
        }
        _aasdk?.connector?.inTestMode = inTestMode
    }

// MARK: - Other Listeners
    func going(toBackground notification: Notification?) {
        if appID == nil || (appID?.count ?? 0) == 0 {
            return
        }
        AASDK.trackAppStopped()
        stopUpdateTimer()
        connector?.dispatchCachedMessages()
    }

    func coming(toForeground notification: Notification?) {
        if appID == nil || (appID?.count ?? 0) == 0 || (lastCame != nil && abs(Int(lastCame?.timeIntervalSinceNow ?? 0)) < 5) {
            return
        }
        lastCame = Date()
        AASDK.trackAppStarted()
        startUpdateTimer()
        updateTimerFired()
        AASDK.checkForPayloads()
    }

    func loadImages() {
        DispatchQueue.main.async(execute: {
            _aasdk?.closeImage = UIImageView()
            _aasdk?.closeImage?.isUserInteractionEnabled = true
            _aasdk?.closeImage?.translatesAutoresizingMaskIntoConstraints = false

            let urlString = AA_CLOSE_IMAGE_URL
            AAHelper.setImageFor(_aasdk?.closeImage, from: URL(string: urlString))
        })
    }

// MARK: - private User Param stuff
    func stopUpdateTimer() {
        if let updateTimer = updateTimer {
            updateTimer.invalidate()
        }
    }

    func startUpdateTimer() {
        DispatchQueue.main.async(execute: { [self] in
            if appID != nil && (appID?.count ?? 0) > 0 {
                if updateTimer == nil {
                    updateTimer = Timer.scheduledTimer(
                        timeInterval: 30,
                        target: self,
                        selector: #selector(updateTimerFired),
                        userInfo: nil,
                        repeats: true)
                }
            }
        })
    }

    @objc func updateTimerFired() {
        if !AASDK.isReadyForUse() || _aasdk?.disableAdvertising ?? false {
            return
        }

        let now = AAHelper.nowAsUTCLong() / 1000
        if AASDK.isOnline() && now > (_aasdk?.sessionExpiresAtUTC ?? 0) {
            reinitSession()
            return
        }

        if _currentState == .kErrorState {
            AASDK.startSession(withAppID: appID, registerListenersFor: _aasdk?.observer, options: _aasdk?.options)
            return
        }

        let timeLeft = (pollingIntervalInMS / 1000) - (now - updateTimerLastFired)
        if timeLeft > 0 {
            return
        } else {
            updateTimerLastFired = now
        }

        AASDK.logDebugMessage("Grabbing updated ads for zones", type: AASDK_DEBUG_GENERAL)

        let request = AAUpdateAdsRequest()

        let responseWasReceivedBlock = { [self] response, forRequest in
            let updateResponse = response as? AAUpdateAdsResponse
            pollingIntervalInMS = updateResponse?.pollingIntervalInMS ?? 0
            checkIfReCacheNeeded(updateResponse?.zones)
        } as AAResponseWasReceivedBlock

        let responseWasErrorBlock = { response, forRequest, error in
            _currentState = .kErrorState
            if _aasdk?.observer == nil {
                AASDK.consoleLogError(error, withMessage: "update/ads", suppressTracking: true)
            }

            var userInfo: [String : String]? = nil
            if let description = error?.localizedDescription {
                userInfo = [
                    AASDK_KEY_MESSAGE: "AASDK ERROR Update Ads returned: \(description)",
                    AASDK_KEY_RECOVERY_SUGGESTION: "RECOVERY suggestion -> \((error as NSError?)?.localizedRecoverySuggestion ?? "")"
                ]
            }

            let notification = Notification(name: Notification.Name(rawValue: AASDK_NOTIFICATION_ERROR), object: nil, userInfo: userInfo)

            AASDK.postDelayedNotification(notification)
        } as AAResponseWasErrorBlock

        _aasdk?.connector?.enqueueRequest(request, responseWasErrorBlock: responseWasErrorBlock, responseWasReceivedBlock: responseWasReceivedBlock)

    }

    func checkIfReCacheNeeded(_ zones: [AnyHashable : Any]?) {
        if !((zones as NSDictionary?)?.isEqual(self.zones) ?? false) {
            AASDK.logDebugMessage("new ad Dictionary doesn't match old one: UPDATE CACHE starting", type: AASDK_DEBUG_NETWORK)
            cacheAds(inAdsDic: zones, completeNotificationName: AASDK_CACHE_UPDATED, shouldUseCachedImages: AASDK.shouldUseCachedImages() , shouldReplaceCurrent: true)
        }
    }

    func reinitSession() {
        stopUpdateTimer()

        if _aasdk?.appID == nil || (_aasdk?.appID?.count ?? 0) == 0 {
            return
        }

        let request = AAInitRequest(appId: _aasdk?.appID, withAppInitParams: _aasdk?.appInitParams)

        let responseWasReceivedBlock = { response, forRequest in
            let initResponse = response as? AAInitResponse
            if initResponse?.zones != nil {
                _aasdk?.sessionExpiresAtUTC = initResponse?.sessionExpiresAt ?? 0
                _aasdk?.pollingIntervalInMS = initResponse?.pollingIntervalMS ?? 0
                AASDK.resetImpressionCounters()
            }
            _aasdk?.startUpdateTimer()
        } as AAResponseWasReceivedBlock

        let responseWasErrorBlock = { response, forRequest, error in
            _currentState = .kErrorState

            if _aasdk?.observer == nil {
                AASDK.consoleLogError(error, withMessage: "session/reinit", suppressTracking: true)
            }

            var userInfo: [String : String]? = nil
            if let description = error?.localizedDescription {
                userInfo = [
                    AASDK_KEY_MESSAGE: "AASDK ERROR reinit session returned: \(description)",
                    AASDK_KEY_RECOVERY_SUGGESTION: "RECOVERY suggestion -> \((error as NSError?)?.localizedRecoverySuggestion ?? "")"
                ]
            }

            let notification = Notification(name: Notification.Name(rawValue: AASDK_NOTIFICATION_ERROR), object: nil, userInfo: userInfo)

            AASDK.postDelayedNotification(notification)
            _aasdk?.startUpdateTimer()
        } as AAResponseWasErrorBlock

        _aasdk?.connector?.enqueueRequest(request, responseWasErrorBlock: responseWasErrorBlock, responseWasReceivedBlock: responseWasReceivedBlock)
    }

// MARK: - Event message enqueing
    func fireTrackEventOf(_ type: AAEventType, for ad: AAAd?, withEventPath eventPath: String?, details: String?) {
        _aasdk?.connector?.addEvent(forBatchDispatch: AAReportableSessionEvent.reportableEventOf(type, for: ad, session: _aasdk?.connector?.sessionId(), eventPath: eventPath, detailedName: details))
    }

    func fireTrackEventV2Of(_ type: AAEventType, for ad: AAAd?, payload: [AnyHashable : Any]?, details: String?) {
        _aasdk?.connector?.addAnomalyEvent(forDispatch: AAReportableAnomalyEvent.reportableEventOf(type, for: ad, payload: payload, optionalDetails: details))
    }

    func fireTrackEventOf(_ type: AAEventType, for ad: AAAd?) {
        _aasdk?.connector?.addEvent(forBatchDispatch: AAReportableSessionEvent.reportableEventOf(type, for: ad, session: _aasdk?.connector?.sessionId()))
    }
}

// MARK: - <AAConnectorObserver>
    /// this int is ABH_Reachability
    var lastStatus = -123
// MARK: - Payload Service
    private var minPayloadIntervalSec: TimeInterval = 10

extension AASDK {
    class func sessionId() -> String? {
        return _aasdk?.connector?.sessionId()
    }

    class func appId() -> String? {
        return _aasdk?.appID
    }

    func aaConnectionStateChanged(to status: Int) {
        if status == lastStatus {
            return
        } else {
            lastStatus = status
        }
        AASDK.logDebugMessage("Connection state changed to: \(status)", type: AASDK_DEBUG_GENERAL)
        _aasdk?.networkStateKnown = true
    }

    class func deviceLocationOrNil() -> CLLocation? {
        return _aasdk?.deviceLocation
    }

// MARK: - endpoint
    class func serverRoot() -> String {
        return "\(_aasdk?.serverRoot ?? "")/\(_aasdk?.serverVersion ?? "")/ios"
    }

    class func eventCollectionServerRoot() -> String {
        if AASDK.inTestMode() {
            return "https://sandec.adadapted.com/v/1/ios"
        } else {
            return "https://ec.adadapted.com/v/1/ios"
        }
    }

    class func payloadServiceServerRoot() -> String {
        if AASDK.inTestMode() {
            return "https://sandpayload.adadapted.com/v/1"
        } else {
            return "https://payload.adadapted.com/v/1"
        }
    }

// MARK: - Private
    class func ad(forZone zoneId: String?, withAltImage image: UIImage?) -> AAAd? {
        let zone = _aasdk?.zones?[zoneId ?? ""] as? AAAdZone

        if let zone = zone {
            return zone.nextAd()
        }

        return nil
    }

    class func remove(_ ad: AAAd?, fromZone zoneId: String?) {
        let zone = _aasdk?.zones?[zoneId ?? ""] as? AAAdZone

        if let zone = zone {
            return zone.remove(ad)
        }
    }

    class func remove(_ ad: AAAd?, fromZone zoneId: String?, andForceReload doReload: Bool) {
        self.remove(ad, fromZone: zoneId)
        if doReload {
            let notification = Notification(name: Notification.Name(rawValue: AASDK_CACHE_UPDATED), object: nil)
            AASDK.postDelayedNotification(notification)
        }
    }

    class func inject(_ ad: AAAd?, intoZone zoneId: String?) {
        var zone = _aasdk?.zones?[zoneId ?? ""] as? AAAdZone

        if zone == nil {
            zone = AAAdZone()
            zone?.zoneId = zoneId
            _aasdk?.zones?[zoneId ?? ""] = zone
        }
        zone?.inject(ad)
    }

// MARK: - console logging
    class func consoleLogError(_ error: Error?, withMessage message: String?, suppressTracking suppress: Bool) {
        var output: String?
        if error == nil {
            output = "(\(message ?? ""))"
        } else {
            output = "\(message ?? ""):\n\((error?.localizedDescription ?? "") )\n\(((error as NSError?)?.localizedFailureReason ?? "") ?? "")\nERROR END"
        }

        if !suppress {
            AASDK.trackAnomalyGenericErrorMessage(output, optionalAd: nil)
        }
    }

// MARK: - debug logging
    class func dispatchMessage(_ message: String?, ofType type: String?) {
        var payload = [AnyHashable : Any](minimumCapacity: 2)

        payload[AASDK_KEY_TYPE] = type
        payload[AASDK_KEY_MESSAGE] = message
        let notification = Notification(
            name: Notification.Name(rawValue: AASDK_NOTIFICATION_DEBUG_MESSAGE),
            object: nil,
            userInfo: payload)

        AASDK.notificationCenter().post(notification)
    }

    class func logDebugMessage(_ message: String?, type: String?) {
        if _aasdk?.userDebugMessageTypes?.count == 0 {
            return
        }

        if _aasdk?.userDebugMessageTypes?.contains(AASDK_DEBUG_ALL) ?? false || _aasdk?.userDebugMessageTypes?.contains(type ?? "") ?? false {
            AASDK.dispatchMessage(message, ofType: type)
        }
    }

    class func logDebugFrame(_ frame: CGRect, message: String?) {
        if _aasdk?.userDebugMessageTypes?.count == 0 {
            return
        }

        if _aasdk?.userDebugMessageTypes?.contains(AASDK_DEBUG_ALL) ?? false || _aasdk?.userDebugMessageTypes?.contains(AASDK_DEBUG_AD_LAYOUT) ?? false {
            AASDK.dispatchMessage("\(message ?? "")", ofType: AASDK_DEBUG_AD_LAYOUT)
        }
    }

    class func customDebuggingPopupURL() -> String? {
        if _aasdk?.customPopupURL != nil && (_aasdk?.customPopupURL?.count ?? 0) > 0 {
            return _aasdk?.customPopupURL
        }

        return nil
    }

    class func customDebuggingAdURL() -> String? {
        if _aasdk?.customAdURL != nil && (_aasdk?.customAdURL?.count ?? 0) > 0 {
            return _aasdk?.customAdURL
        }

        return nil
    }

    class func inTestMode() -> Bool {
        if _aasdk!.inTestMode {
            return true
        }

        return false
    }

    class func shouldHideAllAdsAfterView() -> Bool {
        return _aasdk?.unloadAdAfterOne ?? false
    }

// MARK: - udpated impressions with counters
    class func value(forImpressionId impressionId: String?) -> Int {
        var value = _aasdk?.impressionCounters?[impressionId ?? ""] as? NSNumber
        if value == nil {
            value = NSNumber(value: 1)
            _aasdk?.impressionCounters?[impressionId] = value
        }
        return value?.intValue ?? 0
    }

    class func impressionString(forId impressionId: String?, forImpressionType eventType: AAEventType) -> String? {
        switch eventType {
        case .aa_EVENT_IMPRESSION_END:
                let iVal = AASDK.value(forImpressionId: impressionId)
                _aasdk?.impressionCounters?[impressionId] = NSNumber(value: Int32(iVal + 1))
                return String(format: "%@::%i", impressionId ?? "", iVal)
        case .aa_EVENT_IMPRESSION_STARTED, .aa_EVENT_INTERACTION, .aa_EVENT_POPUP_BEGIN, .aa_EVENT_POPUP_END:
                let iVal = AASDK.value(forImpressionId: impressionId)
                return String(format: "%@::%i", impressionId ?? "", iVal)
        case .aa_EVENT_EVENT, .aa_EVENT_APP_ENTER, .aa_EVENT_APP_EXIT, .aa_EVENT_CUSTOM_EVENT:
                fallthrough
            default:
                return impressionId
        }
    }

    class func resetImpressionCounters() {
        _aasdk?.impressionCounters?.removeAll()
    }

// MARK: - used by AAImage
    class func add(toCurrentlyDisplayedImages ad: AAAd?) {
        if ad == nil {
            return
        }

        if let ad = ad {
            _aasdk?.currentlyDisplayedAds?.append(ad)
        }
    }

    class func remove(fromCurrentlyDisplayedImages ad: AAAd?) -> Bool {
        if ad == nil {
            return false
        }

        var num: Int? = nil
        if let ad = ad {
            num = _aasdk?.currentlyDisplayedAds?.firstIndex(of: ad) ?? NSNotFound
        }
        if num == NSNotFound {
            return false
        } else {
            _aasdk?.currentlyDisplayedAds?.remove(at: num ?? 0)
            return true
        }
    }

    class func popupDefaultCloseButton() -> UIImageView? {
        if _aasdk?.closeImage == nil {
            _aasdk?.loadImages()
        }
        return _aasdk?.closeImage
    }

// MARK: - Event reporting exposed to SDK
    class func trackImpressionStartedForAllDisplayedImages() {
        if _aasdk?.currentlyDisplayedAds?.count == 0 {
            return
        }

        for ad in _aasdk?.currentlyDisplayedAds ?? [] {
            guard let ad = ad as? AAAd else {
                continue
            }
            _aasdk?.fireTrackEventOf(.aa_EVENT_IMPRESSION_STARTED, for: ad)
        }

        let displayedImagesCount = UInt(_aasdk?.currentlyDisplayedAds?.count ?? 0)
        AASDK.logDebugMessage(String(format: "Enqueued START tracking for %lu ads", displayedImagesCount), type: AASDK_DEBUG_NETWORK)
    }

    class func trackImpressionEndedForAllDisplayedImages() {
        if _aasdk?.currentlyDisplayedAds?.count == 0 {
            return
        }

        for ad in _aasdk?.currentlyDisplayedAds ?? [] {
            guard let ad = ad as? AAAd else {
                continue
            }
            _aasdk?.fireTrackEventOf(.aa_EVENT_IMPRESSION_END, for: ad)
        }

        let displayedImagesCount = UInt(_aasdk?.currentlyDisplayedAds?.count ?? 0)
        AASDK.logDebugMessage(String(format: "Enqueued END tracking for %lu ads", displayedImagesCount), type: AASDK_DEBUG_NETWORK)
    }

    class func trackImpressionStarted(for ad: AAAd?) {
        if ad == nil {
            return
        }
        _aasdk?.fireTrackEventOf(.aa_EVENT_IMPRESSION_STARTED, for: ad)
        AASDK.add(toCurrentlyDisplayedImages: ad)
    }

    class func trackInteraction(with ad: AAAd?, withPath eventPath: String?) {
        if ad == nil {
            return
        }
        _aasdk?.fireTrackEventOf(.aa_EVENT_INTERACTION, for: ad, withEventPath: eventPath, details: nil)
    }

    class func trackInteraction(with ad: AAAd?) {
        AASDK.trackInteraction(with: ad, withPath: nil)
    }

    class func trackImpressionEnded(for ad: AAAd?) {
        if ad == nil {
            return
        }
        if AASDK.remove(fromCurrentlyDisplayedImages: ad) {
            _aasdk?.fireTrackEventOf(.aa_EVENT_IMPRESSION_END, for: ad)
        }
    }

    class func trackPopupBegan(for ad: AAAd?) {
        if ad == nil {
            return
        }
        _aasdk?.fireTrackEventOf(.aa_EVENT_POPUP_BEGIN, for: ad)
    }

    class func trackPopupEnded(for ad: AAAd?) {
        _aasdk?.fireTrackEventOf(.aa_EVENT_POPUP_END, for: ad)
    }

    class func trackAppStarted() {
        _aasdk?.connector?.addCollectableEvent(forDispatch: AACollectableEvent.internalEvent(withName: AA_EC_APP_OPEN, andPayload: nil))
    }

    class func trackAppStopped() {
        _aasdk?.connector?.addCollectableEvent(forDispatch: AACollectableEvent.internalEvent(withName: AA_EC_APP_CLOSED, andPayload: nil))
    }

    class func trackAppExit(from ad: AAAd?, withPath path: String?) {
        _aasdk?.fireTrackEventOf(.aa_EVENT_APP_EXIT, for: ad, withEventPath: path, details: nil)
    }

    class func trackContentPayloadDelivered(from ad: AAAd?, contentType: String?) {
        let details = "payload_delivered"
        _aasdk?.fireTrackEventOf(.aa_EVENT_CUSTOM_EVENT, for: ad, withEventPath: nil, details: details)
    }

// MARK: - Improved Anomaly Reporting
    class func params(for ad: AAAd?, andDic dic: [AnyHashable : Any]?) -> [AnyHashable : Any]? {
        if dic == nil && ad == nil {
            return nil
        } else if ad == nil {
            return dic
        } else if dic == nil {
            if let adID = ad?.adID {
                return [
                    "ad_id": adID
                ]
            }
            return nil
        } else {
            var backDic = dic
            backDic!["ad_id"] = ad?.adID
            return backDic
        }
    }

    class func trackAnomalyHiddenInteraction(for ad: AAAd?) {
        AASDK.reportAnomaly(withCode: CODE_HIDDEN_INTERACTION, message: nil, params: AASDK.params(for: ad, andDic: nil))
    }

    class func trackAnomalyAdImgLoad(_ ad: AAAd?, urlString url: String?, message: String?) {
        AASDK.reportAnomaly(withCode: CODE_AD_IMAGE_LOAD_FAILED, message: message, params: AASDK.params(for: ad, andDic: [
            "url": url ?? ""
        ]))
    }

    class func trackAnomalyAdURLLoad(_ ad: AAAd?, urlString url: String?, message: String?) {
        AASDK.reportAnomaly(withCode: CODE_AD_URL_LOAD_FAILED, message: message, params: AASDK.params(for: ad, andDic: [
            "url": url ?? ""
        ]))
    }

    class func trackAnomalyAdPopupURLLoad(_ ad: AAAd?, urlString url: String?, message: String?) {
        AASDK.reportAnomaly(withCode: CODE_POPUP_URL_LOAD_FAILED, message: message, params: AASDK.params(for: ad, andDic: [
            "url": url ?? ""
        ]))
    }

    class func trackAnomalyAdConfiguration(_ ad: AAAd?, message: String?) {
        AASDK.reportAnomaly(withCode: CODE_AD_CONFIG_ERROR, message: message, params: AASDK.params(for: ad, andDic: nil))
    }

    class func trackAnomalyZoneConfiguration(_ zone: AAAdZone?, message: String?) {
        if let zoneId = zone?.zoneId {
            AASDK.reportAnomaly(withCode: CODE_ZONE_CONFIG_ERROR, message: message, params: [
                "zone_id": zoneId
            ])
        }
    }

    class func trackAnomalyWithHTMLTracker(for ad: AAAd?, message: String?) {
        AASDK.reportAnomaly(withCode: CODE_HTML_TRACKING_ERROR, message: message, params: AASDK.params(for: ad, andDic: nil))
    }

    class func trackAnomalyGenericErrorMessage(_ message: String?, optionalAd ad: AAAd?) {
        AASDK.reportAnomaly(withCode: CODE_ERROR, message: message, params: AASDK.params(for: ad, andDic: nil))
    }

// MARK: - HTML Tracking
    class func fireHTMLTracker(incomingAd ad: AAAd?, incomingView view: UIView?) {
        _aasdk?.fireHTMLTrackerInternal(adIn: ad, viewIn: view)
    }

    func fireHTMLTrackerInternal(adIn ad: AAAd?, viewIn view: UIView?) {
        if ad?.trackingHTML != nil && (ad?.trackingHTML?.count ?? 0) > 0 && view != nil {
            let tag = 1949493949
            let oldTag = view?.viewWithTag(tag)
            if oldTag != nil && (oldTag is WKWebView) {
                oldTag?.removeFromSuperview()
            }

            let html = ad?.trackingHTML!.replacingOccurrences(
                of: "[timestamp]",
                with: AAHelper.nowAsUTC()!)
            let webView = WKWebView(frame: CGRect.zero)
            webView.tag = tag
            view?.addSubview(webView)
            webView.loadHTMLString(html ?? "", baseURL: nil)
        }
    }

// MARK: - content stuff
    class func deliverContent(_ content: [AnyHashable : Any]?, from ad: AAAd?, andZoneView zoneView: AAZoneView?) {
        let name = content?[AASDK_KEY_TYPE] as? String
        let contentType = "list_items"
        var dic: [AnyHashable : Any]?

        AASDK.logDebugMessage("AASDK: deliverContent:fromAd:andZoneView enter", type: AASDK_DEBUG_USER_INTERACTION)

        if content == nil {
            var message: String? = nil
            if let adID = ad?.adID {
                message = "Ad \(adID) content payload empty - no action taken"
            }
            AASDK.consoleLogError(nil, withMessage: message, suppressTracking: true)
            AASDK.trackAnomalyAdConfiguration(ad, message: message)
            return
        }

        if name == nil || (name?.count ?? 0) == 0 {
            let adContent = AAAdContent.parse(fromDictionary: content, ad: ad ?? nil)

            if let zoneId = ad?.zoneId, let zoneView = zoneView, let adContent = adContent {
                dic = [
                    AASDK_KEY_TYPE: contentType,
                    AASDK_KEY_ZONE_ID: zoneId,
                    AASDK_KEY_ZONE_VIEW: zoneView,
                    AASDK.AASDK_KEY_AD_CONTENT: adContent
                ]
            }
        } else {
            dic = content
        }

        let notification = Notification(
            name: Notification.Name(rawValue: AASDK_NOTIFICATION_CONTENT_DELIVERY),
            object: nil,
            userInfo: dic)

        AASDK.logDebugMessage("AASDK: deliverContent:fromAd:andZoneView posting content event", type: AASDK_DEBUG_USER_INTERACTION)
        AASDK.notificationCenter().post(notification)
    }

// MARK: - added for async stuff
    class func shouldUseCachedImages() -> Bool {
        return _aasdk!.shouldUseCachedImages
    }

// MARK: - used for testing
    class func resetCache() {
        for zone in _aasdk!.zones!.values {
            guard let zone = zone as? AAAdZone else {
                continue
            }
            zone.reset()
        }
    }

// MARK: - keyword intercept
    class func reportKeywordInterceptInitComplete(_ assets: [AnyHashable : Any]?) {
        let notification = Notification(
            name: Notification.Name(rawValue: AASDK_NOTIFICATION_KEYWORD_INTERCEPT_INIT_COMPLETE),
            object: nil,
            userInfo: assets)

        AASDK.postDelayedNotification(notification)
    }

// MARK: - Private event reporting
    class func reportItem(_ item: String?, addedToList list: String?, from ad: AAAd?) {
        var payload: [AnyHashable : Any]?
        if list == nil {
            if let adID = ad?.adID {
                payload = [
                    "item_name": item ?? "",
                    "ad_id": adID
                ]
            }
        } else {
            if let adID = ad?.adID {
                payload = [
                    "item_name": item ?? "",
                    "ad_id": adID,
                    "list_name": list ?? ""
                ]
            }
        }

        _aasdk?.connector?.addCollectableEvent(forDispatch: AACollectableEvent.internalEvent(withName: AA_EC_ATL_ADDED_TO_LIST, andPayload: payload))
    }

    class func reportItems(_ items: [AnyHashable]?, addedToList list: String?, from ad: AAAd?) {
        do {
            for string in items ?? [] {
                guard let string = string as? String else {
                    continue
                }
                AASDK.reportItem(string, addedToList: list, from: ad)
            }
        }
    }

    class func reportZoneLoaded(_ zoneId: String?) {
        if zoneId == nil {
            return
        }
        let payload = [
            "zone_id": zoneId ?? ""
        ]
        _aasdk?.connector?.addCollectableEvent(forDispatch: AACollectableEvent.internalEvent(withName: AA_EC_ZONE_LOADED, andPayload: payload))
    }

    class func reportAnomaly(withCode errorCode: String?, message: String?, params: [AnyHashable : Any]?) {
        _aasdk?.connector?.addCollectableError(forDispatch: AACollectableError(code: errorCode, message: message, params: params))
    }

    class func reportAddToListFailure(withMessage message: String?, from ad: AAAd) {
        _aasdk?.connector?.addCollectableError(forDispatch: AACollectableError(code: CODE_ATL_FAILURE, message: message, params: [
            "ad_id": ad.adID!
        ]))
    }

// MARK: - Internal NSNotificationCenter
    class func notificationCenter() -> NotificationCenter {
        return (_aasdk?.notificationCenter)!
    }

    class func checkForPayloads() {
        if _aasdk?.lastPayloadCheck != nil && (abs(Int(_aasdk?.lastPayloadCheck?.timeIntervalSinceNow ?? 0)) < Int(minPayloadIntervalSec)) {
            return
        }
        _aasdk?.lastPayloadCheck = Date()

        let worked = { response, forRequest in
            let pickupResponse = response as? AAPayloadPickupResponse

            AASDK.logDebugMessage("Payload Service replied", type: AASDK_DEBUG_GENERAL)

            if pickupResponse?.payloads != nil && (pickupResponse?.payloads?.count ?? 0) > 0 {
                if let payloads = pickupResponse?.payloads {
                    for payload in payloads {
                        guard let payload = payload as? AAContentPayload else {
                            continue
                        }
                        payload.payloadType = "payload"
                    }
                }
                var userInfo: [String : String]? = nil
                if let payloads = pickupResponse?.payloads {
                    userInfo = [
                        AASDK_KEY_MESSAGE: "Returning \(Int(pickupResponse?.payloads?.count ?? 0)) payload items",
                        AASDK_KEY_CONTENT_PAYLOADS: payloads.description
                    ]
                }
                let notification = Notification(name: Notification.Name(rawValue: AASDK_NOTIFICATION_CONTENT_PAYLOADS_INBOUND), object: nil, userInfo: userInfo)

                do {
                    if let payloads = pickupResponse?.payloads {
                        for payload in payloads {
                            guard let payload = payload as? AAContentPayload else {
                                AASDK.logDebugMessage("caught fatal error with payload parsing", type: AASDK_DEBUG_GENERAL)
                                continue
                            }
                            for item in payload.detailedListItems {
                                AASDK.cacheItem(item)
                            }
                        }
                    }

                    AASDK.notificationCenter().post(notification)
                }

            }
        } as AAResponseWasReceivedBlock

        let failed = { response, forRequest, error in
            var userInfo: [String : String]? = nil
            if let description = error?.localizedDescription {
                userInfo = [
                    AASDK_KEY_MESSAGE: "AASDK ERROR Payload Service pickup returned: \(description)",
                    AASDK_KEY_RECOVERY_SUGGESTION: "RECOVERY suggestion -> \((error as NSError?)?.localizedRecoverySuggestion ?? "")"
                ]
            }
            let notification = Notification(name: Notification.Name(rawValue: AASDK_NOTIFICATION_ERROR), object: nil, userInfo: userInfo)
            AASDK.notificationCenter().post(notification)
        } as AAResponseWasErrorBlock

        let request = AAPayloadPickupRequest()

        _aasdk?.connector?.enqueueRequest(request, responseWasErrorBlock: failed, responseWasReceivedBlock: worked)
    }

    class func reportPayloadReceived(_ payload: AAContentPayload, ontoList list: String?) {
        let worked = { response, forRequest in
            AASDK.logDebugMessage("Payload Service Tracked delivery", type: AASDK_DEBUG_GENERAL)
        } as AAResponseWasReceivedBlock

        let failed = { response, forRequest, error in
        } as AAResponseWasErrorBlock

        let request = AAPayloadTrackingRequest(payloadDelivered: payload)

        _aasdk?.connector?.enqueueRequest(request, responseWasErrorBlock: failed, responseWasReceivedBlock: worked)
    }

    class func reportPayloadRejected(_ payload: AAContentPayload) {
        let worked = { response, forRequest in
            AASDK.logDebugMessage("Payload Service Tracked delivery REJECTION", type: AASDK_DEBUG_GENERAL)
        } as AAResponseWasReceivedBlock

        let failed = { response, forRequest, error in
        } as AAResponseWasErrorBlock

        let request = AAPayloadTrackingRequest(payloadRejected: payload)

        _aasdk?.connector?.enqueueRequest(request, responseWasErrorBlock: failed, responseWasReceivedBlock: worked)
    }

    class func cachedItem(matching string: String) -> AADetailedListItem? {
        return _aasdk?.payloadTrackers?[string] as? AADetailedListItem
    }

    class func cacheItem(_ item: AADetailedListItem) {
        _aasdk?.payloadTrackers?[item.productTitle] = item
    }

    class func uncacheItem(_ item: AADetailedListItem?) {
        if item != nil && item?.productTitle != nil {
            _aasdk?.payloadTrackers?.removeValue(forKey: item?.productTitle)
        }
    }

    class func postDelayedNotification(_ notification: Notification?) {
        //#D - does this get used properly? try break point
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            if let notification = notification {
                _aasdk?.notificationCenter.post(notification)
            }
        })
    }

    class func reportItem(_ itemName: String?, from contentPayload: AAContentPayload?) {
        var payload = [AnyHashable : Any](minimumCapacity: 4)
        payload["item_name"] = itemName ?? ""
        if let payloadType = contentPayload?.payloadType {
            payload["source"] = payloadType
        }

        let item = AASDK.cachedItem(matching: itemName ?? "")
        if let item = item {
            payload["tracking_id"] = item.trackingId
            payload["payload_id"] = item.payloadId
        }

        _aasdk?.connector?.addCollectableEvent(forDispatch: AACollectableEvent.internalEvent(withName: AA_EC_ADDIT_ADDED_TO_LIST, andPayload: payload))
    }
}
