//
//  AAPayloadPickupResponse.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//
import Foundation

@objcMembers
class AAPayloadPickupResponse: AAGenericResponse {
    var result: String?
    var payloads: [AnyHashable]?
}
