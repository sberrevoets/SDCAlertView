import UIKit

@objc(SDCAlertVisualStyle)
open class AlertVisualStyle: NSObject {

    /// The width of the alert. A value of 1 or below is interpreted as a percentage of the width of the view
    /// controller that presents the alert.
    public var width: CGFloat

    /// The corner radius of the alert
    public var cornerRadius: CGFloat

    /// The minimum distance between alert elements and the alert itself
    public var contentPadding = UIEdgeInsets(top: 36, left: 16, bottom: 12, right: 16)

    /// The minimum distance between the alert and its superview
    public var margins: UIEdgeInsets

    /// The parallax magnitude
    public var parallax = UIOffset(horizontal: 15.75, vertical: 15.75)

    /// The background color of the alert. The standard blur effect will be added if nil. 
    public var backgroundColor: UIColor?

    /// The vertical spacing between elements
    public var verticalElementSpacing: CGFloat = 24

    /// The size of an action. The specified width is treated as a minimum width. The actual width is
    /// automatically determined.
    public var actionViewSize: CGSize

    /// The color of an action when the user is tapping it
    public var actionHighlightColor = UIColor(white: 0.8, alpha: 0.7)

    /// The color of the separators between actions
    public var actionViewSeparatorColor = UIColor(white: 0.5, alpha: 0.5)

    /// The thickness of the separators between actions
    public var actionViewSeparatorThickness: CGFloat = 1 / UIScreen.main.scale

    /// The font used in text fields
    public var textFieldFont = UIFont.systemFont(ofSize: 13)

    /// The height of a text field if added using the standard method call. Won't affect text fields added
    /// directly to the alert's content view.
    public var textFieldHeight: CGFloat = 25

    /// The border color of a text field if added using the standard method call. Won't affect text fields
    /// added directly to the alert's content view.
    public var textFieldBorderColor = UIColor(red: 64/255, green: 64/255, blue: 64/255, alpha: 1)

    /// The inset of the text within the text field if added using the standard method call. Won't affect text
    /// fields added directly to the alert's content view.
    public var textFieldMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)

    /// The color for a nondestructive action's text
    public var normalTextColor: UIColor?

    /// The color for a destructive action's text
    public var destructiveTextColor = UIColor.red

    /// The font for an alert's preferred action
    public var alertPreferredFont = UIFont.boldSystemFont(ofSize: 17)

    /// The font for an alert's other actions
    public var alertNormalFont = UIFont.systemFont(ofSize: 17)

    /// The font for an action sheet's preferred action
    public var actionSheetPreferredFont = UIFont.boldSystemFont(ofSize: 20)

    /// The font for an action sheet's other actions
    public var actionSheetNormalFont = UIFont.systemFont(ofSize: 20)

    /// The style of the alert.
    private let alertStyle: AlertControllerStyle

    public init(alertStyle: AlertControllerStyle) {
        self.alertStyle = alertStyle

        switch alertStyle {
            case .alert:
                self.width = 270

                if #available(iOS 9, *) {
                    self.cornerRadius = 13
                    self.margins = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
                    self.actionViewSize = CGSize(width: 90, height: 44)
                } else {
                    self.cornerRadius = 7
                    self.margins = UIEdgeInsets.zero
                    self.actionViewSize = CGSize(width: 90, height: 44)
                }

            case .actionSheet:
                self.width = 1

                if #available(iOS 9, *) {
                    self.cornerRadius = 13
                    self.margins = UIEdgeInsets(top: 30, left: 10, bottom: -10, right: 10)
                    self.actionViewSize = CGSize(width: 90, height: 57)
                } else {
                    self.cornerRadius = 4
                    self.margins = UIEdgeInsets(top: 10, left: 10, bottom: -8, right: 10)
                    self.actionViewSize = CGSize(width: 90, height: 44)
                }
        }
    }

    /// The text color for a given action.
    ///
    /// - parameter action: The action that determines the text color.
    ///
    /// - returns: The text color, or nil to use the alert's `tintColor`.
    open func textColor(for action: AlertAction?) -> UIColor? {
        return action?.style == .destructive ? self.destructiveTextColor : self.normalTextColor
    }

    /// The font for a given action.
    ///
    /// - parameter action: The action for which to return the font.
    ///
    /// - returns: The font.
    open func font(for action: AlertAction?) -> UIFont {
        switch (self.alertStyle, action?.style) {
            case (.alert, let style) where style == .preferred:
                return self.alertPreferredFont

            case (.alert, _):
                return self.alertNormalFont

            case (.actionSheet, let style) where style == .preferred:
                return self.actionSheetPreferredFont

            case (.actionSheet, _):
                return self.actionSheetNormalFont
        }
    }
}
