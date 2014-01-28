//
//  SDCAlertView_Private.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 1/28/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertView.h"

@interface SDCAlertView (Private)

- (void)willBePresented;
- (void)wasPresented;

- (void)willBeDismissedWithButtonIndex:(NSInteger)buttonIndex;
- (void)wasDismissedWithButtonIndex:(NSInteger)buttonIndex;

@end