import UIKit

@objc(SDCAlertVisualStyle)
open class AlertVisualStyle: NSObject {
    /// The width of the alert. A value of 1 or below is interpreted as a percentage of the width of the view
    /// controller that presents the alert.
    @objc
    public var width: CGFloat

    /// The corner radius of the alert
    @objc
    public var cornerRadius: CGFloat = 13

    /// The minimum distance between alert elements and the alert itself
    @objc
    public var contentPadding = UIEdgeInsets(top: 36, left: 16, bottom: 12, right: 16)

    /// The minimum distance between the alert and its superview
    @objc
    public var margins: UIEdgeInsets

    /// The background color of the alert. The standard blur effect will be added if nil.
    @objc
    public var backgroundColor: UIColor?

    /// The background color of the action sheet Cancel button. The standard blur effect will be added if nil.
    @objc
    public var actionViewCancelBackgroundColor: UIColor? = {
        guard #available(iOS 13.0, *) else {
            return .white
        }

        return UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1)
            }

            return .white
        }
    }()

    /// The vertical spacing between elements
    @objc
    public var verticalElementSpacing: CGFloat = 28

    /// The size of an action. The specified width is treated as a minimum width. The actual width is
    /// automatically determined.
    @objc
    public var actionViewSize: CGSize

    /// The color of an action when the user is tapping it
    @objc
    public var actionHighlightColor = UIColor(white: 0.5, alpha: 0.3)

    /// The color of the separators between actions
    @objc
    public var actionViewSeparatorColor = UIColor(white: 0.5, alpha: 0.5)

    /// The thickness of the separators between actions
    @objc
    public var actionViewSeparatorThickness: CGFloat = 1 / UIScreen.main.scale

    /// The font used in text fields
    @objc
    public var textFieldFont = UIFont.systemFont(ofSize: 13)

    /// The height of a text field if added using the standard method call. Won't affect text fields added
    /// directly to the alert's content view.
    @objc
    public var textFieldHeight: CGFloat = 25

    /// The border color of a text field if added using the standard method call. Won't affect text fields
    /// added directly to the alert's content view.
    @objc
    public var textFieldBorderColor: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor.separator
        } else {
            return UIColor(red: 64/255, green: 64/255, blue: 64/255, alpha: 1)
        }
    }()
    
    @objc
    public var textFieldBackgroundColor: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor.systemBackground
        } else {
            return UIColor.white
        }
    }()

    /// The inset of the text within the text field if added using the standard method call. Won't affect text
    /// fields added directly to the alert's content view.
    @objc
    public var textFieldMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)

    /// The color for a normal action's text
    @objc
    public var normalTextColor: UIColor?

    /// The color for a preferred action's text. If `nil`, `normalTextColor` is used.
    @objc
    public var preferredTextColor: UIColor?

    /// The color for a destructive action's text
    @objc
    public var destructiveTextColor = UIColor.red

    /// The font for an alert's preferred action
    @objc
    public var alertPreferredFont = UIFont.boldSystemFont(ofSize: 17)

    /// The font for an alert's other actions
    @objc
    public var alertNormalFont = UIFont.systemFont(ofSize: 17)

    /// The font for an action sheet's preferred action
    @objc
    public var actionSheetPreferredFont = UIFont.boldSystemFont(ofSize: 20)

    /// The font for an action sheet's other actions
    @objc
    public var actionSheetNormalFont = UIFont.systemFont(ofSize: 20)

    /// The color that dims the surrounding background of the alert to make it stand out more.
    @objc
    public var dimmingColor: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                return UIColor(white: 0, alpha: traitCollection.userInterfaceStyle == .dark ? 0.48 : 0.2)
            }
        } else {
            return UIColor(white: 0, alpha: 0.2)
        }
    }()

    var blurEffect: UIBlurEffect {
        if #available(iOS 13, *) {
            return UIBlurEffect(style: .systemMaterial)
        } else if #available(iOS 10, *) {
            return UIBlurEffect(style: .prominent)
        } else {
            return UIBlurEffect(style: .extraLight)
        }
    }

    /// The style of the alert.
    private let alertStyle: AlertControllerStyle

    @objc
    public init(alertStyle: AlertControllerStyle) {
        self.alertStyle = alertStyle

        switch alertStyle {
            case .alert:
                if #available(iOS 11, *), UIApplication.shared.keyWindow!.safeAreaInsets.bottom > 0 {
                    self.margins = .zero
                } else {
                    self.margins = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
                }

                self.width = 270
                self.actionViewSize = CGSize(width: 90, height: 44)

            case .actionSheet:
                if #available(iOS 11, *), UIApplication.shared.keyWindow!.safeAreaInsets.bottom > 0 {
                    self.margins = UIEdgeInsets(top: 30, left: 10, bottom: 0, right: 10)
                } else {
                    self.margins = UIEdgeInsets(top: 30, left: 10, bottom: -10, right: 10)
                }

                self.width = 1
                self.actionViewSize = CGSize(width: 90, height: 57)
        }
    }

    /// The text color for a given action.
    ///
    /// - parameter action: The action that determines the text color.
    ///
    /// - returns: The text color, or nil to use the alert's `tintColor`.
    @objc
    open func textColor(for action: AlertAction?) -> UIColor? {
        if action?.style == .destructive {
            return self.destructiveTextColor
        } else if action?.style == .preferred {
            return self.preferredTextColor ?? self.normalTextColor
        } else {
            return self.normalTextColor
        }
    }

    /// The font for a given action.
    ///
    /// - parameter action: The action for which to return the font.
    ///
    /// - returns: The font.
    @objc
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
