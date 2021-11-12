@testable import AASwiftSDK
import XCTest

final class AAADZoneTests: XCTestCase {
    let adZone = AAAdZone()
    let ad = MockAd()

    var ad1: AAAd?
    private var mockNotificationCenter = MockNotificationCenter()

    override func setUp() {
        NotificationCenterWrapper.createInstance(notificationCenter: mockNotificationCenter)
        adZone.ads = ad.getMockAds()
        ad1 = ad.getMockAd()
    }
    
    func testSetupAdZone() {

        let url1 = "http://www.pornimage.com"
        let url2 = "http://www.landimageurl.com"
        ad1?.portImgURL = url1
        ad1?.landImgURL = url2
        adZone.ads?.remove(at: 0)
        adZone.ads?.insert(ad1, at: 0)
        adZone.ads?.insert("Hello", at: 3)

        adZone.zoneId = "101943"
        adZone.portZoneWidth = 120.0
        adZone.portZoneHeight = 70.0
        adZone.landZoneWidth = 70.0
        adZone.landZoneHeight = 120.0

        XCTAssertEqual(adZone.ads?[1], ad.getMockAds()[1])
        adZone.setupZoneAndShouldUseCachedImages(false)
        XCTAssertEqual(adZone.isUsingCachedImages(), false)

        adZone.setupZoneAndShouldUseCachedImages(true)
        XCTAssertEqual(adZone.isUsingCachedImages(), true)
        XCTAssertEqual(adZone.hasAdsAvailable(), true)
        XCTAssertEqual(adZone.nextAd(), adZone.ads?[0] as? AAAd)
        XCTAssertEqual(adZone.nextAd(), adZone.ads?[1] as? AAAd)
    }

    func testInjectAndRemoveAd() {
        adZone.setupZoneAndShouldUseCachedImages(false)
        XCTAssertEqual(adZone.currentAdsCount(), 3)

        print("ads1: \(adZone.currentIndex)")
        adZone.inject(ad1)
        print("ads2: \(adZone.currentIndex)")
        XCTAssertEqual(adZone.currentAdsCount(), 4)

        adZone.remove(adZone.ads?[0] as? AAAd)
        XCTAssertEqual(adZone.currentAdsCount(), 3)

        adZone.removeAll()
        XCTAssertEqual(adZone.hasAdsAvailable(), false)
    }

    func testNextAd() {
        adZone.setupZoneAndShouldUseCachedImages(false)
        XCTAssertEqual(adZone.nextAd(), adZone.ads?[0] as? AAAd)

        adZone.removeAll()
        XCTAssertNil(adZone.nextAd())
    }

    func testReset() {
        let imageView = AAImageAdView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 120, height: 90)))
        (adZone.ads?[0] as? AAAd)?.aaPortImageView = imageView
        (adZone.ads?[0] as? AAAd)?.aaLandImageView = imageView
        XCTAssertEqual((adZone.ads?[0] as? AAAd)?.aaPortImageView, imageView)
        XCTAssertEqual((adZone.ads?[0] as? AAAd)?.aaLandImageView, imageView)

        adZone.reset()
        XCTAssertEqual((adZone.ads?[0] as? AAAd)?.aaPortImageView, nil)
        XCTAssertEqual((adZone.ads?[0] as? AAAd)?.aaLandImageView, nil)

        adZone.removeAll()
        adZone.ads?.append("Hello")
        XCTAssertEqual((adZone.ads?[0] as? AAAd)?.aaPortImageView, nil)
        XCTAssertEqual((adZone.ads?[0] as? AAAd)?.aaLandImageView, nil)
    }

    func testUsingCachedImages() {
        adZone.setupZoneAndShouldUseCachedImages(false)
        XCTAssertEqual(adZone.isUsingCachedImages(), false)

        adZone.setupZoneAndShouldUseCachedImages(true)
        XCTAssertEqual(adZone.isUsingCachedImages(), true)
    }

    func testAdSizeforOrientation() {
        var orientation = UIInterfaceOrientation(rawValue: 1)
        adZone.portZoneWidth = 120.0
        adZone.landZoneWidth = 420.0

        XCTAssertEqual(orientation?.isPortrait, true)
        XCTAssertEqual(adZone.adSizeforOrientation(orientation!).width, 120.0)

        orientation = UIInterfaceOrientation(rawValue: 4)
        XCTAssertEqual(orientation?.isLandscape, true)
        XCTAssertEqual(adZone.adSizeforOrientation(orientation!).width, 420.0)
    }

    func testAdBoundsforOrientation() {
        var orientation = UIInterfaceOrientation(rawValue: 1)
        adZone.portZoneWidth = 120.0
        adZone.portZoneHeight = 40.0
        adZone.landZoneWidth = 420.0
        adZone.landZoneHeight = 80

        XCTAssertEqual(orientation?.isPortrait, true)
        XCTAssertEqual(adZone.adBoundsforOrientation(orientation!), CGRect(x: 0, y: 0, width: adZone.portZoneWidth, height: adZone.portZoneHeight))

        orientation = UIInterfaceOrientation(rawValue: 4)
        XCTAssertEqual(orientation?.isLandscape, true)
        XCTAssertEqual(adZone.adBoundsforOrientation(orientation!), CGRect(x: 0, y: 0, width: adZone.landZoneWidth, height: adZone.landZoneHeight))
    }

    func testOrientationSupport() {
        ad1?.portImgURL = "www.pornimage.url"
        adZone.ads?.remove(at: 0)
        adZone.ads?.insert(ad1, at: 0)
        adZone.setupZoneAndShouldUseCachedImages(false)
        XCTAssertEqual(adZone.supportsPortrait(), true)
        XCTAssertEqual(adZone.supportedInterfaceOrientations(), UIInterfaceOrientationMask.portrait)

        ad1?.portImgURL = nil
        ad1?.landImgURL = "www.landimageurl.com"
        adZone.setupZoneAndShouldUseCachedImages(false)
        XCTAssertEqual(adZone.supportsLandscape(), true)
    }

    func testEqual() {
        XCTAssertEqual(adZone.isEqual(adZone), true)
        XCTAssertEqual(adZone.isEqual("taco"), false)
    }
}
