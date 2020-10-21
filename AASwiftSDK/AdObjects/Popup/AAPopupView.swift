//
//  AAPopup.h
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import UIKit
import WebKit

let kHeaderDefaultBackColor = "#F0F0F0"
let kHeaderDefaultTextColor = "#000000"

@objc protocol AAPopupViewDelegate: NSObjectProtocol {
    func removePopup(_ popupView: AAPopupView?)
    func userDidInteract(withInternalURLString url: String?)
    func actionTaken(with string: String?)
    func contentActionTaken(with string: String?)
}

@objcMembers
class AAPopupView: UIView, WKNavigationDelegate, WKUIDelegate {
    init(frame: CGRect, ad: AAAd?, delegate: AAPopupViewDelegate?) {
        super.init(frame: frame)
        didSetupConstraints = false
        self.ad = ad
        self.delegate = delegate
        isVisible = false
        popupLoadProblem = false

        backgroundColor = UIColor.white

        showCloseButton = !(self.ad?.popupHideCloseButton)!
        showNavButtons = !(self.ad?.popupHideBrowserNav)!
        showHeader = !(self.ad?.popupHideBanner)!

        if ad?.actionPath == nil {
            showHeader = true
            showCloseButton = true
        }

        if showHeader {
            if let header = header {
                addSubview(header)
            }
        }

        if let webView = webView {
            addSubview(webView)
        }

        setNeedsUpdateConstraints()
    }

    func setCurrentAd(_ ad: AAAd?) {
        self.ad = ad
    }

    func resetToRootURL() {
        loadWebView()
    }

    func hide() {
        removeFromSuperview()
    }

    func destroy() {
        AASDK.logDebugMessage("Destroying popup", type: AASDK_DEBUG_GENERAL)
        webView?.removeFromSuperview()
        webView?.navigationDelegate = nil
        webView?.uiDelegate = nil
        //webView = nil
        if closeButtonImageView != nil {
            closeButtonImageView?.removeFromSuperview()
            //closeButtonImageView = nil
        }
        if header != nil {
            header?.removeFromSuperview()
            //header = nil
        }
        if titleLabel != nil {
            titleLabel?.removeFromSuperview()
            //titleLabel = nil
        }
        if nextButton != nil {
            nextButton?.removeFromSuperview()
            //nextButton = nil
        }
        if previousButton != nil {
            previousButton?.removeFromSuperview()
           // previousButton = nil
        }

        super.removeFromSuperview()
    }

    private weak var delegate: AAPopupViewDelegate?
    private var ad: AAAd?

    private var _header: UIView?
    private var header: UIView? {
        if _header == nil {
            _header = UIView()
            _header?.translatesAutoresizingMaskIntoConstraints = false

            if ad?.popupBackColor != nil && (ad?.popupBackColor?.count ?? 0) > 2 {
                _header?.backgroundColor = AAHelper.safeColor(fromHexString: ad?.popupBackColor, fallbackHexString: kHeaderDefaultBackColor)
            } else {
                _header?.backgroundColor = UIColor(named: kHeaderDefaultBackColor)
            }

            if showCloseButton {
                if let closeButtonImageView = closeButtonImageView {
                    _header?.addSubview(closeButtonImageView)
                }
            }

            if let titleLabel = titleLabel {
                _header?.addSubview(titleLabel)
            }
        }
        return _header
    }

    private var _webView: WKWebView?
    private var webView: WKWebView? {
        if _webView == nil {
            _webView = WKWebView()
            _webView?.translatesAutoresizingMaskIntoConstraints = false
            _webView?.backgroundColor = UIColor.gray
            _webView?.contentMode = UIView.ContentMode.scaleAspectFit
            _webView?.isUserInteractionEnabled = true
            _webView?.navigationDelegate = self
            _webView?.uiDelegate = self

            _webView?.alpha = 0.0

            if showNavButtons {
                if let previousButton = previousButton {
                    _webView?.addSubview(previousButton)
                }
                if let nextButton = nextButton {
                    _webView?.addSubview(nextButton)
                }
            }

            loadWebView()
        }
        return _webView
    }

