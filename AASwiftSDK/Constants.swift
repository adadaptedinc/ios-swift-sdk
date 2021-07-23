//
//  Constants.swift
//  AASwiftSDK
//
//  Created by Brett Clifton on 10/26/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

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

let EVENT_COLLECTION_SERVER_ROOT_TEST = "https://sandec.adadapted.com/v/1/ios"
let EVENT_COLLECTION_SERVER_ROOT_PROD = "https://ec.adadapted.com/v/1/ios"

let PAYLOAD_SERVICE_SERVER_ROOT_TEST = "https://sandpayload.adadapted.com/v/1"
let PAYLOAD_SERVICE_SERVER_ROOT_PROD = "https://payload.adadapted.com/v/1"

let AD_FADE_SECONDS = 0.2
let AASDK_TRACKING_DISABLED_KEY = "adTrackingDisabled"
let AASDK_SESSION_ID_KEY = "aasdkSessionIdKey"

let AASDK_OPTION_USE_CACHED_IMAGES = "USE_CACHED_IMAGES"
let AASDK_OPTION_IGNORE_ZONES = "IGNORE_ZONES"
let AASDK_OPTION_TEST_MODE_API_VERSION = "TEST_MODE_API_VERSION"
let AASDK_OPTION_TEST_MODE_UNLOAD_AFTER_ONE = "TEST_MODE_UNLOAD_AFTER_ONE"
let AASDK_OPTION_DISABLE_ADVERTISING = "DISABLE_ADVERTISING"
let AASDK_OPTION_INIT_PARAMS = "INIT_PARAMS"

/// keys used to report details in NSNotifications for Keyword Intercepts
let AASDK_KEY_KI_REPLACEMENT_ID = "KI_REPLACEMENT_ID"
let AASDK_KEY_KI_REPLACEMENT_ICON_URL = "KI_REPLACEMENT_ICON"
let AASDK_KEY_KI_REPLACEMENT_TAGLINE = "KI_REPLACEMENT_TAGLINE"

/// root of the server the framework talks to - don't allow them to pass in arbitrary ones
let AA_PROD_ROOT = "https://ads.adadapted.com/v"
let AA_SANDBOX_ROOT = "https://sandbox.adadapted.com/v"
let AA_UNIVERSAL_LINK_ROOT = "ul.adadapted.com"

/// version of the API. used in conjuntion with AA_SERVER_ROOT to build request base URLs.
let AA_API_VERSION = "0.9.5"
let AA_TEST_API_VERSION = "0.9.5"

let AA_CLOSE_IMAGE_URL = "https://assets.adadapted.com/round_close.png"
let AA_CLOSE_IMAGE_2X_URL = "https://assets.adadapted.com/round_close@2x.png"

let AASDK_NOTIFICATION_INIT_COMPLETE_NAME = "AASDK_INIT_COMPLETE"
let AASDK_NOTIFICATION_ERROR = "AASDK_ERROR"
let AASDK_NOTIFICATION_GET_ADS_COMPLETE_NAME = "AASDK_GET_AD_COMPLETE"
let AASDK_NOTIFICATION_POPUP_INTERNAL_TOUCH = "AASDK_INTERNAL_POPUP_TOUCH"
let AASDK_NOTIFICATION_WILL_LOAD_IMAGE = "AASDK_INTERNAL_WILL_LOAD_IMAGE"
let AASDK_NOTIFICATION_DID_LOAD_IMAGE = "AASDK_INTERNAL_DID_LOAD_IMAGE"
let AASDK_NOTIFICATION_FAILED_LOAD_IMAGE = "AASDK_INTERNAL_FAILED_LOAD_IMAGE"
let AASDK_DEBUG_MESSAGE = "AASDK_DEBUG_MESSAGE"
let AASDK_CACHE_UPDATED = "AASDK_CACHE_UPDATED"
let AASDK_NO_INIT_ERROR = "INSTANCE_NOT_INITIALIZED"

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

/// Codes for reporting back to the API
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
let ADDIT_NO_DEEPLINK_RECEIVED = "ADDIT_NO_DEEPLINK_RECEIVED"

/// Product parameter names
let PRODUCT_IMAGE = "product_image"
let PRODUCT_TITLE = "product_title"
let PRODUCT_BARCODE = "product_barcode"
let PRODUCT_BRAND = "product_brand"
let PRODUCT_CATEGORY = "product_category"
let PRODUCT_SKU = "product_sku"
let RETAILER_ID = "product_discount"
let PRODUCT_DESCRIPTION = "product_description"
let AA_KEY_TRACKING_ID = "tracking_id"
let AA_KEY_PAYLOAD_ID = "payload_id"
let DETAILED_LIST_ITEMS = "detailed_list_items"
