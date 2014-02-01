//
//  SDCAlertViewController.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 11/5/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertViewController.h"

#import "RBBSpringAnimation.h"
#import "SDCAlertView_Private.h"
#import "SDCAlertViewContentView.h"
#import "SDCAlertViewBackgroundView.h"

#import "UIView+SDCAutoLayout.h"

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

+ (instancetype)currentController {
	UIViewController *currentController = [[UIWindow sdc_alertWindow] rootViewController];
	
	if ([currentController isKindOfClass:[SDCAlertViewController class]])
		return (SDCAlertViewController *)currentController;
	else
		return [[self alloc] init];
}

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
	
	/*
	 *  Normally, the keyboard's frame would have to be converted using a convertRect: method to get
	 *  the frame in the right orientation. This works in both portrait and landscape if the orientation
	 *  stays the same, but not if the device is rotated when an alert is shown. So we directly check
	 *  the orientation and use either the keyboard frame's width or height based on that. Nast, but it works.
	 */
	
	CGFloat keyboardHeight = UIInterfaceOrientationIsPortrait(orientation) ? CGRectGetHeight(keyboardFrame) : CGRectGetWidth(keyboardFrame);
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
	 showDimmingView:(BOOL)showDimmingView
   hideOldCompletion:(void (^)(void))hideOldCompletionHandler
   showNewCompletion:(void (^)(void))showNewCompletionHandler {
	if (!newAlert)
		self.dismissingLastAlert = YES;
	
	[self updateDimmingViewVisibility:showDimmingView];
	
	if (oldAlert)
		[self dismissAlert:oldAlert keepDimmingView:showDimmingView completionHandler:hideOldCompletionHandler];
	
	if (newAlert)
		[self showAlert:newAlert withDimmingView:showDimmingView completion:showNewCompletionHandler];
}

- (void)showAlert:(SDCAlertView *)alert withDimmingView:(BOOL)showDimmingView completion:(void(^)(void))completionHandler {
	[alert becomeFirstResponder];
	
	[self.alertContainerView addSubview:alert];
	[alert setNeedsUpdateConstraints];
	
	[CATransaction begin];
	[CATransaction setCompletionBlock:^{
		self.presentingFirstAlert = NO;
		completionHandler();
	}];
	
	[self applyPresentingAnimationsToAlert:alert];
	[CATransaction commit];
}

- (void)dismissAlert:(SDCAlertView *)alert keepDimmingView:(BOOL)keepDimmingView completionHandler:(void(^)(void))completionHandler {
	[alert resignFirstResponder];
	
	[CATransaction begin];
	[CATransaction setCompletionBlock:^{
		[alert removeFromSuperview];
		
		if (!keepDimmingView)
			[self.dimmingView removeFromSuperview];
		
		if (completionHandler)
			completionHandler();
	}];

	[self applyDismissingAnimationsToAlert:alert];
	[CATransaction commit];
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
	RBBSpringAnimation *transformAnimation = [self transformAnimationForPresenting];
	
	alert.alertBackgroundView.layer.opacity = 1;
	alert.alertContentView.layer.opacity = 1;
	alert.toolbar.layer.opacity = 1;
	
	[alert.alertBackgroundView.layer addAnimation:opacityAnimation forKey:@"opacity"];
	[alert.alertContentView.layer addAnimation:opacityAnimation forKey:@"opacity"];
	[alert.toolbar.layer addAnimation:opacityAnimation forKey:@"opacity"];
	
	alert.layer.transform = [transformAnimation.toValue CATransform3DValue];
	[alert.layer addAnimation:transformAnimation forKey:@"transform"];
}

- (void)applyDismissingAnimationsToAlert:(SDCAlertView *)alert {
	RBBSpringAnimation *opacityAnimation = [self opacityAnimationForDismissing];
	RBBSpringAnimation *transformAnimation = [self transformAnimationForDismissing];
	
	alert.alertBackgroundView.layer.opacity = 0;
	alert.alertContentView.layer.opacity = 0;
	alert.toolbar.layer.opacity = 0;
	
	[alert.alertBackgroundView.layer addAnimation:opacityAnimation forKey:@"opacity"];
	[alert.alertContentView.layer addAnimation:opacityAnimation forKey:@"opacity"];
	[alert.toolbar.layer addAnimation:opacityAnimation forKey:@"opacity"];

	alert.layer.transform = [transformAnimation.toValue CATransform3DValue];
	[alert.layer addAnimation:transformAnimation forKey:@"transform"];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@implementation UIWindow(SDCAlertView)

+ (UIWindow *)sdc_alertWindow {
	NSArray *windows = [[UIApplication sharedApplication] windows];
	NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(UIWindow *window, NSDictionary *bindings) {
		return [window.rootViewController isKindOfClass:[SDCAlertViewController class]];
	}];
	
	NSArray *alertWindows = [windows filteredArrayUsingPredicate:predicate];
    
#ifdef TESTING
	NSAssert([alertWindows count] <= 1, @"At most one alert window should be active at any point");
#endif
	
	return [alertWindows firstObject];
}

@end
