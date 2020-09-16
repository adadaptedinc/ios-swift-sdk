//  Converted to Swift 5.2 by Swiftify v5.2.23024 - https://swiftify.com/
//
//  AAKeywordInterceptEventRequest.h
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

@objcMembers
class AAKeywordInterceptBatchEventRequest: AAGenericRequest {
    init(events: [AnyHashable]?) {
        super.init()
        var dics : [Any] = []
        for event in events ?? [] {
            guard let event = event as? AAKeywordInterceptEvent else {
                continue
            }
            if let dictionary = event.asDictionary() {
                dics.append(dictionary)
            }
        }
        setParamValue(dics as NSObject, forKey: "events")
    }

// MARK: - AARequest Overrides
    override func targetURL() -> URL? {
        return super.url(forEndpoint: "intercepts/events")
    }

    override func parseResponse(fromJSON json: Any?) -> AAKeywordInterceptBatchEventResponse? {
        let response = AAKeywordInterceptBatchEventResponse()
        return response
    }

// MARK: - <NSCopying>
    override func copy(with zone: NSZone? = nil) -> Any {
        let request = super.copy(with: zone) as? AAKeywordInterceptBatchEventRequest
        return request!
    }
}
