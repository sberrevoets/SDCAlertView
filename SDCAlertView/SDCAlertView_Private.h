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

FOUNDATION_EXPORT CGFloat const SDCAlertViewWidth;

@interface SDCAlertView (Private)
- (void)willBePresented;
- (void)wasPresented;

- (void)willBeDismissedWithButtonIndex:(NSInteger)buttonIndex;
- (void)wasDismissedWithButtonIndex:(NSInteger)buttonIndex;
@end

@interface UIColor (SDCAlertViewColors)
+ (UIColor *)sdc_alertSeparatorColor;
+ (UIColor *)sdc_textFieldBackgroundViewColor;
+ (UIColor *)sdc_dimmedBackgroundColor;
@end
