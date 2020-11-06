//
//  AAErrorResponse.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//
import Foundation

class AAErrorResponse: AAGenericResponse {
    var aaRequest: AAGenericRequest?
    var nsHTTPURLResponse: HTTPURLResponse?
    var error: Error?
    var errorMessage: String?
    var json: Any?
}
