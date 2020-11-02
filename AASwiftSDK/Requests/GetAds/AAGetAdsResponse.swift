//
//  AAGetAdResponse.h
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

@objcMembers
class AAGetAdsResponse: AAGenericResponse {
    var ads: [AnyHashable : Any]?
}
