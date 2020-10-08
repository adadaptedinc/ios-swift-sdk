//  Converted to Swift 5.2 by Swiftify v5.2.23024 - https://swiftify.com/
//
//  AAAdAdaptedZoneView.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import UIKit

/// \brief  Subclass of AAZoneView configured for AdAdapted image and html content

public class AAAdAdaptedZoneView: AAZoneView {
    /// \brief Constructor 
    /// \param frame where's it goin'
    /// \param zoneId the zone it's for
    /// \param delegate the owner that implements AAZoneViewOwner
    /// - Returns: a configured object
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
