import UIKit

class PresentationController: UIPresentationController {
    
    private let dimmingView = UIView()

    init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?,
         dimmingViewColor: UIColor)
    {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.dimmingView.backgroundColor = dimmingViewColor
    }

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        self.presentingViewController.view.tintAdjustmentMode = .dimmed
        self.dimmingView.alpha = 0

        self.containerView?.addSubview(self.dimmingView)

        let coordinator = self.presentedViewController.transitionCoordinator
        coordinator?.animate(alongsideTransition: { _ in self.dimmingView.alpha = 1 }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()

        self.presentingViewController.view.tintAdjustmentMode = .automatic

        let coordinator = self.presentedViewController.transitionCoordinator
        coordinator?.animate(alongsideTransition: { _ in self.dimmingView.alpha = 0 }, completion: nil)
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()

        if let containerView = self.containerView {
            self.dimmingView.frame = containerView.frame
        }
    }
}
