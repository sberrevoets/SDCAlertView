import UIKit

extension UIViewController {
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
