//
//  SDCAlertView.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/20/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT CGFloat const SDCAlertViewWidth;

CGFloat SDCAlertViewGetSeparatorThickness();

typedef NS_ENUM(NSInteger, SDCAlertViewStyle) {
    SDCAlertViewStyleDefault = 0,
    SDCAlertViewStyleSecureTextInput,
    SDCAlertViewStylePlainTextInput,
    SDCAlertViewStyleLoginAndPasswordInput
};

@interface SDCAlertView : UIView

@property (nonatomic) SDCAlertViewStyle alertViewStyle;
@property (nonatomic, strong) UIView *contentView;

- (instancetype)initWithTitle:(NSString *)title
					  message:(NSString *)message
					 delegate:(id)delegate
			cancelButtonTitle:(NSString *)cancelButtonTitle
			otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (void)show;

@end

@interface UIColor (SDCAlertViewColors)
+ (UIColor *)sdc_alertBackgroundColor;
+ (UIColor *)sdc_alertButtonTextColor;
+ (UIColor *)sdc_alertSeparatorColor;
@end
