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

@property (nonatomic, readonly) CGFloat cornerRadius;
@property (nonatomic, readonly) UIOffset parallax;

@property (nonatomic, readonly) CGFloat width;
@property (nonatomic, readonly) CGFloat actionViewHeight;
@property (nonatomic, readonly) CGFloat minimumActionViewWidth; // For forced horizontal layout and 3+ buttons

@property (nonatomic, readonly) UIEdgeInsets margins;
@property (nonatomic, readonly) UIEdgeInsets contentPadding;
@property (nonatomic, readonly) CGFloat labelSpacing;

@property (nonatomic, readonly) CGFloat estimatedTextFieldHeight;
@property (nonatomic, readonly) CGFloat textFieldsTopSpacing;
@property (nonatomic, readonly) CGFloat textFieldBorderWidth;
@property (nonatomic, readonly) UIColor *textFieldBorderColor;
@property (nonatomic, readonly) UIEdgeInsets textFieldMargins;

@property (nonatomic, readonly) UIView *actionViewHighlightBackgroundView;
@property (nonatomic, readonly) UIColor *actionViewSeparatorColor;
@property (nonatomic, readonly) CGFloat actionViewSeparatorThickness;

@property (nonatomic, readonly) UIFont *titleLabelFont;
@property (nonatomic, readonly) UIFont *messageLabelFont;
@property (nonatomic, readonly) UIFont *textFieldFont;

- (UIColor *)textColorForAction:(SDCAlertAction *)action;
- (UIFont *)fontForAction:(SDCAlertAction *)action;

@end
