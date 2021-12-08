//
//  AAAdAdaptedAdProvider.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation
import UIKit

protocol AAZoneRenderer: NSObjectProtocol {
    var zoneId: String? { get set }
    var zoneOwner: AAZoneViewOwner? { get set }
    func containerSize() -> CGSize
    func viewControllerForPresentingModalView() -> UIViewController?
    func provider(_ provider: AAAdAdaptedAdProvider?, didLoadAdView adView: UIView?, for ad: AAAd?)
    func provider(_ provider: AAAdAdaptedAdProvider?, didFailToLoadZone zone: String?, ofType type: AdTypeAndSource, message: String?)
    func popupWillShow()
    func popupDidHide()
    func userLeavingApplication()
    func userDidInteract(withInternalURLString urlString: String?)
    func deliverAdPayload()
    func handleCallToActionForZone()
    func handleReloadOf(_ ad: AAAd?)
    func invalidateContentView()
    func clientZoneView() -> AAZoneView?
}

@objcMembers
class AAAdAdaptedAdProvider: NSObject, AAImageAdViewDelegate, AAPopupDelegate {
    var currentAd: AAAd?
    var type: AdTypeAndSource?
    var zoneId: String?
    var isDisplayingPopup = false

    weak var targetView: UIView?
    weak var zoneView: AAZoneView?
    weak var zoneRenderer: AAZoneRenderer?

    private var currentWebAdView: AAWebAdView?
    private var adLoaded = false
    private var useCachedImages = false
    private var isHidden = false
    private var allowPopupClose = false
    private var popupView: AAPopupViewController?
    private var timer: Timer?
    private var targetOrientation: UIInterfaceOrientation!

