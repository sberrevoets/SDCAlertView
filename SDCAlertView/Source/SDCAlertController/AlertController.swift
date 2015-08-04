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
        self.modalPresentationStyle = .OverFullScreen

        self.attributedTitle = title
        self.attributedMessage = message
    }

    public convenience init(title: String?, message: String?, preferredStyle: AlertStyle = .Alert) {
        self.init()
        self.modalPresentationStyle = .OverFullScreen

        self.title = title
        self.message = message
        self.preferredStyle = preferredStyle
    }

    override public var title: String? {
        get { return self.attributedTitle?.string }
        set { self.attributedTitle = newValue.map(NSAttributedString.init) }
    }

    public var message: String? {
        get { return self.attributedMessage?.string }
        set { self.attributedMessage = newValue.map(NSAttributedString.init) }
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

    private var alertView = AlertControllerView()

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

    // MARK: - View Controller Lifecyle

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureAlertView()
    }

    private func configureAlertView() {
        self.alertView.translatesAutoresizingMaskIntoConstraints = false

        self.alertView.title = self.attributedTitle
        self.alertView.message = self.attributedMessage
        self.alertView.actions = self.actions

        addTextFieldsIfNecessary()

        self.alertView.prepareLayout()

        self.view.addSubview(self.alertView)
        self.alertView.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor).active = true
        self.alertView.centerYAnchor.constraintEqualToAnchor(self.view.centerYAnchor).active = true
        self.alertView.widthAnchor.constraintEqualToConstant(270).active = true
        self.alertView.heightAnchor.constraintEqualToConstant(185).active = true
    }

    private func addTextFieldsIfNecessary() {
        guard let textFields = self.textFields else { return }

        let textFieldsViewController = TextFieldsViewController(textFields: textFields)
        textFieldsViewController.willMoveToParentViewController(self)
        addChildViewController(textFieldsViewController)
        self.alertView.textFieldsViewController = textFieldsViewController
        textFieldsViewController.didMoveToParentViewController(self)
    }
}
