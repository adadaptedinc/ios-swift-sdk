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
    var manualCreationZone: AdAdaptedZoneView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        offScreenZoneView.setAdZoneVisibility(isViewable: false)
        offScreenScrollView.delegate = self
        offScreenZoneView.setZoneOwner(self)
        
        manualCreationZone = AdAdaptedZoneView(frame: CGRect(x: 0, y: 0, width: 350, height: 100), forZone: "102110", delegate: self, isVisible: false)
        offScreenScrollView.addSubview(manualCreationZone)
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

    // determines if view is visible on screen
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = offScreenScrollView.contentSize.height
        let manualCreationY = contentHeight > offScreenScrollView.bounds.height ? contentHeight - manualCreationZone.frame.height : 0
        manualCreationZone.frame.origin.y = manualCreationY

        let viewFrame1 = scrollView.convert(offScreenZoneView.bounds, from: offScreenZoneView)
        let viewFrame2 = scrollView.convert(manualCreationZone.bounds, from: manualCreationZone)
        
        if viewFrame1.intersects(scrollView.bounds) {
            offScreenZoneView.setAdZoneVisibility(isViewable: true)
        } else {
            offScreenZoneView.setAdZoneVisibility(isViewable: false)
        }
        
        if viewFrame2.intersects(scrollView.bounds) {
            manualCreationZone.setAdZoneVisibility(isViewable: true)
        } else {
            manualCreationZone.setAdZoneVisibility(isViewable: false)
        }
    }
}
