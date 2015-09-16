//
//  AlertController.swift
//  SDCAlertController
//
//  Created by Scott Berrevoets on 7/12/15.
//  Copyright © 2015 Scott Berrevoets. All rights reserved.
//

import UIKit

@available(iOS 8, *)
@objc
public enum AlertStyle: Int {
    case Alert
}

@available(iOS 8, *)
@objc
public enum ActionLayout: Int {
    case Automatic
    case Vertical
    case Horizontal
}

@available(iOS 8, *)
@objc(SDCAlertController)
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

    @available(iOS 9, *)
    public var preferredAction: AlertAction? {
        get {
            let index = self.actions.indexOf { $0.style == .Preferred }
            return index != nil ? self.actions[index!] : nil
        }
        set {
            if let action = newValue {
                action.style = .Preferred

                if self.actions.indexOf({ $0 == newValue }) == nil {
                    self.actions.append(action)
                }
            } else {
                self.actions.forEach { $0.style = .Default }
            }
        }
    }
    public var actionLayout: ActionLayout {
        get { return self.alertView.actionLayout }
        set { self.alertView.actionLayout = newValue }
    }

    private(set) public var textFields: [UITextField]?
    public var automaticallyFocusFirstTextField = true
    private var didAssignFirstResponder = false

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
        listenForKeyboardChanges()
        configureAlertView()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Explanation of why the first responder is set here:
        // http://stackoverflow.com/a/19580888/751268

        if self.automaticallyFocusFirstTextField && !self.didAssignFirstResponder {
            self.textFields?.first?.becomeFirstResponder()
            self.didAssignFirstResponder = true
        }
    }

    private func listenForKeyboardChanges() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardChange:",
            name: UIKeyboardWillChangeFrameNotification, object: nil)
    }

    @objc
    private func keyboardChange(notification: NSNotification) {
        let newFrameValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue
        guard let newFrame = newFrameValue?.CGRectValue() else { return }

        self.view.frame.size = CGSize(width: self.view.frame.width, height: newFrame.minY)

        if !self.isBeingPresented() {
            self.view.layoutIfNeeded()
        }
    }

    private func configureAlertView() {
        self.alertView.translatesAutoresizingMaskIntoConstraints = false

        self.alertView.title = self.attributedTitle
        self.alertView.message = self.attributedMessage
        self.alertView.actions = self.actions

        addTextFieldsIfNecessary()

        self.view.addSubview(self.alertView)
        self.alertView.sdc_centerInSuperview()

        self.alertView.prepareLayout()

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

    public func present(animated animated: Bool = true, completion: (() -> Void)? = nil) {
        let topViewController = UIViewController.topViewController()
        topViewController?.presentViewController(self, animated: animated, completion: completion)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
