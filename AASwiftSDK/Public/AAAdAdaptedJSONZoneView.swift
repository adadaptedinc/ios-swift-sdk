//
//  AAAdAdaptedJSONZone.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation
import UIKit

class AAAdAdaptedJSONZoneView: AAZoneView {
    init(frame: CGRect, forZone zoneId: String?, delegate: AAZoneViewOwner?) {
        super.init(frame: frame, forZone: zoneId, zoneType: .kAdAdaptedJSONAd, delegate: delegate)
    }

    func layoutAssets(_ adAssets: [AnyHashable : Any]?) {
        
    }

    /// \brief DO NOT OVERRIDE
    /// when the user interacts with your ad, call userInteractedWithAd to activate
    /// the Call To Action, most likely to show a popup.
    override func userInteractedWithAd() {
        AASDK.logDebugMessage("AAAdAdaptedJSONZoneView: userInteractedWithAd enter", type: AASDK.DEBUG_USER_INTERACTION)
        adProvider()?.userInteractedWithAd()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setZoneId(nil, zoneType: .kAdAdaptedJSONAd, delegate: nil)
    }

    override func deliverAdPayload() {
        DispatchQueue.main.async(execute: { [self] in
            if adProvider()?.currentAd()!.jsonAdPayload == nil || adProvider()?.currentAd()?.jsonAdPayload?.count == 0 {
                let message = "ad \(String(describing: adProvider()?.currentAd()!.adID)) in zone \(String(describing: zoneId)) missing json payload"
                Logger.consoleLogError(nil, withMessage: message, suppressTracking: true)
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