    init(zoneRenderer: AAZoneRenderer?, zone zoneId: String?, andType type: AdTypeAndSource, zoneView: AAZoneView?) {
        super.init()

        if zoneId == nil || (zoneId?.count ?? 0) == 0 {
            print("Error - attempting to create AAAdAdaptedAdProvider with nil or empty zoneId.")
        }

        self.zoneView = zoneView
        self.zoneRenderer = zoneRenderer
        self.zoneId = zoneId
        self.type = type

        useCachedImages = AASDK.shouldUseCachedImages()
        adLoaded = false
        isHidden = false
        allowPopupClose = false

        targetOrientation = UIApplication.shared.statusBarOrientation

        NotificationCenterWrapper.notifier.addObserver(
            self,
            selector: #selector(going(toBackground:)),
            name: UIApplication.willResignActiveNotification,
            object: nil)

        NotificationCenterWrapper.notifier.addObserver(
            self,
            selector: #selector(coming(toForeground:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
    }

    func getCurrentAd() -> AAAd? {
        return currentAd
    }

    func adSize(for orientation: UIInterfaceOrientation) -> CGSize {
        return AASDK.sizeOfZone(zoneId, for: orientation)
    }

    // Visibility
    func onAdVisibilityChange(isAdVisible: Bool) {
        guard let currentAd = currentAd else { return }
        if !currentAd.impressionWasTracked() {
            trackImpression(currentAd, isAdVisible)
        }
    }

    func trackImpression(_ ad: AAAd?, _ isAdVisible: Bool) {
        if !isAdVisible { return }
        AASDK.trackImpressionStarted(for: ad, isVisible: isAdVisible)
        ad?.setImpressionTracked()
    }

    /// there is a lot of logic here, but it allows us to rotate
    /// different types of AdAdapted ads in the same zone without issue
    func renderNext() {
        renderNextForceReload(false)
    }

    func renderNextForceReload(_ forceReload: Bool) {
        if !AASDK.isReadyForUse() || zoneId == nil || isDisplayingPopup {
            return
        }

        let oldAd = currentAd

        currentAd = AASDK.ad(forZone: zoneId, withAltImage: nil)
        currentAd?.resetImpressionTracking()

        if let oldAd = oldAd {
            if zoneView?.isAdVisible == false && !oldAd.impressionWasTracked() {
                AASDK.trackInvisibleImpression(for: oldAd)
            }
            AASDK.trackImpressionEnded(for: oldAd)
        }

        if AASDK.shouldHideAllAdsAfterView() {
            AASDK.remove(currentAd, fromZone: zoneId)
        }

        if oldAd == currentAd && !forceReload {
            AASDK.logDebugMessage("AdAdapted Zone \(String(describing: zoneId)) reload not needed.", type: AASDK.DEBUG_GENERAL)
            //zoneRenderer.handleReload(of: currentAd)
        } else if currentAd != nil {

            if let zoneView = zoneView, let currentAd = currentAd {
                if !currentAd.impressionWasTracked() {
                    trackImpression(currentAd, zoneView.isAdVisible)
                }
            }

            switch currentAd!.type {
            case .kAdAdaptedJSONAd:
                    zoneRenderer!.deliverAdPayload()
                    zoneRenderer!.provider(self, didLoadAdView: nil, for: currentAd)
            case .kAdAdaptedHTMLAd:
                    if currentWebAdView != nil {
                        if oldAd == currentAd {
                            AASDK.logDebugMessage("Web Zone \(String(describing: zoneId)) being reloaded", type: AASDK.DEBUG_GENERAL)
                        }
                        currentWebAdView?.destroy()
                    } else {
                        AASDK.logDebugMessage("Web Zone \(String(describing: zoneId)) being loaded", type: AASDK.DEBUG_GENERAL)
                    }


                    if currentAd?.adURL != nil && (currentAd?.adURL?.count ?? 0) > 0 {
                        currentWebAdView = AAWebAdView(
                            url: URL(string: currentAd?.adURL ?? ""),
                            with: self,
                            ad: currentAd)
                    } else {
                        currentWebAdView = AAWebAdView(
                            html: currentAd?.adHTML,
                            with: self,
                            ad: currentAd)
                    }
            case .kAdAdaptedImageAd:
                    var adView: AAImageAdView?

                    if useCachedImages {
                        adView = currentAd?.imageView(for: targetOrientation)
                    } else {
                        adView = currentAd?.aaAsyncImageView
                        adView?.loadAsyncImage(for: targetOrientation)
                    }

                    if adView != nil {
                        adView?.delegate = self
                        zoneRenderer!.provider(self, didLoadAdView: adView, for: currentAd)
                    } else {
                        zoneRenderer!.provider(self, didFailToLoadZone: zoneId, ofType: type!, message: "No AdAdapted ad for zone")
                    }
                default:
                    zoneRenderer!.provider(self, didFailToLoadZone: zoneId, ofType: type!, message: "Unknown AdAdapted ad type")
            }
        } else {
            if AASDK.isReadyForUse() {
                zoneRenderer?.provider(self, didFailToLoadZone: zoneId, ofType: type!, message: "No AdAdapted ad for zone")
            }
        }

        fireTimer()
    }

    func destroy() {
        stopTimer()

        if zoneView?.isAdVisible == false {
            if let currentAd = currentAd, !currentAd.impressionWasTracked() {
                AASDK.trackInvisibleImpression(for: currentAd)
            }
        } else {
            AASDK.trackImpressionEnded(for: currentAd)
        }

        if currentAd?.type == AdTypeAndSource.kAdAdaptedHTMLAd && currentWebAdView != nil {
            currentWebAdView?.destroy()
        }

        currentAd = nil
        if isDisplayingPopup {
            dismissPopup(nil)
        }
        if popupView != nil {
            popupView?.destroy()
            popupView = nil
        }

        zoneId = nil
        type = AdTypeAndSource(rawValue: -1)
        zoneRenderer!.invalidateContentView()
        zoneRenderer = nil

        NotificationCenterWrapper.notifier.removeObserver(self)
    }

    func rotate(to newOrientation: UIInterfaceOrientation) {
        targetOrientation = newOrientation
        renderNextForceReload(true)
    }

    /// only used by external calls
    func closePopup() -> Bool {
        if allowPopupClose && isDisplayingPopup {
            dismissPopup(nil)
            return true
        }
        return false
    }

    func closePopup(completionHandler handler: @escaping () -> Void) -> Bool {
        if closePopup() {
            handler()
            return true
        }
        return false
    }

    func userInteractedWithAd() {
        AASDK.logDebugMessage("AdProvider: userInteractedWithAd enter", type: AASDK.DEBUG_USER_INTERACTION)
        takeActionForAd()
    }

    func adWasHidden() {
        isHidden = true
        if let currentAd = currentAd {
            AASDK.trackImpressionEnded(for: currentAd)
        }
        stopTimer()
    }

    func adWasUnHidden() {
        if isHidden {
            if let currentAd = currentAd, let zoneView = zoneView {
                trackImpression(currentAd, zoneView.isAdVisible)
                isHidden = false
                fireTimer()
            }
        }
    }

    func renderCustomView(_ view: UIView?) {
        zoneRenderer!.provider(self, didLoadAdView: view, for: currentAd)
    }

// MARK: - <AAImageAdViewDelegate>
    func takeActionForAd() {
        if let actionType = currentAd?.actionType {
            AASDK.logDebugMessage("AdAdapted Zone \(String(describing: zoneId)) touched - taking action \(actionType)", type: AASDK.DEBUG_USER_INTERACTION)
        }

        if isHidden {
            if let currentAd = currentAd {
                AASDK.trackAnomalyHiddenInteraction(for: currentAd)
                print("AdAdapted SDK Usage Error: a ZoneView marked hidden was just interacted with.")
            }
        }

        if currentAd != nil && currentAd?.hideAfterInteraction == true {
            if let currentAd = currentAd {
                AASDK.remove(currentAd, fromZone: zoneId)
            }
        }

        if let currentAd = currentAd {
            AASDK.trackInteraction(with: currentAd)
        }

        switch AAHelper.actionType(from: currentAd?.actionType) {

        case AASDKActionType.kActionAppDownload, AASDKActionType.kActionLink:
            zoneRenderer!.userLeavingApplication()
                if let actionPath = currentAd?.actionPath {
                    AASDK.logDebugMessage("Opening external URL: \(actionPath)", type: AASDK.DEBUG_GENERAL)
                }
                if let actionPath = currentAd?.actionPath {
                    if !UIApplication.shared.canOpenURL(actionPath) {
                        if let currentAd = currentAd {
                            AASDK.trackAppExit(from: currentAd, withPath: currentAd.actionPath?.absoluteString ?? "")
                        }
                    } else {
                        if let currentAd = currentAd {
                            AASDK.trackContentPayloadDelivered(from: currentAd, contentType: "url encoded")
                        }
                    }
                }
                if let actionPath = currentAd?.actionPath {
                    UIApplication.shared.open(actionPath)
                }

        case AASDKActionType.kActionPopup:
                if popupView == nil {
                    popupView = AAPopupViewController(for: currentAd, delegate: self)
                } else {
                    popupView?.setCurrentAd(currentAd)
                    popupView?.resetToRootURL()
                }
                allowPopupClose = false
            AASDK.logDebugMessage("Zone \(String(describing: zoneId)) displaying popup from delegate", type: AASDK.DEBUG_GENERAL)
            zoneRenderer!.popupWillShow()
                isDisplayingPopup = true
                if let popupView = popupView {
                    zoneRenderer!.viewControllerForPresentingModalView()!.present(popupView, animated: true)
                }

        case AASDKActionType.kActionDelegate:
                zoneRenderer!.handleCallToActionForZone()

        case AASDKActionType.kActionContent:
                if let jsonContentPayload = currentAd?.jsonContentPayload {
                    AASDK.deliverContent(jsonContentPayload, from: currentAd, andZoneView: zoneRenderer!.clientZoneView())
                }

        case AASDKActionType.kActionNone:
                fallthrough

        default:
            var message: String? = nil
            if let actionType = currentAd?.actionType {
                message = "ad.actionType not supported \(actionType)"
            }
            // AASDK.consoleLogError(nil, withMessage: message, surpressTracking: true)
            if let currentAd = currentAd {
                AASDK.trackAnomalyAdConfiguration(currentAd, message: message)
            }
        }
        renderNext()
    }

    func webAdLoaded() {
        zoneRenderer?.provider(self, didLoadAdView: currentWebAdView, for: currentAd)
    }

    func adFailed(toLoad error: Error?) {
        zoneRenderer?.provider(self, didFailToLoadZone: zoneId, ofType: type!, message: "not sure yet")
    }

// MARK: - <AAPopupDelegate>
    func dismissPopup(_ popupView: AAPopupViewController?) {
        AASDK.logDebugMessage("Zone \(String(describing: zoneId)) dismissing popup from delegate", type: AASDK.DEBUG_GENERAL)
        isDisplayingPopup = false
        zoneRenderer!.viewControllerForPresentingModalView()!.dismiss(animated: true)
        if let currentAd = currentAd {
            AASDK.trackPopupEnded(for: currentAd)
        }
        zoneRenderer!.popupDidHide()
        renderNext()
    }

    func userDidInteract(withInternalURLString url: String?) {
        allowPopupClose = true
        if let currentAd = currentAd {
            AASDK.trackInteraction(with: currentAd, withPath: url)
        }
        zoneRenderer!.userDidInteract(withInternalURLString: url)
    }

    func actionTaken(with string: String?) {
        allowPopupClose = true
        if let jsonContentPayload = currentAd?.jsonContentPayload {
            AASDK.deliverContent(jsonContentPayload, from: currentAd, andZoneView: zoneRenderer!.clientZoneView())
        }
    }

    func contentActionTaken(with string: String?) {
        allowPopupClose = true
        AASDK.logDebugMessage("contentActionTakenWithString: b64", type: AASDK.DEBUG_USER_INTERACTION)
        let decodedData = Data(base64Encoded: string ?? "", options: [])
        var contentJson: [AnyHashable : Any]? = nil
        do {
            if let decodedData = decodedData {
                contentJson = try JSONSerialization.jsonObject(with: decodedData, options: .allowFragments) as? [AnyHashable : Any]
            }
        } catch {
            AASDK.trackAnomalyGenericErrorMessage(error.localizedDescription, optionalAd: nil)
        }
        if let contentJson = contentJson {
            AASDK.deliverContent(contentJson, from: currentAd, andZoneView: zoneRenderer!.clientZoneView())
        }
    }

// MARK: - background & foreground
    @objc func going(toBackground notification: Notification?) {
        if !isHidden {
            if let currentAd = currentAd {
                AASDK.trackImpressionEnded(for: currentAd)
            }
        }
        stopTimer()
    }

    @objc func coming(toForeground notification: Notification?) {
        if !isHidden {
            if let currentAd = currentAd, let zoneView = zoneView {
                trackImpression(currentAd, zoneView.isAdVisible)
            }
        }
        fireTimer()
    }

// MARK: - TIMER
    func fireTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }

        if (currentAd?.refreshIntervalSeconds ?? 0) < 1 {
            var message: String? = nil
            if let adID = currentAd?.adID {
                message = "refesh time for ad \(adID) in zone \(String(describing: zoneId)) is zero - using 30s instead"
            }
            Logger.consoleLogError(nil, withMessage: message, suppressTracking: true)
        }

        let interval = TimeInterval((currentAd?.refreshIntervalSeconds ?? 0) > 0 ? TimeInterval(currentAd?.refreshIntervalSeconds ?? Int(0.0)) : 30)
        timer = Timer.scheduledTimer(
            timeInterval: interval,
            target: self,
            selector: #selector(timerFired(_:)),
            userInfo: nil,
            repeats: true)
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    @objc func timerFired(_ timer: Timer?) {
        renderNext()
    }
}
