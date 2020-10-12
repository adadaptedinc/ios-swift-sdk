//  Converted to Swift 5.2 by Swiftify v5.2.19227 - https://swiftify.com/
//
//  AAImage.h
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import UIKit

@objc protocol AAImageAdViewDelegate: NSObjectProtocol {
    func takeActionForAd()
    func webAdLoaded()
    func adFailed(toLoad error: Error?)
}

@objcMembers
class AAImageAdView: UIImageView {
    weak var ad: AAAd?
    var isLoaded = false
    var zoneId: String?
    var specifiedOrientation: UIInterfaceOrientation!
    var width: Float = 0.0
    var height: Float = 0.0
    weak var delegate: AAImageAdViewDelegate?

    // only used in image caching
    class func image(with url: URL?, for ad: AAAd?) -> AAImageAdView? {
        let imageView = AAImageAdView.init(frame: .zero)

        imageView.ad = ad
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.zoneId = ad?.zoneId
        AAHelper.setImageFor(imageView, from: url)

        return imageView
    }

    class func asyncImage(for ad: AAAd?) -> AAImageAdView? {
        let imageView = AAImageAdView.init(frame: .zero)

        imageView.ad = ad
        imageView.isUserInteractionEnabled = true
        if Float(UIDevice.current.systemVersion) ?? 0.0 >= 7.0 {
            imageView.translatesAutoresizingMaskIntoConstraints = false
        }
        imageView.zoneId = ad?.zoneId

        return imageView
    }

    func loadAsyncImage(for orientation: UIInterfaceOrientation) {
        let url = ad?.url(for: orientation)
        backupURL = url
        AAHelper.setImageFor(self, from: url)
    }

    private var backupURL: URL?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        self.contentMode = .scaleAspectFit
        self.contentScaleFactor = UIScreen.main.scale
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
//        AASDK.notificationCenter.removeObserver(self)
    }

    override var intrinsicContentSize: CGSize {
        return AASDK.sizeOfZone(ad?.zoneId ?? "", for: UIApplication.shared.statusBarOrientation)
    }

// MARK: - factory methods
    class func dispatchStart() {
        let notification = Notification(name: Notification.Name(rawValue: AASDK_NOTIFICATION_WILL_LOAD_IMAGE), object: nil, userInfo: nil)
        AASDK.notificationCenter().post(notification)
    }

    class func dispatchDone() {
        let notification = Notification(name: Notification.Name(rawValue: AASDK_NOTIFICATION_DID_LOAD_IMAGE), object: nil, userInfo: nil)
        AASDK.notificationCenter().post(notification)
    }

    class func dispatchFailed() {
        let notification = Notification(name: Notification.Name(rawValue: AASDK_NOTIFICATION_FAILED_LOAD_IMAGE), object: nil, userInfo: nil)
        AASDK.notificationCenter().post(notification)
    }

// MARK: - touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touch_point = touch?.location(in: self)

        if point(inside: touch_point ?? CGPoint.zero, with: event) {
            //        [self enterSelectedState];
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touch_point = touch?.location(in: self)

        if !point(inside: touch_point ?? CGPoint.zero, with: event) {
            //        [self enterSelectedState];
        } else {
            //        [self exitSelectedState];
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        AASDK.logDebugMessage("ImageAdView: touchesEnded:withEvent enter", type: AASDK_DEBUG_USER_INTERACTION)
        let touch = touches.first
        let touch_point = touch?.location(in: self)

        if point(inside: touch_point ?? CGPoint.zero, with: event) {
            AASDK.logDebugMessage("ImageAdView: touchesEnded:withEvent taking action", type: AASDK_DEBUG_USER_INTERACTION)
            delegate?.takeActionForAd()
        } else {
            //        [self exitSelectedState];
            AASDK.logDebugMessage("ImageAdView: touchesEnded:withEvent touch outside", type: AASDK_DEBUG_USER_INTERACTION)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        //    [self exitSelectedState];
    }
}