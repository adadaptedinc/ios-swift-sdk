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

// MARK: - Static initializer enforces singleton
var _aasdk: AASDK?
var _currentState: AASDKState?
var cacheEventName: String?
var imagesToLoad = 0
var imagesLoaded = 0
var lastCame: Date?

@objc public class AASDK: NSObject {
    @objc public static let OPTION_TEST_MODE = "TEST_MODE"
    @objc public static let OPTION_KEYWORD_INTERCEPT = "KEYWORD_INTERCEPT"
    @objc public static let KEY_CONTENT_PAYLOADS = "CONTENT_PAYLOADS"
    @objc public static let KEY_AD_CONTENT = "AD_CONTENT"
    @objc public static let KEY_KI_REPLACEMENT_TEXT = "KI_REPLACEMENT_TEXT"
    @objc public static let KEY_ZONE_VIEW = "ZONE_VIEW"
    
    /// Log types to pass into registerDebugListenersFor:forMessageTypes:
    @objc public static let DEBUG_GENERAL = "GENERAL"
    @objc public static let DEBUG_NETWORK = "NETWORK"
    @objc public static let DEBUG_NETWORK_DETAILED = "NETWORK_DETAILED"
    @objc public static let DEBUG_USER_INTERACTION = "USER_INTERACTION"
    @objc public static let DEBUG_AD_LAYOUT = "AD_LAYOUT"
    @objc public static let DEBUG_ALL = "ALL"
    
    /// keys used to report details in NSNotifications
    @objc public static let KEY_ZONE_ID = "ZONE_ID"
    @objc public static let KEY_ZONE_IDS = "ZONE_IDS"
    @objc public static let KEY_ZONE_COUNT = "ZONE_COUNT"
    @objc public static let KEY_MESSAGE = "MESSAGE"
    @objc public static let KEY_TYPE = "TYPE"
    @objc public static let KEY_RECOVERY_SUGGESTION = "RECOVERY_SUGGESTION"
    
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
    private var isKeywordInterceptOn = false
    private var kiManager: AAKeywordInterceptManager?
    private var impressionCounters: [AnyHashable : Any]?
    private var payloadTrackers: [AnyHashable : Any]?
    private var lastPayloadCheck: Date?
    private var appInitParams: [AnyHashable : Any]?
    
// MARK: - notfications
    @objc public class func registerListeners(for observer: AASDKObserver?) {
        if observer == nil {
            return
        } else {
            Registrar.addListeners(observer: observer!)
        }
    }

    @objc public class func removeListeners(for observer: AASDKObserver?) {
        if observer == nil {
            return
        } else {
            Registrar.clearListeners(observer: observer!)
        }
    }

    @objc public class func registerContentListeners(for delegate: AASDKContentDelegate?) {
        if delegate == nil {
            return
        } else {
            Registrar.addContentListeners(delegate: delegate!)
        }
    }

    @objc public class func removeContentListeners(for delegate: AASDKContentDelegate?) {
        if delegate == nil {
            return
        } else {
            Registrar.clearContentListeners(delegate: delegate!)
        }
    }

// MARK: - ready
    class func isReadyForUse() -> Bool {
        if _aasdk?.appID == nil || (_aasdk?.appID?.count ?? 0) == 0 {
            return false
        }
        return _currentState == AASDKState.kIdle
    }

// MARK: - start session w/ server
    @objc public class func startSession(
        withAppID appID: String?,
        registerListenersFor observer: AASDKObserver?,
        options opDic: [AnyHashable : Any]?
    ) {
        initializeSDK()
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

        DispatchQueue.global(qos: .default).async(execute: {
            //Background Thread
            AASDK.privateStartSession(
                withAppID: appID,
                registerListenersFor: observer,
                options: opDic)
        })
    }

    class func setDeviceLocation(_ location: CLLocation?) {
        if let location = location {
            AASDK.logDebugMessage("AASDK location set \(location.coordinate.latitude) \(location.coordinate.longitude)", type: DEBUG_GENERAL)
            _aasdk?.deviceLocation = location
        } else {
            AASDK.logDebugMessage("Location set to nil", type: DEBUG_GENERAL)
            _aasdk?.deviceLocation = nil
        }
    }

// MARK: - Public event reporting
    @objc public class func reportItem(_ itemName: String, addedToList: String?) {
        ReportManager.getInstance().reportItemInteraction(itemName, itemList: addedToList, eventName: AA_EC_USER_ADDED_TO_LIST)
    }

