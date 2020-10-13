//
//  AAContentPayload.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation

@objc public class AAContentPayload: NSObject {
    /// For AdAdapted use
    var payloadId = ""
    /// Message to display the user
    var payloadMessage: String?
    /// https image URL
    var payloadImageURL: URL?
    /// always 'detailed_list_items' at this time
    var payloadType = ""
    /// array of items
    @objc public var detailedListItems: [AADetailedListItem] = []
    
    class func parse(fromDictionary dictionary: [AnyHashable : Any]?) -> Self? {
        if dictionary == nil {
            return nil
        }

        let payloadId = dictionary?["payload_id"] as? String
        if payloadId != nil && (payloadId?.count ?? 0) > 0 {
            let returnItem = AAContentPayload()
            returnItem.payloadId = payloadId ?? ""
            returnItem.payloadMessage = dictionary?["payload_message"] as? String
            returnItem.payloadImageURL = URL(string: dictionary?["payload_image"] as? String ?? "")
            let items = dictionary?["detailed_list_items"] as? [AnyHashable]
            if items != nil && (items != nil) {
                var returnItems = [AADetailedListItem]()
                returnItem.payloadType = "detailed_list_items"
                for item in items ?? [] {
                    guard let item = item as? [AnyHashable : Any] else {
                        continue
                    }
                    if item.count > 0 {
                        let dItem = AADetailedListItem.parse(fromItemDictionary: item, forPayload: payloadId ?? "")
                        if dItem != nil {
                            returnItems.append(dItem!)
                        }
                    } else {
                        //TODO: - no detailed_list_item isn't in array
                    }
                    // end of items loop
                }
                returnItem.detailedListItems = returnItems
                return returnItem as? Self
            } else {
                //TODO: - detailed_list_items isn't present
            }
        } else {
            //TODO: - no payloadId
        }

        return nil
    }

    func toDictionary() -> [AnyHashable : Any]? {
        return nil
    }

    @objc public func acknowledge() {
        do {
            for item in detailedListItems {
                if item.productTitle.count > 0 {
                    AASDK.reportItem(item.productTitle, from: self)
                }
            }

            AASDK.reportPayloadReceived(self, ontoList: nil)
        }
    }

    func reportReceivedOntoList(_ list: String?) {
        AASDK.reportPayloadReceived(self, ontoList: list)
    }

    func reportRejected() {
        AASDK.reportPayloadRejected(self)
    }
}
