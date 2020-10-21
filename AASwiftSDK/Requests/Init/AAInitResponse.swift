//
//  AAInitResponse.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation

class AAInitResponse: AAGenericResponse {
    /// ads in a dictionary with zoneId for key, and arrays of ads for values
    var zones: [AnyHashable : Any]?
    var pollingIntervalMS = 0
    var sessionExpiresAt = 0
    var sessionId: String?
}
