//
//  AAAdAdaptedZoneView.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import UIKit

@objc public class AdAdaptedZoneView: AAZoneView {
    @objc public init(frame: CGRect, forZone zoneId: String?, delegate: AAZoneViewOwner?, isVisible: Bool = true) {
        super.init(frame: frame, forZone: zoneId, zoneType: .kAdAdaptedImageAd, delegate: delegate, isVisible: isVisible)
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        setZoneId(nil, zoneType: .kAdAdaptedImageAd, delegate: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
