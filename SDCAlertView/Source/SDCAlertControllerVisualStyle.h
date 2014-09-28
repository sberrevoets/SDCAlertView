//
//  SDCAlertControllerVisualStyle.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/27/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

@import Foundation;

@class SDCAlertAction;

@protocol SDCAlertControllerVisualStyle <NSObject>

@property (nonatomic, readonly) CGFloat width;
@property (nonatomic, readonly) CGFloat buttonHeight;

@property (nonatomic, readonly) UIEdgeInsets margins;
@property (nonatomic, readonly) UIEdgeInsets contentPadding;
@property (nonatomic, readonly) CGFloat labelSpacing;


@property (nonatomic, readonly) UIView *buttonHighlightBackgroundView;

@property (nonatomic, readonly) UIFont *titleLabelFont;
@property (nonatomic, readonly) UIFont *messageLabelFont;

- (UIColor *)textColorForButtonRepresentingAction:(SDCAlertAction *)action;
- (UIFont *)fontForButtonRepresentingAction:(SDCAlertAction *)action;

@end
