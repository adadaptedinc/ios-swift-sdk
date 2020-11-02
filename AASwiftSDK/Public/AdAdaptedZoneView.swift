//
//  AAAdAdaptedZoneView.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import UIKit

public class AdAdaptedZoneView: AAZoneView {
    init(frame: CGRect, forZone zoneId: String?, delegate: AAZoneViewOwner?) {
        super.init(frame: frame, forZone: zoneId, zoneType: .kAdAdaptedImageAd, delegate: delegate)
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        setZoneId(nil, zoneType: .kAdAdaptedImageAd, delegate: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
