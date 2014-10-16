//
//  SDCAlertViewController.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 11/5/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

@import UIKit;

@class SDCAlertView;

@interface SDCAlertViewController : UIViewController

- (void)replaceAlert:(SDCAlertView *)oldAlert
		   withAlert:(SDCAlertView *)newAlert
			animated:(BOOL)animated
		  completion:(void(^)(void))completionHandler;
@end
