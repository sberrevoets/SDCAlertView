import UIKit

class Transition: NSObject, UIViewControllerTransitioningDelegate {

    func presentationControllerForPresentedViewController(presented: UIViewController,
        presentingViewController presenting: UIViewController, sourceViewController source: UIViewController)
        -> UIPresentationController?
    {
        return PresentationController(presentedViewController: presented,
            presentingViewController: presenting)
    }

    func animationControllerForPresentedController(presented: UIViewController,
        presentingController presenting: UIViewController, sourceController source: UIViewController)
        -> UIViewControllerAnimatedTransitioning?
    {
        let animationController = AnimationController()
        animationController.isPresentation = true
        return animationController
    }

    func animationControllerForDismissedController(dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning?
    {
        return AnimationController()
    }
}
