import UIKit

/// The alert controller's style
///
/// - actionSheet: An action sheet style alert that slides in from the bottom and presents the user with a
///                list of possible actions to perform. Does not show as expected on iPad.
/// - alert:       The standard alert style that asks the user for information or confirmation.
@objc(SDCAlertControllerStyle)
public enum AlertControllerStyle: Int {
    case actionSheet
    case alert
}


/// The layout of the alert's actions. Only applies to AlertControllerStyle.alert, not .actionSheet (see
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

    private var verticalCenter: NSLayoutConstraint?

    /// The alert's title. Directly uses `attributedTitle` without any attributes.
    override public var title: String? {
        get { return self.attributedTitle?.string }
        set { self.attributedTitle = newValue.map(NSAttributedString.init) }
    }

    /// The alert's message. Directly uses `attributedMessage` without any attributes.
    @objc
    public var message: String? {
        get { return self.attributedMessage?.string }
        set { self.attributedMessage = newValue.map(NSAttributedString.init) }
    }

    /// A stylized title for the alert.
    @objc
    public var attributedTitle: NSAttributedString? {
        get { return self.alert.title }
        set { self.alert.title = newValue }
    }

    /// A stylized message for the alert.
    @objc
    public var attributedMessage: NSAttributedString? {
        get { return self.alert.message }
        set { self.alert.message = newValue }
    }

    /// The alert's content view. This can be used to add custom views to your alert. The width of the content
    /// view is equal to the width of the alert, minus padding. The height must be defined manually since it
    /// depends on the size of the subviews.
    @objc
    public var contentView: UIView {
        return self.alert.contentView
    }

    /// The alert's actions (buttons).
    @objc
    private(set) public var actions = [AlertAction]() {
        didSet { self.alert.actions = self.actions }
    }

    /// The alert's preferred action, if one is set. Setting this value to an action that wasn't already added
    /// to the array will add it and override its style to `.preferred`. Setting this value to `nil` will
    /// remove the preferred style from all actions.
    @objc
    public var preferredAction: AlertAction? {
        get {
            if self.preferredStyle == .actionSheet {
                return nil
            }

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
    @objc
    public var actionLayout: ActionLayout {
        get { return (self.alert as? AlertView)?.actionLayout ?? .automatic }
        set { (self.alert as? AlertView)?.actionLayout = newValue }
    }

    /// The text fields that are added to the alert. Does nothing when used with an action sheet.
    @objc
    private(set) public var textFields: [UITextField]?

    /// The alert's custom behaviors. See `AlertBehaviors` for possible options.
    public lazy var behaviors: AlertBehaviors = AlertBehaviors.defaultBehaviors(forStyle: self.preferredStyle)

    /// A closure that, when set, returns whether the alert or action sheet should dismiss after the user taps
    /// on an action. If it returns false, the AlertAction handler will not be executed.
    @objc
    public var shouldDismissHandler: ((AlertAction?) -> Bool)?
    
    /// A closure called when the alert is dismissed after an outside tap (when `dismissOnOutsideTap` behavior
    /// is enabled)
    @objc
    public var outsideTapHandler: (() -> Void)?

    /// The visual style that applies to the alert or action sheet.
    @objc
    public lazy var visualStyle: AlertVisualStyle = AlertVisualStyle(alertStyle: self.preferredStyle)

    /// The alert's presentation style.
    @objc
    private(set) public var preferredStyle: AlertControllerStyle = .alert

    private let alert: UIView & AlertControllerViewRepresentable
    private lazy var transitionDelegate: Transition = Transition(alertStyle: self.preferredStyle)

    // MARK: - Initialization

    /// Create an alert with an stylized title and message. If no styles are necessary, consider using
    /// `init(title:message:preferredStyle:)`

    ///
    /// - parameter attributedTitle:   An optional stylized title
    /// - parameter attributedMessage: An optional stylized message
    /// - parameter preferredStyle:    The preferred presentation style of the alert. Default is `alert`.
    @objc
    public convenience init(attributedTitle: NSAttributedString?, attributedMessage: NSAttributedString?,
        preferredStyle: AlertControllerStyle = .alert)
    {
        self.init(preferredStyle: preferredStyle)
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
    @objc
    public convenience init(title: String?, message: String?, preferredStyle: AlertControllerStyle = .alert) {
        self.init(preferredStyle: preferredStyle)
        self.preferredStyle = preferredStyle
        self.commonInit()

        self.title = title
        self.message = message
    }

    private init(preferredStyle: AlertControllerStyle) {
        switch preferredStyle {
        case .alert:
            self.alert = AlertView()

        case .actionSheet:
            let nibName = String(describing: ActionSheetView.self)
            let objects = Bundle(for: ActionSheetView.self).loadNibNamed(nibName, owner: nil, options: nil)
            if let actionSheet = objects?.first as? ActionSheetView {
                self.alert = actionSheet
            } else {
                self.alert = AlertView()
            }
        }

        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        preconditionFailure("Please use one of the provided AlertController initializers")
    }

    private func commonInit() {
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self.transitionDelegate

        if self.preferredStyle == .alert {
            let command = UIKeyCommand(input: "\r", modifierFlags: [],
                                       action: #selector(self.handleHardwareReturnKey))
            self.addKeyCommand(command)
        }
    }

    // MARK: - Public

    /// Adds the provided action to the alert. Unlike the `UIAlertController` API, this method adds and shows
    /// buttons in the order they were added. This gives you the flexibility to place buttons of any style in
    /// any position.
    ///
    /// - parameter action: The action to add.
    @objc
    public func addAction(_ action: AlertAction) {
        self.actions.append(action)
    }

    /// Adds a text field to the alert.
    ///
    /// - parameter configurationHandler: An optional closure that can be used to configure the text field,
    ///                                   which is provided as a parameter to the closure.
    @objc
    public func addTextField(withHandler configurationHandler: ((UITextField) -> Void)? = nil) {
        let textField = UITextField()
        textField.autocorrectionType = .no
        configurationHandler?(textField)
        let currentTextFields = self.textFields ?? []
        self.textFields = currentTextFields + [textField]
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

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.textFields?.first?.resignFirstResponder()
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.presentingViewController?.preferredStatusBarStyle ?? .default
    }

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.presentingViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }

    // MARK: - Private

    @objc
    private func handleHardwareReturnKey() {
        if let preferredAction = self.preferredAction {
            self.alert.actionTappedHandler?(preferredAction)
        }
    }

    private func listenForKeyboardChanges() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChange),
                                               name: .UIKeyboardWillChangeFrame, object: nil)
    }

    @objc
    private func keyboardChange(_ notification: Notification) {
        let newFrameValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue
        guard let newFrame = newFrameValue?.cgRectValue else {
            return
        }

        self.verticalCenter?.constant = -newFrame.height / 2
        self.alert.layoutIfNeeded()
    }

    public override func becomeFirstResponder() -> Bool {
        if self.behaviors.contains(.automaticallyFocusTextField) {
            return self.textFields?.first?.becomeFirstResponder() ?? super.becomeFirstResponder()
        }

        return super.becomeFirstResponder()
    }

    private func configureAlertView() {
        self.alert.translatesAutoresizingMaskIntoConstraints = false
        self.alert.visualStyle = self.visualStyle
        self.alert.add(self.behaviors)

        self.addTextFieldsIfNecessary()
        self.addChromeTapHandlerIfNecessary()

        self.view.addSubview(self.alert)
        self.createViewConstraints()

        self.alert.prepareLayout()
        self.alert.actionTappedHandler = { [weak self] action in
            if self?.shouldDismissHandler?(action) != false {
                self?.dismiss(animated: true) {
                    action.handler?(action)
                }
            }
        }

        self.alert.layoutIfNeeded()
    }

    private func createViewConstraints() {
        let margins = self.visualStyle.margins

        switch self.preferredStyle {
            case .actionSheet:
                let bounds = self.presentingViewController?.view.bounds ?? self.view.bounds
                let width = min(bounds.width, bounds.height) - margins.left - margins.right
                NSLayoutConstraint.activate([
                    self.alert.widthAnchor.constraint(equalToConstant: width * self.visualStyle.width),
                    self.alert.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    self.alert.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                                           constant: margins.bottom),
                    self.alert.heightAnchor.constraint(lessThanOrEqualTo: self.heightAnchor,
                                                           constant: -margins.top)
                ])

            case .alert:
                self.alert.widthAnchor.constraint(equalToConstant: self.visualStyle.width).isActive = true
                self.verticalCenter = self.alert.centerYAnchor.constraint(equalTo: self.centerYAnchor)
                let maximumHeightOffset = -(margins.top + margins.bottom)

                NSLayoutConstraint.activate([
                    self.verticalCenter!,
                    self.alert.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    self.alert.heightAnchor.constraint(lessThanOrEqualTo: self.heightAnchor,
                                                       multiplier: 1, constant: maximumHeightOffset),
                ])

                let priority = UILayoutPriority(rawValue: 500)
                self.alert.setContentCompressionResistancePriority(priority, for: .vertical)
        }
    }

    private func addTextFieldsIfNecessary() {
        guard let textFields = self.textFields, let alert = self.alert as? AlertView else {
            return
        }

        let textFieldsViewController = TextFieldsViewController(textFields: textFields)
        textFieldsViewController.willMove(toParentViewController: self)
        self.addChildViewController(textFieldsViewController)
        alert.textFieldsViewController = textFieldsViewController
        textFieldsViewController.didMove(toParentViewController: self)
    }

    private func addChromeTapHandlerIfNecessary() {
        if !self.behaviors.contains(.dismissOnOutsideTap) {
            return
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(chromeTapped(_:)))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }

    @objc
    private func chromeTapped(_ sender: UITapGestureRecognizer) {
        if !self.alert.frame.contains(sender.location(in: self.view)) {
            self.dismiss() {
                self.outsideTapHandler?()
            }
        }
    }
}

private extension AlertController {
    var bottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11, *) {
            return self.view.safeAreaLayoutGuide.bottomAnchor
        } else {
            return self.view.bottomAnchor
        }
    }

    var centerYAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11, *) {
            return self.view.safeAreaLayoutGuide.centerYAnchor
        } else {
            return self.view.centerYAnchor
        }
    }

    var heightAnchor: NSLayoutDimension {
        if #available(iOS 11, *) {
            return self.view.safeAreaLayoutGuide.heightAnchor
        } else {
            return self.view.heightAnchor
        }
    }
}
