import UIKit

/**
The style of the alert. The only available style is "Alert" and the only reason this enum exists is to provide
as much parity with UIAlertController as possible.

- Alert: Display the alert in the traditional alert style
*/
@objc
public enum AlertStyle: Int {
    case Alert
}

/**
The layout of the alert's actions

- Automatic:  If the alert has 2 actions, display them horizontally. Otherwise, display them vertically.
- Vertical:   Display the actions vertically
- Horizontal: Display the actions horizontally
*/
@objc
public enum ActionLayout: Int {
    case Automatic
    case Vertical
    case Horizontal
}

@objc(SDCAlertController)
public class AlertController: UIViewController {

    /// The alert's title. Directly uses `attributedTitle` without any attributes.
    override public var title: String? {
        get { return self.attributedTitle?.string }
        set { self.attributedTitle = newValue.map(NSAttributedString.init) }
    }

    /// The alert's message. Directly uses `attributedMessage` without any attributes.
    public var message: String? {
        get { return self.attributedMessage?.string }
        set { self.attributedMessage = newValue.map(NSAttributedString.init) }
    }

    /// A stylized title for the alert.
    public var attributedTitle: NSAttributedString? {
        get { return self.alertView.title }
        set { self.alertView.title = newValue }
    }

    /// A stylized message for the alert.
    public var attributedMessage: NSAttributedString? {
        get { return self.alertView.message }
        set { self.alertView.message = newValue }
    }

    /// The alert's content view. This can be used to add custom views to your alert. The width of the content
    /// view is equal to the width of the alert, minus padding. The height must be defined manually since it
    /// depends on the size of the subviews.
    public var contentView: UIView {
        return self.alertView.contentView
    }

    /// The alert's actions (buttons).
    private(set) public var actions = [AlertAction]()

    /// The alert's preferred action, if one is set. Setting this value to an action that wasn't already added
    /// to the array will add it and override its style to `.Preferrded`. Setting this value to `nil` will
    /// remove the preferred style from all actions.
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

    /// The layout of the actions in the alert.
    public var actionLayout: ActionLayout {
        get { return self.alertView.actionLayout }
        set { self.alertView.actionLayout = newValue }
    }

    /// The text fields that are added to the alert.
    private(set) public var textFields: [UITextField]?

    /// Controls whether to automatically make the first text field, if available, the first responder.
    public var automaticallyFocusFirstTextField = true
    private var didAssignFirstResponder = false

    /// The alert's presentation style.
    private(set) public var preferredStyle: AlertStyle = .Alert

    private let alertView = AlertControllerView()
    private let transitionDelegate = Transition()
    private var shouldDismissHandler: (AlertAction -> Bool)?

    // MARK: - Initialization

    /**
    Create an alert with an stylized title and message. If no styles are necessary, consider using
    `init(title:message:preferredStyle:)`

    - parameter title:   An optional stylized title
    - parameter message: An optional stylized message
    */
    public convenience init(title: NSAttributedString?, message: NSAttributedString?) {
        self.init()
        commonInit()

        self.attributedTitle = title
        self.attributedMessage = message
    }

    /**
    Creates an alert with a plain title and message. To add styles to the title or message, use
    `init(title:message:)`.

    - parameter title:          An optional title
    - parameter message:        An optional message
    - parameter preferredStyle: The preferred presentation style of the alert
    */
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

    // MARK: - Public

    /**
    Adds the provided action to the alert. Unlike the `UIAlertController` API, this method adds and shows
    buttons in the order they were added. This gives you the flexibility to place buttons of any style in any
    position.

    - parameter action: The action to add
    */
    public func addAction(action: AlertAction) {
        self.actions.append(action)
    }

    /**
    Adds a text field to the alert.

    - parameter configurationHandler: An optional closure that can be used to configure the text field, which
    is provided as a parameter to the closure
    */
    public func addTextFieldWithConfigurationHandler(configurationHandler: (UITextField -> Void)? = nil) {
        let textField = UITextField()
        textField.autocorrectionType = .No
        configurationHandler?(textField)

        if self.textFields?.append(textField) == nil {
            self.textFields = [textField]
        }
    }

    /**
    Set the visual style for the alert.

    - parameter visualStyle: The new visual style
    */
    public func setVisualStyle(visualStyle: VisualStyle) {
        self.alertView.visualStyle = visualStyle
    }

    /**
    Set the closure that should determine whether an action can dismiss the alert.

    - parameter handler: The handler that provides an `AlertAction` to identify which action wants to dismiss
    the alert
    */
    public func setShouldDismissHandler(handler: AlertAction -> Bool) {
        self.shouldDismissHandler = handler
    }

    /**
    Presents the alert.

    - parameter animated:   Whether to present the alert in an animated fashion
    - parameter completion: An optional closure that's called when the presentation finishes
    */
    public func present(animated animated: Bool = true, completion: (() -> Void)? = nil) {
        let topViewController = UIViewController.topViewController()
        topViewController?.presentViewController(self, animated: animated, completion: completion)
    }

    /**
     Dismisses the alert.

     - parameter animated:   Whether to dismiss the alert in an animated fashion
     - parameter completion: An optional closure that's called when the presentation finishes
     */
    public func dismiss(animated animated: Bool = true, completion: (() -> Void)? = nil) {
        self.presentingViewController?.dismissViewControllerAnimated(animated, completion: completion)
    }

    // MARK: - Override

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

    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return self.presentingViewController?.preferredStatusBarStyle() ?? .Default
    }

    // MARK: - Private

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

        self.alertView.setActionTappedHandler { [weak self] action in
            guard self?.shouldDismissHandler?(action) != false else { return }
            self?.presentingViewController?.dismissViewControllerAnimated(true) {
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

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

public extension AlertController {

    /**
    Convenience method to quickly display a basic alert

    - parameter title:       An optional title for the alert
    - parameter message:     An optional message for the alert
    - parameter actionTitle: An optional action for the alert
    - parameter customView:  An optional view that will be displayed in the alert's `contentView`

    - returns: The alert that was presented
    */
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