    private var _closeButtonImageView: UIImageView?
    private var closeButtonImageView: UIImageView? {
        if _closeButtonImageView == nil {
            _closeButtonImageView = UIImageView()
            _closeButtonImageView?.translatesAutoresizingMaskIntoConstraints = false
            let tap = UITapGestureRecognizer(target: self, action: #selector(closePopup))
            _closeButtonImageView?.isUserInteractionEnabled = true
            _closeButtonImageView?.addGestureRecognizer(tap)

            if ad?.popupAltCloseButtonURL != nil && (ad?.popupAltCloseButtonURL?.count ?? 0) > 15 {
                let imageUrl = ad?.popupAltCloseButtonURL
                AAHelper.setImageFor(_closeButtonImageView, from: URL(string: imageUrl ?? ""))
            } else {
                _closeButtonImageView?.image = AASDK.popupDefaultCloseButton()?.image
            }
            if let _closeButtonImageView = _closeButtonImageView {
                addSubview(_closeButtonImageView)
            }
        }
        return _closeButtonImageView
    }

    private var _titleLabel: UILabel?
    private var titleLabel: UILabel? {
        if _titleLabel == nil {
            _titleLabel = UILabel()
            _titleLabel?.translatesAutoresizingMaskIntoConstraints = false

            if ad?.popupTitleText != nil {
                _titleLabel?.text = ad?.popupTitleText
            } else {
                _titleLabel?.text = "AdAdapted"
            }

            _titleLabel?.backgroundColor = UIColor.clear
            _titleLabel?.textAlignment = .center

            if ad?.popupTextColor != nil && (ad?.popupTextColor?.count ?? 0) > 2 {
                _titleLabel?.textColor = AAHelper.safeColor(fromHexString: ad?.popupTextColor, fallbackHexString: kHeaderDefaultTextColor)
            } else {
                _titleLabel?.textColor = UIColor(named: kHeaderDefaultTextColor)
            }
            _titleLabel?.font = UIFont(name: "Helvetica", size: 20)
        }
        return _titleLabel
    }

    private var _previousButton: UIButton?
    private var previousButton: UIButton? {
        if _previousButton == nil {
            _previousButton = UIButton(type: .roundedRect)
            _previousButton?.translatesAutoresizingMaskIntoConstraints = false
            _previousButton?.setTitle("<", for: .normal)
            _previousButton?.addTarget(self, action: #selector(previousTouched), for: .touchUpInside)
            _previousButton?.isEnabled = false
        }
        return _previousButton
    }

    private var _nextButton: UIButton?
    private var nextButton: UIButton? {
        if _nextButton == nil {
            _nextButton = UIButton(type: .roundedRect)
            _nextButton?.translatesAutoresizingMaskIntoConstraints = false
            _nextButton?.setTitle(">", for: .normal)
            _nextButton?.addTarget(self, action: #selector(nextTouched), for: .touchUpInside)
            _nextButton?.isEnabled = false
        }
        return _nextButton
    }
    private var didSetupConstraints = false
    private var isVisible = false
    private var showCloseButton = false
    private var showNavButtons = false
    private var showHeader = false
    private var popupLoadProblem = false

// MARK: - accessors

// MARK: - constraints
    override func updateConstraints() {
        if didSetupConstraints == false {
            setupHeaderConstraints()
            setupWebViewContraints()
            setupConstraints()
        }
        super.updateConstraints()
        didSetupConstraints = true

        handleLoadProblem()
    }

    func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false

        var viewsDictionary: [AnyHashable : Any]?
        var metrics: [AnyHashable : Any]?
        var constraint_V: [AnyHashable]?
        var constraint_H: [AnyHashable]?

        if showHeader {
            if let header = header, let webView = webView {
                viewsDictionary = [
                    "header": header,
                    "webView": webView
                ]
            }

            var height: NSNumber?

            if UIApplication.shared.isStatusBarHidden {
                height = NSNumber(value: 37)
            } else {
                height = NSNumber(value: 57)
            }

            if let height = height {
                metrics = [
                    "headerHeight": height
                ]
            }

            if let viewsDictionary = viewsDictionary as? [String : Any] {
                constraint_V = NSLayoutConstraint.constraints(
                    withVisualFormat: "V:[header(headerHeight)]",
                    options: [],
                    metrics: metrics as? [String : Any],
                    views: viewsDictionary)
            }
            if let constraint_V = constraint_V as? [NSLayoutConstraint] {
                header?.addConstraints(constraint_V)
            }

            if let viewsDictionary = viewsDictionary as? [String : Any] {
                constraint_V = NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|[header][webView]|",
                    options: [],
                    metrics: metrics as? [String : Any],
                    views: viewsDictionary)
            }
            if let constraint_V = constraint_V as? [NSLayoutConstraint] {
                addConstraints(constraint_V)
            }

            if let viewsDictionary = viewsDictionary as? [String : Any] {
                constraint_H = NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|[header]|",
                    options: [],
                    metrics: metrics as? [String : Any],
                    views: viewsDictionary)
            }
            if let constraint_H = constraint_H as? [NSLayoutConstraint] {
                addConstraints(constraint_H)
            }
        } else {
            if let webView = webView {
                viewsDictionary = [
                    "webView": webView
                ]
            }

            metrics = [:]

            if let viewsDictionary = viewsDictionary as? [String : Any] {
                constraint_V = NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|[webView]|",
                    options: [],
                    metrics: metrics as? [String : Any],
                    views: viewsDictionary)
            }
            if let constraint_V = constraint_V as? [NSLayoutConstraint] {
                addConstraints(constraint_V)
            }
        }

