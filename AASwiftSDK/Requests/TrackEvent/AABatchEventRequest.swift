//
//  AABatchEventRequest.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//
import Foundation

@objcMembers
class AABatchEventRequest: AAGenericRequest {
    private var version = 0
    
    init(events: Set<AnyHashable>?, forVersion version: Int) {
        super.init()
        self.version = version
        var dics: [Any] = []
        
        for event in events ?? [] {
            guard let event = event as? AAReportableSessionEvent else {
                continue
            }
            
            if let dict = event.asDictionary() {
                dics.append(dict)
            }
        }
        
        setParamValue(dics as NSObject, forKey: "events")
    }
    
    convenience init(events: Set<AnyHashable>?) {
        self.init(events: events, forVersion: 1)
    }

// MARK: - AARequest Overrides
    override func targetURL() -> URL? {
        switch version {
            case 2:
                let root = String(AASDK.serverRoot().dropLast(3))
                let url = "\(root)\("anomaly/track")"
                return URL(string: url)
            default:
                return super.url(forEndpoint: "ads/events")
        }
    }

    override func parseResponse(fromJSON json: Any?) -> AABatchEventResponse? {
        var response: AABatchEventResponse?
        response = AABatchEventResponse()
        response?.result = (json as? NSObject)?.value(forKey: "Result") as? String
        return response
    }

// MARK: - <NSCopying>
    override func copy(with zone: NSZone? = nil) -> Any {
        let request = super.copy(with: zone) as? AABatchEventRequest
        return request!
    }
}
