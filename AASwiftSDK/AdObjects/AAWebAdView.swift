import Foundation
import UIKit
import WebKit

class AAWebAdView: UIView, UIGestureRecognizerDelegate, UIScrollViewDelegate, WKNavigationDelegate, WKUIDelegate {
    weak var delegate: AAImageAdViewDelegate?
    weak var ad: AAAd?
    var isWebViewLoaded: Bool = false
    var isWebViewVisible: Bool = true
    
    private var url: URL?
    private var html: String?
    private var webView: WKWebView?

    init(url: URL?, with delegate: AAImageAdViewDelegate?, ad: AAAd?, isVisible: Bool) {
        super.init(frame: .zero)
        self.url = url
        self.delegate = delegate
        self.ad = ad
        self.isWebViewVisible = isVisible

        sharedInit()
        self.loadWebViewByUrl()
    }

    init(html: String?, with delegate: AAImageAdViewDelegate?, ad: AAAd?, isVisible: Bool) {
        super.init(frame: .zero)
        self.delegate = delegate
        self.html = html
        self.ad = ad
        self.isWebViewVisible = isVisible

        sharedInit()
        DispatchQueue.main.async {
            self.loadWebViewByHtml()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func loadWebViewByUrl() {
        if(isWebViewVisible) {
            if let url = url {
                let requestObj = URLRequest(url: url)
                isWebViewLoaded = true
                webView?.load(requestObj)
            }
        }
    }
    
    private func loadWebViewByHtml() {
        if(isWebViewVisible) {
            isWebViewLoaded = true
            webView?.loadHTMLString(html ?? "", baseURL: nil)
        }
    }
    
    func onAdVisibilityChanged(isAdVisible: Bool) {
        isWebViewVisible = isAdVisible
        if !isWebViewLoaded {
            if url != nil {
                loadWebViewByUrl()
            } else if let html = html, !html.isEmpty {
                loadWebViewByHtml()
            }
        }
    }

    func sharedInit() {
        AASDK.logDebugMessage("WebAdView: sharedInit enter", type: AASDK.DEBUG_USER_INTERACTION)
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = .audio

        webView = WKWebView(frame: .zero, configuration: configuration)
        webView?.accessibilityIdentifier = "web_view"
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
            alpha = 0.0
            addSubview(webView)
        }

        var viewsDictionary: [String: WKWebView?]?
        if let webView = webView {
            viewsDictionary = [
                "web": webView
            ]
        }
        let metrics = [
            "padding": NSNumber(value: 0)
        ]

        var constraint_POS_V: [NSLayoutConstraint]?
        if let viewsDictionary = viewsDictionary {
            constraint_POS_V = NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-padding-[web]-padding-|",
                options: [],
                metrics: metrics,
                views: viewsDictionary as [String: Any])
        }

        var constraint_POS_H: [NSLayoutConstraint]?
        if let viewsDictionary = viewsDictionary {
            constraint_POS_H = NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-padding-[web]-padding-|",
                options: [],
                metrics: metrics,
                views: viewsDictionary as [String: Any])
        }

        if let constraint_POS_V = constraint_POS_V {
            addConstraints(constraint_POS_V)
        }
        if let constraint_POS_H = constraint_POS_H {
            addConstraints(constraint_POS_H)
        }
    }
    
    func destroy() {
        AASDK.logDebugMessage("WebAdView: destroy enter", type: AASDK.DEBUG_USER_INTERACTION)
        webView?.stopLoading()
        webView?.navigationDelegate = nil
        webView?.uiDelegate = nil
        webView = nil
        url = nil
    }

// MARK: - <UIScrollViewDelegate>
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }

// MARK: - <UIGestureRecognizerDelegate>
    @objc func tapAction(_ sender: UITapGestureRecognizer?) {
        AASDK.logDebugMessage("WebAdView: tapAction enter", type: AASDK.DEBUG_USER_INTERACTION)
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

        Logger.consoleLogError(error, withMessage: str, suppressTracking: false)
        AASDK.logDebugMessage(str, type: AASDK.DEBUG_GENERAL)

        var url = "unkown"
        if (error as NSError).userInfo["NSErrorFailingURLStringKey"] != nil {
            url = (error as NSError).userInfo["NSErrorFailingURLStringKey"] as? String ?? ""
        }

        if let adID = ad?.adID, let zoneId = ad?.zoneId {
            Logger.consoleLogError(error, withMessage: "HTML ad \(adID) in zone \(zoneId) failed to load \(url) ", suppressTracking: true)
        }
        AASDK.trackAnomalyAdURLLoad(ad, urlString: url, message: error.localizedDescription)

        delegate?.adFailed(toLoad: error)
    }
}
