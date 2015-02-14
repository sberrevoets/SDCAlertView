//
//  SDCAlertViewController.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 11/5/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertViewController.h"

#import "SDCAlertViewCoordinator.h"

#import "RBBSpringAnimation.h"
#import "SDCAlertView.h"

#import "UIView+SDCAutoLayout.h"

#ifndef NSFoundationVersionNumber_iOS_7_1
#define NSFoundationVersionNumber_iOS_7_1 1047.25
#endif

static CGFloat 			const SDCAlertViewShowingAnimationScale = 1.26;
static CGFloat 			const SDCAlertViewDismissingAnimationScale = 0.84;
static CFTimeInterval	const SDCAlertViewSpringAnimationDuration = 0.5058237314224243;
static CGFloat			const SDCAlertViewSpringAnimationDamping = 500;
static CGFloat			const SDCAlertViewSpringAnimationMass = 3;
static CGFloat			const SDCAlertViewSpringAnimationStiffness = 1000;
static CGFloat			const SDCAlertViewSpringAnimationVelocity = 0;

@interface UIWindow (SDCAlertView)
+ (UIWindow *)sdc_alertWindow;
@end

@interface SDCAlertViewController ()
@property (nonatomic, strong) UIView *alertContainerView;
@property (nonatomic, strong) UIView *dimmingView;
@property (nonatomic) BOOL showsDimmingView;
@property (nonatomic, strong) NSLayoutConstraint *bottomSpacingConstraint;
@property (nonatomic, getter = isPresentingFirstAlert) BOOL presentingFirstAlert;
@property (nonatomic, getter = isDismissingLastAlert) BOOL dismissingLastAlert;
@end

@implementation SDCAlertViewController

// UIViewController has a private instance variable named dimmingView. Divert from the convention...
@synthesize dimmingView = dimmingView_;

- (instancetype)init {
	self = [super init];
	
	if (self) {
		[self createViewHierarchy];
		
		_presentingFirstAlert = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	}
	
	return self;
}

#pragma mark - Status Bar

