import UIKit

@objc(SDCAlertAction)
public class AlertAction: NSObject {
    /// Creates an action with a plain title.
    ///
    /// parameter title:   An optional title for the action
    /// parameter style:   The action's style
    /// parameter handler: An optional closure that's called when the user taps on this action
    @objc
    public convenience init(title: String?, style: AlertAction.Style, handler: ((AlertAction) -> Void)? = nil)
    {
        self.init()
        self.title = title
        self.style = style
        self.handler = handler
    }

    @objc
    /// Creates an action with a stylized title.
    ///
    /// - parameter attributedTitle: An optional stylized title
    /// - parameter style:           The action's style
    /// - parameter handler:         An optional closure that is called when the user taps on this action
    public convenience init(attributedTitle: NSAttributedString?, style: AlertAction.Style,
        handler: ((AlertAction) -> Void)? = nil)
    {
        self.init()
        self.attributedTitle = attributedTitle
        self.style = style
        self.handler = handler
    }

    /// A closure that gets executed when the user taps on this actions in the UI
    @objc
    public var handler: ((AlertAction) -> Void)?

    /// The plain title for the action. Uses `attributedTitle` directly.
    @objc
    private(set) public var title: String? {
        get { return self.attributedTitle?.string }
        set { self.attributedTitle = newValue.map(NSAttributedString.init) }
    }

    /// The stylized title for the action.
    @objc
    private(set) public var attributedTitle: NSAttributedString?

    /// The action's style.
    @objc
    internal(set) public var style: AlertAction.Style = .normal

    /// The action's button accessibility identifier
    @objc
    public var accessibilityIdentifier: String?

    /// Whether this action can be interacted with by the user.
    @objc
    public var isEnabled = true {
        didSet { self.actionView?.isEnabled = self.isEnabled }
    }

    var actionView: ActionCell? {
        didSet { self.actionView?.isEnabled = self.isEnabled }
    }
    
    /// Left-aligned image view. If an image is provided, the title label will be left-aligned instead of
    /// centered. If not other constraints are set, the size of the image is used to determine the size of
    /// the image view, preserving the image's aspect ratio. Custom constraints are also valid, but the image
    /// height can't be taller than the action it's shown in. This property only has an effect on action
    /// sheets.
    @objc
    public private(set) var imageView = UIImageView()
    
    /// Right-aligned accessory view. If set, the title label will be left-aligned instead of centered. If no
    /// other constraints are set, the view's intrinsic size is used to determine the size of the accessory
    /// view, preserving its aspect ratio. If the view has no intrinsic size, it's up to the developer to
    /// define a complete set of constraints. This property only has an effect on action sheets.
    @objc
    public var accessoryView: UIView?
}

extension AlertAction {
    /// The action's style
    @objc(SDCAlertActionStyle)
    public enum Style: Int {
        /// The action will have default font and text color
        case normal
        /// The action will take a style that indicates it's the preferred option
        case preferred
        /// The action will convey that this action will do something destructive
        case destructive
    }
}
