//
//  AAAdAdaptedAdProvider.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation
import UIKit

@objcMembers
class AAAdAdaptedAdProvider: AAAbstractAdProvider, AAImageAdViewDelegate, AAPopupDelegate {
    var currentAd: AAAd?
    private var currentWebAdView: AAWebAdView?
    private var adLoaded = false
    private var useCachedImages = false
    private var isHidden = false
    private var allowPopupClose = false
    private var popupView: AAPopupViewController?
    private var timer: Timer?
    private var targetOrientation: UIInterfaceOrientation!

// MARK: - Overriding Abstract Methods
    override init(zoneRenderer: AAZoneRenderer?, zone zoneId: String?, andType type: AdTypeAndSource) {
        super.init(zoneRenderer: zoneRenderer, zone: zoneId, andType: type)
        // depandcy injection would be cleaner here
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

    override func adSize(for orientation: UIInterfaceOrientation) -> CGSize {
        return AASDK.sizeOfZone(zoneId, for: orientation)
    }

    /// there is a lot of logic here, but it allows us to rotate 
    /// different types of AdAdapted ads in the same zone without issue
    override func renderNext() {
        renderNextForceReload(false)
    }

    func renderNextForceReload(_ forceReload: Bool) {
        if !AASDK.isReadyForUse() || zoneId == nil || isDisplayingPopup {
            return
        }

        let oldAd = currentAd
        
        currentAd = AASDK.ad(forZone: zoneId, withAltImage: nil)

        if let oldAd = oldAd {
            AASDK.trackImpressionEnded(for: oldAd)
        }

        if AASDK.shouldHideAllAdsAfterView() {
            AASDK.remove(currentAd, fromZone: zoneId)
        }

        if oldAd == currentAd && !forceReload {
            AASDK.logDebugMessage("AdAdapted Zone \(String(describing: zoneId)) reloaded not needed.", type: AASDK_DEBUG_GENERAL)
            AASDK.trackImpressionStarted(for: currentAd)
            //zoneRenderer.handleReload(of: currentAd)
        } else if currentAd != nil {

            switch currentAd!.type {
            case .kAdAdaptedJSONAd:
                    zoneRenderer!.deliverAdPayload()
                    zoneRenderer!.provider(self, didLoadAdView: nil, for: currentAd)
            case .kAdAdaptedHTMLAd:
                    if currentWebAdView != nil {
                        if oldAd == currentAd {
                            AASDK.logDebugMessage("Web Zone \(String(describing: zoneId)) being reloaded", type: AASDK_DEBUG_GENERAL)
                        }
                        currentWebAdView?.destroy()
                    } else {
                        AASDK.logDebugMessage("Web Zone \(String(describing: zoneId)) being loaded", type: AASDK_DEBUG_GENERAL)
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
            AASDK.trackImpressionStarted(for: currentAd)
        } else {
            if AASDK.isReadyForUse() {
                zoneRenderer?.provider(self, didFailToLoadZone: zoneId, ofType: type!, message: "No AdAdapted ad for zone")
            }
        }

        fireTimer()
    }

    override func destroy() {
        stopTimer()
        AASDK.trackImpressionEnded(for: currentAd)

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

    override func rotate(to newOrientation: UIInterfaceOrientation) {
        targetOrientation = newOrientation
        renderNextForceReload(true)
    }

    /// only used by external calls
    override func closePopup() -> Bool {
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

    override func userInteractedWithAd() {
        AASDK.logDebugMessage("AdProvider: userInteractedWithAd enter", type: AASDK_DEBUG_USER_INTERACTION)
        takeActionForAd()
    }

    override func adWasHidden() {
        isHidden = true
        if let currentAd = currentAd {
            AASDK.trackImpressionEnded(for: currentAd)
        }
        stopTimer()
    }

    override func adWasUnHidden() {
        if isHidden {
            if let currentAd = currentAd {
                AASDK.trackImpressionStarted(for: currentAd)
                isHidden = false
                fireTimer()
            }
        }
    }

    override func renderCustomView(_ view: UIView?) {
        zoneRenderer!.provider(self, didLoadAdView: view, for: currentAd)
    }

// MARK: - <AAImageAdViewDelegate>
    func takeActionForAd() {
        if let actionType = currentAd?.actionType {
            AASDK.logDebugMessage("AdAdapted Zone \(String(describing: zoneId)) touched - taking action \(actionType)", type: AASDK_DEBUG_USER_INTERACTION)
        }

        if isHidden {
            if let currentAd = currentAd {
                AASDK.trackAnomalyHiddenInteraction(for: currentAd)
                print("AdAdapted SDK Usage Error: a ZoneView marked hidden was just interacted with.")
            }
        }

        if currentAd != nil && currentAd?.hideAfterInteraction != nil {
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
                    AASDK.logDebugMessage("Opening external URL: \(actionPath)", type: AASDK_DEBUG_GENERAL)
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
            AASDK.logDebugMessage("Zone \(String(describing: zoneId)) displaying popup from delegate", type: AASDK_DEBUG_GENERAL)
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
                //AASDK.consoleLogError(nil, withMessage: message, surpressTracking: true)
                if let currentAd = currentAd {
                    AASDK.trackAnomalyAdConfiguration(currentAd, message: message)
                }
        }

    }

    func webAdLoaded() {
        zoneRenderer?.provider(self, didLoadAdView: currentWebAdView, for: currentAd)
    }

    func adFailed(toLoad error: Error?) {
        zoneRenderer?.provider(self, didFailToLoadZone: zoneId, ofType: type!, message: "not sure yet")
    }

// MARK: - <AAPopupDelegate>
    func dismissPopup(_ popupView: AAPopupViewController?) {
        AASDK.logDebugMessage("Zone \(String(describing: zoneId)) dismissing popup from delegate", type: AASDK_DEBUG_GENERAL)
        isDisplayingPopup = false
        zoneRenderer!.viewControllerForPresentingModalView()!.dismiss(animated: true)
        if let currentAd = currentAd {
            AASDK.trackPopupEnded(for: currentAd)
        }
        zoneRenderer!.popupDidHide()
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
        AASDK.logDebugMessage("contentActionTakenWithString: b64", type: AASDK_DEBUG_USER_INTERACTION)
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
            if let currentAd = currentAd {
                AASDK.trackImpressionStarted(for: currentAd)
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
