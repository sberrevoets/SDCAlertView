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
	
	[self.rootView sdc_centerInSuperview];
}

- (void)showAlert:(SDCAlertView *)alert {
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
		alert.alpha = SDCAlertViewAlpha;
	}];
}

- (void)removeAlert:(SDCAlertView *)alert {
	BOOL isLastAlert = [self.alertViews count] == 1;
	
	if (isLastAlert)
		self.previousWindow.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
	
	[UIView animateWithDuration:SDCAlertViewShowingDismissingAnimationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
		if (isLastAlert)
			[[[self.rootView subviews] firstObject] setAlpha:0];
		
		alert.alpha = 0;
		alert.transform = CGAffineTransformMakeScale(SDCAlertViewDismissingAnimationScale, SDCAlertViewDismissingAnimationScale);
	} completion:^(BOOL finished) {
		[alert removeFromSuperview];
		[self.alertViews removeObject:alert];
		
		if (isLastAlert) {
			self.window = nil;
			[self.previousWindow makeKeyAndVisible];
		}
	}];
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
