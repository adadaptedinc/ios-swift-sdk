//  Converted to Swift 5.2 by Swiftify v5.2.19227 - https://swiftify.com/
//
//  AAKeywordInterceptManager.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation
import WebKit

let DISPATCH_TIMER_INTERVAL = 5.0

@objcMembers
class AAKeywordInterceptManager: NSObject, WKUIDelegate {
    init(connector: AAConnector?, minMatchLength minMatch: Int, triggeredAds ads: [AnyHashable : Any]?) {
        
        super.init()
        events = []
        self.connector = connector
        minMatchLength = minMatch
        triggeredAds = ads
        activeAds = []
    }
    
    func loadKeywordIntercepts(_ keywordIntercepts: [AnyHashable]?) {
        if let keywordIntercepts = keywordIntercepts {
            self.keywordIntercepts = keywordIntercepts
        }
        //cacheHTMLAds()
        compileCachableAssetsAndNotify()
    }
    
    func matchUserInput(_ userInput: String?) -> [AnyHashable : Any]? {
        if (userInput?.count ?? 0) < minMatchLength {
            lastKeywordIntercept = nil
            activeAds = nil
            return nil
        }
        
        lastUserInput = userInput
        lastKeywordIntercept = matchKeywordIntercept(withUserInput: userInput)
        if lastKeywordIntercept != nil {
            fileEvent(forUserInput: lastUserInput, with: lastKeywordIntercept, andType: AASDK_KI_EVENT_TYPE_MATCHED)
            return getMatchFor(lastKeywordIntercept)
        } else {
            return handleNoMatch(forUserInput: userInput)
        }
    }
    
    func hasZone(_ zoneId: String?) -> Bool {
        if availableZones != nil {
            return availableZones?.contains(zoneId ?? "") ?? false
        }
        return false
    }
    
    func allAvailableZones() -> [AnyHashable]? {
        if let availableZones = availableZones {
            return Array(availableZones)
        }
        return []
    }
    
    func reportPresented() {
        AASDK.logDebugMessage("Regeistered KI event: presented", type: AASDK_DEBUG_GENERAL)
        fileEvent(forUserInput: lastUserInput, with: lastKeywordIntercept, andType: AASDK_KI_EVENT_TYPE_PRESENTED)
    }
    
    func reportSelected() {
        AASDK.logDebugMessage("Regeistered KI event: selected", type: AASDK_DEBUG_GENERAL)
        fileEvent(forUserInput: lastUserInput, with: lastKeywordIntercept, andType: AASDK_KI_EVENT_TYPE_SELECTED)
    }
    
    private var minMatchLength = 0
    private var keywordIntercepts: [AnyHashable]?
    private var dispatchTimer: Timer?
    private var events: [AnyHashable]?
    private var lastUserInput: String?
    private var lastKeywordIntercept: AAKeywordIntercept?
    private weak var connector: AAConnector?
    private var triggeredAds: [AnyHashable : Any]?
    
    private var _activeAds: [AnyHashable]?
    private var activeAds: [AnyHashable]? {
        get {
            _activeAds
        }
        set(activeAds) {
            if activeAds == nil && _activeAds != nil && (_activeAds?.count ?? 0) > 0 {
                for ii in 0..<(_activeAds?.count ?? 0) {
                    if let ad = _activeAds?[ii] as? AAAd {
                        AASDK.remove(ad, fromZone: ad.zoneId ?? "", andForceReload: ii == (_activeAds?.count ?? 0) - 1 ? true : false)
                    }
                }
            }
            _activeAds = activeAds
        }
    }
    private var cachingAds: [AnyHashable]?
    private var availableZones: Set<AnyHashable>?
    
    // MARK: - PRIVATE
    func matchKeywordIntercept(withUserInput userInput: String?) -> AAKeywordIntercept? {
        for intercept in keywordIntercepts ?? [] {
            guard let intercept = intercept as? AAKeywordIntercept else {
                continue
            }
            if (intercept.term as NSString?)?.range(of: userInput ?? "", options: .caseInsensitive).location != NSNotFound {
                return intercept
            }
        }
        return nil
    }
    
    func getMatchFor(_ keywordIntercept: AAKeywordIntercept?) -> [AnyHashable : Any]? {
        var dic = [
            AASDK_KEY_KI_REPLACEMENT_ID: keywordIntercept?.hashValue ?? "",
            AASDK.AASDK_KEY_KI_REPLACEMENT_TEXT: keywordIntercept?.replacementText ?? "",
            AASDK_KEY_KI_REPLACEMENT_ICON_URL: keywordIntercept?.iconURL ?? "",
            AASDK_KEY_KI_REPLACEMENT_TAGLINE: keywordIntercept?.taglineText ?? ""
        ] as [String : Any]
        
        var zones = [AnyHashable](repeating: 0, count: 2)
        var tempActiveAds = [AnyHashable](repeating: 0, count: 2)
        var adIds = [AnyHashable](repeating: 0, count: 2)
        
        if keywordIntercept?.hasTriggeredAds() ?? false {
            for ad_id in keywordIntercept?.triggeredAdIds ?? [] {
                guard let ad_id = ad_id as? String else {
                    continue
                }
                let ad = triggeredAd(forId: ad_id)
                if !zones.contains(ad?.zoneId ?? "") {
                    zones.append(ad?.zoneId ?? "")
                }
                if let ad = ad {
                    if !(activeAds?.contains(ad) ?? false) {
                        AASDK.inject(ad, intoZone: ad.zoneId ?? "")
                        tempActiveAds.append(ad)
                        adIds.append(ad.adID ?? "")
                    } else {
                        adIds.append(ad.adID ?? "")
                    }
                }
            }
        }
        
        keywordIntercept?.injectedZones = zones
        keywordIntercept?.injectedAds = adIds
        
        activeAds = tempActiveAds
        dic[AASDK_KEY_KI_TRIGGERED_ZONES] = (zones as? [String])?.compactMap({$0}).joined(separator: " ")
        return dic
    }
    
