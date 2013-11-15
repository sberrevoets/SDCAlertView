//
//  SDCAlertViewController.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 11/5/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertViewController.h"

#import "SDCAlertView.h"

#import "UIView+SDCAutoLayout.h"

static CGFloat 		SDCAlertViewShowingAnimationScale = 1.15;
static CGFloat 		SDCAlertViewDismissingAnimationScale = 0.85;
static CGFloat 		SDCAlertViewShowingDismissingAnimationDuration = 0.25;
static NSUInteger 	SDCAlertViewShowingDismissingAnimationOptions = UIViewAnimationOptionBeginFromCurrentState;

static CGFloat 		SDCAlertViewAlpha = 0.9;

@interface UIWindow (SDCAlertView)
+ (UIWindow *)sdc_alertWindow;
@end

@interface SDCAlertViewController ()
@property (nonatomic, strong) UIWindow *previousWindow;
@property (nonatomic, strong) UIView *rootView;
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
	self.window.rootViewController = self;
	self.window.windowLevel = UIWindowLevelAlert;
	
	self.rootView = [[UIView alloc] initWithFrame:self.window.bounds];
	[self.window addSubview:self.rootView];
	
	UIView *backgroundColorView = [[UIView alloc] initWithFrame:self.rootView.bounds];
	backgroundColorView.backgroundColor = [UIColor colorWithWhite:0 alpha:.4];
	backgroundColorView.alpha = 0;
	[backgroundColorView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self.rootView addSubview:backgroundColorView];
	
	[self.rootView sdc_horizontallyCenterInSuperview];
}

- (void)keyboardWillShow:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	NSValue *keyboardFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey];
	CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
	
	self.rootView.frame = CGRectMake(0, 0, CGRectGetWidth(self.rootView.frame), CGRectGetHeight(self.rootView.frame) - CGRectGetHeight(keyboardFrame));
}

- (void)keyboardDidHide:(NSNotification *)notification {
	self.rootView.frame = self.window.frame;
}

- (void)showAlert:(SDCAlertView *)alert completion:(void (^)(void))completionHandler {
	[self.alertViews addObject:alert];
	
	alert.transform = CGAffineTransformMakeScale(SDCAlertViewShowingAnimationScale, SDCAlertViewShowingAnimationScale);
	[self.rootView addSubview:alert];
	
	if ([[UIApplication sharedApplication] keyWindow] != self.window) {
		[[[UIApplication sharedApplication] keyWindow] setTintAdjustmentMode:UIViewTintAdjustmentModeDimmed];
		[self.window makeKeyAndVisible];
		[self.window bringSubviewToFront:self.rootView];
	}
	
	[UIView animateWithDuration:SDCAlertViewShowingDismissingAnimationDuration delay:0 options:SDCAlertViewShowingDismissingAnimationOptions animations:^{
		UIView *backgroundColorView = [[self.rootView subviews] firstObject];
		backgroundColorView.alpha = 1.0;
		
		alert.transform = CGAffineTransformMakeScale(1.0, 1.0);
	} completion:^(BOOL finished) {
		completionHandler();
	}];
}

- (void)dismissAlert:(SDCAlertView *)alert completion:(void (^)(void))completionHandler {
	[alert resignFirstResponder];
	
	BOOL isLastAlert = [self.alertViews count] == 1;
	if (isLastAlert)
		self.previousWindow.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;

	[UIView animateWithDuration:SDCAlertViewShowingDismissingAnimationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
		if (isLastAlert)
			[[[self.rootView subviews] firstObject] setAlpha:0];
		
		alert.alpha = 0;
		
		// We use a layer transformation here because setting the transform property on a UIView instance causes the view to trigger layout. updateConstraints is called, which adds constraints that in some cases causes conflicting constraints. Applying the transform to the layer does not trigger layout while keeping the same animation. See http://stackoverflow.com/a/14105757/751268 for more information.
		alert.layer.transform = CATransform3DMakeScale(SDCAlertViewDismissingAnimationScale, SDCAlertViewDismissingAnimationScale, 1);
	} completion:^(BOOL finished) {
		[alert removeFromSuperview];
		[self.alertViews removeObject:alert];
		
		if (isLastAlert) {
			self.window = nil;
			[self.previousWindow makeKeyAndVisible];
		}
		
		completionHandler();
	}];
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
	NSAssert([alertWindows count] <= 1, @"At most one alert window should be active at any point");
	
	return [alertWindows firstObject];
}

@end
