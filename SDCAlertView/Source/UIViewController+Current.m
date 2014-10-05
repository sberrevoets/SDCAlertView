//
//  UIViewController+Current.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 10/3/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "UIViewController+Current.h"

@implementation UIViewController (Current)

+ (UIViewController *)sdc_currentViewController {
	UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
	return [self sdc_topViewControllerForViewController:rootViewController];
}

+ (UIViewController *)sdc_topViewControllerForViewController:(UIViewController *)rootViewController {
	if ([rootViewController isKindOfClass:[UINavigationController class]]) {
		UINavigationController *navigationController = (UINavigationController *)rootViewController;
		return [self sdc_topViewControllerForViewController:navigationController.visibleViewController];
	}
	
	if (rootViewController.presentedViewController) {
		return [self sdc_topViewControllerForViewController:rootViewController.presentedViewController];
	}
	
	return rootViewController;
}

@end