        if let viewsDictionary = viewsDictionary as? [String : Any] {
            constraint_H = NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[webView]|",
                options: [],
                metrics: metrics as? [String : Any],
                views: viewsDictionary)
        }
        if let constraint_H = constraint_H as? [NSLayoutConstraint] {
            addConstraints(constraint_H)
        }
    }

    func setupHeaderConstraints() {
        if !showHeader {
            return
        }

        var viewsDictionary: [AnyHashable : Any]?
        var metrics: [AnyHashable : Any]?
        var constraint_POS_V: [AnyHashable]?
        var constraint_POS_H: [AnyHashable]?

        if showCloseButton {
            if let closeButtonImageView = closeButtonImageView, let titleLabel = titleLabel {
                viewsDictionary = [
                    "close": closeButtonImageView,
                    "title": titleLabel
                ]
            }

            metrics = [
                "padding": NSNumber(value: 1),
                "closeHeight": NSNumber(value: 35),
                "closeWidth": NSNumber(value: 40),
                "titleHeight": NSNumber(value: 35)
            ]

            if let viewsDictionary = viewsDictionary as? [String : Any] {
                constraint_POS_V = NSLayoutConstraint.constraints(
                    withVisualFormat: "V:[close(closeHeight)]-padding-|",
                    options: [],
                    metrics: metrics as? [String : Any],
                    views: viewsDictionary)
            }
            if let constraint_POS_V = constraint_POS_V as? [NSLayoutConstraint] {
                header?.addConstraints(constraint_POS_V)
            }

            if let viewsDictionary = viewsDictionary as? [String : Any] {
                constraint_POS_H = NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|-padding-[close(closeWidth)]",
                    options: [],
                    metrics: metrics as? [String : Any],
                    views: viewsDictionary)
            }
            if let constraint_POS_H = constraint_POS_H as? [NSLayoutConstraint] {
                header?.addConstraints(constraint_POS_H)
            }
        } else {
            if let titleLabel = titleLabel {
                viewsDictionary = [
                    "title": titleLabel
                ]
            }

            metrics = [
                "titleHeight": NSNumber(value: 35),
                "padding": NSNumber(value: 1)
            ]
        }

        if let viewsDictionary = viewsDictionary as? [String : Any] {
            constraint_POS_H = NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-padding-[title]-padding-|",
                options: [],
                metrics: metrics as? [String : Any],
                views: viewsDictionary)
        }
        if let constraint_POS_H = constraint_POS_H as? [NSLayoutConstraint] {
            header?.addConstraints(constraint_POS_H)
        }


        if let viewsDictionary = viewsDictionary as? [String : Any] {
            constraint_POS_V = NSLayoutConstraint.constraints(
                withVisualFormat: "V:[title(titleHeight)]-padding-|",
                options: [],
                metrics: metrics as? [String : Any],
                views: viewsDictionary)
        }
        if let constraint_POS_V = constraint_POS_V as? [NSLayoutConstraint] {
            header?.addConstraints(constraint_POS_V)
        }
    }

    func setupWebViewContraints() {
        if showNavButtons {
            var viewsDictionary: [String : UIButton?]? = nil
            if let previousButton = previousButton, let nextButton = nextButton {
                viewsDictionary = [
                    "prev": previousButton,
                    "next": nextButton
                ]
            }

            let metrics = [
                "padding": NSNumber(value: 3),
                "dimension": NSNumber(value: 35)
            ]

            var constraint_POS_V: [AnyHashable]?
            var constraint_POS_H: [AnyHashable]?

            if let viewsDictionary = viewsDictionary {
                constraint_POS_V = NSLayoutConstraint.constraints(
                    withVisualFormat: "V:[prev(dimension)]-padding-|",
                    options: [],
                    metrics: metrics,
                    views: viewsDictionary as [String : Any])
            }
            if let constraint_POS_V = constraint_POS_V as? [NSLayoutConstraint] {
                webView?.addConstraints(constraint_POS_V)
            }

            if let viewsDictionary = viewsDictionary {
                constraint_POS_V = NSLayoutConstraint.constraints(
                    withVisualFormat: "V:[next(dimension)]-padding-|",
                    options: [],
                    metrics: metrics,
                    views: viewsDictionary as [String : Any])
            }
            if let constraint_POS_V = constraint_POS_V as? [NSLayoutConstraint] {
                webView?.addConstraints(constraint_POS_V)
            }


            if let viewsDictionary = viewsDictionary {
                constraint_POS_H = NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|-padding-[prev(dimension)]",
                    options: [],
                    metrics: metrics,
                    views: viewsDictionary as [String : Any])
            }
            if let constraint_POS_H = constraint_POS_H as? [NSLayoutConstraint] {
                webView?.addConstraints(constraint_POS_H)
            }

            if let viewsDictionary = viewsDictionary {
                constraint_POS_H = NSLayoutConstraint.constraints(
                    withVisualFormat: "H:[next(dimension)]-padding-|",
                    options: [],
                    metrics: metrics,
                    views: viewsDictionary as [String : Any])
            }
            if let constraint_POS_H = constraint_POS_H as? [NSLayoutConstraint] {
                webView?.addConstraints(constraint_POS_H)
            }
        }
    }

    func loadWebView() {
        isVisible = true

        let value = AASDK.customDebuggingPopupURL()
        var url: URL?

        if let value = value {
            url = URL(string: value)
        } else {
            if ad?.actionPath == nil {
                popupLoadProblem = true
                AASDK.trackAnomalyAdPopupURLLoad(ad, urlString: "", message: "null popup path")
                return
            }
            url = URL(string: ad?.actionPath?.absoluteString ?? "")
        }

        AASDK.logDebugMessage("Popup loading with URL:'\(url?.absoluteString ?? "")'", type: AASDK_DEBUG_GENERAL)

        var requestObj: NSMutableURLRequest? = nil
        if let url = url {
            requestObj = NSMutableURLRequest(url: url)
        }
        requestObj?.setValue("Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3", forHTTPHeaderField: "User-Agent")

        DispatchQueue.main.async(execute: {
            if let requestObj = requestObj {
                self.webView?.load(requestObj as URLRequest)
            }
        })
    }

