//
//  AlertController.swift
//  SDCAlertController
//
//  Created by Scott Berrevoets on 7/12/15.
//  Copyright © 2015 Scott Berrevoets. All rights reserved.
//

import UIKit

@objc
public enum AlertStyle: Int {
    case Alert
}

@objc
public class AlertController: UIViewController {

    public convenience init(title: NSAttributedString?, message: NSAttributedString?) {
        self.init()
        self.attributedTitle = title
        self.attributedMessage = message
    }

    public convenience init(title: String?, message: String?, preferredStyle: AlertStyle = .Alert) {
        self.init()
        self.title = title
        self.message = message
        self.preferredStyle = preferredStyle
    }

    override public var title: String? {
        get { return self.attributedTitle?.string }
        set {
            let attributedTitle = title.map(NSAttributedString.init)
            self.attributedTitle = attributedTitle
        }
    }

    public var message: String? {
        get { return self.attributedMessage?.string }
        set {
            let attributedMessage = title.map(NSAttributedString.init)
            self.attributedMessage = attributedMessage
        }
    }

    public var attributedTitle: NSAttributedString? = nil {
        didSet { updateAlertView() }
    }

    public var attributedMessage: NSAttributedString? = nil {
        didSet { updateAlertView() }
    }

    private(set) public var actions = [AlertAction]()
    public var preferredAction: AlertAction?

    private(set) public var textFields: [UITextField]?

    private(set) public var preferredStyle: AlertStyle = .Alert

    public func addAction(action: AlertAction) {
        self.actions.append(action)
    }

    public func addTextFieldWithConfigurationHandler(configurationHandler: ((UITextField) -> Void)? = nil) {
        let textField = UITextField()
        configurationHandler?(textField)

        if self.textFields?.append(textField) == nil {
            self.textFields = [textField]
        }
    }

    private func updateAlertView() {

    }
}
