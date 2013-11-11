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

@class SDCAlertView;

@protocol SDCAlertViewDelegate <NSObject>
@optional

- (void)alertView:(SDCAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

// To make SDCAlertViewDelegate match all methods from UIAlertView, alertViewCancel: is added to this protocol. However, since SDCAlertView is not a system alert and this method will only be called if the system dismisses the alert, the delegate will never receive the alertViewCancel: message.
- (void)alertViewCancel:(SDCAlertView *)alertView __attribute__((deprecated("This method will never be called--see SDCAlertView.h for more information.")));

- (void)willPresentAlertView:(SDCAlertView *)alertView;
- (void)didPresentAlertView:(SDCAlertView *)alertView;

- (BOOL)alertView:(SDCAlertView *)alertView shouldDismissWithButtonIndex:(NSInteger)buttonIndex;
- (void)alertView:(SDCAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex;
- (void)alertView:(SDCAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;

- (BOOL)alertViewShouldEnableFirstOtherButton:(SDCAlertView *)alertView;

@end

@interface SDCAlertView : UIView

@property (nonatomic, weak) id <SDCAlertViewDelegate> delegate;

@property (nonatomic) NSInteger cancelButtonIndex;

@property (nonatomic) SDCAlertViewStyle alertViewStyle;

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
+ (UIColor *)sdc_disabledAlertButtonTextColor;
+ (UIColor *)sdc_alertSeparatorColor;
@end
