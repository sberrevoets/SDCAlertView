import UIKit

final class Transition: NSObject, UIViewControllerTransitioningDelegate {
    private let alertStyle: AlertControllerStyle

    init(alertStyle: AlertControllerStyle) {
        self.alertStyle = alertStyle
    }

    func presentationController(forPresented presented: UIViewController,
        presenting: UIViewController?, source: UIViewController)
        -> UIPresentationController?
    {
        return PresentationController(presentedViewController: presented, presenting: presenting)
    }

    func animationController(forPresented presented: UIViewController,
        presenting: UIViewController, source: UIViewController)
        -> UIViewControllerAnimatedTransitioning?
    {
        return self.alertStyle == .alert ? AnimationController(presentation: true) : nil
    }

    func animationController(forDismissed dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning?
    {
        return self.alertStyle == .alert ? AnimationController(presentation: false) : nil
    }
}
