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
    var manualCreation: AdAdaptedZoneView!

    override func viewDidLoad() {
        super.viewDidLoad()

//        manual creation
        //manualCreation = AdAdaptedZoneView(frame: .init(x: 0, y: 0, width: 350, height: 100), forZone: "102110", delegate: self, isVisible: false)
        //manualCreation.setAdZoneContext(contextID: "organic")
        //manualCreation.setAdZoneVisibility(isViewable: true)
        
        offScreenZoneView.setAdZoneVisibility(isViewable: false)
        offScreenScrollView.delegate = self
        offScreenZoneView.setZoneOwner(self)
        
        //offScreenScrollView.addSubview(manualCreation)
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
        if offScreenScrollView != nil {
            let viewFrame = scrollView.convert(offScreenZoneView.bounds, from: offScreenZoneView)
            if viewFrame.intersects(scrollView.bounds) {
                // Set ad zone visibility here for accurate tracking of off screen ads
                offScreenZoneView.setAdZoneVisibility(isViewable: true)
            } else {
                offScreenZoneView.setAdZoneVisibility(isViewable: false)

            }
        }
    }
}
