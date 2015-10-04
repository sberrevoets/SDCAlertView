//
//  SDCAlertViewCoordinator.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 1/25/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertViewTransitioning.h"

@class SDCAlertView;

@interface SDCAlertViewCoordinator : NSObject <SDCAlertViewTransitioning>

+ (instancetype)sharedCoordinator;

- (BOOL)shouldRotateAlerts;
- (NSUInteger)supportedAlertInterfaceOrientations;

@end
