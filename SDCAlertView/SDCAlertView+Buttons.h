//
//  SDCAlertView+Buttons.h
//  SDCAlertView
//
//  Created by Luke Stringer on 01/12/2013.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertView.h"

static NSInteger const SDCAlertViewUnspecifiedButtonIndex = -1;
static NSInteger const SDCAlertViewDefaultFirstButtonIndex = 0;

@interface SDCAlertView (Buttons)
@property (nonatomic, strong) NSMutableArray *buttonTitles;
@property (nonatomic, assign) NSInteger firstOtherButtonIndex;

- (void)tappedButtonAtIndex:(NSInteger)index;
- (NSInteger)numberOfButtons;

@end
