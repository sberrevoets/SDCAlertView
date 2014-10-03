//
//  SDCAlertTransition.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/21/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertTransition.h"

#import "SDCAlertPresentationController.h"
#import <RBBSpringAnimation.h>

@implementation SDCAlertTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
													  presentingViewController:(UIViewController *)presenting
														  sourceViewController:(UIViewController *)source {
	return [[SDCAlertPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

- (SDCAlertAnimationController *)animationControllerForPresentation:(BOOL)presentation {
	SDCAlertAnimationController *animationController = [[SDCAlertAnimationController alloc] init];
	animationController.presentation = presentation;
	return animationController;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
																  presentingController:(UIViewController *)presenting
																	  sourceController:(UIViewController *)source {
	return [self animationControllerForPresentation:YES];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
	return [self animationControllerForPresentation:NO];
}

@end


@implementation SDCAlertAnimationController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
	return 0.404;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
	UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	
	if (self.isPresentation) {
		[[transitionContext containerView] addSubview:toViewController.view];
	}
	
	UIViewController *animatingViewController = self.isPresentation ? toViewController : fromViewController;
	UIView *animatingView = animatingViewController.view;
	
	animatingView.frame = [transitionContext finalFrameForViewController:animatingViewController];
	
	if (self.isPresentation) {
		[self animatePresentingView:animatingView completion:^{
			[transitionContext completeTransition:YES];
		}];
	} else {
		[self animateDismissingView:animatingView completion:^{
			[fromViewController.view removeFromSuperview];
			[transitionContext completeTransition:YES];
		}];
	}
}

- (void)animatePresentingView:(UIView *)view completion:(void (^)(void))completion {
	RBBSpringAnimation *opacityAnimation = [self opacityAnimationFrom:@0 to:@1];
	RBBSpringAnimation *transformAnimation = [self transformAnimationForPresenting];
	
	view.layer.opacity = 1;
	view.layer.transform = [transformAnimation.toValue CATransform3DValue];
	
	CAAnimationGroup *group = [CAAnimationGroup animation];
	group.animations = @[opacityAnimation, transformAnimation];
	
	[self applyAnimation:group toView:view withCompletion:completion];
}

- (void)animateDismissingView:(UIView *)view completion:(void(^)(void))completion {
	RBBSpringAnimation *opacityAnimation = [self opacityAnimationFrom:@1 to:@0];
	view.alpha = 0;
	
	[self applyAnimation:opacityAnimation toView:view withCompletion:completion];
}

- (void)applyAnimation:(CAAnimation *)animation toView:(UIView *)view withCompletion:(void (^)(void))completion {
	[CATransaction begin];
	[CATransaction setCompletionBlock:completion];
	[view.layer addAnimation:animation forKey:@"presentation"];
	[CATransaction commit];
}

#pragma mark - Animations

- (RBBSpringAnimation *)springAnimationForKey:(NSString *)key {
	RBBSpringAnimation *animation = [[RBBSpringAnimation alloc] init];
	animation.additive = YES;
	animation.keyPath = key;
	
	animation.duration = [self transitionDuration:nil];
	animation.damping = 45.71;
	animation.mass = 1;
	animation.stiffness = 522.35;
	animation.velocity = 0;
	
	return animation;
}

- (RBBSpringAnimation *)opacityAnimationFrom:(NSNumber *)from to:(NSNumber *)to {
	RBBSpringAnimation *opacityAnimation = [self springAnimationForKey:@"opacity"];
	opacityAnimation.fromValue = from;
	opacityAnimation.toValue = to;
	
	return opacityAnimation;
}

#pragma mark Transform

- (RBBSpringAnimation *)transformAnimationForPresenting {
	CATransform3D transformFrom = CATransform3DMakeScale(1.26, 1.26, 1);
	CATransform3D transformTo = CATransform3DMakeScale(1, 1, 1);
	return [self transformAnimationFrom:transformFrom to:transformTo];
}

- (RBBSpringAnimation *)transformAnimationFrom:(CATransform3D)from to:(CATransform3D)to {
	RBBSpringAnimation *transformAnimation = [self springAnimationForKey:@"transform"];
	transformAnimation.fromValue = [NSValue valueWithCATransform3D:from];
	transformAnimation.toValue = [NSValue valueWithCATransform3D:to];
	
	return transformAnimation;
}

@end