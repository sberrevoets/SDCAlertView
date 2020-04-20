import UIKit

extension NSLayoutConstraint {
    func prioritized(value: UILayoutPriority) -> Self {
        self.priority = value
        return self
    }
}
