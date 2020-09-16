//  Converted to Swift 5.2 by Swiftify v5.2.23024 - https://swiftify.com/
//
//  AAAdAdaptedJSONZone.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation
import UIKit

/// \brief each natively rendered is (or contains) a sub-class of this
/// using this class ensures reporting of impressions is correct, and 
/// that Call To Actions are handled correctly.

class AAAdAdaptedJSONZoneView: AAZoneView {
    /// \brief constructor
    init(frame: CGRect, forZone zoneId: String?, delegate: AAZoneViewOwner?) {
        super.init(frame: frame, forZone: zoneId, zoneType: .kAdAdaptedJSONAd, delegate: delegate)
    }

    /// \brief MUST OVERRIDE IN SUBCLASS
    /// \param adAssets the raw data about the Ad.
    /// NOTE: this is called on the main thread so you can more easily update UI elements.
    func layoutAssets(_ adAssets: [AnyHashable : Any]?) {
        
    }

    /// \brief DO NOT OVERRIDE
    /// when the user interacts with your ad, call [self userInteractedWithAd] to activate 
    /// the Call To Action, most likely to show a popup.
    override func userInteractedWithAd() {
        AASDK.logDebugMessage("AAAdAdaptedJSONZoneView: userInteractedWithAd enter", type: AASDK_DEBUG_USER_INTERACTION)
        adProvider()?.userInteractedWithAd()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setZoneId(nil, zoneType: .kAdAdaptedJSONAd, delegate: nil)
    }

    override func deliverAdPayload() {
        DispatchQueue.main.async(execute: { [self] in
            if adProvider()?.currentAd()!.jsonAdPayload == nil || adProvider()?.currentAd()?.jsonAdPayload?.count == 0 {
                let message = "ad \(adProvider()?.currentAd()!.adID) in zone \(zoneId) missing json payload"
                AASDK.consoleLogError(nil, withMessage: message, suppressTracking: true)
                AASDK.trackAnomalyAdConfiguration(adProvider()?.currentAd(), message: message)
                adProvider()?.zoneRenderer!.provider(adProvider(), didFailToLoadZone: zoneId, ofType: AdTypeAndSource.kAdAdaptedJSONAd, message: "JSON ad payload missing")
            } else {
                layoutAssets(adProvider()?.currentAd()!.jsonAdPayload)
            }

        })
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
