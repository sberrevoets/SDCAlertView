import UIKit

private var kDidAssignFirstResponderToken: dispatch_once_t = 0
/**
The alert controller's style.

- ActionSheet: An action sheet style alert that slides in from the bottom and presents the user with a list
               of possible actions to perform. Only available on iOS 9, and does not show as expected on
               iPad.
- Alert:       The standard alert style that asks the user for information or confirmation.
*/
@objc(SDCAlertControllerStyle)
public enum AlertControllerStyle: Int {
    case ActionSheet
    case Alert
}

/**
The layout of the alert's actions. Only applies to the Alert style alerts, not ActionSheet (see
`AlertControllerStyle`).

- Automatic:  If the alert has 2 actions, display them horizontally. Otherwise, display them vertically.
- Vertical:   Display the actions vertically
- Horizontal: Display the actions horizontally
*/
@objc(SDCActionLayout)
public enum ActionLayout: Int {
    case Automatic
    case Vertical
    case Horizontal
}

@available(*, deprecated, renamed="AlertVisualStyle")
public typealias DefaultVisualStyle = AlertVisualStyle

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
    private(set) public var actions = [AlertAction]() {
        didSet { self.alertView.actions = self.actions }
    }

    /// The alert's preferred action, if one is set. Setting this value to an action that wasn't already added
    /// to the array will add it and override its style to `.Preferred`. Setting this value to `nil` will
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
        get { return (self.alertView as? AlertView)?.actionLayout ?? .Automatic }
        set { (self.alertView as? AlertView)?.actionLayout = newValue }
    }

    /// The text fields that are added to the alert. Does nothing when used with an action sheet.
    private(set) public var textFields: [UITextField]?

    /// The alert's custom behaviors. See `AlertBehaviors` for possible options.
    public lazy var behaviors: AlertBehaviors? =
        AlertBehaviors.defaultBehaviorsForAlertWithStyle(self.preferredStyle)

    /// A closure that, when set, returns whether the alert or action sheet should dismiss after the user taps
    /// on an action. If it returns false, the AlertAction handler will not be executed.
    public var shouldDismissHandler: (AlertAction? -> Bool)?

    /// The visual style that applies to the alert or action sheet.
    public lazy var visualStyle: AlertVisualStyle = AlertVisualStyle(alertStyle: self.preferredStyle)

    /// The alert's presentation style.
    private(set) public var preferredStyle: AlertControllerStyle = .Alert

    @IBOutlet private var alertView: AlertControllerView! = AlertView()
    private lazy var transitionDelegate: Transition = Transition(alertStyle: self.preferredStyle)

    // MARK: - Initialization

    /**
    Create an alert with an stylized title and message. If no styles are necessary, consider using
    `init(title:message:preferredStyle:)`

    - parameter title:          An optional stylized title
    - parameter message:        An optional stylized message
    - parameter preferredStyle: The preferred presentation style of the alert. Default is Alert.
    */
    public convenience init(attributedTitle: NSAttributedString?, attributedMessage: NSAttributedString?,
        preferredStyle: AlertControllerStyle = .Alert)
    {
        self.init()
        self.preferredStyle = preferredStyle
        self.commonInit()

        self.attributedTitle = attributedTitle
        self.attributedMessage = attributedMessage

    }

    /**
    Creates an alert with a plain title and message. To add styles to the title or message, use
    `init(title:message:)`.

    - parameter title:          An optional title
    - parameter message:        An optional message
    - parameter preferredStyle: The preferred presentation style of the alert. Default is Alert.
    */
    public convenience init(title: String?, message: String?, preferredStyle: AlertControllerStyle = .Alert) {
        self.init()
        self.preferredStyle = preferredStyle
        self.commonInit()

        self.title = title
        self.message = message
    }

    private func commonInit() {
        self.modalPresentationStyle = .Custom
        self.transitioningDelegate = self.transitionDelegate

        if self.preferredStyle == .ActionSheet {
            let nibName = NSStringFromClass(ActionSheetView).componentsSeparatedByString(".").last!
            NSBundle(forClass: self.dynamicType).loadNibNamed(nibName, owner: self, options: nil)
        }
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
    Presents the alert.

    - parameter animated:   Whether to present the alert in an animated fashion
    - parameter completion: An optional closure that's called when the presentation finishes
    */
    @objc(presentAnimated:completion:)
    public func present(animated animated: Bool = true, completion: (() -> Void)? = nil) {
        let topViewController = UIViewController.topViewController()
        topViewController?.presentViewController(self, animated: animated, completion: completion)
    }

    /**
     Dismisses the alert.

     - parameter animated:   Whether to dismiss the alert in an animated fashion
     - parameter completion: An optional closure that's called when the presentation finishes
     */
    @objc(dismissAnimated:completion:)
    public func dismiss(animated animated: Bool = true, completion: (() -> Void)? = nil) {
        self.presentingViewController?.dismissViewControllerAnimated(animated, completion: completion)
    }

    // MARK: - Override

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.listenForKeyboardChanges()
        self.configureAlertView()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Explanation of why the first responder is set here:
        // http://stackoverflow.com/a/19580888/751268

        if self.behaviors?.contains(.AutomaticallyFocusTextField) == true {
            dispatch_once(&kDidAssignFirstResponderToken) {
                self.textFields?.first?.becomeFirstResponder()
            }
        }
    }

    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return self.presentingViewController?.preferredStatusBarStyle() ?? .Default
    }

    // MARK: - Private

    private func listenForKeyboardChanges() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardChange),
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
        self.alertView.visualStyle = self.visualStyle
        if let behaviors = self.behaviors {
            self.alertView.addBehaviors(behaviors)
        }

        self.addTextFieldsIfNecessary()
        self.addChromeTapHandlerIfNecessary()

        self.view.addSubview(self.alertView)
        self.createViewConstraints()

        self.alertView.prepareLayout()
        self.alertView.actionTappedHandler = { [weak self] action in
            guard self?.shouldDismissHandler?(action) != false else { return }
            self?.dismiss(animated: true) {
                action.handler?(action)
            }
        }
    }

    private func createViewConstraints() {
        let margins = self.visualStyle.margins

        switch self.preferredStyle {
            case .ActionSheet:
                let bounds = self.presentingViewController?.view.bounds ?? self.view.bounds
                let width = min(bounds.width, bounds.height) - margins.left - margins.right
                self.alertView.sdc_pinWidth(width * self.visualStyle.width)
                self.alertView.sdc_horizontallyCenterInSuperview()
                self.alertView.sdc_alignEdgesWithSuperview([.Bottom], insets: margins)
                self.alertView.sdc_setMaximumHeightToSuperviewHeightWithOffset(-margins.top)

            case .Alert:
                self.alertView.sdc_pinWidth(self.visualStyle.width)
                self.alertView.sdc_centerInSuperview()
                let maximumHeightOffset = -(margins.top + margins.bottom)
                self.alertView.sdc_setMaximumHeightToSuperviewHeightWithOffset(maximumHeightOffset)
                self.alertView.setContentCompressionResistancePriority(500, forAxis: .Vertical)
        }
    }

    private func addTextFieldsIfNecessary() {
        guard let textFields = self.textFields, alert = self.alertView as? AlertView else {
            return
        }

        let textFieldsViewController = TextFieldsViewController(textFields: textFields)
        textFieldsViewController.willMoveToParentViewController(self)
        self.addChildViewController(textFieldsViewController)
        alert.textFieldsViewController = textFieldsViewController
        textFieldsViewController.didMoveToParentViewController(self)
    }

    private func addChromeTapHandlerIfNecessary() {
        if self.behaviors?.contains(.DismissOnOutsideTap) != true {
            return
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(chromeTapped(_:)))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }

    @objc
    private func chromeTapped(sender: UITapGestureRecognizer) {
        if !self.alertView.frame.contains(sender.locationInView(self.view)) {
            self.dismiss()
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
