//
//  AAAd.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//
import CoreGraphics
import Foundation
import UIKit

@objcMembers
public class AAAd: NSObject {
    var aaPortImageView: AAImageAdView?
    var aaLandImageView: AAImageAdView?
    var aaAsyncImageView: AAImageAdView?
    var type: AdTypeAndSource?
    var adID: String?
    var zoneId: String?
    var portImgURL: String?
    var landImgURL: String?
    var actionPath: URL?
    var actionType: String?
    var datetime: String?
    var refreshIntervalSeconds = 0
    var impressionID: String?
    var adURL: String?
    var adHTML: String?
    var hideAfterInteraction = false
    var popupType: String?
    var popupHideBanner = false
    var popupHideBrowserNav = false
    var popupHideCloseButton = false
    var popupAltCloseButtonURL: String?
    var popupTitleText: String?
    var popupTextColor: String?
    var popupBackColor: String?
    var jsonAdPayload: [AnyHashable : Any]?
    var jsonContentPayload: [AnyHashable : Any]?
    // added in 0.9.4 API
    var campaignId: String?
    var advertiserId: String?
    var creativeId: String?
    var trackingHTML: String?

    private var orientations: UIInterfaceOrientationMask!
    private var isImpressionTracked = false

    class func dicOfZonesWithAds(fromJSONDic response: [AnyHashable : Any]?) -> [AnyHashable : Any]? {
        guard let response = response else {
            return nil
        }

        var returnDic: [AnyHashable : Any] = [:]

        for zoneWrapper in response.enumerated() {
            let zone = zoneWrapper.element.value as! [String : AnyObject]

            let zoneId = zone["id"] as? String ?? ""
            let aaZone = AAAdZone()
            aaZone.zoneId = zoneId
            aaZone.portZoneWidth = zone["port_width"] as? Double ?? 0.0
            aaZone.portZoneHeight = zone["port_height"] as? Double ?? 0.0
            aaZone.landZoneWidth = zone["land_width"] as? Double ?? 0.0
            aaZone.landZoneHeight = zone["land_height"] as? Double ?? 0.0

            let adData = zone[AA_KEY_ADS] as? [AnyHashable]
            var ads: [AnyHashable] = []

            for dic in adData ?? [] {
                guard let dic = dic as? [AnyHashable : Any] else {
                    continue
                }
                let ad = AAAd.adFromJSONDictionary(adDic: dic)
                if let ad = ad {
                    ad.zoneId = zoneId
                    ads.append(ad)
                }
            }

            aaZone.ads = ads

            returnDic[zoneId] = aaZone
        }

        return returnDic
    }

    class func adFromJSONDictionary(adDic: [AnyHashable : Any]?) -> AAAd? {
        if adDic == nil {

        }

        var errorString = ""
        let ad = AAAd.init()

        ad.adID = (adDic?[AA_KEY_AD_ID] as? String)?.trimmingCharacters(in: .whitespaces)
        //ad.zoneId = (adDic?[AA_KEY_ZONE] as? String)?.trimmingCharacters(in: .whitespaces)
        ad.actionType = (adDic?[AA_KEY_ACTION_TYPE] as? String)?.trimmingCharacters(in: .whitespaces)
        //ad.datetime = adDic?[AA_KEY_DATETIME] as? String ?? ""
        ad.refreshIntervalSeconds = (adDic?[AA_KEY_REFRESH_INTERVAL] as? Int) ?? 0
        ad.impressionID = (adDic?[AA_KEY_IMPRESSION_ID] as? String) ?? ""
        ad.hideAfterInteraction = (adDic?[AA_KEY_HIDE_AFTER_CLICK] as? Bool) ?? false
        ad.adURL = (adDic?[AA_KEY_AD_URL] as? String) ?? ""
        ad.trackingHTML = (adDic?[AA_KEY_TRACKING_HTML] as? String) ?? ""

