import UIKit

public protocol VisualStyle {

    /// The width of the alert. A value of 1 or below is interpreted as a percentage of the width of the view
    /// controller that presents the alert.
    var width: CGFloat { get }

    /// The corner radius of the alert
    var cornerRadius: CGFloat { get }

    /// The minimum distance between alert elements and the alert itself
    var contentPadding: UIEdgeInsets { get }

    /// The minimum distance between the alert and its superview
    var margins: UIEdgeInsets { get }

    /// The parallax magnitude
    var parallax: UIOffset { get }

    /// The background color of the alert. The standard blur effect will be added if nil. (Not supported on
    /// action sheets).
    var backgroundColor: UIColor? { get }

    /// The vertical spacing between elements
    var verticalElementSpacing: CGFloat { get }

    /// The size of an action. The specified width is treated as a minimum width. The actual width is
    /// automatically determined.
    var actionViewSize: CGSize { get }

    /// The color of an action when the user is tapping it
    var actionHighlightColor: UIColor { get }

    /// The color of the separators between actions
    var actionViewSeparatorColor: UIColor { get }

    /// The thickness of the separators between actions
    var actionViewSeparatorThickness: CGFloat { get }

    /**
    The text color for a given action.

    - parameter action: The action that determines the text color

    - returns: The text color. A nil value will use the alert's `tintColor`.
    */
    func textColor(forAction action: AlertAction?) -> UIColor?

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

    public var contentPadding: UIEdgeInsets { return UIEdgeInsets(top: 36, left: 16, bottom: 12, right: 16) }

    public var parallax: UIOffset { return UIOffset(horizontal: 15.75, vertical: 15.75) }

    public var backgroundColor: UIColor? { return nil }

    public var verticalElementSpacing: CGFloat { return 24 }

    public var actionHighlightColor: UIColor { return UIColor(white: 0.8, alpha: 0.7) }
    public var actionViewSeparatorColor: UIColor { return UIColor(white: 0.5, alpha: 0.5) }
    public var actionViewSeparatorThickness: CGFloat { return 1 / UIScreen.mainScreen().scale }

    public func textColor(forAction action: AlertAction?) -> UIColor? {
        return action?.style == .Destructive ? UIColor.redColor() : nil
    }

    public var textFieldFont: UIFont { return UIFont.systemFontOfSize(13) }
    public var textFieldHeight: CGFloat { return 25 }
    public var textFieldBorderColor: UIColor {
        return UIColor(red: 64/255, green: 64/255, blue: 64/255, alpha: 1)
    }
    public var textFieldMargins: UIEdgeInsets { return UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4) }
}

@objc(SDCDefaultVisualStyle)
public class DefaultVisualStyle: NSObject, VisualStyle {

    private let alertStyle: AlertControllerStyle
    public init(alertStyle: AlertControllerStyle) { self.alertStyle = alertStyle }

    public var width: CGFloat { return self.alertStyle == .Alert ? 270 : 1 }

    public var cornerRadius: CGFloat {
        if #available(iOS 9, *) {
            return 13
        } else {
            return self.alertStyle == .Alert ? 7 : 4
        }
    }

    public var margins: UIEdgeInsets {
        if self.alertStyle == .Alert {
            if #available(iOS 9, *) {
                return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
            } else {
                return UIEdgeInsetsZero
            }
        } else {
            if #available(iOS 9, *) {
                return UIEdgeInsets(top: 30, left: 10, bottom: -10, right: 10)
            } else {
                return UIEdgeInsets(top: 10, left: 10, bottom: -8, right: 10)
            }
        }
    }

    public var actionViewSize: CGSize {
        if #available(iOS 9, *) {
            return self.alertStyle == .Alert ? CGSize(width: 90, height: 44) : CGSize(width: 90, height: 57)
        } else {
            return CGSize(width: 90, height: 44)
        }
    }

    public func font(forAction action: AlertAction?) -> UIFont {
        switch (self.alertStyle, action?.style) {
            case (.Alert, let style) where style == .Preferred:
                return UIFont.boldSystemFontOfSize(17)

            case (.Alert, _):
                return UIFont.systemFontOfSize(17)

            case (.ActionSheet, let style) where style == .Preferred:
                return UIFont.boldSystemFontOfSize(20)

            case (.ActionSheet, _):
                return UIFont.systemFontOfSize(20)
        }
    }
}
