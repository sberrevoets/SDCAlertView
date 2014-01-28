//
//  SDCAlertViewCoordinator.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 1/25/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertViewCoordinator.h"

#import "SDCAlertView_Private.h"
#import "SDCAlertViewController.h"

@interface SDCAlertViewCoordinator ()
@property (nonatomic, strong) UIWindow *userWindow;
@property (nonatomic, strong) UIWindow *alertWindow;
@property (nonatomic, strong) NSMutableArray *alerts;
@property (nonatomic, weak) SDCAlertView *presentingAlert;
@property (nonatomic, weak) SDCAlertView *dismissingAlert;
@property (nonatomic, weak) SDCAlertView *visibleAlert;
@end

@implementation SDCAlertViewCoordinator

- (UIWindow *)alertWindow {
	if (!_alertWindow) {
		_alertWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		_alertWindow.backgroundColor = [UIColor clearColor];
		_alertWindow.rootViewController = [SDCAlertViewController currentController];
		_alertWindow.windowLevel = UIWindowLevelAlert;
	}
	
	return _alertWindow;
}

- (NSMutableArray *)alerts {
	if (!_alerts)
		_alerts = [NSMutableArray array];
	return _alerts;
}

- (id)init {
	self = [super init];
	
	if (self)
		_userWindow = [[UIApplication sharedApplication] keyWindow];
	
	return self;
}

+ (instancetype)sharedCoordinator {
	static SDCAlertViewCoordinator *sharedCoordinator;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedCoordinator = [[self alloc] init];
	});
	
	return sharedCoordinator;
}

- (void)presentAlert:(SDCAlertView *)alert {
	SDCAlertView *oldAlert = [self.alerts lastObject];
	[self.alerts addObject:alert];
	
	if (!oldAlert)
		[self makeAlertWindowKeyWindow];
	
	// If we're already presenting an alert, don't show this one yet. The completion handler
	// for the alert that is currently presenting will take care of presenting this one.
	if (self.presentingAlert)
		return;
	
	[self showAlert:alert replacingAlert:oldAlert];
}

- (void)showAlert:(SDCAlertView *)newAlert replacingAlert:(SDCAlertView *)oldAlert {
	[newAlert willBePresented];
	
	self.presentingAlert = newAlert;
	SDCAlertViewController *alertViewController = [SDCAlertViewController currentController];
	[alertViewController replaceAlert:oldAlert
							withAlert:newAlert
					  showDimmingView:YES
					hideOldCompletion:nil
					showNewCompletion:^{
						[newAlert wasPresented];
						self.presentingAlert = nil;
						self.visibleAlert = newAlert;
						
						[self showNextAlertIfNecessary];
					}];
}

- (void)showNextAlertIfNecessary {
	if (self.visibleAlert != [self.alerts lastObject])
		[self showAlert:[self.alerts lastObject] replacingAlert:self.visibleAlert];
}

- (void)dismissAlert:(SDCAlertView *)alert withButtonIndex:(NSInteger)buttonIndex {
	[self.alerts removeObject:alert];
	SDCAlertView *nextAlert = [self.alerts lastObject];
	
	// UIAlertView doesn't send willPresentAlert: when it's taken off the queue, so we don't do that either:
	// [nextAlert willBePresented];
	[alert willBeDismissedWithButtonIndex:buttonIndex];
	
	self.dismissingAlert = alert;
	self.presentingAlert = nextAlert;
	
	SDCAlertViewController *alertViewController = [SDCAlertViewController currentController];
	[alertViewController replaceAlert:alert
							withAlert:nextAlert
					  showDimmingView:(nextAlert != nil)
					hideOldCompletion:^{
						if (!nextAlert)
							[self returnToUserWindow];
						
						[alert wasDismissedWithButtonIndex:buttonIndex];
						self.dismissingAlert = nil;
					}
					showNewCompletion:^{
						[nextAlert wasPresented];
						self.presentingAlert = nil;
					}];
}

- (void)makeAlertWindowKeyWindow {
	self.userWindow.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
	[self.alertWindow makeKeyAndVisible];
}

- (void)returnToUserWindow {
	self.userWindow.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
	[self.userWindow makeKeyAndVisible];
	
	self.alertWindow = nil;
}

@end
