//
//  UIViewController+Current.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 10/3/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

@import UIKit;

@interface UIViewController (Current)

/**
 *  Returns the currently visible view controller, taking into account navigation controllers and modally presented view controllers.
 */
+ (UIViewController *)sdc_currentViewController;

@end
