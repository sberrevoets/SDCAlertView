//
//  SDCAlertTransition.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/21/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertTransition.h"

#import "SDCAlertPresentationController.h"

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
	return .25;
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
	
	CGAffineTransform presentedTransform = CGAffineTransformIdentity;
	CGAffineTransform dismissedTransform = CGAffineTransformMakeScale(0.0001, 0.0001);
	
	animatingView.transform = self.isPresentation ? dismissedTransform : presentedTransform;
	
	[UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
		animatingView.transform = self.isPresentation ? presentedTransform : dismissedTransform;
	} completion:^(BOOL finished) {
		if (!self.isPresentation) {
			[fromViewController.view removeFromSuperview];
		}
		
		[transitionContext completeTransition:finished];
	}];
}

@end