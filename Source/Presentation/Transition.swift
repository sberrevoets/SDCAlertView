import UIKit

class Transition: NSObject, UIViewControllerTransitioningDelegate {

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
        if self.alertStyle == .actionSheet {
            return nil
        }

        return AnimationController(presentation: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.alertStyle == .alert ? AnimationController(presentation: false) : nil
    }
}
