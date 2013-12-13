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

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, readonly) SDCAlertView *visibleAlert;

+ (instancetype)currentController;

- (void)showAlert:(SDCAlertView *)alert animated:(BOOL)animated completion:(void(^)(void))completionHandler;
- (void)dismissAlert:(SDCAlertView *)alert animated:(BOOL)animated completion:(void(^)(void))completionHandler;

@end
