//
//  SDCAlertScrollView.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/21/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

@import UIKit;

#import "SDCAlertControllerVisualStyle.h"

@class SDCAlertTextFieldViewController;

@interface SDCAlertScrollView : UIScrollView

@property (nonatomic, strong) SDCAlertTextFieldViewController *textFieldViewController;
@property (nonatomic, strong) id<SDCAlertControllerVisualStyle> visualStyle;

- (instancetype)initWithTitle:(NSAttributedString *)title message:(NSAttributedString *)message;

@end
