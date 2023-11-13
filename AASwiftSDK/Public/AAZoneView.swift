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

@objc public class AAZoneView: UIView, AASDKObserver, UIGestureRecognizerDelegate, AAZoneRenderer {

    @IBInspectable public var zoneId: String? = ""
    var isAdVisible = true
    internal weak var zoneOwner: AAZoneViewOwner?
    private(set) var type: AdTypeAndSource?
    private var provider: AAAdAdaptedAdProvider?
    private var currentAdView: UIView?
    private var reportAdView: UIButton = UIButton(type: .custom)
    private var reportAdUrlComponents = URLComponents()

    init(frame: CGRect, forZone zoneId: String?, zoneType type: AdTypeAndSource, delegate: AAZoneViewOwner?) {
        super.init(frame: frame)
        setZoneId(zoneId, zoneType: type, delegate: delegate)
        sharedInit()
        AASDK.logDebugFrame(self.frame, message: "AAZoneView \(zoneId ?? "") initWithFrame")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        sharedInit()
        AASDK.logDebugFrame(frame, message: "AAZoneView initWithCoder")
    }

    deinit {
        removeListeners()
        //clear recipe context automatically
        clearAdZoneContext()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        if let type1 = AdTypeAndSource(rawValue: -1) {
            setZoneId(nil, zoneType: type1, delegate: nil)
        }
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

    func sharedInit() {
        registerListeners()
    }

    @objc public func setZoneOwner(_ zoneOwner: AAZoneViewOwner?) {
        setZoneId(nil, zoneType: .kTypeUnsupportedAd, delegate: zoneOwner)
    }

    @objc public func getZoneOwner() -> AAZoneViewOwner? {
        return zoneOwner
    }

    public func clientZoneView() -> AAZoneView? {
        return self
    }

    func rotate(to newOrientation: UIInterfaceOrientation) {
        adProvider()?.rotate(to: newOrientation)
    }

    func adContentViewSize(for orientation: UIInterfaceOrientation) -> CGSize {
        if adProvider() != nil {
            let size = adProvider()?.adSize(for: orientation)
            AASDK.logDebugMessage(String(format: "AAZoneView returning ad size of (%0.0f, %0.0f) in adContentViewSizeForOrientation", size?.width ?? 0.0, size?.height ?? 0.0), type: AASDK.DEBUG_AD_LAYOUT)
            return size ?? CGSize.zero
        }
        AASDK.logDebugMessage("AAZoneView returning ad size of (0, 0) in adContentViewSizeForOrientation", type: AASDK.DEBUG_AD_LAYOUT)
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
        return adProvider()?.closePopup(completionHandler: handler) ?? false
    }

    func setZoneType(_ value: NSNumber?) {
        if let value = value {
            let ii = value.intValue
            type = AdTypeAndSource(rawValue: ii)
        }
    }

    func userInteractedWithAd() {
        AASDK.logDebugMessage("AAZoneView: userInteractedWithAd enter", type: AASDK.DEBUG_USER_INTERACTION)
        if adProvider() != nil {
            adProvider()?.userInteractedWithAd()
        } else {
            AASDK.logDebugMessage("AAZoneView: NO AD PROVIDER", type: AASDK.DEBUG_USER_INTERACTION)
        }
    }

    @objc
    func reportAdAction(sender: UIButton) {
        guard let reportAdUrl = reportAdUrlComponents.url else { return }
        UIApplication.shared.open(reportAdUrl)
    }

    @objc public func setAdZoneVisibility(isViewable: Bool) {
        isAdVisible = isViewable
        provider?.onAdVisibilityChange(isAdVisible: isAdVisible)
    }
    
    @objc public func setAdZoneContext(contextID: String) {
        _aasdk?.zoneContext.setProps(zoneId ?? "", contextID) //set contextual zone properties
        provider?.onZoneContextChanged(zoneId: _aasdk?.zoneContext.zoneId ?? "", contextId: _aasdk?.zoneContext.contextId ?? "")
    }
    
    @objc public func clearAdZoneContext() {
        _aasdk?.zoneContext.setProps("", "") //clear contextual zone properties
        provider?.onZoneContextChanged(zoneId: _aasdk?.zoneContext.zoneId ?? "", contextId: _aasdk?.zoneContext.contextId ?? "")
    }

// MARK: - <AAZoneRenderer> used by the AAAdAdaptedAdProvider
    func containerSize() -> CGSize {
        let size = frame.size
        AASDK.logDebugMessage(String(format: "AAZoneView returning ad size of (%0.0f, %0.0f) in intrinsicContentSize", size.width, size.height), type: AASDK.DEBUG_AD_LAYOUT)
        return size
    }

    func viewControllerForPresentingModalView() -> UIViewController? {
        return zoneOwner?.viewControllerForPresentingModalView()
    }

    func provider(_ provider: AAAdAdaptedAdProvider?, didLoadAdView adView: UIView?, for ad: AAAd?) {
        pointView(to: adView, ad: ad)
        AASDK.fireHTMLTracker(incomingAd: ad, incomingView: zoneOwner?.viewControllerForPresentingModalView()?.view)

        if zoneOwner?.responds(to: #selector(AAZoneViewOwner.zoneViewDidLoadZone(_:))) ?? false {
            zoneOwner?.zoneViewDidLoadZone?(self)
        }
    }

    func handleReloadOf(_ ad: AAAd?) {
        AASDK.fireHTMLTracker(incomingAd: ad, incomingView: zoneOwner?.viewControllerForPresentingModalView()?.view)
    }

    func provider(_ provider: AAAdAdaptedAdProvider?, didFailToLoadZone zone: String?, ofType type: AdTypeAndSource, message: String?) {
        if currentAdView != nil {
            pointView(to: nil, ad: nil)
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
            reportAdView.removeFromSuperview()
        }
    }

    func userDidInteract(withInternalURLString urlString: String?) {
        if zoneOwner?.responds(to: #selector(AAZoneViewOwner.zoneView(_:hadPopupSendURLString:))) ?? false {
            zoneOwner?.zoneView?(self, hadPopupSendURLString: urlString)
        }
    }

// MARK: - Ad Rendering
    func pointView(to newAdView: UIView?, ad: AAAd?) {
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

        AASDK.logDebugFrame(self.frame, message: "AAZoneView \(zoneId ?? "") rendering ad. The AAZoneView's frame is")
        let frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        currentAdView?.frame = frame

        reportAdView.setImage(UIImage(named: "reportAdIcon", in: Bundle(for: AAZoneView.self), compatibleWith: nil), for: .normal)

        if let adId = ad?.adID, let uid = UserDefaults.standard.string(forKey: AA_KEY_UDID) {
            let queryItems = [URLQueryItem(name: "aid", value: adId.addingPercentEncoding(withAllowedCharacters: .alphanumerics)), URLQueryItem(name: "uid", value: uid.addingPercentEncoding(withAllowedCharacters: .alphanumerics))]
            reportAdUrlComponents.scheme = "https"
            reportAdUrlComponents.path = _aasdk?.testMode() == true ? AA_REPORT_AD_DEV : AA_REPORT_AD_BASE
            reportAdUrlComponents.queryItems = queryItems
        }

        reportAdView.addTarget(self, action: #selector(reportAdAction), for: .touchUpInside)
        reportAdView.frame = CGRect(x: (Int(frame.width)) - 25, y: (Int(frame.height) - (Int(frame.height) - 10)), width: 14, height: 14)
        reportAdView.backgroundColor = .clear
        reportAdView.clipsToBounds = true
        reportAdView.setNeedsLayout()
        reportAdView.layoutIfNeeded()

        if let currentAdView = currentAdView {
            self.addSubview(currentAdView)
            self.addSubview(reportAdView)
        }

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
    func adProvider() -> AAAdAdaptedAdProvider? {
        return provider
    }

    func setAdProvider(_ adProvider: AAAdAdaptedAdProvider?) {
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

        switch self.type {
            case .kAdAdaptedImageAd, .kAdAdaptedJSONAd:
            self.setAdProvider(AAAdAdaptedAdProvider(zoneRenderer: self, zone: self.zoneId, adType: self.type!, zoneView: self))
                advanceToNextAd()
            default:
                break
        }
    }
}
