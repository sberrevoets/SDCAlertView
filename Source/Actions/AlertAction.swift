import UIKit

/**
The action's style

- Default:     The action will have default font and text color
- Preferred:   The action will take a style that indicates it's the preferred option
- Destructive: The action will convey that this action will do something destructive
*/
@objc(SDCAlertActionStyle)
public enum AlertActionStyle: Int {
    case Default
    case Preferred
    case Destructive
}

@objc(SDCAlertAction)
public class AlertAction: NSObject {

    /**
    Creates an action with a plain title.

    - parameter title:   An optional title for the action
    - parameter style:   The action's style
    - parameter handler: An optional closure that's called when the user taps on this action
    */
    public convenience init(title: String?, style: AlertActionStyle, handler: (AlertAction -> Void)? = nil) {
        self.init()
        self.title = title
        self.style = style
        self.handler = handler
    }

    /**
    Creates an action with a stylized title.

    - parameter attributedTitle: An optional stylized title
    - parameter style:           The action's style
    - parameter handler:         An optional closure that is called when the user taps on this action
    */
    public convenience init(attributedTitle: NSAttributedString?, style: AlertActionStyle,
        handler: (AlertAction -> Void)? = nil)
    {
        self.init()
        self.attributedTitle = attributedTitle
        self.style = style
        self.handler = handler
    }

    /// A closure that gets executed when the user taps on this actions in the UI
    public var handler: (AlertAction -> Void)?

    /// The plain title for the action. Uses `attributedTitle` directly.
    private(set) public var title: String? {
        get { return self.attributedTitle?.string }
        set { self.attributedTitle = newValue.map(NSAttributedString.init) }
    }

    /// The stylized title for the action.
    private(set) public var attributedTitle: NSAttributedString?

    /// The action's style.
    internal(set) public var style: AlertActionStyle = .Default

    /// Whether this action can be interacted with by the user.
    public var enabled = true {
        didSet { self.actionView?.enabled = self.enabled }
    }

    var actionView: ActionCell? {
        didSet { self.actionView?.enabled = self.enabled }
    }
}
