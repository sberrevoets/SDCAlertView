public struct AlertBehaviors: OptionSet {

    /// When applied, the user can dismiss the alert or action sheet by tapping outside of it. Enabled for
    /// action sheets by default.
    public static let DismissOnOutsideTap = AlertBehaviors(rawValue: 1)

    /// Applies the "drag tap" behavior, meaning when the user taps on an action and then drags their finger
    /// to another action the new action will be selected. Enabled on iOS 9 by default for both alerts and
    /// action sheets.
    public static let DragTap = AlertBehaviors(rawValue: 1 << 1)

    /// Adds a parallax effect to the alert. Does not apply to action sheets. Enabled on iOS 8 by default.
    public static let Parallax = AlertBehaviors(rawValue: 1 << 2)

    /// Automatically focuses the first text field in an alert. This doesn't work for text fields added to an
    /// alert's content view.
    public static let AutomaticallyFocusTextField = AlertBehaviors(rawValue: 1 << 3)

    static func defaultBehaviorsForAlert(with style: AlertControllerStyle) -> AlertBehaviors {
        var behaviors: AlertBehaviors = []

        if #available(iOS 9, *) {
            behaviors.insert([.DragTap])
        } else if style == .alert {
            behaviors.insert([.Parallax])
        }

        switch style {
            case .actionSheet:  return behaviors.union(.DismissOnOutsideTap)
            case .alert:        return behaviors.union(.AutomaticallyFocusTextField)
        }
    }

    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
}
