//  Converted to Swift 5.2 by Swiftify v5.2.23024 - https://swiftify.com/
//
//  AAPopupViewController.swift
//  AASDK
//
//  Created by Brett Clifton on 9/16/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import UIKit

@objc protocol AAPopupDelegate: NSObjectProtocol {
    func dismissPopup(_ popupView: AAPopupViewController?)
    func userDidInteract(withInternalURLString url: String?)
    func actionTaken(with string: String?)
    func contentActionTaken(with string: String?)
}

@objcMembers
class AAPopupViewController: UIViewController, AAPopupViewDelegate {
    init(for ad: AAAd?, delegate: AAPopupDelegate?) {
        super.init(nibName: nil, bundle: nil)
        self.ad = ad
        self.delegate = delegate
    }

    func setCurrentAd(_ ad: AAAd?) {
        popup?.setCurrentAd(ad)
    }

    func resetToRootURL() {
        popup?.resetToRootURL()
    }

    func destroy() {
        popup?.removeFromSuperview()
        popup?.destroy()
        popup = nil
        view = nil
    }

    private var ad: AAAd?
    private var popup: AAPopupView?
    private weak var delegate: AAPopupDelegate?

    override func loadView() {

        let applicationFrame = UIScreen.main.bounds
        let contentView = UIView(frame: applicationFrame)
        contentView.backgroundColor = UIColor.clear
        view = contentView

        popup = AAPopupView(frame: applicationFrame, ad: ad, delegate: self)
        if let popup = popup {
            view.addSubview(popup)
        }

        var viewsDictionary: [String : AAPopupView?]? = nil
        if let popup = popup {
            viewsDictionary = [
                "pop": popup
            ]
        }
        let metrics = [
            "padding": NSNumber(value: 0)
        ]

        var constraint_POS_V: [NSLayoutConstraint]? = nil
        if let viewsDictionary = viewsDictionary {
            constraint_POS_V = NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-padding-[pop]-padding-|",
                options: [],
                metrics: metrics,
                views: viewsDictionary)
        }

        var constraint_POS_H: [NSLayoutConstraint]? = nil
        if let viewsDictionary = viewsDictionary {
            constraint_POS_H = NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-padding-[pop]-padding-|",
                options: [],
                metrics: metrics,
                views: viewsDictionary)
        }

        if let constraint_POS_V = constraint_POS_V {
            view.addConstraints(constraint_POS_V)
        }
        if let constraint_POS_H = constraint_POS_H {
            view.addConstraints(constraint_POS_H)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

// MARK: - Public

// MARK: - <AAPopupViewDelegate>
    func removePopup(_ popupView: AAPopupView?) {
        delegate?.dismissPopup(self)
    }

    func userDidInteract(withInternalURLString url: String?) {
        delegate?.userDidInteract(withInternalURLString: url)
    }

    func actionTaken(with string: String?) {
        AASDK.logDebugMessage("PopupVC-action: actionTakenWithString enter", type: AASDK_DEBUG_USER_INTERACTION)
        delegate?.actionTaken(with: string)
    }

    func contentActionTaken(with string: String?) {
        AASDK.logDebugMessage("PopupVC-content: contentActionTakenWithString enter", type: AASDK_DEBUG_USER_INTERACTION)
        delegate?.contentActionTaken(with: string)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
