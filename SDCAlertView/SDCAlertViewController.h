//
//  SDCAlertViewController.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 11/5/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDCAlertView;

@interface SDCAlertViewController : UIViewController

+ (instancetype)currentController;

- (void)replaceAlert:(SDCAlertView *)oldAlert
		   withAlert:(SDCAlertView *)newAlert
	 showDimmingView:(BOOL)showDimmingView
   hideOldCompletion:(void (^)(void))hideOldCompletionHandler
   showNewCompletion:(void (^)(void))showNewCompletionHandler;

@end
