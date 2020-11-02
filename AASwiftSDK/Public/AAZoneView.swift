//
//  AAZoneView.swift
//  AASwiftSDK
//
//  Created by Brett Clifton on 9/21/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import UIKit
import WebKit

@objc public protocol AAZoneViewOwner: NSObjectProtocol {
    func viewControllerForPresentingModalView() -> UIViewController?

    @objc optional func zoneView(_ view: AAZoneView?, hadPopupSendURLString urlString: String?)
    @objc optional func zoneViewDidLoadZone(_ view: AAZoneView?)
    @objc optional func zoneViewDidFail(toLoadZone view: AAZoneView?)
    @objc optional func willPresentModalView(forZone view: AAZoneView?)
    @objc optional func didDismissModalView(forZone view: AAZoneView?)
    @objc optional func willLeaveApplication(fromZone view: AAZoneView?)
    @objc optional func handleCallToAction(forZone view: AAZoneView?)
}

@IBDesignable
public class AAZoneView: UIView, AASDKObserver, UIGestureRecognizerDelegate, AAZoneRenderer {

    @IBInspectable public var zoneId: String?
    internal weak var zoneOwner: AAZoneViewOwner?
    private(set) var type: AdTypeAndSource?
    private var provider: AAAbstractAdProvider?
    private var currentAdView: UIView?
    
    @objc public func setZoneOwner(_ zoneOwner: AAZoneViewOwner?) {
        setZoneId(nil, zoneType: .kTypeUnsupportedAd, delegate: zoneOwner)
    }
    
    public func clientZoneView() -> AAZoneView? {
        return self
    }

    init(frame: CGRect, forZone zoneId: String?, zoneType type: AdTypeAndSource, delegate: AAZoneViewOwner?) {
        super.init(frame: frame)
        setZoneId(zoneId, zoneType: type, delegate: delegate)
        sharedInit()
        AASDK.logDebugFrame(self.frame, message: "AAZoneView \(zoneId ?? "") initWithFrame")
    }

    func rotate(to newOrientation: UIInterfaceOrientation) {
        adProvider()?.rotate(to: newOrientation)
    }

    func adContentViewSize(for orientation: UIInterfaceOrientation) -> CGSize {
        if adProvider() != nil {
            let size = adProvider()?.adSize(for: orientation)
            AASDK.logDebugMessage(String(format: "AAZoneView returning ad size of (%0.0f, %0.0f) in adContentViewSizeForOrientation", size?.width ?? 0.0, size?.height ?? 0.0), type: AASDK_DEBUG_AD_LAYOUT)
            return size ?? CGSize.zero
        }
        AASDK.logDebugMessage("AAZoneView returning ad size of (0, 0) in adContentViewSizeForOrientation", type: AASDK_DEBUG_AD_LAYOUT)
        return CGSize(width: 0, height: 0)
    }

    func advanceToNextAd() {
        if adProvider() != nil {
            adProvider()?.renderNext()
        }
    }

    func closePopup() -> Bool {
        return adProvider()?.closePopup() ?? false
    }

    func closePopup(withCompletionHandler handler: @escaping () -> Void) -> Bool {
        return adProvider()?.closePopup(withCompletionHandler: handler) ?? false
    }

    func setZoneType(_ value: NSNumber?) {
        if let value = value {
            let ii = value.intValue
            type = AdTypeAndSource(rawValue: ii)
        }
    }

    func userInteractedWithAd() {
        AASDK.logDebugMessage("AAZoneView: userInteractedWithAd enter", type: AASDK_DEBUG_USER_INTERACTION)
        if adProvider() != nil {
            adProvider()?.userInteractedWithAd()
        } else {
            AASDK.logDebugMessage("AAZoneView: NO AD PROVIDER", type: AASDK_DEBUG_USER_INTERACTION)
        }
    }

    func wasHidden() {
        if let provider = provider {
            provider.adWasHidden()
        }
    }

    func wasUnHidden() {
        if let provider = provider {
            if let ad = adProvider()?.currentAd() {
                AASDK.fireHTMLTracker(incomingAd: ad, incomingView: zoneOwner?.viewControllerForPresentingModalView()?.view)
                provider.adWasUnHidden()
            }
        }
    }

// MARK: - LIFECYCLE

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        sharedInit()
        AASDK.logDebugFrame(frame, message: "AAZoneView initWithCoder")
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        if let type1 = AdTypeAndSource(rawValue: -1) {
            setZoneId(nil, zoneType: type1, delegate: nil)
        }
    }

    deinit {
        removeListeners()
    }

    func sharedInit() {
        registerListeners()
    }

    public override func layoutSubviews() {
        backgroundColor = UIColor.clear
        AASDK.logDebugFrame(frame, message: "AAZoneView \(zoneId ?? "") START layoutSubviews")
        super.layoutSubviews()
        if let currentAdView = currentAdView {
            currentAdView.frame = bounds
            AASDK.logDebugFrame(frame, message: "AAZoneView \(zoneId ?? "") updated child Ad UIView's frame to")
        }
        AASDK.logDebugFrame(frame, message: "AAZoneView \(zoneId ?? "") END layoutSubviews")
    }

