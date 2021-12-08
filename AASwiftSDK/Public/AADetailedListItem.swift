import Foundation

@objc public class AADetailedListItem: NSObject {
    var payloadId = ""
    var trackingId = ""
    @objc public var productTitle = ""
    @objc public var productImageURL: URL?
    @objc public var productBrand: String?
    @objc public var productCategory: String?
    @objc public var productBarcode: String?
    @objc public var retailerId: String?
    @objc public var productDescription: String?
    @objc public var productUpc: String?
    @objc public var retailerSku: String?
    
    class func parse(fromItemDictionary dictionary: [AnyHashable : Any]?, forPayload payloadId: String) -> AADetailedListItem? {
        let trackingId = dictionary?[AA_KEY_TRACKING_ID] as? String
        let productTitle = dictionary?[PRODUCT_TITLE] as? String
        
        if trackingId != nil && productTitle != nil && (trackingId?.count ?? 0) > 0 && (productTitle?.count ?? 0) > 0 {
            let returnItem = AADetailedListItem()
            returnItem.trackingId = trackingId!
            returnItem.payloadId = payloadId
            returnItem.productTitle = productTitle!
            returnItem.productBrand = dictionary?[PRODUCT_BRAND] as? String
            returnItem.productCategory = dictionary?[PRODUCT_CATEGORY] as? String
            returnItem.productBarcode = dictionary?[PRODUCT_BARCODE] as? String
            returnItem.productUpc = dictionary?[PRODUCT_BARCODE] as? String
            returnItem.retailerSku = dictionary?[PRODUCT_SKU] as? String

            let url = dictionary?[PRODUCT_IMAGE] as? NSObject
            if url != nil && (url is NSString) {
                returnItem.productImageURL = URL(string: (url as? String) ?? "")
            }
            return returnItem
        }
        return nil
    }

    func toDictionary() -> [AnyHashable : Any]? {
        var item = [
            AA_KEY_TRACKING_ID: trackingId,
            PRODUCT_TITLE: productTitle
        ]
        if (productBrand != nil) {
            item[PRODUCT_BRAND] = productBrand
        }
        if (productCategory != nil) {
            item[PRODUCT_CATEGORY] = productCategory
        }
        if (productBarcode != nil) {
            item[PRODUCT_BARCODE] = productBarcode
        }
        if (productUpc != nil) {
            item[PRODUCT_BARCODE] = productUpc
        }
        if (retailerSku != nil) {
            item[PRODUCT_SKU] = retailerSku
        }
        if (retailerId != nil) {
            item[RETAILER_ID] = retailerId
        }
        if (productImageURL != nil) {
            item[PRODUCT_IMAGE] = productImageURL?.absoluteString
        }

        return [
            AA_KEY_PAYLOAD_ID: payloadId,
            "detailed_list_item": item
        ]
    }
}
