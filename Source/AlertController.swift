import UIKit

/// The alert controller's style
///
/// - actionSheet: An action sheet style alert that slides in from the bottom and presents the user with a
///                list of possible actions to perform. Only available on iOS 9, and does not show as expected
///                on iPad.
/// - alert:       The standard alert style that asks the user for information or confirmation.
@objc(SDCAlertControllerStyle)
public enum AlertControllerStyle: Int {
    case actionSheet
    case alert
}


/// The layout of the alert's actions. Only applies to the Alert style alerts, not ActionSheet (see
/// `AlertControllerStyle`).

///
/// - automatic:  If the alert has 2 actions, display them horizontally. Otherwise, display them vertically.
/// - vertical:   Display the actions vertically.
/// - horizontal: Display the actions horizontally.
@objc(SDCActionLayout)
public enum ActionLayout: Int {
    case automatic
    case vertical
    case horizontal
}

@objc(SDCAlertController)
public class AlertController: UIViewController {

    private lazy var assignResponder: () -> Bool = { [weak self] _ in
        self?.textFields?.first?.becomeFirstResponder() ?? false
    }

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
            let index = self.actions.index { $0.style == .preferred }
            return index != nil ? self.actions[index!] : nil
        }
        set {
            if let action = newValue {
                action.style = .preferred

                if self.actions.index(where: { $0 == newValue }) == nil {
                    self.actions.append(action)
                }
            } else {
                self.actions.forEach { $0.style = .normal }
            }
        }
    }

    /// The layout of the actions in the alert.
    public var actionLayout: ActionLayout {
        get { return (self.alertView as? AlertView)?.actionLayout ?? .automatic }
        set { (self.alertView as? AlertView)?.actionLayout = newValue }
    }

    /// The text fields that are added to the alert. Does nothing when used with an action sheet.
    private(set) public var textFields: [UITextField]?

    /// The alert's custom behaviors. See `AlertBehaviors` for possible options.
    public lazy var behaviors: AlertBehaviors? =
        AlertBehaviors.defaultBehaviorsForAlert(with: self.preferredStyle)

    /// A closure that, when set, returns whether the alert or action sheet should dismiss after the user taps
    /// on an action. If it returns false, the AlertAction handler will not be executed.
    public var shouldDismissHandler: ((AlertAction?) -> Bool)?

    /// The visual style that applies to the alert or action sheet.
    public lazy var visualStyle: AlertVisualStyle = AlertVisualStyle(alertStyle: self.preferredStyle)

    /// The alert's presentation style.
    private(set) public var preferredStyle: AlertControllerStyle = .alert

    @IBOutlet private var alertView: AlertControllerView! = AlertView()
    private lazy var transitionDelegate: Transition = Transition(alertStyle: self.preferredStyle)

    // MARK: - Initialization

    /// Create an alert with an stylized title and message. If no styles are necessary, consider using
    /// `init(title:message:preferredStyle:)`

    ///
    /// - parameter attributedTitle:   An optional stylized title
    /// - parameter attributedMessage: An optional stylized message
    /// - parameter preferredStyle:    The preferred presentation style of the alert. Default is `alert`.
    public convenience init(attributedTitle: NSAttributedString?, attributedMessage: NSAttributedString?,
        preferredStyle: AlertControllerStyle = .alert)
    {
        self.init()
        self.preferredStyle = preferredStyle
        self.commonInit()

        self.attributedTitle = attributedTitle
        self.attributedMessage = attributedMessage

    }

    /// Creates an alert with a plain title and message. To add styles to the title or message, use
    /// `init(attributedTitle:attributedMessage:)`.
    ///
    /// - parameter title:          An optional title
    /// - parameter message:        An optional message
    /// - parameter preferredStyle: The preferred presentation style of the alert. Default is `alert`.
    public convenience init(title: String?, message: String?, preferredStyle: AlertControllerStyle = .alert) {
        self.init()
        self.preferredStyle = preferredStyle
        self.commonInit()

        self.title = title
        self.message = message
    }

    private func commonInit() {
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self.transitionDelegate

        if self.preferredStyle == .actionSheet {
            let nibName = String(describing: ActionSheetView.self)
            Bundle(for: type(of: self)).loadNibNamed(nibName, owner: self, options: nil)
        }
    }

    // MARK: - Public

    /// Adds the provided action to the alert. Unlike the `UIAlertController` API, this method adds and shows
    /// buttons in the order they were added. This gives you the flexibility to place buttons of any style in
    /// any position.
    ///
    /// - parameter action: The action to add.
    public func add(_ action: AlertAction) {
        self.actions.append(action)
    }

    /// Adds a text field to the alert.
    ///
    /// - parameter configurationHandler: An optional closure that can be used to configure the text field,
    ///                                   which is provided as a parameter to the closure.
    public func addTextField(withHandler configurationHandler: ((UITextField) -> Void)? = nil) {
        let textField = UITextField()
        textField.autocorrectionType = .no
        configurationHandler?(textField)

        if self.textFields?.append(textField) == nil {
            self.textFields = [textField]
        }
    }

    /// Presents the alert.
    ///
    /// - parameter animated:   Whether to present the alert animated.
    /// - parameter completion: An optional closure that's called when the presentation finishes.
    @objc(presentAnimated:completion:)
    public func present(animated: Bool = true, completion: (() -> Void)? = nil) {
        let topViewController = UIViewController.topViewController()
        topViewController?.present(self, animated: animated, completion: completion)
    }

    /// Dismisses the alert.
    ///
    /// - parameter animated:   Whether to dismiss the alert animated.
    /// - parameter completion: An optional closure that's called when the dismissal finishes.
    @objc(dismissViewControllerAnimated:completion:)
    public override func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.presentingViewController?.dismiss(animated: animated, completion: completion)
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
            _ = self.assignResponder()
        }
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.presentingViewController?.preferredStatusBarStyle ?? .default
    }

    // MARK: - Private

    private func listenForKeyboardChanges() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChange),
            name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }

    @objc
    private func keyboardChange(_ notification: Notification) {
        let newFrameValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue
        guard let newFrame = newFrameValue?.cgRectValue else {
            return
        }

        self.view.frame.size = CGSize(width: self.view.frame.width, height: newFrame.minY)

        if !self.isBeingPresented {
            self.view.layoutIfNeeded()
        }
    }

    private func configureAlertView() {
        self.alertView.translatesAutoresizingMaskIntoConstraints = false
        self.alertView.visualStyle = self.visualStyle
        if let behaviors = self.behaviors {
            self.alertView.add(behaviors)
        }

        self.addTextFieldsIfNecessary()
        self.addChromeTapHandlerIfNecessary()

        self.view.addSubview(self.alertView)
        self.createViewConstraints()

        self.alertView.prepareLayout()
        self.alertView.actionTappedHandler = { [weak self] action in
            guard self?.shouldDismissHandler?(action) != false else {
                return
            }

            self?.dismiss(animated: true) {
                action.handler?(action)
            }
        }
    }

    private func createViewConstraints() {
        let margins = self.visualStyle.margins

        switch self.preferredStyle {
            case .actionSheet:
                let bounds = self.presentingViewController?.view.bounds ?? self.view.bounds
                let width = min(bounds.width, bounds.height) - margins.left - margins.right
                self.alertView.sdc_pinWidth(width * self.visualStyle.width)
                self.alertView.sdc_horizontallyCenterInSuperview()
                self.alertView.sdc_alignEdges(withSuperview: [.bottom], insets: margins)
                self.alertView.sdc_setMaximumHeightToSuperviewHeight(withOffset: -margins.top)

            case .alert:
                self.alertView.sdc_pinWidth(self.visualStyle.width)
                self.alertView.sdc_centerInSuperview()
                let maximumHeightOffset = -(margins.top + margins.bottom)
                self.alertView.sdc_setMaximumHeightToSuperviewHeight(withOffset: maximumHeightOffset)
                self.alertView.setContentCompressionResistancePriority(500, for: .vertical)
        }
    }

    private func addTextFieldsIfNecessary() {
        guard let textFields = self.textFields, let alert = self.alertView as? AlertView else {
            return
        }

        let textFieldsViewController = TextFieldsViewController(textFields: textFields)
        textFieldsViewController.willMove(toParentViewController: self)
        self.addChildViewController(textFieldsViewController)
        alert.textFieldsViewController = textFieldsViewController
        textFieldsViewController.didMove(toParentViewController: self)
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
    private func chromeTapped(_ sender: UITapGestureRecognizer) {
        if !self.alertView.frame.contains(sender.location(in: self.view)) {
            self.dismiss()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
