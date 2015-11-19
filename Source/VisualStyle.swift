import UIKit

public protocol VisualStyle {

    /// The width of the alert
    var width: CGFloat { get }

    /// The corner radius of the alert
    var cornerRadius: CGFloat { get }

    /// The minimum distance between alert elements and the alert itself
    var contentPadding: UIEdgeInsets { get }

    /// The minimum distance between the alert and its superview
    var margins: UIEdgeInsets { get }

    /// The parallax magnitude
    var parallax: UIOffset { get }

    /// The background color of the alert, if nil a blur effect view will be added
    var backgroundColor: UIColor? { get }

    /// The font used for the title label
    var titleLabelFont: UIFont { get }

    /// The color used for the title label
    var titleLabelColor: UIColor { get }

    /// The font used for the message label
    var messageLabelFont: UIFont { get }

    /// The color used for the message label
    var messageLabelColor: UIColor { get }

    /// The vertical spacing between elements
    var verticalElementSpacing: CGFloat { get }

    /// The size of an action. The specified width is treated as a minimum width. The actual width is
    /// automatically determined.
    var actionViewSize: CGSize { get }

    /// The color of the separators between actions
    var actionViewSeparatorColor: UIColor { get }

    /// The thickness of the separators between actions
    var actionViewSeparatorThickness: CGFloat { get }

    /**
    The text color for a given action.

    - parameter action: The action that determines the text color

    - returns: The text color
    */
    func textColor(forAction action: AlertAction?) -> UIColor

    /**
    The font for a given action

    - parameter action: The action that determines the font

    - returns: The font
    */
    func font(forAction action: AlertAction?) -> UIFont

    /// The font used in text fields
    var textFieldFont: UIFont { get }

    /// The height of a text field if added using the standard method call. Won't affect text fields added
    /// directly to the alert's content view.
    var textFieldHeight: CGFloat { get }

    /// The border color of a text field if added using the standard method call. Won't affect text fields
    /// added directly to the alert's content view.
    var textFieldBorderColor: UIColor { get }

    /// The inset of the text within the text field if added using the standard method call. Won't affect text
    /// fields added directly to the alert's content view.
    var textFieldMargins: UIEdgeInsets { get }
}

extension VisualStyle {

    public var width: CGFloat { return 270 }
    public var cornerRadius: CGFloat {
        if #available(iOS 9, *) {
            return 13
        } else {
            return 7
        }
    }

    public var contentPadding: UIEdgeInsets { return UIEdgeInsets(top: 36, left: 16, bottom: 12, right: 16) }

    public var margins: UIEdgeInsets { return UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0) }
    public var parallax: UIOffset { return UIOffset(horizontal: 15.75, vertical: 15.75) }

    public var backgroundColor: UIColor? { return nil }

    public var titleLabelFont: UIFont { return UIFont.boldSystemFontOfSize(17) }
    public var titleLabelColor: UIColor { return UIColor.blackColor() }

    public var messageLabelFont: UIFont { return UIFont.systemFontOfSize(13) }
    public var messageLabelColor: UIColor { return UIColor.blackColor() }

    public var verticalElementSpacing: CGFloat { return 24 }

    public var actionViewSize: CGSize { return CGSize(width: 90, height: 44) }
    public var actionViewSeparatorColor: UIColor { return UIColor(white: 0.5, alpha: 0.5) }
    public var actionViewSeparatorThickness: CGFloat { return 1 / UIScreen.mainScreen().scale }

    public func textColor(forAction action: AlertAction?) -> UIColor {
        if action?.style == .Destructive {
            return UIColor.redColor()
        } else {
            return UIView().tintColor
        }
    }

    public func font(forAction action: AlertAction?) -> UIFont {
        if action?.style == .Preferred {
            return UIFont.boldSystemFontOfSize(17)
        } else {
            return UIFont.systemFontOfSize(17)
        }
    }

    public var textFieldFont: UIFont { return UIFont.systemFontOfSize(13) }
    public var textFieldHeight: CGFloat { return 25 }
    public var textFieldBorderColor: UIColor {
        return UIColor(red: 64/255, green: 64/255, blue: 64/255, alpha: 1)
    }
    public var textFieldMargins: UIEdgeInsets { return UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4) }
}

public class DefaultVisualStyle: VisualStyle { }
