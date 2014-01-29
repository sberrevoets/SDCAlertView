//
//  SDCAlertViewController.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 11/5/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertViewController.h"

#import "RBBSpringAnimation.h"
#import "SDCAlertView.h"
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

@interface SDCAlertView (SDCAlertViewSubviews)
@property (nonatomic, strong) SDCAlertViewBackgroundView *alertBackgroundView;
@property (nonatomic, strong) SDCAlertViewContentView *alertContentView;
@property (nonatomic, strong) UIToolbar *toolbar;
@end

@interface SDCAlertViewController ()
@property (nonatomic, strong) UIView *alertContainerView;
@property (nonatomic, strong) UIView *dimmingView;
@property (nonatomic, strong) void(^alertTransitionCompletion)(void);
@property (nonatomic) BOOL showsDimmingView;
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
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
	}
	
	return self;
}

- (void)createViewHierarchy {
	
	/*
	 *  When displaying a UIAlertView, the view that contains the dimmed background and alert view itself
	 *  ("self.rootView") is added as a separate view to the UIWindow. The original implementation of 
	 *  SDCAlertView did the same, but handling rotation is much easier when self.rootView is added to
	 *  self.view. So, while it's implemented differently by Apple, this solution is probably easier
	 *  with regards to auto-rotation, which is why self.rootView is now added to self.view instead of self.window.
	 */
	
	self.alertContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
	self.alertContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:self.alertContainerView];
	
	self.dimmingView = [[UIView alloc] initWithFrame:self.alertContainerView.bounds];
	self.dimmingView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	self.dimmingView.backgroundColor = [UIColor sdc_dimmedBackgroundColor];
	self.dimmingView.layer.opacity = 1.0;
	[self.dimmingView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self.alertContainerView addSubview:self.dimmingView];
	
	[self.alertContainerView sdc_horizontallyCenterInSuperview];
}

#pragma mark - Showing/Hiding

- (void)keyboardWillShow:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	NSValue *keyboardFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey];
	CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
	
	self.alertContainerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.alertContainerView.frame), CGRectGetHeight(self.alertContainerView.frame) - CGRectGetHeight(keyboardFrame));
}

- (void)keyboardDidHide:(NSNotification *)notification {
	self.alertContainerView.frame = [[UIWindow sdc_alertWindow] frame];
}

- (void)replaceAlert:(SDCAlertView *)oldAlert
		   withAlert:(SDCAlertView *)newAlert
	 showDimmingView:(BOOL)showDimmingView
   hideOldCompletion:(void (^)(void))hideOldCompletionHandler
   showNewCompletion:(void (^)(void))showNewCompletionHandler {
	
	if (oldAlert)
		[self dismissAlert:oldAlert keepDimmingView:showDimmingView completionHandler:hideOldCompletionHandler];
	
	if (newAlert)
		[self showAlert:newAlert withDimmingView:showDimmingView completion:showNewCompletionHandler];
}

- (void)showAlert:(SDCAlertView *)alert withDimmingView:(BOOL)showDimmingView completion:(void(^)(void))completionHandler {
	[self.alertContainerView addSubview:alert];
	[alert setNeedsUpdateConstraints];

	[CATransaction begin];
	[CATransaction setCompletionBlock:completionHandler];
	
	[self applyPresentingAnimationsToAlert:alert];
	
	if (showDimmingView && !self.showsDimmingView)
		[self showDimmingView];
	
	[CATransaction commit];
}

- (void)dismissAlert:(SDCAlertView *)alert keepDimmingView:(BOOL)keepDimmingView completionHandler:(void(^)(void))completionHandler {
	[CATransaction begin];
	[CATransaction setCompletionBlock:^{
		[alert removeFromSuperview];
		
		if (!keepDimmingView)
			[self.dimmingView removeFromSuperview];
		
		if (completionHandler)
			completionHandler();
	}];

	[self applyDismissingAnimationsToAlert:alert];
	
	if (!keepDimmingView && self.showsDimmingView)
		[self hideDimmingView];
	
	[CATransaction commit];
}

- (void)showDimmingView {
	RBBSpringAnimation *animation = [self opacityAnimationForPresenting];
	[self.dimmingView.layer addAnimation:animation forKey:@"opacity"];
	
	self.showsDimmingView = YES;
}

- (void)hideDimmingView {
	RBBSpringAnimation *animation = [self opacityAnimationForDismissing];
	[self.dimmingView.layer addAnimation:animation forKey:@"opacity"];
	
	self.showsDimmingView = NO;
}

#pragma mark - Animations

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	if (self.alertTransitionCompletion) {
		self.alertTransitionCompletion();
		self.alertTransitionCompletion = nil;
	}
}

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
