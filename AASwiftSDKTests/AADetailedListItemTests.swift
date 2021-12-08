@testable import AASwiftSDK
import XCTest

final class AADetailedListItemTests: XCTestCase {
    var detailedItem = [AnyHashable : Any]()
    var dictionary = AADetailedListItem()

    override func setUp() {
        detailedItem["payload_id"] = "957478"
        detailedItem["tracking_id"] = "65865865::7675865"
        detailedItem["product_title"] = "Spice"
        detailedItem["product_image"] = "https://images.adadapted.com/20200810_163018_SunMaid_SmoresBites_Hero_400x400.png"
        detailedItem["product_brand"] = "Melange"
        detailedItem["product_category"] = "Snacks"
        detailedItem["product_barcode"] = "041143510018"
        detailedItem["product_discount"] = "98302038"
        detailedItem["product_sku"] = "3874938498"
        detailedItem["product_description"] = "Delicious smores that you can take on the go!"
        detailedItem["product_barcode"] = "99802039923"
        detailedItem["product_discount"] = "99802039923"
        detailedItem["product_sku"] = "3059835"
        detailedItem["product_discount"] = "buy_more"

        dictionary = AADetailedListItem.parse(fromItemDictionary: detailedItem, forPayload: "957478")!
    }

    func testParse() {

        XCTAssertEqual(dictionary.payloadId, "957478")
        XCTAssertEqual(dictionary.trackingId, "65865865::7675865")
        XCTAssertEqual(dictionary.productTitle, "Spice")
        XCTAssertEqual(dictionary.productBrand, "Melange")
        XCTAssertEqual(dictionary.productCategory, "Snacks")
        XCTAssertEqual(dictionary.productUpc, "99802039923")
        XCTAssertEqual(dictionary.productBarcode, "99802039923")
        XCTAssertEqual(dictionary.retailerSku, "3059835")
        XCTAssertEqual(dictionary.productImageURL, URL(string: "https://images.adadapted.com/20200810_163018_SunMaid_SmoresBites_Hero_400x400.png"))
    }

    func testToDictionary() {
        let detailedListItem = dictionary.toDictionary()
        print(detailedListItem as Any)
        let itemDetails = (detailedListItem?["detailed_list_item"])! as! NSDictionary
        print(itemDetails)
        XCTAssertEqual(detailedListItem?[AA_KEY_PAYLOAD_ID] as? String, "957478")
        XCTAssertEqual(itemDetails[AA_KEY_TRACKING_ID] as? String, "65865865::7675865")
        XCTAssertEqual(itemDetails[PRODUCT_TITLE] as? String, "Spice")
        XCTAssertEqual(itemDetails[PRODUCT_BRAND] as? String, "Melange")
        XCTAssertEqual(itemDetails[PRODUCT_CATEGORY] as? String, "Snacks")
        XCTAssertEqual(itemDetails[PRODUCT_BARCODE] as? String, "99802039923")
        XCTAssertEqual(itemDetails[PRODUCT_SKU] as? String, "3059835")
        XCTAssertEqual(itemDetails[PRODUCT_IMAGE] as? String, "https://images.adadapted.com/20200810_163018_SunMaid_SmoresBites_Hero_400x400.png")
    }
}
