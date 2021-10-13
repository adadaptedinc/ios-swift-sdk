//
//  AAAbstractAdProvider.swift
//  AASwiftSDK
//
//  Created by Brett Clifton on 9/21/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation
import UIKit

protocol AAZoneRenderer: NSObjectProtocol {
    var zoneId: String? { get set }
    var zoneOwner: AAZoneViewOwner? { get set }
    func containerSize() -> CGSize
    func viewControllerForPresentingModalView() -> UIViewController?
    func provider(_ provider: AAAbstractAdProvider?, didLoadAdView adView: UIView?, for ad: AAAd?)
    func provider(_ provider: AAAbstractAdProvider?, didFailToLoadZone zone: String?, ofType type: AdTypeAndSource, message: String?)
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

class AAAbstractAdProvider: NSObject {
    weak var zoneRenderer: AAZoneRenderer?
    var zoneId: String?
    weak var targetView: UIView?
    var isDisplayingPopup = false
    weak var zoneView: AAZoneView?
    var type: AdTypeAndSource?

    init(zoneRenderer: AAZoneRenderer?, zone zoneId: String?, andType type: AdTypeAndSource, zoneView: AAZoneView?) {
        super.init()
        if zoneId == nil || (zoneId?.count ?? 0) == 0 {
            print("Error - attempting to create AAAbstractAdProvider with nil or empty zoneId.")
        }
        self.zoneRenderer = zoneRenderer
        self.zoneId = zoneId
        self.type = type
        isDisplayingPopup = false
    }

    func rotate(to newOrientation: UIInterfaceOrientation) {
        
    }

    func adSize(for orientation: UIInterfaceOrientation) -> CGSize {
        return CGSize()
    }

    func renderNext() {
        
    }

    func destroy() {
        
    }

    func closePopup() -> Bool {
        return false
    }

    func closePopup(withCompletionHandler handler: @escaping () -> Void) -> Bool {
        return false
    }

    func currentAd() -> AAAd? {
        return AAAd()
    }

    func userInteractedWithAd() {
        
    }

    func adWasHidden() {
        
    }

    func adWasUnHidden() {
        
    }

    func renderCustomView(_ view: UIView?) {
        
    }
}
