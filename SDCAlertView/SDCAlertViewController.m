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
@property (nonatomic, strong) UIWindow *previousWindow;
@property (nonatomic, strong) UIView *rootView;
@property (nonatomic, strong) UIView *backgroundColorView;
@property (nonatomic, strong) NSMutableOrderedSet *alertViews;
@end

@implementation SDCAlertViewController

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
		_alertViews = [[NSMutableOrderedSet alloc] init];
		[self initializeWindow];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
	}
	
	return self;
}

- (void)initializeWindow {
	self.previousWindow = [[UIApplication sharedApplication] keyWindow];
	
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.backgroundColor = [UIColor clearColor];
	self.window.rootViewController = self;
	self.window.windowLevel = UIWindowLevelAlert;
	
	/*
	 *  When displaying a UIAlertView, the view that contains the dimmed background and alert view itself
	 *  ("self.rootView") is added as a separate view to the UIWindow. The original implementation of 
	 *  SDCAlertView did the same, but handling rotation is much easier when self.rootView is added to
	 *  self.view. So, while it's implemented differently by Apple, this solution is probably easier
	 *  with regards to auto-rotation, which is why self.rootView is now added to self.view instead of self.window.
	 */
	
	self.rootView = [[UIView alloc] initWithFrame:self.window.bounds];
	self.rootView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:self.rootView];
	
	self.backgroundColorView = [[UIView alloc] initWithFrame:self.rootView.bounds];
	self.backgroundColorView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	self.backgroundColorView.backgroundColor = [UIColor colorWithWhite:0 alpha:.4];
	self.backgroundColorView.layer.opacity = 1.0;
	[self.backgroundColorView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self.rootView addSubview:self.backgroundColorView];
	
	[self.rootView sdc_horizontallyCenterInSuperview];
}

#pragma mark - Showing/Hiding

- (void)keyboardWillShow:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	NSValue *keyboardFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey];
	CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
	
	self.rootView.frame = CGRectMake(0, 0, CGRectGetWidth(self.rootView.frame), CGRectGetHeight(self.rootView.frame) - CGRectGetHeight(keyboardFrame));
}

- (void)keyboardDidHide:(NSNotification *)notification {
	self.rootView.frame = self.window.frame;
}

- (void)showAlert:(SDCAlertView *)alert animated:(BOOL)animated completion:(void (^)(void))completionHandler {
	[self.alertViews addObject:alert];
	[self.rootView addSubview:alert];
	
	if ([[UIApplication sharedApplication] keyWindow] != self.window) {
		[[[UIApplication sharedApplication] keyWindow] setTintAdjustmentMode:UIViewTintAdjustmentModeDimmed];
		[self.window makeKeyAndVisible];
		[self.window bringSubviewToFront:self.rootView];
	}
	
	if (animated) {
		[CATransaction begin];
		[CATransaction setCompletionBlock:completionHandler];
		[self applyAnimationsForShowingAlert:alert];
		[CATransaction commit];
	} else {
		if (completionHandler)
			completionHandler();
	}
}

- (void)dismissAlert:(SDCAlertView *)alert animated:(BOOL)animated completion:(void (^)(void))completionHandler {
	[alert resignFirstResponder];
	
	BOOL isLastAlert = [self.alertViews count] == 1;
	if (isLastAlert)
		self.previousWindow.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;

	void (^dismissBlock)() = ^{
		[alert removeFromSuperview];
		[self.alertViews removeObject:alert];
		
		if (isLastAlert) {
			[self.previousWindow makeKeyAndVisible];
			self.window = nil;
		}
		
		completionHandler();
	};
	
	if (animated) {
		[CATransaction begin];
		[CATransaction setCompletionBlock:dismissBlock];
		[self applyAnimationsForDismissingAlert:alert];
		[CATransaction commit];
	} else {
		dismissBlock();
	}
}

- (SDCAlertView *)visibleAlert {
	return [self.alertViews lastObject];
}

#pragma mark - Animations

- (RBBSpringAnimation *)springAnimationForKey:(NSString *)key {
	RBBSpringAnimation *animation = [[RBBSpringAnimation alloc] init];
	animation.duration = SDCAlertViewSpringAnimationDuration;
	animation.damping = SDCAlertViewSpringAnimationDamping;
	animation.mass = SDCAlertViewSpringAnimationMass;
	animation.stiffness = SDCAlertViewSpringAnimationStiffness;
	animation.velocity = SDCAlertViewSpringAnimationVelocity;
	
	return animation;
}

- (void)addTransformAnimationToAlert:(SDCAlertView *)alert transformingFrom:(CATransform3D)transformFrom to:(CATransform3D)transformTo {
	RBBSpringAnimation *transformAnimation = [self springAnimationForKey:@"transform"];
	transformAnimation.fromValue = [NSValue valueWithCATransform3D:transformFrom];
	transformAnimation.toValue = [NSValue valueWithCATransform3D:transformTo];
	
	alert.layer.transform = transformTo;
	[alert.layer addAnimation:transformAnimation forKey:@"transform"];
}

- (void)applyAnimationsForShowingAlert:(SDCAlertView *)alert {
	CATransform3D transformFrom = CATransform3DMakeScale(SDCAlertViewShowingAnimationScale, SDCAlertViewShowingAnimationScale, 1);
	CATransform3D transformTo = CATransform3DMakeScale(1, 1, 1);
	[self addTransformAnimationToAlert:alert transformingFrom:transformFrom to:transformTo];
	
	// Create opacity animation
	RBBSpringAnimation *opacityAnimation = [self springAnimationForKey:@"opacity"];
	opacityAnimation.fromValue = @0;
	opacityAnimation.toValue = @1;
	[alert.alertBackgroundView.layer addAnimation:opacityAnimation forKey:@"opacity"];
	[alert.alertContentView.layer addAnimation:opacityAnimation forKey:@"opacity"];
	[alert.toolbar.layer addAnimation:opacityAnimation forKey:@"opacity"];
	
	// If we're animating the first alert in the queue, also animate the dimmed background
	if ([self.alertViews count] == 1)
		[self.backgroundColorView.layer addAnimation:opacityAnimation forKey:@"opacity"];
}

- (void)applyAnimationsForDismissingAlert:(SDCAlertView *)alert {
	CATransform3D transformFrom = CATransform3DMakeScale(1, 1, 1);
	CATransform3D transformTo = CATransform3DMakeScale(SDCAlertViewDismissingAnimationScale, SDCAlertViewDismissingAnimationScale, 1);
	[self addTransformAnimationToAlert:alert transformingFrom:transformFrom to:transformTo];
	
	RBBSpringAnimation *opacityAnimation = [self springAnimationForKey:@"opacity"];
	opacityAnimation.fromValue = @1;
	opacityAnimation.toValue = @0;
	
	alert.alertBackgroundView.layer.opacity = 0;
	alert.alertContentView.layer.opacity = 0;
	alert.toolbar.layer.opacity = 0;
	
	[alert.alertBackgroundView.layer addAnimation:opacityAnimation forKey:@"opacity"];
	[alert.alertContentView.layer addAnimation:opacityAnimation forKey:@"opacity"];
	[alert.toolbar.layer addAnimation:opacityAnimation forKey:@"opacity"];

	// If the last alert is being dismissed, also animate the dimmed background back to normal
	if ([self.alertViews count] == 1) {
		self.backgroundColorView.layer.opacity = 0;
		[self.backgroundColorView.layer addAnimation:opacityAnimation forKey:@"opacity"];
	}
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
