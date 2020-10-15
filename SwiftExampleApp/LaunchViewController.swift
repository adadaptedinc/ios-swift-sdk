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

class LaunchViewController: UIViewController, WKUIDelegate {
    @IBOutlet weak var launchLabel: UILabel!
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
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
    
    @IBAction func testUniversalLink(_ sender: Any) {
        view = webView
        let myURL = URL(string:"https://ul.adadapted.com/swiftexample?data=eyJwYXlsb2FkX2lkIjoiMUJDMjBGNDQtMzE1My00QURDLUFCNEEtQzlERUQzNUE0MkQ4IiwicGF5bG9hZF9tZXNzYWdlIjoiRmlyc3QgU2FtcGxlIFByb2R1Y3QiLCJwYXlsb2FkX2ltYWdlIjoiMjAxOTAxMTRfMjIxMTIzX3Rlc3RfaW1hZ2VfMi5wbmciLCJjYW1wYWlnbl9pZCI6IjI1NyIsImFwcF9pZCI6Imdyb2NlcnlsaXN0dGVzdGFwcCIsImV4cGlyZV9zZWNvbmRzIjo2MDQ4MDAsImRldGFpbGVkX2xpc3RfaXRlbXMiOlt7InRyYWNraW5nX2lkIjoiQ0RFQTNGODUtRTc4Ri00NzlGLUFFQkEtMjdBQjY1MEZBMjI2IiwicHJvZHVjdF90aXRsZSI6IkZpcnN0IFNhbXBsZSBQcm9kdWN0IiwicHJvZHVjdF9icmFuZCI6IlNhbXBsZSBCcmFuZCIsInByb2R1Y3RfY2F0ZWdvcnkiOiIiLCJwcm9kdWN0X2JhcmNvZGUiOiIwMTIzNCIsInByb2R1Y3Rfc2t1IjoiIiwicHJvZHVjdF9kaXNjb3VudCI6IiIsInByb2R1Y3RfaW1hZ2UiOiJodHRwczpcL1wvaW1hZ2VzLmFkYWRhcHRlZC5jb21cLzIwMTkwMTE0XzIyMTEyM190ZXN0X2ltYWdlXzIucG5nIn0seyJ0cmFja2luZ19pZCI6IjIxMEI5RUNBLTk4MjQtNDdBMi1BMDQ2LTg0NjRGMkEyOTdENiIsInByb2R1Y3RfdGl0bGUiOiJTZWNvbmQgU2FtcGxlIFByb2R1Y3QiLCJwcm9kdWN0X2JyYW5kIjoiU2FtcGxlIEJyYW5kIiwicHJvZHVjdF9jYXRlZ29yeSI6IiIsInByb2R1Y3RfYmFyY29kZSI6IjQzMjEwIiwicHJvZHVjdF9za3UiOiIiLCJwcm9kdWN0X2Rpc2NvdW50IjoiIiwicHJvZHVjdF9pbWFnZSI6Imh0dHBzOlwvXC9pbWFnZXMuYWRhZGFwdGVkLmNvbVwvMjAxOTAxMTRfMjIxMTQ2X3Rlc3RfaW1hZ2VfMi5wbmcifV19")
               let myRequest = URLRequest(url: myURL!)
               webView.load(myRequest)
    }
    
    func showToast(message : String, font: UIFont) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
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

