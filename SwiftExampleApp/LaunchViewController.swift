//
//  LaunchViewController.swift
//  AASwiftExampleApp
//
//  Created by Brett Clifton on 7/31/20.
//  Copyright © 2020 AA. All rights reserved.
//

import UIKit
import WebKit
import AASwiftSDK

class LaunchViewController: UIViewController, WKUIDelegate, AASDKContentDelegate {
    @IBOutlet weak var launchLabel: UILabel!
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        AASDK.registerContentListeners(for: self)
    }
    
    @IBAction func testSendListManagerReports(_ sender: Any) {
        // Item added to list
        AASDK.reportItem("test_swift_product", addedToList: "swift_list")
        AASDK.reportItems(["swift_first","swift_second"], addedToList: "swift_list")

         //Item crossed off list
        AASDK.reportItem("test_swift_crossed_off_product", crossedOffList: "swift_list")
        AASDK.reportItems(["swift_first","swift_second"], crossedOffList: "swift_list")

         //Item removed from list
        AASDK.reportItem("test_swift_deleted_product", deletedFromList: "swift_list")
        AASDK.reportItems(["swift_first","swift_second"], deletedFromList: "swift_list")
        
        self.showToast(message: "Reports sent", font: .systemFont(ofSize: 14.0))
    }
    
    func aaPayloadNotification(_ notification: Notification) {
        print("*******Deeplink Payload Received*********")
        guard let userinfo = notification.userInfo else { return }
        let adPayload = userinfo[AASDK.KEY_CONTENT_PAYLOADS] as? [AAContentPayload]

        for payload in adPayload ?? [] {
               for item in payload.detailedListItems {
                print("From Payload -> AADetailedListItem: \(item.productTitle), \(String(describing: item.productBrand)), \(String(describing: item.productUpc)), \(String(describing: item.retailerSku)), \(String(describing: item.retailerId)), \(String(describing: item.productDescription))")
               }
               payload.acknowledge()
           }
    }
    
    func showToast(message : String, font: UIFont = .systemFont(ofSize: 14.0)) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 100, y: self.view.frame.size.height-100, width: 200, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