    @objc public class func reportItem(_ itemName: String, crossedOffList: String?) {
        ReportManager.getInstance().reportItemInteraction(itemName, itemList: crossedOffList, eventName: AA_EC_USER_CROSSED_OFF_LIST)
    }

    @objc public class func reportItem(_ itemName: String, deletedFromList: String?) {
        ReportManager.getInstance().reportItemInteraction(itemName, itemList: deletedFromList, eventName: AA_EC_USER_DELETED_FROM_LIST)
    }

    @objc public class func reportItems(_ items: [String]?, addedToList list: String?) {
        for string in items ?? [] {
            AASDK.reportItem(string, addedToList: list)
        }
        do {
            for string in items ?? [] {
                AASDK.reportItem(string, addedToList: list)
            }
        }
    }
    
    @objc public class func reportItems(_ items: [String], crossedOffList list: String?) {
        for itemName in items {
            AASDK.reportItem(itemName, crossedOffList: list)
        }
    }

    @objc public class func reportItems(_ items: [String], deletedFromList list: String?) {
        for itemName in items {
            AASDK.reportItem(itemName, deletedFromList: list)
        }
    }

// MARK: - programatic layout conveniences
    class func sizeOfZone(_ zoneId: String?) -> CGSize {
        return AASDK.sizeOfZone(zoneId, for: UIApplication.shared.statusBarOrientation)
    }

    class func sizeOfZone(_ zoneId: String?, for orientation: UIInterfaceOrientation) -> CGSize {
        let zone = _aasdk?.zones?[zoneId ?? ""] as? AAAdZone
        if let zone = zone {
            return zone.adSizeforOrientation(orientation)
        }
        return CGSize(width: 0, height: 0)
    }

    class func boundsOfZone(_ zoneId: String?, for orientation: UIInterfaceOrientation) -> CGRect {
        let zone = _aasdk?.zones?[zoneId ?? ""] as? AAAdZone
        if let zone = zone {
            return zone.adBoundsforOrientation(orientation)
        }
        return CGRect(x: 0, y: 0, width: 0, height: 0)
    }

    class func supportedInterfaceOrientations(forZone zoneId: String?) -> UIInterfaceOrientationMask {
        let zone = _aasdk?.zones?[zoneId ?? ""] as? AAAdZone
        if let zone = zone {
            return zone.supportedInterfaceOrientations()
        }
        return .portrait
    }

// MARK: - cacheInfo
    @objc public class func availableZoneIDs() -> [AnyHashable] {
        let zones = _aasdk?.zones
        var zoneKeys = [AnyHashable]()
        if ((zones != nil) || zones!.isEmpty == false) {
            for key in zones!.keys {
                zoneKeys.append(key)
            }
        }
        return zoneKeys
    }

    @objc public class func zoneAvailable(_ zoneId: String?) -> Bool {
        let zone = _aasdk?.zones?[zoneId ?? ""] as? AAAdZone
        if zone != nil && zone?.hasAdsAvailable != nil {
            return zone?.isCacheComplete ?? false
        } else {
            return false
        }
    }
    
    @objc public class func disableAdTracking() {
        let preferences = UserDefaults.standard
        preferences.set(true, forKey: AASDK_TRACKING_DISABLED_KEY)
        preferences.synchronize()
    }
    
    @objc public class func enableAdTracking() {
        let preferences = UserDefaults.standard
        preferences.set(false, forKey: AASDK_TRACKING_DISABLED_KEY)
        preferences.synchronize()
    }

// MARK: - debugging
    @objc public class func registerDebugListeners(for observer: AASDKDebugObserver?, forMessageTypes types: [AnyHashable]?) {
        if observer == nil {
            return
        }
        _aasdk?.debugObserver = observer
        _aasdk?.userDebugMessageTypes = types
        Registrar.addDebugListeners(observer: observer!)
    }

