//  Converted to Swift 5.2 by Swiftify v5.2.23024 - https://swiftify.com/
//
//  AAGetAdResponse.h
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

@objc
class AAUpdateAdsResponse: AAGenericResponse {
    /// ads in a dictionary with zoneId for key, and arrays of ads for values
    var zones: [AnyHashable : Any]?
    var sessionId: String?
    var pollingIntervalInMS = 0
}
