import UIKit

private let kInitialScale: CGFloat = 1.2
private let kSpringDamping: CGFloat = 45.71
private let kSpringVelocity: CGFloat = 0

class AnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    var isPresentation = false

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.404
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromController =
                transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            let toController =
                transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
            let fromView = fromController.view,
            let toView = toController.view
        else {
            return
        }

        if self.isPresentation {
            transitionContext.containerView()?.addSubview(toView)
        }

        let animatingController = self.isPresentation ? toController : fromController
        let animatingView = animatingController.view
        animatingView.frame = transitionContext.finalFrameForViewController(animatingController)

        if self.isPresentation {
            animatingView.transform = CGAffineTransformMakeScale(kInitialScale, kInitialScale)
            animatingView.alpha = 0

            animate({
                    animatingView.transform = CGAffineTransformMakeScale(1, 1)
                    animatingView.alpha = 1
                }, inContext: transitionContext, withCompletion: { finished in
                    transitionContext.completeTransition(finished)
                })

        } else {
            animate({
                    animatingView.alpha = 0
                }, inContext: transitionContext, withCompletion: { finished in
                    fromView.removeFromSuperview()
                    transitionContext.completeTransition(finished)
                })
        }

    }

    private func animate(animations: (() -> Void), inContext context: UIViewControllerContextTransitioning,
        withCompletion completion: (Bool) -> Void)
    {
        UIView.animateWithDuration(self.transitionDuration(context), delay: 0,
            usingSpringWithDamping: kSpringDamping, initialSpringVelocity: kSpringVelocity, options: [],
            animations: animations, completion: completion)
    }
}
