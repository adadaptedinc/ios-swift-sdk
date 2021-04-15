//
//  AAHelper.swift
//  AASwiftSDK
//
//  Created by Brett Clifton on 9/21/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import AdSupport
import CommonCrypto
import CoreGraphics
import CoreTelephony
import Foundation
import UIKit
import CoreTelephony
import AppTrackingTransparency

// INITIALIZATION
let AA_KEY_ZONE_ID = "zone_id"
let AA_KEY_ZONES = "zones"

// app / user info
let AA_KEY_APP_ID = "app_id"
let AA_KEY_UDID = "udid"
let AA_KEY_BUNDLE_ID = "bundle_id"
let AA_KEY_SDK_BUNDLE_VERSION = "sdk_version"
let AA_KEY_ALLOW_RETARGETING = "allow_retargeting"

// device info
let AA_KEY_DEVICE_ID = "device_udid"
let AA_KEY_DEVICE_CARRIER_NAME = "device_carrier"

let AA_KEY_DEVICE_MODEL = "device_name"
let AA_KEY_DEVICE_HEIGHT = "device_height"
let AA_KEY_DEVICE_WIDTH = "device_width"
let AA_KEY_DEVICE_DENSITY = "device_density"
let AA_KEY_LOCALE = "device_locale"
let AA_KEY_OS_NAME = "device_os"
let AA_KEY_OS_VERSION = "device_osv"
let AA_KEY_TIMEZONE = "device_timezone"

// PARAMS USED FOR EC, PAYLOAD REQUESTS, ETC.
let AA_KEY_EVENT_DEVICE_MODEL = "device"
let AA_KEY_EVENT_DEVICE_HEIGHT = "dh"
let AA_KEY_EVENT_DEVICE_WIDTH = "dw"
let AA_KEY_EVENT_DEVICE_DENSITY = "density"
let AA_KEY_EVENT_LOCALE = "locale"
let AA_KEY_EVENT_OS_NAME = "os"
let AA_KEY_EVENT_OS_VERSION = "osv"
let AA_KEY_EVENT_TIMEZONE = "timezone"
let AA_KEY_EVENT_CARRIER = "carrier"

// from Generic Request
let AA_KEY_DATETIME = "created_at"
let AA_KEY_APP_INIT_PARAMS = "params"

let AA_KEY_ZONE_SIZE = "size"
let AA_KEY_LONGITUDE = "long"
let AA_KEY_LATITUDE = "lat"
let AA_KEY_AUDID = "audid"
let AA_KEY_SYS_DPI = "sys_dpi"
let AA_KEY_SUBJECT = "subject"
let AA_KEY_CONTEXT = "context"
let AA_KEY_COUNT = "count"

// init output
let AA_KEY_SESSION_ID = "session_id"
let AA_KEY_AD = "ad"
let AA_KEY_ADS = "ads"
let AA_KEY_AD_ID = "ad_id"
let AA_KEY_IMG_URL_1 = "img_url1"
let AA_KEY_IMG_DPI_1 = "img_dpi1"
let AA_KEY_IMG_URL_2 = "img_url2"
let AA_KEY_IMG_DPI_2 = "img_dpi2"
let AA_KEY_IMG_URL_3 = "img_url3"
let AA_KEY_IMG_DPI_3 = "img_dpi3"
let AA_KEY_IMG_URL_4 = "img_url4"
let AA_KEY_IMG_DPI_4 = "img_dpi4"
let AA_KEY_AD_TXT_1 = "ad_txt1"
let AA_KEY_ACTION_TYPE = "action_type"
let AA_KEY_ACTION_PATH = "action_path"
let AA_KEY_PRELOAD = "preload"
// new in 0.9
let AA_KEY_ZONE = "zone"
let AA_KEY_ZONE_HEIGHT = "zone_height"
let AA_KEY_ZONE_WIDTH = "zone_width"
let AA_KEY_REFRESH_INTERVAL = "refresh_time"
let AA_KEY_IMPRESSION_ID = "impression_id"

// events
let AA_KEY_EVENT_TYPE = "event_type"
let AA_KEY_EVENT_PATH = "event_path"
let AA_KEY_RESULT = "result"

// new popup behavior apr 2013
let AA_KEY_ALT_CLOSE = "alt_close_btn"
let AA_KEY_HIDE_BANNER = "hide_banner"
let AA_KEY_TITLE_TEXT = "title_text"
let AA_KEY_TEXT_COLOR = "text_color"
let AA_KEY_BACK_COLOR = "background_color"

