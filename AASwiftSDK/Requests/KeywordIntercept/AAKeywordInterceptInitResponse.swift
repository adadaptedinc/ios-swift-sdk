//  Converted to Swift 5.2 by Swiftify v5.2.23024 - https://swiftify.com/
//
//  AAKeywordInterceptResponse.h
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation

class AAKeywordInterceptInitResponse: AAGenericResponse {
    var searchId: String?
    var refreshSeconds = 0
 /*#D - don't know where/how to even use this? is the response just 0? pushed into other KI files? */    var minMatchLength = 0
    var keywordIntercepts: [AnyHashable]?
    var triggeredAds: [AnyHashable : Any]?
 //#d - mark deprecated
}
