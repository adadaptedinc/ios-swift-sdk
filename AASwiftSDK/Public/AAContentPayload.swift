//
//  AAContentPayload.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation

@objc public class AAContentPayload: NSObject {
    var payloadId = ""
    @objc public var payloadMessage: String?
    @objc public var payloadImageURL: URL?
    @objc public var payloadType = ""
    @objc public var detailedListItems: [AADetailedListItem] = []
    
    class func parse(fromDictionary dictionary: [AnyHashable: Any]?) -> Self? {
        if dictionary == nil {
            return nil
        }

        let payloadId = dictionary?[AA_KEY_PAYLOAD_ID] as? String
        if payloadId != nil && (payloadId?.count ?? 0) > 0 {
            let returnItem = AAContentPayload()
            returnItem.payloadId = payloadId ?? ""
            returnItem.payloadMessage = dictionary?["payload_message"] as? String
            returnItem.payloadImageURL = URL(string: dictionary?["payload_image"] as? String ?? "")
            let items = dictionary?[DETAILED_LIST_ITEMS] as? [AnyHashable]
            if items != nil && (items != nil) {
                var returnItems = [AADetailedListItem]()
                returnItem.payloadType = DETAILED_LIST_ITEMS
                for item in items ?? [] {
                    guard let item = item as? [AnyHashable: Any] else {
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

    func toDictionary() -> [AnyHashable: Any]? {
        var items = [AnyHashable: Any]()

        for item in detailedListItems {

            if !item.trackingId.isEmpty {
                items[AA_KEY_TRACKING_ID] = item.trackingId
            }
            if !item.productTitle.isEmpty {
                items[PRODUCT_TITLE] = item.productTitle
            }
            if (item.productBrand != nil) {
                items[PRODUCT_BRAND] = item.productBrand
            }
            if (item.productCategory != nil) {
                items[PRODUCT_CATEGORY] = item.productCategory
            }
            if (item.productBarcode != nil) {
                items[PRODUCT_BARCODE] = item.productBarcode
            }
            if (item.productUpc != nil) {
                items[PRODUCT_BARCODE] = item.productUpc
            }
            if (item.retailerSku != nil) {
                items[PRODUCT_SKU] = item.retailerSku
            }
            if (item.retailerId != nil) {
                items[RETAILER_ID] = item.retailerId
            }
            if (item.productImageURL != nil) {
                items[PRODUCT_IMAGE] = item.productImageURL?.absoluteString
            }
        }
        return items
    }

    @objc public func acknowledge() {
        do {
            for item in detailedListItems {
                if item.productTitle.count > 0 {
                    AASDK.reportItem(item.productTitle, from: self)
                }
            }
            AASDK.reportPayloadReceived(self)
        }
    }

    @objc public func reportReceivedOntoList(_ list: String?) {
        AASDK.reportPayloadReceived(self)
    }

    @objc public func reportRejected() {
        AASDK.reportPayloadRejected(self)
    }
}
