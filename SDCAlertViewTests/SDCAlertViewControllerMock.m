//
//  SDCAlertViewControllerMock.m
//  SDCAlertView
//
//  Created by Luke Stringer on 01/12/2013.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertViewControllerMock.h"

@implementation SDCAlertViewControllerMock

- (void)dismissAlert:(SDCAlertView *)alert animated:(BOOL)animated completion:(void (^)(void))completionHandler {
	[super dismissAlert:alert animated:animated completion:completionHandler];

	// Call the completion block immediately as we cannot wait for UI code to finish in our unit tests
	if (completionHandler)
		completionHandler();
}

@end
