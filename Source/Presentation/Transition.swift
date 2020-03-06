import UIKit

class Transition: NSObject, UIViewControllerTransitioningDelegate {

    private let alertStyle: AlertControllerStyle
    private let dimmingViewColor: UIColor

    init(alertStyle: AlertControllerStyle, dimmingViewColor: UIColor) {
        self.alertStyle = alertStyle
        self.dimmingViewColor = dimmingViewColor
    }

    func presentationController(forPresented presented: UIViewController,
        presenting: UIViewController?, source: UIViewController)
        -> UIPresentationController?
    {
        return PresentationController(presentedViewController: presented,
                                      presenting: presenting,
                                      dimmingViewColor: dimmingViewColor)
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
