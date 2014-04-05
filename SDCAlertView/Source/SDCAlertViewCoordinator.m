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
@property (nonatomic, strong) NSMutableArray *transitionQueue;
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
	
	if (self) {
		_userWindow = [[UIApplication sharedApplication] keyWindow];
		_transitionQueue = [NSMutableArray array];
	}
	
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

#pragma mark - Transition Queue

- (BOOL)enqueuePresentingAnimationOfAlert:(SDCAlertView *)alert {
	if (!self.presentingAlert && !self.dismissingAlert)
		return NO;

	NSMethodSignature *methodSignature = [[self class] instanceMethodSignatureForSelector:@selector(presentAlert:)];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
	[invocation setSelector:@selector(presentAlert:)];
	[invocation setArgument:&alert atIndex:2];
	[invocation retainArguments];
	
	[self.transitionQueue addObject:invocation];
	
	return YES;
}

- (BOOL)enqueueDismissingAnimationOfAlert:(SDCAlertView *)alert withButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
	if (!self.presentingAlert && !self.dismissingAlert)
		return NO;
	
	NSMethodSignature *methodSignature = [[self class] instanceMethodSignatureForSelector:@selector(dismissAlert:withButtonIndex:animated:)];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
	[invocation setSelector:@selector(dismissAlert:withButtonIndex:animated:)];
	[invocation setArgument:&alert atIndex:2];
	[invocation setArgument:&buttonIndex atIndex:3];
	[invocation setArgument:&animated atIndex:4];
	[invocation retainArguments];
	
	[self.transitionQueue addObject:invocation];
	
	return YES;
}

- (void)dequeueNextTransition {
	NSInvocation *nextInvocation = [self.transitionQueue firstObject];
	[self.transitionQueue removeObject:nextInvocation];
	
	[nextInvocation invokeWithTarget:self];
}

#pragma mark - Presenting & Dismissing

- (void)showAlert:(SDCAlertView *)newAlert
   replacingAlert:(SDCAlertView *)oldAlert
		 animated:(BOOL)animated
	   completion:(void(^)())completionHandler {
	if (!newAlert)
		[self resaturateUI];
	
	self.presentingAlert = newAlert;
	self.dismissingAlert = oldAlert;
	self.visibleAlert = nil;
	
	SDCAlertViewController *alertViewController = [SDCAlertViewController currentController];
	[alertViewController replaceAlert:oldAlert
							withAlert:newAlert
							 animated:animated
						   completion:^{
							   self.presentingAlert = nil;
							   self.dismissingAlert = nil;
							   self.visibleAlert = newAlert;
							   
							   if (!newAlert)
								   [self returnToUserWindow];
							   
							   if (completionHandler)
								   completionHandler();
							   
							   [self dequeueNextTransition];
						   }];
}

- (void)presentAlert:(SDCAlertView *)alert {
	if ([self enqueuePresentingAnimationOfAlert:alert])
		return;
	
	[self.alerts addObject:alert];
	
	if (!self.visibleAlert)
		[self makeAlertWindowKeyWindow];
	
	[alert willBePresented];
	[self showAlert:alert replacingAlert:self.visibleAlert animated:YES completion:^{
		[alert wasPresented];
	}];
}

- (void)dismissAlert:(SDCAlertView *)alert withButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
	if ([self dismissAlertImmediately:alert withButtonIndex:buttonIndex] ||
		[self enqueueDismissingAnimationOfAlert:alert withButtonIndex:buttonIndex animated:animated])
		return;
	
	[self.alerts removeObject:alert];
	
	[alert willBeDismissedWithButtonIndex:buttonIndex];
	SDCAlertView *nextAlert = [self.alerts lastObject];
	
	[self showAlert:nextAlert replacingAlert:alert animated:animated completion:^{
		[alert wasDismissedWithButtonIndex:buttonIndex];
		[nextAlert wasPresented];
	}];
}

- (BOOL)dismissAlertImmediately:(SDCAlertView *)alert withButtonIndex:(NSInteger)buttonIndex {
	if (self.visibleAlert == alert || self.presentingAlert == alert)
		return NO;
	
	[self.alerts removeObject:alert];
	[alert willBeDismissedWithButtonIndex:buttonIndex];
	[alert wasDismissedWithButtonIndex:buttonIndex];
	
	return YES;
}

#pragma mark - Window Switching

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
