import Foundation
import UIKit

@objcMembers
class AAAdZone: NSObject {
    var ads: [AnyHashable]?
    var currentIndex = 0
    var isCacheComplete = false
    var landZoneHeight = 0.0
    var landZoneWidth = 0.0
    var portZoneHeight = 0.0
    var portZoneWidth = 0.0
    var zoneId: String?

    private var availableAdIds: [AnyHashable]?
    private var currentAds: [AnyHashable]?
    private var nextTimelineEvent: Date?
    private var orientations = UIInterfaceOrientationMask.init(rawValue: UInt(UIInterfaceOrientation.unknown.rawValue))
    private var shouldUseCachedImages = false

    func setupZoneAndShouldUseCachedImages(_ shouldUseCachedImages: Bool) {
        isCacheComplete = false
        self.shouldUseCachedImages = shouldUseCachedImages
        var setOrientations = false

        if let ads = ads {
            for ad in ads {
                guard let ad = ad as? AAAd else { continue }

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
        }
        populateCurrentAds()
        isCacheComplete = true
    }

    func nextAd() -> AAAd? {
        if let currentAds = currentAds {
            if (currentAds.count) > 0 {
                return currentAds[nextIndexAndIncrement()] as? AAAd
            }
        }
        return nil
    }

    func remove(_ ad: AAAd?) {
        guard var currentAds = currentAds else { return }

        currentAds.removeAll(where: { $0 as AnyObject === ad as AnyObject })
        self.currentAds = currentAds
        currentIndex = 0
    }

    func removeAll() {
        guard currentAds != nil else { return }
        self.currentAds?.removeAll()
        currentIndex = 0
    }

    func inject(_ ad: AAAd?) {
        if let ad = ad, let currentAds = currentAds {
            if !currentAds.contains(ad) {
                self.currentAds?.insert(ad, at: 0)
                currentIndex = 0
                NotificationCenterWrapper.notifier.post(name: NSNotification.Name(rawValue: AASDK_CACHE_UPDATED), object: nil)
            }
        }
    }

    func currentAdsCount() -> Int {
        guard let ads = currentAds, hasAdsAvailable() == true else { return 0 }
        return ads.count
    }

    func hasAdsAvailable() -> Bool {
        var hasAds = false
        if let ads = currentAds {
            hasAds = ads.count > 0
        }
        return hasAds
    }

    /// remove the cached images
    func reset() {
        if let ads = ads {
            for ad in ads {
                if let ad = ad as? AAAd {
                    ad.aaPortImageView = nil
                    ad.aaLandImageView = nil
                }
            }
        }
    }

    /// defaults to NO
    func isUsingCachedImages() -> Bool {
        return shouldUseCachedImages
    }

    func adSizeforOrientation(_ orientation: UIInterfaceOrientation) -> CGSize {
        if orientation.isPortrait {
            return CGSize(width: CGFloat(portZoneWidth), height: CGFloat(portZoneHeight))
        }
        return CGSize(width: CGFloat(landZoneWidth), height: CGFloat(landZoneHeight))
    }

    func adBoundsforOrientation(_ orientation: UIInterfaceOrientation) -> CGRect {
        if orientation.isPortrait {
            return CGRect(x: 0, y: 0, width: CGFloat(portZoneWidth), height: CGFloat(portZoneHeight))
        }
        return CGRect(x: 0, y: 0, width: CGFloat(landZoneWidth), height: CGFloat(landZoneHeight))
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

        if let currentAds = currentAds {
            if Int(currentIndex) >= (currentAds.count) {
                currentIndex = 0
            }
        }
        return Int(currentIndex)
    }
    
    func populateCurrentAds() {
        currentAds = ads
        if let currentAds = currentAds {
            self.currentIndex = currentAds.count
        }
    }
}
