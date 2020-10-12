//
//  AAWebAdView.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class AAWebAdView: UIView, UIGestureRecognizerDelegate, UIScrollViewDelegate, WKNavigationDelegate, WKUIDelegate {
    weak var delegate: AAImageAdViewDelegate?
    weak var ad: AAAd?

    init(url: URL?, with delegate: AAImageAdViewDelegate?, ad: AAAd?) {
        super.init(frame: .zero)
        self.url = url
        self.delegate = delegate
        self.ad = ad

        sharedInit()

        var requestObj: URLRequest? = nil
        if let url = url {
            requestObj = URLRequest(url: url)
        }
        if let requestObj = requestObj {
            webView?.load(requestObj)
        }
    }

    init(html: String?, with delegate: AAImageAdViewDelegate?, ad: AAAd?) {
        super.init(frame: .zero)
        self.delegate = delegate
        self.ad = ad

        sharedInit()

        webView?.loadHTMLString(html ?? "", baseURL: nil)
    }

    /// we need to do this in case an html ad is released before it's done loading... I think
    func destroy() {
        AASDK.logDebugMessage("WebAdView: destroy enter", type: AASDK_DEBUG_USER_INTERACTION)
        webView?.stopLoading()
        webView?.navigationDelegate = nil
        webView?.uiDelegate = nil
        webView = nil
        url = nil
    }

    private var url: URL?
    private var webView: WKWebView?

    func sharedInit() {
        AASDK.logDebugMessage("WebAdView: sharedInit enter", type: AASDK_DEBUG_USER_INTERACTION)
        webView = WKWebView()
        alpha = 0.0

        webView?.isUserInteractionEnabled = true
        webView?.scrollView.isScrollEnabled = false
        webView?.scrollView.bounces = false
        webView?.scrollView.delegate = self
        webView?.contentMode = UIView.ContentMode.scaleAspectFit
        webView?.translatesAutoresizingMaskIntoConstraints = false
        webView?.navigationDelegate = self
        webView?.uiDelegate = self
        webView?.backgroundColor = UIColor.clear
        webView?.isOpaque = false

        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(tapAction(_:)))

        tap.numberOfTapsRequired = 1
        tap.delegate = self
        webView?.addGestureRecognizer(tap)
        if let webView = webView {
            addSubview(webView)
        }

        var viewsDictionary: [String : WKWebView?]? = nil
        if let webView = webView {
            viewsDictionary = [
                "web": webView
            ]
        }
        let metrics = [
            "padding": NSNumber(value: 0)
        ]

        var constraint_POS_V: [NSLayoutConstraint]? = nil
        if let viewsDictionary = viewsDictionary {
            constraint_POS_V = NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-padding-[web]-padding-|",
                options: [],
                metrics: metrics,
                views: viewsDictionary as [String : Any])
        }

        var constraint_POS_H: [NSLayoutConstraint]? = nil
        if let viewsDictionary = viewsDictionary {
            constraint_POS_H = NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-padding-[web]-padding-|",
                options: [],
                metrics: metrics,
                views: viewsDictionary as [String : Any])
        }

        if let constraint_POS_V = constraint_POS_V {
            addConstraints(constraint_POS_V)
        }
        if let constraint_POS_H = constraint_POS_H {
            addConstraints(constraint_POS_H)
        }
    }

// MARK: - <UIScrollViewDelegate>
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }

// MARK: - <UIGestureRecognizerDelegate>
    @objc func tapAction(_ sender: UITapGestureRecognizer?) {
        AASDK.logDebugMessage("WebAdView: tapAction enter", type: AASDK_DEBUG_USER_INTERACTION)
        delegate?.takeActionForAd()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    override var intrinsicContentSize: CGSize {
        let size = AASDK.sizeOfZone(ad?.zoneId, for: UIApplication.shared.statusBarOrientation)
        return size
    }

// MARK: - <WKNavigationDelegate>
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .other {
            decisionHandler(WKNavigationActionPolicy.allow)
        } else {
            decisionHandler(WKNavigationActionPolicy.cancel)
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIView.animate(withDuration: AD_FADE_SECONDS, animations: {
            self.alpha = 1.0
        })
        delegate?.webAdLoaded()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false

        var str: String? = nil
        if let adID = ad?.adID, let zoneId = ad?.zoneId {
            str = "ERROR - HTML ad: \(adID) in zone: \(zoneId) failed to load: \n\((error as NSError).userInfo)"
        }

        AASDK.consoleLogError(error, withMessage: str, suppressTracking: false)
        AASDK.logDebugMessage(str, type: AASDK_DEBUG_GENERAL)

        var url = "unkown"
        if (error as NSError).userInfo["NSErrorFailingURLStringKey"] != nil {
            url = (error as NSError).userInfo["NSErrorFailingURLStringKey"] as? String ?? ""
        }

        if let adID = ad?.adID, let zoneId = ad?.zoneId {
            AASDK.consoleLogError(error, withMessage: "HTML ad \(adID) in zone \(zoneId) failed to load \(url) ", suppressTracking: true)
        }
        AASDK.trackAnomalyAdURLLoad(ad, urlString: url, message: error.localizedDescription)

        delegate?.adFailed(toLoad: error)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

