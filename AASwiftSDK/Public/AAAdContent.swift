//
//  AAAdContent.swift
//  AASwiftSDK
//
//  Created by Brett Clifton on 9/21/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

@objc public class AAAdContent: NSObject {
    /// The ad associated with this ad content
    var ad: Any!
    /// array of items
    @objc public var detailedListItems: [AADetailedListItem] = []
    
    class func parse(fromDictionary dictionary: [AnyHashable : Any]?, ad: AAAd?) -> Self? {
        if dictionary == nil {
            return nil
        }

        var adContent: AAAdContent? = nil
        
        let items = dictionary?["list-items"] as? [AnyHashable]
        if items != nil && (items != nil) {
            adContent = AAAdContent.parseBasicListItemsArray(items) as? Self
        }

        let itemsDict = dictionary?["list-items"] as? [AnyHashable : Any]
        if itemsDict != nil && (itemsDict != nil) {
            adContent = AAAdContent.parseBasicListItemsDictionary(itemsDict) as? Self
        }

        let richItems = dictionary?["rich-list-items"] as? [AnyHashable]
        if richItems != nil && (richItems != nil) {
            adContent = AAAdContent.parseRichListItemsDictionary(richItems) as? Self
        }

        let detailedItems = dictionary?["detailed_list_items"] as? [AnyHashable]
        if detailedItems != nil && (detailedItems != nil) {
            adContent = AAAdContent.parseRichListItemsDictionary(detailedItems) as? Self
        }
        
        if let adContent = adContent {
            adContent.ad = ad
        }

        return adContent as? Self
    }


    class func parseBasicListItemsArray(_ items: [AnyHashable]?) -> Self? {
        var returnItems = [AADetailedListItem]()
        for itemString in items ?? [] {
            guard let itemString = itemString as? String else {
                continue
            }
            if itemString != "" {
                let dItem = AADetailedListItem()

                dItem.productTitle = itemString
                dItem.productBarcode = itemString
                returnItems.append(dItem)
            }
        }

        let content = AAAdContent()
        content.detailedListItems = returnItems
        return content as? Self
    }

    class func parseBasicListItemsDictionary(_ item: [AnyHashable : Any]?) -> Self? {
        let dItem = AAAdContent.parseDetailedListItemDictionary(item)!

        let content = AAAdContent()
        var items = [AADetailedListItem]()
        items.append(dItem)
        content.detailedListItems = items
        return content as? Self
    }

    class func parseRichListItemsDictionary(_ items: [AnyHashable]?) -> Self? {
        var returnItems = [AADetailedListItem]()

        for item in items ?? [] {
            guard let item = item as? [AnyHashable : Any] else {
                continue
            }
            let dItem = AAAdContent.parseDetailedListItemDictionary(item)
            if let dItem = dItem {
                returnItems.append(dItem)
            }
        }

        let content = AAAdContent()
        content.detailedListItems = returnItems
        return content as? Self
    }

    class func parseDetailedListItemDictionary(_ item: [AnyHashable : Any]?) -> AADetailedListItem? {
        let dItem = AADetailedListItem()
        dItem.productTitle = item?["product-title"] as? String ?? ""
        if dItem.productTitle.isEmpty {
            dItem.productTitle = item?["product_title"] as! String
        }

        if item?["product-image"] != nil {
            dItem.productImageURL = URL(string: (item?["product-image"] as? String) ?? "")
        } else if item?["product_image"] != nil {
            dItem.productImageURL = URL(string: (item?["product_image"] as? String) ?? "")
        }

        dItem.productDescription = item?["product-description"] as? String
        return dItem
    }
    
    @objc public func acknowledge() {
        do {
            for item in detailedListItems {
                if item.productTitle.count > 0 {
                    AASDK.reportItem(item.productTitle, addedToList: nil, from: ad as? AAAd)
                }
            }
        }
    }

    public func failure(_ message: String?) {
        AASDK.reportAddToListFailure(withMessage: message, from: (ad as? AAAd)!)
    }
}