    func handleNoMatch(forUserInput userInput: String?) -> [AnyHashable : Any]? {
        activeAds = nil
        fileEvent(forUserInput: userInput, with: nil, andType: AASDK_KI_EVENT_TYPE_NOT_MATCHED)
        return nil
    }
    
    func fileEvent(forUserInput userInput: String?, with keywordIntercept: AAKeywordIntercept?, andType type: String?) {
        if (type == AASDK_KI_EVENT_TYPE_MATCHED) || (type == AASDK_KI_EVENT_TYPE_NOT_MATCHED) || (type == AASDK_KI_EVENT_TYPE_PRESENTED) {
            for event in events ?? [] {
                guard let event = event as? AAKeywordInterceptEvent else {
                    continue
                }
                if (type == event.eventType()) && (userInput?.hasPrefix(event.getUserInput() ?? "") ?? false) {
                    events?.removeAll { $0 as AnyObject === event as AnyObject }
                    break
                }
                //for checking events queued when removing characters (leaving out for now to match Android)
                // if ( [type isEqualToString:event.eventType] && [event.userInput hasPrefix:userInput] ) {
                //     [self.events removeObject:event];
                //     break;
                // }
            }
        }
        
        let event = AAKeywordInterceptEvent(type: type, userInput: userInput, with: keywordIntercept)
        events?.append(event)
        
        fireDispatchTimer()
    }
    
    func fireDispatchTimer() {
        if dispatchTimer != nil {
            dispatchTimer?.invalidate()
            dispatchTimer = nil
        }
        
        
        dispatchTimer = Timer.scheduledTimer(
            timeInterval: TimeInterval(DISPATCH_TIMER_INTERVAL),
            target: self,
            selector: #selector(timerFired),
            userInfo: nil,
            repeats: false)
    }
    
    @objc func timerFired() {
        if dispatchTimer != nil {
            dispatchTimer?.invalidate()
            dispatchTimer = nil
        }
        
        
        let request = AAKeywordInterceptBatchEventRequest(events: events)
         //Add helper
        connector?.enqueueRequest(request, responseWasErrorBlock: { response, forRequest, error in
            AASDK.consoleLogError(error, withMessage: "AASDK KI events reporting FAILED", suppressTracking: false)
        }, responseWasReceivedBlock: { response, forRequest in
            self.events?.removeAll()
        })
    }
    
    func triggeredAd(forId adId: String?) -> AAAd? {
        if triggeredAds != nil && triggeredAds?[adId ?? ""] != nil {
            return triggeredAds?[adId ?? ""] as? AAAd
        }
        return nil
    }
    
//    func cacheHTMLAds() {
//        cachingAds = []
//        if let triggeredAds = triggeredAds {
//            for (_, value) in (triggeredAds).enumerated() {
//                guard let ad = value as? AAAd else {
//                    continue
//                }
//                let url = URL(string: ad.adURL ?? "")
//                DispatchQueue.main.async(execute: {
//                    let wv = WKWebView(frame: CGRect(x: 0, y: 0, width: 320, height: 460))
//                    wv.uiDelegate = self
//                    self.cachingAds?.append(wv)
//                    if let url = url {
//                        wv.load(URLRequest(url: url))
//                    }
//                })
//            }
//        }
//    }
    
    func compileCachableAssetsAndNotify() {
        let set = NSMutableSet()
        var mdic : [AnyHashable : Any] = [:]
        for ki in keywordIntercepts ?? [] {
            guard let ki = ki as? AAKeywordIntercept else {
                continue
            }
            var dic = [
                AASDK_KEY_KI_REPLACEMENT_ID: ki.hashValue ,
                AASDK.AASDK_KEY_KI_REPLACEMENT_TEXT: ki.replacementText ?? "",
                AASDK_KEY_KI_REPLACEMENT_TAGLINE: ki.taglineText ?? ""
            ] as [String : Any]
            if ki.iconURL != nil && (ki.iconURL?.count ?? 0) > 0 {
                dic[AASDK_KEY_KI_REPLACEMENT_ICON_URL] = ki.iconURL ?? ""
            }
            mdic[ki.hashValue] = dic
            set.addObjects(from: ki.triggeredAdIds!)
        }
        availableZones = Set.init(_immutableCocoaSet: set)
        AASDK.reportKeywordInterceptInitComplete(mdic)
    }
    
    // MARK: - <WKWebViewDelegate>
    func webViewDidFinishLoad(_ webView: WKWebView) {
        cachingAds?.removeAll { $0 as AnyObject === webView as AnyObject }
        if cachingAds?.count == 0 {
            cachingAds = nil
            AASDK.logDebugMessage("Search ad caching COMPLETE", type: AASDK_DEBUG_GENERAL)
        }
    }
}
