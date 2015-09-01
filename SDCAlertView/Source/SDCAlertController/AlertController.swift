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

public enum ActionLayout {
    case Automatic
    case Vertical
    case Horizontal
}

@objc
public class AlertController: UIViewController {

    override public var title: String? {
        get { return self.attributedTitle?.string }
        set { self.attributedTitle = newValue.map(NSAttributedString.init) }
    }

    public var message: String? {
        get { return self.attributedMessage?.string }
        set { self.attributedMessage = newValue.map(NSAttributedString.init) }
    }

    public var attributedTitle: NSAttributedString? {
        get { return self.alertView.title }
        set { self.alertView.title = newValue }
    }

    public var attributedMessage: NSAttributedString? {
        get { return self.alertView.message }
        set { self.alertView.message = newValue }
    }

    public var contentView: UIView {
        return self.alertView.contentView
    }

    private(set) public var actions = [AlertAction]()
    public var preferredAction: AlertAction?
    public var actionLayout: ActionLayout {
        get { return self.alertView.actionLayout }
        set { self.alertView.actionLayout = newValue }
    }

    private(set) public var textFields: [UITextField]?
    public var automaticallyFocusFirstTextField = true

    private(set) public var preferredStyle: AlertStyle = .Alert

    private let alertView = AlertControllerView()
    private let transitionDelegate = Transition()
    private var shouldDismissHandler: ((AlertAction) -> Bool)?

    public convenience init(title: NSAttributedString?, message: NSAttributedString?) {
        self.init()
        commonInit()

        self.attributedTitle = title
        self.attributedMessage = message
    }

    public convenience init(title: String?, message: String?, preferredStyle: AlertStyle = .Alert) {
        self.init()
        commonInit()

        self.title = title
        self.message = message
        self.preferredStyle = preferredStyle
    }

    private func commonInit() {
        self.modalPresentationStyle = .Custom
        self.transitioningDelegate = self.transitionDelegate
    }

    public func addAction(action: AlertAction) {
        self.actions.append(action)
    }

    public func addTextFieldWithConfigurationHandler(configurationHandler: ((UITextField) -> Void)? = nil) {
        let textField = UITextField()
        textField.autocorrectionType = .No
        configurationHandler?(textField)

        if self.textFields?.append(textField) == nil {
            self.textFields = [textField]
        }
    }

    public func setVisualStyle(visualStyle: VisualStyle) {
        self.alertView.visualStyle = visualStyle
    }

    public func setShouldDismissHandler(handler: (AlertAction) -> Bool) {
        self.shouldDismissHandler = handler
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

        self.alertView.setActionTappedHandler { action in
            guard self.shouldDismissHandler?(action) != false else { return }
            self.presentingViewController?.dismissViewControllerAnimated(true) {
                action.handler?(action)
            }
        }
    }

    private func addTextFieldsIfNecessary() {
        guard let textFields = self.textFields else { return }

        let textFieldsViewController = TextFieldsViewController(textFields: textFields)
        textFieldsViewController.willMoveToParentViewController(self)
        addChildViewController(textFieldsViewController)
        self.alertView.textFieldsViewController = textFieldsViewController
        textFieldsViewController.didMoveToParentViewController(self)
    }

    func present(animated animated: Bool = true, completion: (() -> Void)? = nil) {
        completion?()
    {
        if self.automaticallyFocusFirstTextField {
            self.textFields?.first?.becomeFirstResponder()
        }

    }
}

public extension AlertController {

    public class func showWithTitle(title: String? = nil, message: String? = nil, actionTitle: String? = nil,
        customView: UIView? = nil) -> AlertController
    {
        let alertController = AlertController(title: title, message: message)
        alertController.addAction(AlertAction(title: actionTitle, style: .Preferred))

        if let customView = customView {
            alertController.contentView.addSubview(customView)
        }

        alertController.present()
        return alertController
    }
}
