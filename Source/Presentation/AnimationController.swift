import UIKit

private let kInitialScale: CGFloat = 1.2
private let kSpringDamping: CGFloat = 45.71
private let kSpringVelocity: CGFloat = 0

class AnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    private var isPresentation = false

    init(presentation: Bool) {
        self.isPresentation = presentation
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.404
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromController =
                transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toController =
                transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromView = fromController.view,
            let toView = toController.view else
        {
            return
        }

        if self.isPresentation {
            transitionContext.containerView.addSubview(toView)
        }

        let animatingController = self.isPresentation ? toController : fromController
        let animatingView = animatingController.view
        animatingView?.frame = transitionContext.finalFrame(for: animatingController)

        if self.isPresentation {
            animatingView?.transform = CGAffineTransform(scaleX: kInitialScale, y: kInitialScale)
            animatingView?.alpha = 0

            animate({
                    animatingView?.transform = CGAffineTransform(scaleX: 1, y: 1)
                    animatingView?.alpha = 1
                }, inContext: transitionContext, withCompletion: { finished in
                    transitionContext.completeTransition(finished)
                })

        } else {
            animate({
                    animatingView?.alpha = 0
                }, inContext: transitionContext, withCompletion: { finished in
                    fromView.removeFromSuperview()
                    transitionContext.completeTransition(finished)
                })
        }

    }

    private func animate(_ animations: @escaping (() -> Void),
                         inContext context: UIViewControllerContextTransitioning,
                         withCompletion completion: @escaping (Bool) -> Void)
    {
        UIView.animate(withDuration: self.transitionDuration(using: context), delay: 0,
            usingSpringWithDamping: kSpringDamping, initialSpringVelocity: kSpringVelocity, options: [],
            animations: animations, completion: completion)
    }
}