    /// \brief removes only the debug observer
    @objc public class func removeDebugListener() {
        if _aasdk?.debugObserver != nil {
            if let debugObserver1 = _aasdk?.debugObserver {
                NotificationCenterWrapper.notifier.removeObserver(
                    debugObserver1,
                    name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_DEBUG_MESSAGE),
                    object: nil)
            }
            _aasdk?.debugObserver = nil
            _aasdk?.userDebugMessageTypes = []
        }
    }
   
// MARK: - Keyword Intercept
    @objc public class func keywordIntercept(for userInput: String?) -> [AnyHashable : Any]? {
        if _aasdk?.kiManager != nil {
            return _aasdk?.kiManager?.matchUserInput(userInput)
        }
        return nil
    }
    
    @objc public class func keywordInterceptPresented() {
        if _aasdk?.kiManager != nil {
            _aasdk?.kiManager?.reportPresented()
        }
    }

    @objc public class func keywordInterceptSelected() {
        if _aasdk?.kiManager != nil {
            _aasdk?.kiManager?.reportSelected()
        }
    }

// MARK: - Universal Link
    @objc public class func linkContentParser(_ userActivity: NSUserActivity?) {
        AAHelper.universalLinkContentParser(userActivity, connector: _aasdk?.connector)
    }

// MARK: - get Ad inside session from server

    static var initialized = false

    internal static func initializeSDK() {
        if !AASDK.initialized {
            AASDK.initialized = true
            _aasdk = AASDK()
            _aasdk?.appID = nil
            _aasdk?.connector = AAConnector()
            _aasdk?.currentlyDisplayedAds = [AnyHashable](repeating: 0, count: 10)
            _aasdk?.zones = [AnyHashable : Any](minimumCapacity: 3)
            _aasdk?.impressionCounters = [AnyHashable : Any](minimumCapacity: 10)
            _aasdk?.userDebugMessageTypes = []
            _aasdk?.rootURLString = AA_PROD_ROOT
            _aasdk?.pollingIntervalInMS = 600000
            _aasdk?.updateTimerLastFired = AAHelper.nowAsUTCLong() / 1000
            _aasdk?.unloadAdAfterOne = false
            _currentState = .kUninitialized
            _aasdk?.disableAdvertising = false
            _aasdk?.isKeywordInterceptOn = false
            _aasdk?.serverRoot = AA_PROD_ROOT
            _aasdk?.serverVersion = AA_API_VERSION
            _aasdk?.payloadTrackers = [AnyHashable : Any](minimumCapacity: 0)
            _aasdk?.appInitParams = nil
            
            initializeComponents()
        }
    }
    
    private class func initializeComponents() {
        ReportManager.createInstance(connector: AAConnector())
        NotificationCenterWrapper.createInstance(notificationCenter: NotificationCenter())
    }

