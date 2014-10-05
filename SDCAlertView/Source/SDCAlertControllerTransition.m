//
//  SDCAlertControllerTransition.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/21/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertControllerTransition.h"

#import "SDCAlertPresentationController.h"

static CGFloat const SDCAlertAnimationControllerSpringDamping = 45.71;
static CGFloat const SDCAlertAnimationControllerSpringVelocity = 0;
static CGFloat const SDCAlertAnimationControllerInitialScale = 1.2;

@implementation SDCAlertControllerTransitioningDelegate

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
		animatingView.transform = CGAffineTransformMakeScale(SDCAlertAnimationControllerInitialScale, SDCAlertAnimationControllerInitialScale);
		animatingView.alpha = 0;
		
		[self animate:^{
			animatingView.transform = CGAffineTransformMakeScale(1, 1);
			animatingView.alpha = 1;
		}	inContext:transitionContext
	   withCompletion:^(BOOL finished) {
		   [transitionContext completeTransition:finished];
	   }];
		
	} else {
		[self animate:^{
			animatingView.alpha = 0;
		} inContext:transitionContext withCompletion:^(BOOL finished) {
			[fromViewController.view removeFromSuperview];
			[transitionContext completeTransition:finished];
		}];
	}
}

- (void)animate:(void(^)(void))animations inContext:(id<UIViewControllerContextTransitioning>)context withCompletion:(void(^)(BOOL finished))completion {
	[UIView animateWithDuration:[self transitionDuration:context]
						  delay:0
		 usingSpringWithDamping:SDCAlertAnimationControllerSpringDamping
		  initialSpringVelocity:SDCAlertAnimationControllerSpringVelocity
						options:0
					 animations:animations
					 completion:completion];
}

@end