// MARK: - click handlers
    @objc func closePopup() {
        if isVisible {
            delegate?.removePopup(self)
            webView?.stopLoading()
            AASDK.logDebugMessage("Popup Closed", type: AASDK_DEBUG_USER_INTERACTION)
            webView?.loadHTMLString("<html><head></head><body></body></html>", baseURL: nil)
            isVisible = false
        }
    }

// MARK: - PUBLIC

// MARK: - web nav
    @objc func previousTouched() {
        previousButton?.isEnabled = false
        nextButton?.isEnabled = false
        webView?.goBack()
    }

    @objc func nextTouched() {
        previousButton?.isEnabled = false
        nextButton?.isEnabled = false
        webView?.goForward()
    }

// MARK: - <WKNavigationDelegate>
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .other {
            // this is entered when you're initially loading the webview
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            if let adID = ad?.adID {
                AASDK.logDebugMessage("Popup for ad \(adID) navigating to \(navigationAction.request.url?.absoluteString ?? "")", type: AASDK_DEBUG_GENERAL)
            }
            decisionHandler(WKNavigationActionPolicy.allow)
        } else {
            let rawString = navigationAction.request.url?.absoluteString
            if rawString?.hasPrefix("external:") ?? false {
                AASDK.logDebugMessage("User navigating from popup to external link", type: AASDK_DEBUG_USER_INTERACTION)
                let targetURL = (rawString as NSString?)?.substring(from: 9)
                if let url = URL(string: targetURL ?? "") {
                    if !UIApplication.shared.canOpenURL(url) {
                        AASDK.trackAppExit(from: ad, withPath: targetURL)
                    } else {
                        AASDK.trackContentPayloadDelivered(from: ad, contentType: "url encoded")
                    }
                }
                if let url = URL(string: targetURL ?? "") {
                    UIApplication.shared.open(url)
                }
                decisionHandler(WKNavigationActionPolicy.cancel)
            } else if rawString?.hasPrefix("close:") ?? false {
                AASDK.logDebugMessage("User closed popup via internal link", type: AASDK_DEBUG_USER_INTERACTION)
                closePopup()
                decisionHandler(WKNavigationActionPolicy.cancel)
            } else if rawString?.hasPrefix("internal:") ?? false {
                AASDK.logDebugMessage("User navigating to internal link", type: AASDK_DEBUG_USER_INTERACTION)
                let targetURL = (rawString as NSString?)?.substring(from: 9)
                delegate?.userDidInteract(withInternalURLString: targetURL)
                decisionHandler(WKNavigationActionPolicy.cancel)
            } else if rawString?.hasPrefix("action:") ?? false {
                AASDK.logDebugMessage("PopupView: Delivering popup ATL content", type: AASDK_DEBUG_USER_INTERACTION)
                delegate?.actionTaken(with: (rawString as NSString?)?.substring(from: 7))
                decisionHandler(WKNavigationActionPolicy.cancel)
            } else if rawString?.hasPrefix("content:") ?? false {
                AASDK.logDebugMessage("PopupView: Delivering circular content", type: AASDK_DEBUG_USER_INTERACTION)
                delegate?.contentActionTaken(with: (rawString as NSString?)?.substring(from: 8))
                decisionHandler(WKNavigationActionPolicy.cancel)
            } else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                decisionHandler(WKNavigationActionPolicy.cancel)
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        previousButton?.isEnabled = self.webView?.canGoBack ?? false
        nextButton?.isEnabled = self.webView?.canGoForward ?? false

        UIApplication.shared.isNetworkActivityIndicatorVisible = false

        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            options: .curveEaseOut,
            animations: { [self] in
                self.webView?.alpha = 1.0
                setNeedsDisplay()
            }) { finished in
            }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if (error as NSError).code == NSURLErrorCancelled {
            return
        }

        popupLoadProblem = true

        UIApplication.shared.isNetworkActivityIndicatorVisible = false

        var url = "unkown"
        if (error as NSError).userInfo["NSErrorFailingURLStringKey"] != nil {
            url = (error as NSError).userInfo["NSErrorFailingURLStringKey"] as? String ?? ""
        }

        AASDK.trackAnomalyAdPopupURLLoad(ad, urlString: url, message: error.localizedDescription)

        if let adID = ad?.adID, let zoneId = ad?.zoneId {
            AASDK.consoleLogError(error, withMessage: "popup for ad \(adID) in zone \(zoneId) failed to load \(url) ", suppressTracking: true)
        }

        handleLoadProblem()
    }

    func handleLoadProblem() {
        if !popupLoadProblem {
            return
        }

        if didSetupConstraints {
            DispatchQueue.main.async(execute: { [self] in
                if !showHeader || !showCloseButton {
                    removeConstraints(constraints)
                    if !showHeader {
                        if let header = header {
                            addSubview(header)
                        }
                    }
                    if !showCloseButton {
                        if let closeButtonImageView = closeButtonImageView {
                            header?.addSubview(closeButtonImageView)
                        }
                    }

                    showHeader = true
                    showCloseButton = true
                    didSetupConstraints = false
                    setNeedsUpdateConstraints()
                }
            })
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