        if ad.refreshIntervalSeconds < 1 {
            let message = String(format: "Invalid refresh rate %i - using 30 sec - ad %@ in zone %@", ad.refreshIntervalSeconds, ad.adID ?? "", ad.zoneId ?? "")
            Logger.consoleLogError(nil, withMessage: message, suppressTracking: true)
            errorString += "\n\(message)"
            ad.refreshIntervalSeconds = 30
        }

        var jsonPayload = adDic?["json"]

        if jsonPayload != nil && jsonPayload is [AnyHashable: Any] {
            ad.jsonAdPayload = jsonPayload as? [AnyHashable : Any] ?? [:]
            if ad.jsonAdPayload?.count == 0 {
                let message = "JSON Ad payload contained no items for ad \(ad.adID ?? "") in zone \(ad.zoneId ?? "")"
                Logger.consoleLogError(nil, withMessage: message, suppressTracking: true)
                errorString += "\n\(message)"
            }
        }

        jsonPayload = adDic?["payload"]
        if ad.actionType != "e" && jsonPayload != nil && (jsonPayload is [AnyHashable : Any]) {
            ad.jsonContentPayload = jsonPayload as? [AnyHashable : Any] ?? [:]
            if ad.jsonContentPayload?.count == 0 {
                let message = "JSON content payload contained no items for ad \(ad.adID ?? "") in zone \(ad.zoneId ?? "")"
                Logger.consoleLogError(nil, withMessage: message, suppressTracking: true)
                errorString = "\(errorString)\n\(message)"
            }
        }

        var _str = ""
        if let str = adDic?[AA_KEY_ACTION_PATH] as? String {
            _str = str
            if !str.isEmpty {
                let url = URL.init(string: str)
                ad.actionPath = url
            } else {
                let actionType = AAHelper.actionType(from: ad.actionType ?? "")
                if (actionType == AASDKActionType.kActionPopup || actionType == AASDKActionType.kActionLink) {
                    let message = "ad \(ad.adID ?? "") in zone \(ad.zoneId ?? "") missing action path"
                    Logger.consoleLogError(nil, withMessage: message, suppressTracking: true)
                    errorString = "\(errorString)\n\(message)"
                }
            }
        }

        ad.type = AdTypeAndSource.kTypeUnsupportedAd
        _str = (adDic?[AA_KEY_AD_TYPE] as? String) ?? ""
        if !_str.isEmpty {
            if _str == "image" {
                ad.type = AdTypeAndSource.kAdAdaptedImageAd
            } else if _str == "html" {
                ad.type = AdTypeAndSource.kAdAdaptedHTMLAd
            } else if _str == "json" {
                ad.type = AdTypeAndSource.kAdAdaptedJSONAd
            }
        }

        if ad.type == AdTypeAndSource.kTypeUnsupportedAd {
            let message = "ad \(ad.adID ?? "") in zone \(ad.zoneId ?? "") bad ad type '\(_str)'"
            Logger.consoleLogError(nil, withMessage: message, suppressTracking: true)
            errorString = "\(errorString)\n\(message)"
        }

        if let popup = adDic?["popup"] as? [String: Any] {
            if !popup.isEmpty {
                ad.popupType = popup["type"] as? String
                ad.popupAltCloseButtonURL = popup[AA_KEY_ALT_CLOSE] as? String
                ad.popupHideCloseButton = popup[AA_KEY_HIDE_CLOSE] as? Bool ?? false
                ad.popupHideBrowserNav = popup[AA_KEY_HIDE_NAV] as? Bool ?? false
                ad.popupHideBanner = popup[AA_KEY_HIDE_BANNER] as? Bool ?? false
                ad.popupTitleText = popup[AA_KEY_TITLE_TEXT] as? String
                ad.popupTextColor = popup[AA_KEY_TEXT_COLOR] as? String
                ad.popupBackColor = popup[AA_KEY_BACK_COLOR] as? String
            }
        }

        var images: [Any] = []
        if let imageGroups = adDic?["images"] as? [String: Any] {
            if UIScreen.main.scale >= 2.0 {
                images = (imageGroups["retina"] as? [AnyObject]) ?? []
            } else {
                images = (imageGroups["standard"] as? [AnyObject]) ?? []
            }
        }

