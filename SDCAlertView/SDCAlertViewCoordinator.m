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

- (void)presentAlert:(SDCAlertView *)alert {
	SDCAlertView *oldAlert = [self.alerts lastObject];
	[self.alerts addObject:alert];
	
	if (!oldAlert)
		[self makeAlertWindowKeyWindow];
	
	[alert willBePresented];
	
	SDCAlertViewController *alertViewController = [SDCAlertViewController currentController];
	[alertViewController replaceAlert:oldAlert
							withAlert:alert
					  showDimmingView:YES
					hideOldCompletion:nil
					showNewCompletion:^{
						[alert wasPresented];
					}];
}

- (void)dismissAlert:(SDCAlertView *)alert withButtonIndex:(NSInteger)buttonIndex {
	[self.alerts removeObject:alert];
	SDCAlertView *dequeuedAlert = [self.alerts lastObject];
	
	[alert willBeDismissedWithButtonIndex:buttonIndex];
	
	SDCAlertViewController *alertViewController = [SDCAlertViewController currentController];
	[alertViewController replaceAlert:alert
							withAlert:dequeuedAlert
					  showDimmingView:(dequeuedAlert != nil)
					hideOldCompletion:^{
						if (!dequeuedAlert)
							[self returnToUserWindow];
						
						[alert wasDismissedWithButtonIndex:buttonIndex];
					}
					showNewCompletion:^{
						[dequeuedAlert wasPresented];
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