// MARK: - Public start session
    class func privateStartSession(
        withAppID appID: String?,
        registerListenersFor observer: AASDKObserver?,
        options opDic: [AnyHashable : Any]?
    ) {
        if _currentState == .kInitializing {
            return
        }

        if _currentState == .kOffline {
            _currentState = .kErrorState
            let userInfo = [
                KEY_MESSAGE: "AASDK ERROR - internet connection not available. Aborting init() attempt.",
                KEY_RECOVERY_SUGGESTION: "Re-connecting to internet will make SDK automatically come back online."
            ]

            let notification = Notification(name: Notification.Name(rawValue: AASDK_NOTIFICATION_ERROR), object: nil, userInfo: userInfo)
            AASDK.postDelayedNotification(notification)
            return
        }

        _currentState = .kInitializing

        // Extracting options
        if opDic != nil {
            let useCached = opDic?[AASDK_OPTION_USE_CACHED_IMAGES] as? NSNumber
            if let useCached = useCached {
                _aasdk!.shouldUseCachedImages = useCached.boolValue
            }

            let testMode = opDic?[OPTION_TEST_MODE] as? NSNumber
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

            _aasdk?.setupTestMode(forOptionalVersion: opDic?[AASDK_OPTION_TEST_MODE_API_VERSION] as? String)

            let ignoreZones = opDic?[AASDK_OPTION_IGNORE_ZONES] as? [AnyHashable]
            if ignoreZones != nil && (ignoreZones?.count ?? 0) > 0 {
                if let ignoreZones = ignoreZones {
                    _aasdk?.zonesToIgnore = ignoreZones
                }
            }

            /// "PRIVATE" PARAMS
            let customPopupTarget = opDic?[AASDK_OPTION_PRIVATE_CUSTOM_POPUP_TARGET] as? String
            if customPopupTarget != nil && (customPopupTarget?.count ?? 0) > 0 {
                AASDK.logDebugMessage("PRIVATE - Using custom popup URL \(customPopupTarget ?? "")", type: DEBUG_GENERAL)
                _aasdk?.customPopupURL = customPopupTarget
            }

            let customAdTarget = opDic?[AASDK_OPTION_PRIVATE_CUSTOM_WEBVIEW_AD] as? String
            if customAdTarget != nil && (customAdTarget?.count ?? 0) > 0 {
                AASDK.logDebugMessage("PRIVATE - Using custom Ad URL \(customAdTarget ?? "")", type: DEBUG_GENERAL)
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

            _aasdk?.isKeywordInterceptOn = (opDic?[OPTION_KEYWORD_INTERCEPT] ?? false) as! Bool
            _aasdk?.appInitParams = opDic?[AASDK_OPTION_INIT_PARAMS] as? [AnyHashable : Any]
        }

        _aasdk?.stopUpdateTimer()

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
                Logger.consoleLogError(error, withMessage: "init", suppressTracking: true)
            }

            var userInfo: [String : String]? = nil
            if let description = error?.localizedDescription {
                userInfo = [
                    KEY_MESSAGE: "AASDK ERROR start session returned: \(description)",
                    KEY_RECOVERY_SUGGESTION: "RECOVERY suggestion -> \((error! as NSError).localizedRecoverySuggestion ?? "")"
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
                _aasdk?.kiManager = AAKeywordInterceptManager(connector: _aasdk?.connector, minMatchLength: initResponse!.minMatchLength)
                AASDK.logDebugMessage("Loading Keyword Intercepts", type: DEBUG_GENERAL)
                _aasdk?.kiManager?.loadKeywordIntercepts(initResponse?.keywordIntercepts)
            } as AAResponseWasReceivedBlock

            let keywordInitResponseWasErrorBlock = { response, forRequest, error in
                var userInfo: [String : String]? = nil
                if let description = error?.localizedDescription {
                    userInfo = [
                        KEY_MESSAGE: "AASDK ERROR keyword intercept / INIT returned: \(description)",
                        KEY_RECOVERY_SUGGESTION: "RECOVERY suggestion -> \((error as NSError?)?.localizedRecoverySuggestion ?? "")"
                    ]
                }
                let notification = Notification(name: Notification.Name(rawValue: AASDK_NOTIFICATION_ERROR), object: nil, userInfo: userInfo)
                AASDK.postDelayedNotification(notification)
            } as AAResponseWasErrorBlock

            _aasdk?.connector?.enqueueRequest(keywordInitRequest, responseWasErrorBlock: keywordInitResponseWasErrorBlock, responseWasReceivedBlock: keywordInitResponseWasReceivedBlock)
        }
    }

// MARK: - Private instance methods
    class func currentState() -> AASDKState {
        return _currentState!
    }

    func cacheAds(inAdsDic ads: [AnyHashable : Any]?, completeNotificationName name: String?, shouldUseCachedImages useCached: Bool, shouldReplaceCurrent shouldReplace: Bool) {
        cacheEventName = name
        AASDK.logDebugMessage("Caching ads for zones", type: AASDK.DEBUG_GENERAL)

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
        AASDK.logDebugMessage("Cache completed", type: AASDK.DEBUG_GENERAL)

        let info = [
            AASDK.KEY_ZONE_IDS: zones!,
            AASDK.KEY_ZONE_COUNT: NSNumber(value: zones?.count ?? 0)
        ] as [String : Any]

        let notification = Notification(name: NSNotification.Name(cacheEventName!), object: nil, userInfo: info)

        AASDK.postDelayedNotification(notification)
    }