let AA_KEY_HIDE_NAV = "hide_browser_nav"
let AA_KEY_HIDE_CLOSE = "hide_close_btn"
let AA_KEY_POPUP_TYPE = "type"
let AA_KEY_HIDE_AFTER_CLICK = "hide_after_interaction"
let AA_KEY_WILL_SERVE_ADS = "will_serve_ads"
let AA_KEY_AD_TYPE = "type"
let AA_KEY_AD_URL = "creative_url"
let AA_KEY_TRACKING_HTML = "tracking_html"

let AA_KEY_ZONE_PORT_WIDTH = "port_width"
let AA_KEY_ZONE_PORT_HEIGHT = "port_height"
let AA_KEY_ZONE_LAND_WIDTH = "land_width"
let AA_KEY_ZONE_LAND_HEIGHT = "land_height"

// new in 0.9.1
let AA_KEY_POLLING_INTERVAL = "polling_interval_ms"
let AA_KEY_START_TIME = "start_time"
let AA_KEY_END_TIME = "end_time"

// new 3/14
let AA_KEY_IMG_URL_LAND = "img_url_land"

//new for v3
let AA_KEY_SESSION_EXPIRES = "session_expires_at"
let AA_KEY_PAYLOAD = "payload"
let AA_KEY_TEST_MODE = "test_mode"
let AA_KEY_EVENT_NAME = "event_name"
let AA_KEY_SDK_BUNDLE_SHA = "sha"

// MARK: - Keyword Intercept
let AA_KEY_KI_SEARCH_ID = "search_id"
let AA_KEY_KI_MIN_MATCH_LENGTH = "min_match_length"
let AA_KEY_KI_REFRESH_TIME = "refresh_time"
let AA_KEY_KI_TERMS = "terms"
let AA_KEY_KI_TERM_ID = "term_id"
let AA_KEY_KI_TERM = "term"
let AA_KEY_KI_REPLACEMENT = "replacement"
let AA_KEY_KI_ICON = "icon"
let AA_KEY_KI_TAGLINE = "tagline"
let AA_KEY_KI_PRIORITY = "priority"
let AA_KEY_KI_USER_INPUT = "user_input"

// MARK: - Event Collection Service KEYS
let AA_KEY_EVENT_TIMESTAMP = "event_timestamp"
let AA_KEY_EVENT_PARAMS = "event_params"
let AA_KEY_EVENT_SOURCE = "event_source"
let AA_KEY_ERROR_CODE = "error_code"
let AA_KEY_ERROR_MESSAGE = "error_message"
let AA_KEY_ERROR_TIMESTAMP = "error_timestamp"
let AA_KEY_ERROR_PARAMS = "error_params"

// MARK: - Event Collection Service EVENTS
let AA_EC_APP_OPEN = "app_opened"
let AA_EC_APP_CLOSED = "app_closed"
let AA_EC_ATL_ADDED_TO_LIST = "atl_added_to_list"
let AA_EC_ATL_ADDED_TO_LIST_FAILED = "atl_added_to_list_failed"
let AA_EC_USER_ADDED_TO_LIST = "user_added_to_list"
let AA_EC_USER_CROSSED_OFF_LIST = "user_crossed_off_list"
let AA_EC_USER_DELETED_FROM_LIST = "user_deleted_from_list"
let AA_EC_ZONE_LOADED = "zone_loaded"
let AA_EC_ADDIT_ADDED_TO_LIST = "addit_added_to_list"
let AA_EC_ADDIT_APP_OPENED = "addit_app_opened"
let AA_EC_ADDIT_URL_RECEIVED = "deeplink_url_received"

// MARK: - Private
let kEventImpressionStarted = "impression"
let kEventInteraction = "interaction"
let kEventEvent = "event"
let kEventImpressionEnd = "impression_end"
let kEventPopupBegin = "popup_begin"
let kEventPopupEnd = "popup_end"
let kEventAppEnter = "app_enter"
let kEventAppExit = "app_exit"
let kEventCustomEvent = "custom"
let kEventAnomaly = "anomaly"

var _screenSize = CGSize.zero

extension String: Error {}

class AAHelper: NSObject {
    class func buildVersion() -> String? {
        return Bundle(identifier: "com.adadapted.AASwiftSDK")?.infoDictionary!["CFBundleShortVersionString"] as? String
    }
    
