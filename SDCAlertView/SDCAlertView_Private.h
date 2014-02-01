//
//  SDCAlertView_Private.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 1/28/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertView.h"

@class SDCAlertViewBackgroundView;
@class SDCAlertViewContentView;

@interface SDCAlertView (Private)

@property (nonatomic, strong) SDCAlertViewBackgroundView *alertBackgroundView;
@property (nonatomic, strong) SDCAlertViewContentView *alertContentView;
@property (nonatomic, strong) UIToolbar *toolbar;

- (void)willBePresented;
- (void)wasPresented;

- (void)willBeDismissedWithButtonIndex:(NSInteger)buttonIndex;
- (void)wasDismissedWithButtonIndex:(NSInteger)buttonIndex;

@end