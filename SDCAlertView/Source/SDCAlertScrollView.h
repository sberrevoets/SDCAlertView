//
//  SDCAlertScrollView.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/21/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

@import UIKit;

@interface SDCAlertScrollView : UIScrollView

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message;

- (void)prepareForDisplay;

@end
