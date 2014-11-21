//
//  SDCAlertControllerScrollView.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/21/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

@import UIKit;

#import "SDCAlertControllerVisualStyle.h"

@class SDCAlertControllerTextFieldViewController;

@interface SDCAlertControllerScrollView : UIScrollView

@property (nonatomic, strong) NSAttributedString *title;
@property (nonatomic, strong) NSAttributedString *message;

@property (nonatomic, strong) SDCAlertControllerTextFieldViewController *textFieldViewController;
@property (nonatomic, strong) id<SDCAlertControllerVisualStyle> visualStyle;

- (instancetype)initWithTitle:(NSAttributedString *)title message:(NSAttributedString *)message;

- (void)finalizeElements;

@end
