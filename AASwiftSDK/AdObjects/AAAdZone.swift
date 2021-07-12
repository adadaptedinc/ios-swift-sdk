//
//  AAAdZone.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation
import UIKit

@objcMembers
class AAAdZone: NSObject {
    var ads: [AnyHashable]?
    var isCacheComplete = false
    var zoneId: String?
    var portZoneWidth: Float = 0.0
    var portZoneHeight: Float = 0.0
    var landZoneWidth: Float = 0.0
    var landZoneHeight: Float = 0.0

    var currentIndex: UInt = 0
    private var currentAds: [AnyHashable]?
    private var availableAdIds: [AnyHashable]?
    private var nextTimelineEvent: Date?
    private var shouldUseCachedImages = false
    private var orientations: UIInterfaceOrientationMask!

    override init() {
        super.init()

        isCacheComplete = false
        shouldUseCachedImages = false
        orientations = UIInterfaceOrientationMask.init(rawValue: UInt(UIInterfaceOrientation.unknown.rawValue))
    }

    func setupZoneAndShouldUseCachedImages(_ shouldUseCachedImages: Bool) {
        isCacheComplete = false
        self.shouldUseCachedImages = shouldUseCachedImages

        var setOrientations = false
        for ad in ads ?? [] {
            guard let ad = ad as? AAAd else {
                continue
            }
            if self.shouldUseCachedImages {
                if ad.portImgURL != nil && (ad.portImgURL?.count ?? 0) > 0 {
                    AASDK.logDebugMessage("Caching portrait ad \(ad.adID ?? "") with URL \(ad.portImgURL ?? "") for zone \(ad.zoneId ?? "")", type: AASDK.DEBUG_NETWORK)
                    let portImageView = AAImageAdView.image(with: URL(string: ad.portImgURL ?? ""), for: ad)
                    ad.aaPortImageView = portImageView
                }
                if ad.landImgURL != nil && (ad.landImgURL?.count ?? 0) > 0 {
                    AASDK.logDebugMessage("Caching landscape ad \(ad.adID ?? "") with URL \(ad.landImgURL ?? "") for zone \(ad.zoneId ?? "")", type: AASDK.DEBUG_NETWORK)
                    let landImageView = AAImageAdView.image(with: URL(string: ad.landImgURL ?? ""), for: ad)
                    ad.aaLandImageView = landImageView
                }
            } else {
                DispatchQueue.main.async(execute: {
                    let asyncImageView = AAImageAdView.asyncImage(for: ad)
                    ad.aaAsyncImageView = asyncImageView
                })
            }

            if !setOrientations {
                if ad.portImgURL != nil {
                    orientations = UIInterfaceOrientationMask(rawValue: orientations.rawValue | UIInterfaceOrientationMask.portrait.rawValue)
                }
                if ad.landImgURL != nil {
                    orientations = UIInterfaceOrientationMask(rawValue: orientations.rawValue | UIInterfaceOrientationMask.landscape.rawValue)
                }
                setOrientations = true
            }
        }

        populateCurrentAds()
        isCacheComplete = true
    }

    func nextAd() -> AAAd? {
        if nextTimelineEvent?.compare(Date()) == .orderedAscending {
            populateCurrentAds()
        }

        if (currentAds?.count ?? 0) > 0 {
            return currentAds?[nextIndexAndIncrement()] as? AAAd
        } else {
            return nil
        }
    }

    func remove(_ ad: AAAd?) {
        var array: [AnyHashable]? = nil
        if let currentAds = currentAds {
            array = currentAds
        }
        array?.removeAll { $0 as AnyObject === ad as AnyObject }
        if let array = array {
            currentAds = array
        }
        currentIndex = 0
    }

    func inject(_ ad: AAAd?) {
        if let ad = ad {
            if !(currentAds?.contains(ad) ?? false) {
                var array: [AnyHashable]? = nil
                if let currentAds = currentAds {
                    array = currentAds
                }
                array?.insert(ad, at: 0)
                if let array = array {
                    currentAds = array
                }
                currentIndex = 0
                NotificationCenterWrapper.notifier.post(name: NSNotification.Name(rawValue: AASDK_CACHE_UPDATED), object: nil)
            }
        }
    }

    func hasAdsAvailable() -> Bool {
        return (currentAds?.count ?? 0) > 0
    }

    /// remove the cached images
    func reset() {
        for ad in ads ?? [] {
            guard let ad = ad as? AAAd else {
                continue
            }
            ad.aaPortImageView = nil
            ad.aaLandImageView = nil
        }
    }

    /// defaults to NO
    func isUsingCachedImages() -> Bool {
        return shouldUseCachedImages
    }

    func adSizeforOrientation(_ orientation: UIInterfaceOrientation) -> CGSize {
        if orientation.isPortrait {
            return CGSize(width: CGFloat(portZoneWidth), height: CGFloat(portZoneHeight))
        } else {
            return CGSize(width: CGFloat(landZoneWidth), height: CGFloat(landZoneHeight))
        }
    }

    func adBoundsforOrientation(_ orientation: UIInterfaceOrientation) -> CGRect {
        if orientation.isPortrait {
            return CGRect(x: 0, y: 0, width: CGFloat(portZoneWidth), height: CGFloat(portZoneHeight))
        } else {
            return CGRect(x: 0, y: 0, width: CGFloat(landZoneWidth), height: CGFloat(landZoneHeight))
        }
    }

    func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        //NOTE: we don't take action if data is passed and the zone and ad orientations don't line up.
        return orientations
    }

    func supportsLandscape() -> Bool {
        return (orientations.rawValue != 0 & UIInterfaceOrientationMask.landscape.rawValue)
    }

    func supportsPortrait() -> Bool {
        return (orientations.rawValue != 0 & UIInterfaceOrientationMask.portrait.rawValue)
    }

    override func isEqual(_ object: Any?) -> Bool {
        let zone = object as? AAAdZone
        return zone?.ads == ads
    }

// MARK: - Private
    func nextIndexAndIncrement() -> Int {
        currentIndex += 1

        if Int(currentIndex) >= (currentAds?.count ?? 0) {
            currentIndex = 0
        }

        return Int(currentIndex)
    }
    
    func populateCurrentAds() {
        currentAds = ads
        currentIndex = UInt(currentAds?.count ?? 0)
    }
}
