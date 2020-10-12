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
    var minMatchLength = 0
    var keywordIntercepts: [AnyHashable]?
}
