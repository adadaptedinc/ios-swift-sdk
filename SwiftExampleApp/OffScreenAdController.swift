//
//  OffScreenAdController.swift
//  SwiftExampleApp
//
//  Created by Matthew Kruk on 8/31/21.
//  Copyright © 2021 AdAdapted. All rights reserved.
//

import AASwiftSDK
import UIKit

class OffScreenAdContoller: UIViewController, UIScrollViewDelegate, AAZoneViewOwner {

    @IBOutlet weak var offScreenScrollView: UIScrollView!
    @IBOutlet weak var offScreenZoneView: AdAdaptedZoneView!

    override func viewDidLoad() {
        super.viewDidLoad()

        offScreenScrollView.delegate = self
        offScreenZoneView.setZoneOwner(self)
        offScreenZoneView.setAdZoneVisibility(isViewable: false)
    }

    func viewControllerForPresentingModalView() -> UIViewController? {
        return self
    }

    func zoneViewDidLoadZone(_ view: AAZoneView?) {
        if let zoneId = view?.zoneId {
            print("Zone \(zoneId) loaded")
        }
    }

    func zoneViewDidFail(toLoadZone view: AAZoneView?) {
        print("Zone loading failed")
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if offScreenScrollView != nil {
            let onScreen = isVisible(view: offScreenZoneView)
            // Set ad zone visibility here for accurate tracking of off screen ads
            offScreenZoneView.setAdZoneVisibility(isViewable: onScreen)
        }
    }

    // determines if view is visible on screen
    func isVisible(view: UIView) -> Bool {
        func isVisible(view: UIView, onScreen: UIView?) -> Bool {
            guard let onScreen = onScreen else { return true }
            let adFrame = onScreen.convert(view.bounds, from: view)
            if adFrame.intersects(onScreen.bounds) {
                return isVisible(view: view, onScreen: onScreen.superview)
            }
            return false
        }
        return isVisible(view: view, onScreen: view.superview)
    }
}
