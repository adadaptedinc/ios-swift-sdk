//  Converted to Swift 5.2 by Swiftify v5.2.23024 - https://swiftify.com/
//
//  AAErrorResponse.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

class AAErrorResponse: AAGenericResponse {
    var aaRequest: AAGenericRequest?
    var nsHTTPURLResponse: HTTPURLResponse?
    var error: Error?
    var errorMessage: String?
    var json: Any?
}
