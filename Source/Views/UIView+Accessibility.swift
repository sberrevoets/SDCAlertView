import UIKit

extension UIView {
    func setupAccessibility(using action: AlertAction) {
        self.accessibilityLabel = action.attributedTitle?.string
        self.accessibilityTraits = .button
        self.accessibilityIdentifier = action.accessibilityIdentifier
        self.isAccessibilityElement = true
    }
}
