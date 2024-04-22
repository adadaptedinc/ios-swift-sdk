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
        DispatchQueue.main.async(execute: { [weak self] in
            guard let self = self else { return }
            if self.adProvider()?.getCurrentAd()!.jsonAdPayload == nil || self.adProvider()?.getCurrentAd()?.jsonAdPayload?.count == 0 {
                let message = "ad \(String(describing: self.adProvider()?.getCurrentAd()!.adID)) in zone \(String(describing: self.zoneId)) missing json payload"
                Logger.consoleLogError(nil, withMessage: message, suppressTracking: true)
                AASDK.trackAnomalyAdConfiguration(self.adProvider()?.getCurrentAd(), message: message)
                self.adProvider()?.zoneRenderer!.provider(self.adProvider(), didFailToLoadZone: self.zoneId, ofType: AdTypeAndSource.kAdAdaptedJSONAd, message: "JSON ad payload missing")
            } else {
                self.layoutAssets(self.adProvider()?.getCurrentAd()!.jsonAdPayload)
            }
        })
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