        ad.orientations = UIInterfaceOrientationMask.init(rawValue: UInt(UIInterfaceOrientation.unknown.rawValue))

        for i in images {
            if let image = i as? [String: Any] {
                let orientation = image["orientation"] as? String
                if orientation == "port" {
                    ad.portImgURL = image["url"] as? String
                    ad.orientations = UIInterfaceOrientationMask(rawValue: ad.orientations.rawValue | UIInterfaceOrientationMask.init(rawValue: UInt(UIInterfaceOrientation.portrait.rawValue)).rawValue)
                }
                if orientation == "land" {
                    ad.landImgURL = image["url"] as? String
                    ad.orientations = UIInterfaceOrientationMask(rawValue: ad.orientations.rawValue | UIInterfaceOrientationMask.landscape.rawValue)
                }
            }
        }

        if !errorString.isEmpty {
            AASDK.trackAnomalyAdConfiguration(ad, message: errorString)
        }

        return ad
    }

    func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        //NOTE: we don't take action if data is passed and the zone and ad orientations don't line up.
        return orientations
    }

    /// returns either the aaPortImageView or the aaLandImageView
    func imageView(for orientation: UIInterfaceOrientation) -> AAImageAdView? {
        let orientationMask: UIInterfaceOrientationMask = orientation.isPortrait ? .portrait : .landscape

        if orientationMask.rawValue & orientations.rawValue != 0 {
            if orientation.isLandscape {
                return aaLandImageView
            } else {
                return aaPortImageView
            }
        } else {
            if aaPortImageView != nil {
                let str = "WARNING - don't have image for landscape orientation with ad \(adID ?? "").  using portrait image instead"
                AASDK.logDebugMessage(str, type: AASDK.DEBUG_GENERAL)
                return aaPortImageView
            }

            if aaLandImageView != nil {
                let str = "WARNING - don't have image for landscape orientation with ad \(adID ?? "").  using portrait image instead"
                AASDK.logDebugMessage(str, type: AASDK.DEBUG_GENERAL)
                return aaLandImageView
            }
        }
        let str = "WARNING - don't have any cached images for ad \(adID ?? "").  returning nil."
        AASDK.logDebugMessage(str, type: AASDK.DEBUG_GENERAL)
        return nil
    }

    /// returns either the landscape or portrait URL
    func url(for orientation: UIInterfaceOrientation) -> URL? {
        let orientationMask: UIInterfaceOrientationMask = orientation.isPortrait ? .portrait : .landscape

        if orientationMask.rawValue & orientations.rawValue != 0 {
            if orientation.isLandscape {
                return URL(string: landImgURL ?? "")
            } else {
                return URL(string: portImgURL ?? "")
            }
        } else {
            if portImgURL != nil && (portImgURL?.count ?? 0) > 0 {
                let str = "WARNING - don't have URL for landscape orientation with ad \(adID ?? "").  using portrait image instead"
                AASDK.logDebugMessage(str, type: AASDK.DEBUG_GENERAL)
                return URL(string: portImgURL ?? "")
            }

            if landImgURL != nil && (landImgURL?.count ?? 0) > 0 {
                let str = "WARNING - don't have URL for landscape orientation with ad \(adID ?? "").  using portrait image instead"
                AASDK.logDebugMessage(str, type: AASDK.DEBUG_GENERAL)
                return URL(string: landImgURL ?? "")
            }
        }
        let str = "WARNING - don't have any URL for ad \(adID ?? "").  returning nil."
        AASDK.logDebugMessage(str, type: AASDK.DEBUG_GENERAL)
        return nil
    }

// MARK: Visibility
    func setImpressionTracked() {
        isImpressionTracked = true
    }

    func resetImpressionTracking() {
        isImpressionTracked = false
    }

    func impressionWasTracked() -> Bool {
        return isImpressionTracked
    }

// MARK: - NSObject
    public override func isEqual(_ object: Any?) -> Bool {
        let ad = object as? AAAd
        return adID == ad?.adID
    }
}
