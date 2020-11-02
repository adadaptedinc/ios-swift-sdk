//
//  AAGetAdResponse.h
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

@objc
class AAUpdateAdsResponse: AAGenericResponse {
    var zones: [AnyHashable : Any]?
    var sessionId: String?
    var pollingIntervalInMS = 0
}
