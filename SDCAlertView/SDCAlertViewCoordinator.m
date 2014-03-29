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
	[self.alerts addObject:alert];
	
	if (self.presentingAlert)
		return;
	
	if (!self.visibleAlert)
		[self makeAlertWindowKeyWindow];
	
	[alert willBePresented];
	[self showAlert:alert replacingAlert:self.visibleAlert completion:^{
		[alert wasPresented];
		[self showNextAlertIfNecessary];
	}];
}

- (void)showAlert:(SDCAlertView *)newAlert replacingAlert:(SDCAlertView *)oldAlert completion:(void(^)())completionHandler {
	self.presentingAlert = newAlert;
	self.visibleAlert = nil;
	
	SDCAlertViewController *alertViewController = [SDCAlertViewController currentController];
	[alertViewController replaceAlert:oldAlert
							withAlert:newAlert
					hideOldCompletion:nil
					showNewCompletion:^{
						self.presentingAlert = nil;
						self.visibleAlert = newAlert;
						
						if (completionHandler)
							completionHandler();
					}];
}

- (void)showNextAlertIfNecessary {
	if (self.visibleAlert != [self.alerts lastObject]) {
		[self showAlert:[self.alerts lastObject] replacingAlert:self.visibleAlert completion:^{
			[self showNextAlertIfNecessary];
		}];
	}
}

- (void)dismissAlert:(SDCAlertView *)alert withButtonIndex:(NSInteger)buttonIndex {
	[self.alerts removeObject:alert];
	SDCAlertView *nextAlert = [self.alerts lastObject];
	
	// UIAlertView doesn't send willPresentAlert: to an alert that's being dequeued
	// [nextAlert willBePresented];
	[alert willBeDismissedWithButtonIndex:buttonIndex];
	
	self.dismissingAlert = alert;
	self.presentingAlert = nextAlert;
	
	if (!nextAlert)
		[self resaturateUI];
	
	SDCAlertViewController *alertViewController = [SDCAlertViewController currentController];
	[alertViewController replaceAlert:alert
							withAlert:nextAlert
					hideOldCompletion:^{
						if (!nextAlert)
							[self returnToUserWindow];
						
						[alert wasDismissedWithButtonIndex:buttonIndex];
						self.dismissingAlert = nil;
					} showNewCompletion:^{
						[nextAlert wasPresented];
						self.presentingAlert = nil;
					}];
}

- (void)resaturateUI {
	self.userWindow.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
}

- (void)makeAlertWindowKeyWindow {
	self.userWindow.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
	[self.alertWindow makeKeyAndVisible];
}

- (void)returnToUserWindow {
	[self.userWindow makeKeyAndVisible];
	self.alertWindow = nil;
}

@end
