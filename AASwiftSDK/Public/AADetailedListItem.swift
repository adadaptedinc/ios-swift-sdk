//
//  AADetailedListItem.swift
//  AASwiftSDK
//
//  Created by Brett Clifton on 9/21/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

@objc public class AADetailedListItem: NSObject {
    /// For AdAdapted use
    var payloadId = ""
    /// For AdAdapted use
    var trackingId = ""
    /// Text to add to list
    @objc public var productTitle = ""
    /// https image URL
    var productImageURL: URL?
    /// product brand
    var productBrand: String?
    /// A category for the product
    var productCategory: String?
    /// barcode
    var productBarcode: String?
    /// discount - things like 10% or $3 off
    var productDiscount: String?
    /// description - extra text information about the product
    var productDescription: String?
    /// product UPC
    var productUpc: String?
    /// retailer sku
    var retailerSku: String?
    
    class func parse(fromItemDictionary dictionary: [AnyHashable : Any]?, forPayload payloadId: String) -> AADetailedListItem? {
        let trackingId = dictionary?["tracking_id"] as? String
        let productTitle = dictionary?["product_title"] as? String
        if trackingId != nil && productTitle != nil && (trackingId?.count ?? 0) > 0 && (productTitle?.count ?? 0) > 0 {
            let returnItem = AADetailedListItem()
            returnItem.trackingId = trackingId!
            returnItem.payloadId = payloadId
            returnItem.productTitle = productTitle!
            returnItem.productBrand = dictionary?["product_brand"] as? String
            returnItem.productCategory = dictionary?["product_category"] as? String
            returnItem.productBarcode = dictionary?["product_barcode"] as? String
            returnItem.productUpc = dictionary?["product_barcode"] as? String
            returnItem.retailerSku = dictionary?["product_sku"] as? String

            let url = dictionary?["product_image"] as? NSObject
            if url != nil && (url is NSString) {
                returnItem.productImageURL = URL(string: (url as? String) ?? "")
            }
            return returnItem
        }
        return nil
    }

    func toDictionary() -> [AnyHashable : Any]? {
        var item = [
            "tracking_id": trackingId,
            "product_title": productTitle
        ]
        if (productBrand != nil) {
            item["product_brand"] = productBrand
        }
        if (productCategory != nil) {
            item["product_category"] = productCategory
        }
        if (productBarcode != nil) {
            item["product_barcode"] = productBarcode
        }
        if (productUpc != nil) {
            item["product_barcode"] = productUpc
        }
        if (retailerSku != nil) {
            item["product_sku"] = retailerSku
        }
        if (productDiscount != nil) {
            item["product_discount"] = productDiscount
        }
        if (productImageURL != nil) {
            item["product_image"] = productImageURL?.absoluteString
        }

        return [
            "payload_id": payloadId,
            "detailed_list_item": item
        ]
    }
}