// MARK: - Async loading Listeners
    func addCacheListeners() {
        NotificationCenterWrapper.notifier.addObserver(
            self,
            selector: #selector(startLoadingImage(_:)),
            name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_WILL_LOAD_IMAGE),
            object: nil)

        NotificationCenterWrapper.notifier.addObserver(
            self,
            selector: #selector(doneLoadingImage(_:)),
            name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_DID_LOAD_IMAGE),
            object: nil)

        NotificationCenterWrapper.notifier.addObserver(
            self,
            selector: #selector(failedLoadingImage(_:)),
            name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_FAILED_LOAD_IMAGE),
            object: nil)
    }

    func removeCacheListeners() {
        NotificationCenterWrapper.notifier.removeObserver(self, name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_WILL_LOAD_IMAGE), object: nil)
        NotificationCenterWrapper.notifier.removeObserver(self, name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_DID_LOAD_IMAGE), object: nil)
        NotificationCenterWrapper.notifier.removeObserver(self, name: NSNotification.Name(rawValue: AASDK_NOTIFICATION_FAILED_LOAD_IMAGE), object: nil)
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
        if now > (_aasdk?.sessionExpiresAtUTC ?? 0) {
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

        AASDK.logDebugMessage("Grabbing updated ads for zones", type: AASDK.DEBUG_GENERAL)

        let request = AAUpdateAdsRequest()

        let responseWasReceivedBlock = { [self] response, forRequest in
            let updateResponse = response as? AAUpdateAdsResponse
            pollingIntervalInMS = updateResponse?.pollingIntervalInMS ?? 0
            checkIfReCacheNeeded(updateResponse?.zones)
        } as AAResponseWasReceivedBlock

        let responseWasErrorBlock = { response, forRequest, error in
            _currentState = .kErrorState
            if _aasdk?.observer == nil {
                Logger.consoleLogError(error, withMessage: "update/ads", suppressTracking: true)
            }

            var userInfo: [String : String]? = nil
            if let description = error?.localizedDescription {
                userInfo = [
                    AASDK.KEY_MESSAGE: "AASDK ERROR Update Ads returned: \(description)",
                    AASDK.KEY_RECOVERY_SUGGESTION: "RECOVERY suggestion -> \((error as NSError?)?.localizedRecoverySuggestion ?? "")"
                ]
            }

            let notification = Notification(name: Notification.Name(rawValue: AASDK_NOTIFICATION_ERROR), object: nil, userInfo: userInfo)

            AASDK.postDelayedNotification(notification)
        } as AAResponseWasErrorBlock

        _aasdk?.connector?.enqueueRequest(request, responseWasErrorBlock: responseWasErrorBlock, responseWasReceivedBlock: responseWasReceivedBlock)

    }

    func checkIfReCacheNeeded(_ zones: [AnyHashable : Any]?) {
        if !((zones as NSDictionary?)?.isEqual(self.zones) ?? false) {
            AASDK.logDebugMessage("new ad Dictionary doesn't match old one: UPDATE CACHE starting", type: AASDK.DEBUG_NETWORK)
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
                Logger.consoleLogError(error, withMessage: "session/reinit", suppressTracking: true)
            }

            var userInfo: [String : String]? = nil
            if let description = error?.localizedDescription {
                userInfo = [
                    AASDK.KEY_MESSAGE: "AASDK ERROR reinit session returned: \(description)",
                    AASDK.KEY_RECOVERY_SUGGESTION: "RECOVERY suggestion -> \((error as NSError?)?.localizedRecoverySuggestion ?? "")"
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

    class func deviceLocationOrNil() -> CLLocation? {
        return _aasdk?.deviceLocation
    }

// MARK: - endpoint
    class func serverRoot() -> String {
        return "\(_aasdk?.serverRoot ?? "")/\(_aasdk?.serverVersion ?? "")/ios"
    }

    class func eventCollectionServerRoot() -> String {
        if AASDK.inTestMode() {
            return EVENT_COLLECTION_SERVER_ROOT_TEST
        } else {
            return EVENT_COLLECTION_SERVER_ROOT_PROD
        }
    }

    class func payloadServiceServerRoot() -> String {
        if AASDK.inTestMode() {
            return PAYLOAD_SERVICE_SERVER_ROOT_TEST
        } else {
            return PAYLOAD_SERVICE_SERVER_ROOT_PROD
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

// MARK: - debug logging
    class func logDebugMessage(_ message: String?, type: String?) {
        if _aasdk?.userDebugMessageTypes?.count == 0 {
            return
        }

        if _aasdk?.userDebugMessageTypes?.contains(DEBUG_ALL) ?? false || _aasdk?.userDebugMessageTypes?.contains(type ?? "") ?? false {
            Logger.dispatchMessage(message, ofType: type)
        }
    }

    class func logDebugFrame(_ frame: CGRect, message: String?) {
        if _aasdk?.userDebugMessageTypes?.count == 0 {
            return
        }

        if _aasdk?.userDebugMessageTypes?.contains(DEBUG_ALL) ?? false || _aasdk?.userDebugMessageTypes?.contains(DEBUG_AD_LAYOUT) ?? false {
            Logger.dispatchMessage("\(message ?? "")", ofType: DEBUG_AD_LAYOUT)
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
        AASDK.logDebugMessage(String(format: "Enqueued START tracking for %lu ads", displayedImagesCount), type: DEBUG_NETWORK)
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
        AASDK.logDebugMessage(String(format: "Enqueued END tracking for %lu ads", displayedImagesCount), type: DEBUG_NETWORK)
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
        ReportManager.getInstance().reportAnomaly(withCode: CODE_HIDDEN_INTERACTION, message: nil, params: AASDK.params(for: ad, andDic: nil))
    }

    class func trackAnomalyAdImgLoad(_ ad: AAAd?, urlString url: String?, message: String?) {
        ReportManager.getInstance().reportAnomaly(withCode: CODE_AD_IMAGE_LOAD_FAILED, message: message, params: AASDK.params(for: ad, andDic: ["url": url ?? ""]))
    }

    class func trackAnomalyAdURLLoad(_ ad: AAAd?, urlString url: String?, message: String?) {
        ReportManager.getInstance().reportAnomaly(withCode: CODE_AD_URL_LOAD_FAILED, message: message, params: AASDK.params(for: ad, andDic: ["url": url ?? ""]))
    }

    class func trackAnomalyAdPopupURLLoad(_ ad: AAAd?, urlString url: String?, message: String?) {
        ReportManager.getInstance().reportAnomaly(withCode: CODE_POPUP_URL_LOAD_FAILED, message: message, params: AASDK.params(for: ad, andDic: ["url": url ?? ""]))
    }

    class func trackAnomalyAdConfiguration(_ ad: AAAd?, message: String?) {
        ReportManager.getInstance().reportAnomaly(withCode: CODE_AD_CONFIG_ERROR, message: message, params: AASDK.params(for: ad, andDic: nil))
    }

    class func trackAnomalyZoneConfiguration(_ zone: AAAdZone?, message: String?) {
        if let zoneId = zone?.zoneId {
            ReportManager.getInstance().reportAnomaly(withCode: CODE_ZONE_CONFIG_ERROR, message: message, params: ["zone_id": zoneId])
        }
    }

    class func trackAnomalyWithHTMLTracker(for ad: AAAd?, message: String?) {
        ReportManager.getInstance().reportAnomaly(withCode: CODE_HTML_TRACKING_ERROR, message: message, params: AASDK.params(for: ad, andDic: nil))
    }

    class func trackAnomalyGenericErrorMessage(_ message: String?, optionalAd ad: AAAd?) {
        ReportManager.getInstance().reportAnomaly(withCode: CODE_ERROR, message: message, params: AASDK.params(for: ad, andDic: nil))
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
        let name = content?[KEY_TYPE] as? String
        let contentType = "list_items"
        var dic: [AnyHashable : Any]?

        AASDK.logDebugMessage("AASDK: deliverContent:fromAd:andZoneView enter", type: DEBUG_USER_INTERACTION)

        if content == nil {
            var message: String? = nil
            if let adID = ad?.adID {
                message = "Ad \(adID) content payload empty - no action taken"
            }
            Logger.consoleLogError(nil, withMessage: message, suppressTracking: true)
            AASDK.trackAnomalyAdConfiguration(ad, message: message)
            return
        }

        if name == nil || (name?.count ?? 0) == 0 {
            let adContent = AdContent.parse(fromDictionary: content, ad: ad ?? nil)

            if let zoneId = ad?.zoneId, let zoneView = zoneView, let adContent = adContent {
                dic = [
                    KEY_TYPE: contentType,
                    KEY_ZONE_ID: zoneId,
                    KEY_ZONE_VIEW: zoneView,
                    AASDK.KEY_AD_CONTENT: adContent
                ]
            }
        } else {
            dic = content
        }

        let notification = Notification(
            name: Notification.Name(rawValue: AASDK_NOTIFICATION_CONTENT_DELIVERY),
            object: nil,
            userInfo: dic)

        AASDK.logDebugMessage("AASDK: deliverContent:fromAd:andZoneView posting content event", type: DEBUG_USER_INTERACTION)
        NotificationCenterWrapper.notifier.post(notification)
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
        ReportManager.getInstance().reportAcknowledgeItem(item, addedToList: list, from: ad, eventName: AA_EC_ATL_ADDED_TO_LIST)
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
        ReportManager.getInstance().reportInternalEvent(eventName: AA_EC_ZONE_LOADED, payload: payload)
    }

    class func reportAddToListFailure(withMessage message: String?, from ad: AAAd) {
        ReportManager.getInstance().reportAnomaly(withCode: CODE_ATL_FAILURE, message: message, params: ["ad_id": ad.adID!])
    }

// MARK: - Internal NSNotificationCenter
    class func checkForPayloads() {
        if _aasdk?.lastPayloadCheck != nil && (abs(Int(_aasdk?.lastPayloadCheck?.timeIntervalSinceNow ?? 0)) < Int(minPayloadIntervalSec)) {
            return
        }
        _aasdk?.lastPayloadCheck = Date()

        let worked = { response, forRequest in
            let pickupResponse = response as? AAPayloadPickupResponse

            AASDK.logDebugMessage("Payload Service replied", type: DEBUG_GENERAL)

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
                        KEY_MESSAGE: "Returning \(Int(pickupResponse?.payloads?.count ?? 0)) payload items",
                        KEY_CONTENT_PAYLOADS: payloads.description
                    ]
                }
                let notification = Notification(name: Notification.Name(rawValue: AASDK_NOTIFICATION_CONTENT_PAYLOADS_INBOUND), object: nil, userInfo: userInfo)

                do {
                    if let payloads = pickupResponse?.payloads {
                        for payload in payloads {
                            guard let payload = payload as? AAContentPayload else {
                                AASDK.logDebugMessage("caught fatal error with payload parsing", type: DEBUG_GENERAL)
                                continue
                            }
                            for item in payload.detailedListItems {
                                AASDK.cacheItem(item)
                            }
                        }
                    }

                    NotificationCenterWrapper.notifier.post(notification)
                }
            }
        } as AAResponseWasReceivedBlock

        let failed = { response, forRequest, error in
            var userInfo: [String : String]? = nil
            if let description = error?.localizedDescription {
                userInfo = [
                    KEY_MESSAGE: "AASDK ERROR Payload Service pickup returned: \(description)",
                    KEY_RECOVERY_SUGGESTION: "RECOVERY suggestion -> \((error as NSError?)?.localizedRecoverySuggestion ?? "")"
                ]
            }
            let notification = Notification(name: Notification.Name(rawValue: AASDK_NOTIFICATION_ERROR), object: nil, userInfo: userInfo)
            NotificationCenterWrapper.notifier.post(notification)
        } as AAResponseWasErrorBlock

        let request = AAPayloadPickupRequest()

        _aasdk?.connector?.enqueueRequest(request, responseWasErrorBlock: failed, responseWasReceivedBlock: worked)
    }

    class func reportPayloadReceived(_ payload: AAContentPayload) {
        ReportManager.getInstance().reportPayloadReceived(payload)
    }

    class func reportPayloadRejected(_ payload: AAContentPayload) {
        ReportManager.getInstance().reportPayloadRejected(payload)
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
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            if let notification = notification {
                NotificationCenterWrapper.notifier.post(notification)
            }
        })
    }

    class func reportItem(_ itemName: String?, from contentPayload: AAContentPayload?) {
        ReportManager.getInstance().reportItemInteractionFromPayload(itemName, from: contentPayload, eventName: AA_EC_ADDIT_ADDED_TO_LIST)
    }
}