    class func currentTimezone() -> String? {
        let zone = NSTimeZone.local as NSTimeZone
        return zone.name
    }

    class func deviceCarrier() -> String? {
        let info = CTTelephonyNetworkInfo()
        let carrier = info.subscriberCellularProvider
        return carrier?.carrierName
    }
    
    class func nowAsUTC() -> String? {
        return String(format: "%.0f", Date().timeIntervalSince1970 * 1000)
    }

    class func nowAsUTCNumber() -> NSNumber? {
        let value = NSNumber(value: Date().timeIntervalSince1970)
        return NSNumber(value: value.intValue)
    }

    class func nowAsUTCLong() -> Int {
        return NSNumber(value: Date().timeIntervalSince1970).intValue * 1000
    }

    class func actionString(forInt type: AASDKActionType) -> String? {
        switch type {
        case AASDKActionType.kActionLink:
                return "l"
        case AASDKActionType.kActionAppDownload:
                return "a"
        case AASDKActionType.kActionPopup:
                return "p"
        case AASDKActionType.kActionNone:
                return "n"
        case AASDKActionType.kActionContent:
                return "c"
        case AASDKActionType.kActionDelegate:
                return "d"
        }
    }

    class func actionType(from string: String?) -> AASDKActionType {
        if string == "l" || string == "e" {
            return AASDKActionType.kActionLink
        } else if string == "a" {
            return AASDKActionType.kActionAppDownload
        } else if string == "p" {
            return AASDKActionType.kActionPopup
        } else if string == "n" {
            return AASDKActionType.kActionNone
        } else if string == "d" {
            return AASDKActionType.kActionDelegate
        } else if string == "c" {
            return AASDKActionType.kActionContent
        }

        print("bad action type string requested '\(string ?? "")' - should be found in AASDKActionType: taking no action")
        return AASDKActionType.kActionNone
    }

    class func string(for type: AAEventType) -> String? {
        switch type {
        case AAEventType.aa_EVENT_EVENT:
                return kEventEvent
        case AAEventType.aa_EVENT_INTERACTION:
                return kEventInteraction
        case AAEventType.aa_EVENT_IMPRESSION_STARTED:
                return kEventImpressionStarted
        case AAEventType.aa_EVENT_IMPRESSION_END:
                return kEventImpressionEnd
        case AAEventType.aa_EVENT_POPUP_BEGIN:
                return kEventPopupBegin
        case AAEventType.aa_EVENT_POPUP_END:
                return kEventPopupEnd
        case AAEventType.aa_EVENT_APP_ENTER:
                return kEventAppEnter
        case AAEventType.aa_EVENT_APP_EXIT:
                return kEventAppExit
        case AAEventType.aa_EVENT_CUSTOM_EVENT:
                return kEventCustomEvent
        case AAEventType.aa_EVENT_ANOMALY:
                return kEventAnomaly
        }
    }
    
    class func storeCurrentSessionId(sessionId: String?) {
        let preferences = UserDefaults.standard
        preferences.set(sessionId, forKey: AASDK_SESSION_ID_KEY)
        preferences.synchronize()
    }
    
    class func getCurrentSessionId() -> String {
        let preferences = UserDefaults.standard
        if preferences.object(forKey: AASDK_SESSION_ID_KEY) == nil {
            return "00000000-0000-0000-0000-000000000000"
        } else {
            return preferences.value(forKey: AASDK_SESSION_ID_KEY) as! String
        }
    }
    
    // checks if IDFA tracking is disabled
    class func isTrackingDisabled() -> Bool {
        let preferences = UserDefaults.standard
        if preferences.object(forKey: AASDK_TRACKING_DISABLED_KEY) == nil {
            return false
        } else {
            return preferences.value(forKey: AASDK_TRACKING_DISABLED_KEY) as! Bool
        }
    }

    // Grabs the IDFA if enabled otherwise uses the current session ID
    class func udid() -> String? {
        if (isTrackingDisabled()) {
            return getCurrentSessionId()
        } else {
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }
    }