- (BOOL)prefersStatusBarHidden {
	return [[UIApplication sharedApplication] isStatusBarHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return [[UIApplication sharedApplication] statusBarStyle];
}

#pragma mark - Rotation

- (BOOL)shouldAutorotate {
	return [self.coordinator shouldRotateAlerts];
}

- (NSUInteger)supportedInterfaceOrientations {
	return [self.coordinator supportedAlertInterfaceOrientations];
}

#pragma mark - View Hierarchy

- (void)createViewHierarchy {
	[self createDimmingView];
	[self createAlertContainer];
}

- (void)createDimmingView {
	self.dimmingView = [[UIView alloc] initWithFrame:self.alertContainerView.bounds];
	[self.dimmingView setTranslatesAutoresizingMaskIntoConstraints:NO];
	self.dimmingView.backgroundColor = [UIColor sdc_dimmedBackgroundColor];
	[self.view addSubview:self.dimmingView];
	[self.dimmingView sdc_alignEdgesWithSuperview:UIRectEdgeAll];
}

- (void)createAlertContainer {
	self.alertContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
	[self.alertContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self.view addSubview:self.alertContainerView];
	[self.alertContainerView sdc_alignEdgesWithSuperview:UIRectEdgeLeft|UIRectEdgeTop|UIRectEdgeRight];
	self.bottomSpacingConstraint = [[self.alertContainerView sdc_alignEdgesWithSuperview:UIRectEdgeBottom] firstObject];
}

#pragma mark - Showing/Hiding

- (void)animateAlertContainerForKeyboardChangeWithDuration:(NSTimeInterval)duration {
	[UIView animateWithDuration:duration animations:^{
		[self.view layoutIfNeeded];
	}];
}

- (void)keyboardWillShow:(NSNotification *)notification {
	CGRect keyboardFrame = [[notification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	
	CGFloat keyboardHeight = CGRectGetHeight(keyboardFrame);
	
	/*
	 *  Normally, the keyboard's frame would have to be converted using a convertRect: method to get
	 *  the frame in the right orientation. This works in both portrait and landscape if the orientation
	 *  stays the same, but not if the device is rotated when an alert is shown. So we directly check
	 *  the orientation and use either the keyboard frame's width or height based on that. Not great, but it works.
	 *  This problem is fixed in iOS 8, so the hack is only in place for iOS 7.
	 */
	
	if (UIInterfaceOrientationIsLandscape(orientation) && floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
		keyboardHeight = CGRectGetWidth(keyboardFrame);
	}
	
	self.bottomSpacingConstraint.constant = -keyboardHeight;
	
	// No need to animate the resizing of the alert container when the first alert is presented
	if (!self.isPresentingFirstAlert) {
		NSTimeInterval animationDuration = [[notification userInfo][UIKeyboardAnimationDurationUserInfoKey] doubleValue];
		[self animateAlertContainerForKeyboardChangeWithDuration:animationDuration];
	}
}

- (void)keyboardWillHide:(NSNotification *)notification {
	/*
	 *  Don't resize the alert container if we're animating the last alert that was going to
	 *  be shown. If an alert showed a keyboard, that keyboard will animate away when the alert
	 *  is dismissed. To make sure the next alert is shown centered, we normally resize the alert
	 *  container so that the next alert is centered. This causes the previous alert's dismissing
	 *  animation to be "warped"--it fades out toward the center of the screen. If a new alert is
	 *  showing, that effect is barely visible due to the new alert covering the old alert. However,
	 *  if there is no new alert, that effect is visible pretty well. That's why we don't resize
	 *  the container if there is no new alert.
	 */
	
	if (!self.isDismissingLastAlert) {
		NSDictionary *userInfo = [notification userInfo];
		NSTimeInterval animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
		
		self.bottomSpacingConstraint.constant = 0;
		[self animateAlertContainerForKeyboardChangeWithDuration:animationDuration];
	}
}

- (void)replaceAlert:(SDCAlertView *)oldAlert
		   withAlert:(SDCAlertView *)newAlert
			animated:(BOOL)animated
		  completion:(void (^)(void))completionHandler {
	self.dismissingLastAlert = newAlert == nil;
	[self updateDimmingViewVisibility:!self.isDismissingLastAlert];
	
	[self showAlert:newAlert];
	[oldAlert resignFirstResponder];
	
	[CATransaction begin];
	[CATransaction setCompletionBlock:^{
		self.presentingFirstAlert = newAlert == nil;
		[oldAlert removeFromSuperview];
		
		if (completionHandler)
			completionHandler();
	}];
	
	if (oldAlert && animated)	[self applyDismissingAnimationsToAlert:oldAlert];
	if (newAlert)				[self applyPresentingAnimationsToAlert:newAlert];
	
	[CATransaction commit];
}

- (void)showAlert:(SDCAlertView *)alert {
	if (alert) {
		[alert becomeFirstResponder];
		[self.alertContainerView addSubview:alert];
		[alert layoutIfNeeded]; // Layout the alert before any animations are applied
	}
}

#pragma mark - Dimming View

- (void)updateDimmingViewVisibility:(BOOL)show {
	if (show && !self.showsDimmingView)
		[self showDimmingView];
	else if (!show && self.showsDimmingView)
		[self hideDimmingView];
}

- (void)showDimmingView {
	RBBSpringAnimation *animation = [self opacityAnimationForPresenting];
	self.dimmingView.layer.opacity = 1;
	[self.dimmingView.layer addAnimation:animation forKey:@"opacity"];
	
	self.showsDimmingView = YES;
}

- (void)hideDimmingView {
	RBBSpringAnimation *animation = [self opacityAnimationForDismissing];
	self.dimmingView.layer.opacity = 0;
	[self.dimmingView.layer addAnimation:animation forKey:@"opacity"];
	
	self.showsDimmingView = NO;
}

#pragma mark - Animations

- (RBBSpringAnimation *)springAnimationForKey:(NSString *)key {
	RBBSpringAnimation *animation = [[RBBSpringAnimation alloc] init];
	animation.delegate = self;
	
	animation.duration = SDCAlertViewSpringAnimationDuration;
	animation.damping = SDCAlertViewSpringAnimationDamping;
	animation.mass = SDCAlertViewSpringAnimationMass;
	animation.stiffness = SDCAlertViewSpringAnimationStiffness;
	animation.velocity = SDCAlertViewSpringAnimationVelocity;
	
	return animation;
}

#pragma mark - Opacity

- (RBBSpringAnimation *)opacityAnimationForPresenting {
	return [self opacityAnimationFrom:@0 to:@1];
}

- (RBBSpringAnimation *)opacityAnimationForDismissing {
	return [self opacityAnimationFrom:@1 to:@0];
}

- (RBBSpringAnimation *)opacityAnimationFrom:(NSNumber *)from to:(NSNumber *)to {
	RBBSpringAnimation *opacityAnimation = [self springAnimationForKey:@"opacity"];
	opacityAnimation.fromValue = from;
	opacityAnimation.toValue = to;
	
	return opacityAnimation;
}

#pragma mark Transform

- (RBBSpringAnimation *)transformAnimationForPresenting {
	CATransform3D transformFrom = CATransform3DMakeScale(SDCAlertViewShowingAnimationScale, SDCAlertViewShowingAnimationScale, 1);
	CATransform3D transformTo = CATransform3DMakeScale(1, 1, 1);
	return [self transformAnimationFrom:transformFrom to:transformTo];
}

- (RBBSpringAnimation *)transformAnimationForDismissing {
	CATransform3D transformFrom = CATransform3DMakeScale(1, 1, 1);
	CATransform3D transformTo = CATransform3DMakeScale(SDCAlertViewDismissingAnimationScale, SDCAlertViewDismissingAnimationScale, 1);
	return [self transformAnimationFrom:transformFrom to:transformTo];
}

- (RBBSpringAnimation *)transformAnimationFrom:(CATransform3D)from to:(CATransform3D)to {
	RBBSpringAnimation *transformAnimation = [self springAnimationForKey:@"transform"];
	transformAnimation.fromValue = [NSValue valueWithCATransform3D:from];
	transformAnimation.toValue = [NSValue valueWithCATransform3D:to];
	
	return transformAnimation;
}

#pragma mark Presenting & Dismissing

- (void)applyPresentingAnimationsToAlert:(SDCAlertView *)alert {
	RBBSpringAnimation *opacityAnimation = [self opacityAnimationForPresenting];
	alert.layer.opacity = 1;
	[alert.layer addAnimation:opacityAnimation forKey:@"opacity"];
	
	RBBSpringAnimation *transformAnimation = [self transformAnimationForPresenting];
	alert.layer.transform = [transformAnimation.toValue CATransform3DValue];
	[alert.layer addAnimation:transformAnimation forKey:@"transform"];
}

- (void)applyDismissingAnimationsToAlert:(SDCAlertView *)alert {
	RBBSpringAnimation *opacityAnimation = [self opacityAnimationForDismissing];
	alert.layer.opacity = 0;
	[alert.layer addAnimation:opacityAnimation forKey:@"opacity"];
	
	RBBSpringAnimation *transformAnimation = [self transformAnimationForDismissing];
	[alert.layer addAnimation:transformAnimation forKey:@"transform"];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
