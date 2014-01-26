//
//  SDCAlertViewCoordinator.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 1/25/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SDCAlertView;

@interface SDCAlertViewCoordinator : NSObject

@property (nonatomic, readonly) SDCAlertView *visibleAlert;

+ (instancetype)sharedCoordinator;

- (void)presentAlert:(SDCAlertView *)alert completion:(void (^)(void))completionHandler;
- (void)dismissAlert:(SDCAlertView *)alert completion:(void (^)(void))completionHandler;

@end
