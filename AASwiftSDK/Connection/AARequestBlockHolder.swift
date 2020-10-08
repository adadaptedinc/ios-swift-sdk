//  Converted to Swift 5.2 by Swiftify v5.2.23024 - https://swiftify.com/
//
//  AARequestBlockHolder.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation

typealias AAResponseWasErrorBlock = (AAErrorResponse?, AAGenericRequest?, Error?) -> Void
typealias AAResponseWasReceivedBlock = (AAGenericResponse?, AAGenericRequest?) -> Void

@objcMembers
class AARequestBlockHolder: NSObject {
    var request: AAGenericRequest?
    var requestWasErrorBlock: AAResponseWasErrorBlock?
    var responseWasReceivedBlock: AAResponseWasReceivedBlock?
}
