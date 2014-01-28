//
//  SDCAlertViewCoordinator.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 1/25/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertViewCoordinator.h"

#import "SDCAlertViewController.h"

@interface SDCAlertViewCoordinator ()
@property (nonatomic, strong) UIWindow *userWindow;
@property (nonatomic, strong) UIWindow *alertWindow;
@property (nonatomic, strong) NSMutableArray *alerts;
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

- (SDCAlertView *)visibleAlert {
	return [self.alerts lastObject];
}

- (void)presentAlert:(SDCAlertView *)alert completion:(void (^)(void))completionHandler {
	SDCAlertView *oldAlert = [self.alerts lastObject];
	[self.alerts addObject:alert];
	
	if (!oldAlert)
		[self makeAlertWindowKeyWindow];
	
	SDCAlertViewController *alertViewController = [SDCAlertViewController currentController];
	[alertViewController replaceAlert:oldAlert withAlert:alert animated:YES showDimmingView:YES completion:completionHandler];
}

- (void)dismissAlert:(SDCAlertView *)alert completion:(void (^)(void))completionHandler {
	[self.alerts removeObject:alert];
	SDCAlertView *dequeuedAlert = [self.alerts lastObject];
	
	SDCAlertViewController *alertViewController = [SDCAlertViewController currentController];
	[alertViewController replaceAlert:alert
							withAlert:dequeuedAlert
							 animated:YES
					  showDimmingView:(dequeuedAlert != nil)
						   completion:^{
		if (!dequeuedAlert)
			[self returnToUserWindow];
		
		completionHandler();
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