    // Checking if ad tracking is enabled on the device
    class func isAdTrackingEnabled() -> Bool {
        if #available(iOS 14, *) {
            return ATTrackingManager.trackingAuthorizationStatus == .authorized
        } else {
            return ASIdentifierManager.shared().isAdvertisingTrackingEnabled
        }
    }

    class func safeColor(fromHexString str: String?, fallbackHexString fallback: String?) -> UIColor? {
        var color: UIColor?
        if #available(iOS 11.0, *) {
            color = UIColor(named: str!)
        } else {
            color = hexStringToUIColor(hex: str!)
        }
        return color
    }
    
    class func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    class func bundleID() -> String? {
        return Bundle(identifier: "com.adadapted.AASwiftSDK")?.bundleIdentifier
    }
    
    class func deviceModelName() -> String {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] { return simulatorModelIdentifier }
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }

    class func deviceIdentifier() -> String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }

    class func deviceOS() -> String? {
        return "iPhone OS"
    }

    class func deviceOSVersion() -> String? {
        return UIDevice.current.systemVersion
    }

    class func deviceLocale() -> String? {
        return NSLocale.preferredLanguages[0]
    }

    class func screenSize() -> CGSize {
        if _screenSize.height == 0.0 {
            let screenBounds = UIScreen.main.bounds
            let screenScale = UIScreen.main.scale
            _screenSize = CGSize(width: screenBounds.size.width * screenScale, height: screenBounds.size.height * screenScale)
        }
        return _screenSize
    }

    class func deviceWidth() -> String? {
        return String(format: "%4.0f", AAHelper.screenSize().width)
    }

    class func deviceHeight() -> String? {
        return String(format: "%4.0f", AAHelper.screenSize().height)
    }

    class func deviceScreenDensity() -> String? {
        let scaleFactor = Float(UIScreen.main.scale)
        return String(format: "%0.0f", scaleFactor)
    }

    class func deviceWidthNumber() -> NSNumber? {
        return NSNumber(value: Int32(Int(AAHelper.screenSize().width)))
    }

    class func deviceHeightNumber() -> NSNumber? {
        return NSNumber(value: Int32(Int(AAHelper.screenSize().height)))
    }

    class func deviceScreenDensityNumber() -> NSNumber? {
        return NSNumber(value: Int32(Int(UIScreen.main.scale)))
    }

    class func setImageFor(_ imageView: UIImageView?, from url: URL?) {
        if let url = url {
            URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
                if error == nil {
                    DispatchQueue.main.async(execute: {
                        if let data = data {
                            imageView?.image = UIImage(data: data)
                        }
                    })
                }
            }).resume()
        }
    }
    
    class func universalLinkContentParser(_ userActivity: NSUserActivity?, connector: AAConnector?) {
        connector?.addCollectableEvent(forDispatch: AACollectableEvent.internalEvent(withName: AA_EC_ADDIT_APP_OPENED, andPayload: [:]))

        var retArray = [AnyHashable]()
        do {
            let url = userActivity?.webpageURL?.absoluteString
            let params = [
                "url": url ?? ""
            ]
            if url == nil {
                connector?.addCollectableError(forDispatch: AACollectableError(code: ADDIT_NO_DEEPLINK_RECEIVED, message: "Did not receive a universal link url.", params: params))
                return
            }
            
            if (!url!.contains(AA_UNIVERSAL_LINK_ROOT)) {
                return
            }

            connector?.addCollectableEvent(forDispatch: AACollectableEvent.internalEvent(withName: AA_EC_ADDIT_URL_RECEIVED, andPayload: params))
            let components = NSURLComponents(string: url ?? "")
            for item in components?.queryItems ?? [] {
                if item.name == "data" {
                    let decodedData = Data(base64Encoded: item.value ?? "", options: [])
                    var json: Any? = nil
                    do {
                        if let decodedData = decodedData {
                            json = try JSONSerialization.jsonObject(with: decodedData, options: [])
                        }
                    } catch {
                        ReportManager.getInstance().reportAnomaly(withCode: CODE_UNIVERSAL_LINK_PARSE_ERROR, message: url, params: nil)
                    }
                    let payload = AAContentPayload.parse(fromDictionary: json as? [AnyHashable : Any])
                    payload!.payloadType = "universal-link"
                    if let payload = payload {
                        retArray.append(payload as AnyHashable)
                    }
                }
            }
        }

        let userInfo = [
            AASDK.KEY_MESSAGE: "Returning universal link payload item",
            AASDK.KEY_CONTENT_PAYLOADS: retArray
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
            NotificationCenterWrapper.notifier.post(notification)
        }
    }
}
