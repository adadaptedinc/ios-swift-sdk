//
//  AAZoneView.swift
//  AASwiftSDK
//
//  Created by Brett Clifton on 9/21/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import UIKit
import WebKit

/// \brief Super class for rendering ads from AdAdapted.
/// /// Requires a zone id provided from AdAdapted./// \brief implemented by the UIViewController that contains a AAZoneView
@objc public protocol AAZoneViewOwner: NSObjectProtocol {
    /// \brief generally returns `self`
    /// - Returns: a UIViewController object from which the popup may be presented.
    func viewControllerForPresentingModalView() -> UIViewController?

    /// \brief OPTIONAL - Capture URL that user clicked on in popup.
    /// When User touches an anchor tag in the popup that has the prefix "internal:" this is called
    /// \param view the object that launched the popup
    /// \param urlString URL, in the popup, that was clicked. This is interpreted by the delegate app for internal navigation, or what not.
    /// See \ref popuphooks on how to tailor popup html content to pass data to this method
    @objc optional func zoneView(_ view: AAZoneView?, hadPopupSendURLString urlString: String?)
    /// \brief OPTIONAL - ad has loaded and rendered
    /// \param view the AAZoneView sub-class that was loaded
    @objc optional func zoneViewDidLoadZone(_ view: AAZoneView?)
    /// \brief OPTIONAL - an error occurred
    /// \param view the AAZoneView sub-class that failed to load an ad
    @objc optional func zoneViewDidFail(toLoadZone view: AAZoneView?)
    /// \brief OPTIONAL - modal presentation is going to happen, due to user interaction with ad
    /// \param view the AAZoneView sub-class that was interacted with
    @objc optional func willPresentModalView(forZone view: AAZoneView?)
    /// \brief OPTIONAL - modal dismissal is going to happen, due to user interaction with popup
    /// \param view the AAZoneView sub-class that was interacted with
    @objc optional func didDismissModalView(forZone view: AAZoneView?)
    /// \brief OPTIONAL - the user has interacted with a popup, and your app is going to the background
    /// \param view the AAZoneView sub-class that was interacted with
    @objc optional func willLeaveApplication(fromZone view: AAZoneView?)
    /// \brief OPTIONAL - if the zone delegates call to action handling to the client, this will be called.
    /// NOTE: this is in progress and not supported by the API at this time. To turn on, you should have `@"PRIVATE_CUSTOM_DELEGATE_ZONES_CTA":@[@"ZONEID1",@"ZONEID2"]` in your options dictionary when starting the SDK.
    /// When the user interacts with these specified zones, this method is called.
    @objc optional func handleCallToAction(forZone view: AAZoneView?)
}

/// \brief UIView subclass that renders ads
/// a superclass for convenience classes (that you really should be using)
/// see \ref zoneusage for detailed usage instructions in both IB and programatically
@IBDesignable
public class AAZoneView: UIView, AASDKObserver, UIGestureRecognizerDelegate, AAZoneRenderer {

    @IBInspectable public var zoneId: String?
    internal weak var zoneOwner: AAZoneViewOwner?
    private(set) var type: AdTypeAndSource?
    
    @objc public func setZoneOwner(_ zoneOwner: AAZoneViewOwner?) {
        setZoneId(nil, zoneType: .kTypeUnsupportedAd, delegate: zoneOwner)
    }
    
    public func clientZoneView() -> AAZoneView? {
        return self
    }

    /// \brief constructor
    /// use AAAdAdaptedZoneView and AAMoPubBannerZoneView instead
    init(frame: CGRect, forZone zoneId: String?, zoneType type: AdTypeAndSource, delegate: AAZoneViewOwner?) {
        super.init(frame: frame)
        setZoneId(zoneId, zoneType: type, delegate: delegate)
        sharedInit()
        AASDK.logDebugFrame(self.frame, message: "AAZoneView \(zoneId ?? "") initWithFrame")
    }

    /// \brief let the AAZoneView know it needs to rotate, and maybe load another ad
    /// \param newOrientation the new orientation (the one you're going to).
    /// see \ref zoneusage for more details
    func rotate(to newOrientation: UIInterfaceOrientation) {
        adProvider()?.rotate(to: newOrientation)
    }

