//
//  UIViewController+Current.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 10/3/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "UIViewController+Current.h"

@implementation UIViewController (Current)

+ (UIViewController *)currentViewController {
	UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
	return [self topViewControllerForViewController:rootViewController];
}

+ (UIViewController *)topViewControllerForViewController:(UIViewController *)rootViewController {
	if ([rootViewController isKindOfClass:[UINavigationController class]]) {
		UINavigationController *navigationController = (UINavigationController *)rootViewController;
		return [self topViewControllerForViewController:navigationController.visibleViewController];
	}
	
	if (rootViewController.presentedViewController) {
		return [self topViewControllerForViewController:rootViewController.presentedViewController];
	}
	
	return rootViewController;
}

@end
