import UIKit

class PresentationController: UIPresentationController {

    private let dimmingView = UIView()

    override init(presentedViewController: UIViewController, presentingViewController: UIViewController) {
        super.init(presentedViewController: presentedViewController,
            presentingViewController: presentingViewController)
        self.dimmingView.backgroundColor = UIColor(white: 0, alpha: 0.4)
    }

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        self.presentingViewController.view.tintAdjustmentMode = .Dimmed
        self.dimmingView.alpha = 0

        self.containerView?.addSubview(self.dimmingView)

        let coordinator = self.presentedViewController.transitionCoordinator()
        coordinator?.animateAlongsideTransition({ _ in self.dimmingView.alpha = 1 }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()

        self.presentingViewController.view.tintAdjustmentMode = .Automatic

        let coordinator = self.presentedViewController.transitionCoordinator()
        coordinator?.animateAlongsideTransition({ _ in self.dimmingView.alpha = 0 }, completion: nil)
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()

        guard let containerView = self.containerView else { return }
        self.dimmingView.frame = containerView.frame
    }
}