// MARK: - <AAZoneRenderer> used by the AAAbstractAdProvider
    func containerSize() -> CGSize {
        let size = frame.size
        AASDK.logDebugMessage(String(format: "AAZoneView returning ad size of (%0.0f, %0.0f) in intrinsicContentSize", size.width, size.height), type: AASDK_DEBUG_AD_LAYOUT)
        return size
    }

    func viewControllerForPresentingModalView() -> UIViewController? {
        return zoneOwner?.viewControllerForPresentingModalView()
    }

    func provider(_ provider: AAAbstractAdProvider?, didLoadAdView adView: UIView?, for ad: AAAd?) {
        pointView(to: adView)
        AASDK.fireHTMLTracker(incomingAd: ad, incomingView: zoneOwner?.viewControllerForPresentingModalView()?.view)
        if zoneOwner?.responds(to: #selector(AAZoneViewOwner.zoneViewDidLoadZone(_:))) ?? false {
            zoneOwner?.zoneViewDidLoadZone?(self)
        }
    }

    func handleReloadOf(_ ad: AAAd?) {
        AASDK.fireHTMLTracker(incomingAd: ad, incomingView: zoneOwner?.viewControllerForPresentingModalView()?.view)
    }

    func provider(_ provider: AAAbstractAdProvider?, didFailToLoadZone zone: String?, ofType type: AdTypeAndSource, message: String?) {
        if currentAdView != nil {
            pointView(to: nil)
        }

        if zoneOwner?.responds(to: #selector(AAZoneViewOwner.zoneViewDidFail(toLoadZone:))) ?? false {
            zoneOwner?.zoneViewDidFail?(toLoadZone: self)
        }
    }

    func popupWillShow() {
        if zoneOwner?.responds(to: #selector(AAZoneViewOwner.willPresentModalView(forZone:))) ?? false {
            zoneOwner?.willPresentModalView?(forZone: self)
        }
    }

    func popupDidHide() {
        if zoneOwner?.responds(to: #selector(AAZoneViewOwner.didDismissModalView(forZone:))) ?? false {
            zoneOwner?.didDismissModalView?(forZone: self)
        }
    }

    func userLeavingApplication() {
        if zoneOwner?.responds(to: #selector(AAZoneViewOwner.willLeaveApplication(fromZone:))) ?? false {
            zoneOwner?.willLeaveApplication?(fromZone: self)
        }
    }

    func deliverAdPayload() {
        //NOOP unless overridden
    }

    func handleCallToActionForZone() {
        if zoneOwner?.responds(to: #selector(AAZoneViewOwner.handleCallToAction(forZone:))) ?? false {
            zoneOwner?.handleCallToAction?(forZone: self)
        }
    }

    func invalidateContentView() {
        if let currentAdView = currentAdView {
            currentAdView.removeFromSuperview()
        }
    }

    func userDidInteract(withInternalURLString urlString: String?) {
        if zoneOwner?.responds(to: #selector(AAZoneViewOwner.zoneView(_:hadPopupSendURLString:))) ?? false {
            zoneOwner?.zoneView?(self, hadPopupSendURLString: urlString)
        }
    }

// MARK: - Ad Rendering
    func pointView(to newAdView: UIView?) {
        if newAdView == nil {
            UIView.animate(
                withDuration: AD_FADE_SECONDS,
                animations: { [self] in
                    currentAdView?.alpha = 0.0
                }) { [self] finished in
                    currentAdView?.removeFromSuperview()
                }
            return
        }

        if let currentAdView = currentAdView {
            currentAdView.removeFromSuperview()
        }
        currentAdView = newAdView

        if let currentAdView = currentAdView {
            addSubview(currentAdView)
        }
        AASDK.logDebugFrame(self.frame, message: "AAZoneView \(zoneId ?? "") rendering ad. The AAZoneView's frame is")
        let frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        currentAdView?.frame = frame
        AASDK.logDebugFrame(currentAdView!.frame, message: "AAZoneView \(zoneId ?? "") rendering ad. The ad's frame is")
    }

// MARK: - PRIVATE
    func registerListeners() {
        AASDK.registerListeners(for: self)
    }

    func removeListeners() {
        AASDK.removeListeners(for: self)
    }

// MARK: - <AASDKObserver> - HACKED - needs repair
    public func aaSDKInitComplete(_ notification: Notification) {
        advanceToNextAd()
    }

    public func aaSDKError(_ error: Notification) {
        //no-op
    }

    public func aaSDKGetAdsComplete(_ notification: Notification) {
        advanceToNextAd()
    }

    func aaSDKCacheFailure(_ notification: Notification?) {
    }

    public func aaSDKCacheUpdated(_ notification: Notification) {
        advanceToNextAd()
    }
}

extension AAZoneView {
    func adProvider() -> AAAbstractAdProvider? {
        return provider
    }

    func setAdProvider(_ adProvider: AAAbstractAdProvider?) {
        provider = adProvider
    }

    func setZoneId(_ zoneId: String?, zoneType type: AdTypeAndSource, delegate: AAZoneViewOwner?) {
        if zoneId == self.zoneId && adProvider() != nil {
            return
        }

        self.zoneId = zoneId == nil ? self.zoneId : zoneId
        self.type = type.rawValue > 0 ? type : self.type
        zoneOwner = delegate == nil ? zoneOwner : delegate

        if zoneOwner == nil || self.zoneId == nil {
            return
        }

        if adProvider() != nil {
            adProvider()?.destroy()
        }

        AASDK.reportZoneLoaded(self.zoneId)

        switch self.type {
            case .kAdAdaptedImageAd, .kAdAdaptedJSONAd:
                provider = AAAdAdaptedAdProvider(zoneRenderer: self, zone: self.zoneId, andType: self.type!)
                advanceToNextAd()
            default:
                break
        }
    }
}
