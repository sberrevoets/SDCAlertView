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

/*
 *  Alert-related values
 */

@property (nonatomic, readonly) CGFloat width;
@property (nonatomic, readonly) CGFloat cornerRadius;
@property (nonatomic, readonly) UIEdgeInsets contentPadding;

/// The margins determine the distance between the edge of the screen and the alert
@property (nonatomic, readonly) UIEdgeInsets margins;

/// The alert's parallax magnitude in horizontal and vertical directions.
@property (nonatomic, readonly) UIOffset parallax;

/*
 *  Title and message label values
 */

@property (nonatomic, readonly) UIFont *titleLabelFont;
@property (nonatomic, readonly) UIFont *messageLabelFont;
@property (nonatomic, readonly) UIFont *textFieldFont;

@property (nonatomic, readonly) CGFloat labelSpacing;

/*
 *  Action-related values
 */

@property (nonatomic, readonly) CGFloat actionViewHeight;
@property (nonatomic, readonly) CGFloat minimumActionViewWidth; // For forced horizontal layout and 3+ buttons
@property (nonatomic, readonly) UIView *actionViewHighlightBackgroundView;
@property (nonatomic, readonly) UIColor *actionViewSeparatorColor;
@property (nonatomic, readonly) CGFloat actionViewSeparatorThickness;

- (UIColor *)textColorForAction:(SDCAlertAction *)action;
- (UIFont *)fontForAction:(SDCAlertAction *)action;

/*
 * Text field-related values
 */

@property (nonatomic, readonly) CGFloat estimatedTextFieldHeight;
@property (nonatomic, readonly) CGFloat textFieldsTopSpacing;
@property (nonatomic, readonly) CGFloat textFieldBorderWidth;
@property (nonatomic, readonly) UIColor *textFieldBorderColor;
@property (nonatomic, readonly) UIEdgeInsets textFieldMargins;

@end