    /// \brief the size, according the server, of the content
    /// - Returns: the size of the ad, as returned from the API
    func adContentViewSize(for orientation: UIInterfaceOrientation) -> CGSize {
        if adProvider() != nil {
            let size = adProvider()?.adSize(for: orientation)
            AASDK.logDebugMessage(String(format: "AAZoneView returning ad size of (%0.0f, %0.0f) in adContentViewSizeForOrientation", size?.width ?? 0.0, size?.height ?? 0.0), type: AASDK_DEBUG_AD_LAYOUT)
            return size ?? CGSize.zero
        }
        AASDK.logDebugMessage("AAZoneView returning ad size of (0, 0) in adContentViewSizeForOrientation", type: AASDK_DEBUG_AD_LAYOUT)
        return CGSize(width: 0, height: 0)
    }

    /// \brief load next ad
    /// MoPub ads will flicker even if they don't load new content - AdAdapted ZoneView are noop if ad is unchanged
    func advanceToNextAd() {
        if adProvider() != nil {
            adProvider()?.renderNext()
        }
    }

    /// \brief close the zone's popup ad
    /// - Returns: true if the popup will close in response to this request
    /// only responds if the AAZoneViewOwner's zoneView:hadPopupSendURLString: method is called. allows the application the ability to close the popup ad once the app has finished doing what it was getting into.
    //- (CGSize)intrinsicContentSize
    //{
    //    CGSize size = [AASDK sizeOfZone:_zoneId forOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    //    [AASDK logDebugMessage:[NSString stringWithFormat:@"AAZoneView returning ad size of (%0.0f, %0.0f) in intrinsicContentSize", size.width, size.height] type:AASDK_DEBUG_AD_LAYOUT];
    //    return size;
    //}

    func closePopup() -> Bool {
        return adProvider()?.closePopup() ?? false
    }

    /// \brief close the zone's popup ad
    /// \param handler is called once the popup view controller has been removed.
    /// - Returns: true if the popup will close in response to this request. handler() is called only in the case where the return value is true.
    /// only responds if the AAZoneViewOwner's zoneView:hadPopupSendURLString: method is called. allows the application the ability to close the popup ad once the app has finished doing what it was getting into.
    func closePopup(withCompletionHandler handler: @escaping () -> Void) -> Bool {
        return adProvider()?.closePopup(withCompletionHandler: handler) ?? false
    }

    /// \brief used by Interface Builder
    /// \param value an NSNumber that gets converted to AdTypeAndSource
    /// have to convert from NSNumber to int when setting type from Interface Builder. using AAAdAdaptedZoneView and AAMoPubBannerZoneView means you can ignore this.
    /// for use in IB only
    func setZoneType(_ value: NSNumber?) {
        if let value = value {
            let ii = value.intValue
            type = AdTypeAndSource(rawValue: ii)
        }
    }

    /// \brief in JSON Ads, this hook is how you report user interaction
    /// since JSON Ads are built by you (the client developer) you need a way to report the user interacted, and the popup (or whatnot) needs to be opened.
    func userInteractedWithAd() {
        AASDK.logDebugMessage("AAZoneView: userInteractedWithAd enter", type: AASDK_DEBUG_USER_INTERACTION)
        if adProvider() != nil {
            adProvider()?.userInteractedWithAd()
        } else {
            AASDK.logDebugMessage("AAZoneView: NO AD PROVIDER", type: AASDK_DEBUG_USER_INTERACTION)
        }
    }

    /// \brief only to be used when AAZoneView can't be removed, but is no longer visible
    /// reports an impression has ended. this should only be called if you're obscuring an ad (rather than removing it).
    /// see \ref zoneusage_zoneLifeCycle
    func wasHidden() {
        if let provider = provider {
            provider.adWasHidden()
        }
    }

    /// \brief only to be used when AAZoneView couldn't be removed, but is no longer obscured
    /// calling this before wasHidden has no effect. reports an impression has re-started for an ad that wasHidden has been called on. this should only be called if you're obscuring an ad (rather than removing it).
    /// see \ref zoneusage_zoneLifeCycle
    func wasUnHidden() {
        if let provider = provider {
            if let ad = adProvider()?.currentAd() {
                AASDK.fireHTMLTracker(incomingAd: ad, incomingView: zoneOwner?.viewControllerForPresentingModalView()?.view)
                provider.adWasUnHidden()
            }
        }
    }

    private var provider: AAAbstractAdProvider?
    private var currentAdView: UIView?

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
//        adProvider()?.destroy()
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

// MARK: - PUBLIC

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

    func aaSDKError(_ error: Notification?) {
        //no-op
    }

    func aaSDKGetAdsComplete(_ notification: Notification?) {
        advanceToNextAd()
    }

    func aaSDKCacheFailure(_ notification: Notification?) {
    }

    func aaSDKCacheUpdated(_ notification: Notification?) {
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
            //adProvider() = nil
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
