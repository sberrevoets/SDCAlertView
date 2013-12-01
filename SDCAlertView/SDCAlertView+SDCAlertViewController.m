//
//  SDCAlertView+SDCAlertViewController.m
//  SDCAlertView
//
//  Created by Luke Stringer on 01/12/2013.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertView+SDCAlertViewController.h"
#import "SDCAlertViewController.h"
#import <objc/runtime.h>

static NSString * const PropertyKey_AlertViewController = @"AlertViewController";

@implementation SDCAlertView (SDCAlertViewController)

- (void)setAlertViewController:(SDCAlertViewController *)alertViewController {
    objc_setAssociatedObject(self, (__bridge const void *)(PropertyKey_AlertViewController), alertViewController, OBJC_ASSOCIATION_RETAIN);
}


- (SDCAlertViewController *)alertViewController {
    SDCAlertViewController *_alertViewController = objc_getAssociatedObject(self, (__bridge const void *)(PropertyKey_AlertViewController));
	if (!_alertViewController) {
		self.alertViewController = [SDCAlertViewController currentController];
        _alertViewController = self.alertViewController;
    }
	return _alertViewController;
}

@end
