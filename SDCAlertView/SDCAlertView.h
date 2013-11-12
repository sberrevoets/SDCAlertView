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

// TODO: Setting the cancelButtonIndex is not yet supported.
@property (nonatomic) NSInteger cancelButtonIndex;
@property (nonatomic, readonly) NSInteger firstOtherButtonIndex;
@property (nonatomic, readonly) NSInteger numberOfButtons;

// TODO: The semantics of this property are a little different than UIAlertView's visible property.
// Currently, if the receiver has been presented (but then dismissed, but still in the heap), this property will be set to YES.
@property (nonatomic, readonly, getter = isVisible) BOOL visible;

@property (nonatomic) SDCAlertViewStyle alertViewStyle;

// The contentView property can be used to display any arbitrary view in an alert view by adding these views to the contentView.
// SDCAlertView uses auto-layout to layout all its subviews, including the contentView. That means that you should not modify the contentView's frame property, as it will do nothing. Use NSLayoutConstraint or helper methods included in SDCAutoLayout to modify the contentView's dimensions. The contentView will take up the entire width of the alert. The height cannot be automatically determined and will need to be explicitly defined. If there are no subviews, the contentView will not be added to the alert. 
@property (nonatomic, readonly) UIView *contentView;

- (instancetype)initWithTitle:(NSString *)title
					  message:(NSString *)message
					 delegate:(id)delegate
			cancelButtonTitle:(NSString *)cancelButtonTitle
			otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (void)show;

- (void)addButtonWithTitle:(NSString *)title;
- (NSString *)buttonTitleAtIndex:(NSInteger)index;

// TODO: The animated argument is currently ignored.
// All alerts are dismissed with animation, regardless of the animated argument
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex;

@end

@interface UIColor (SDCAlertViewColors)
+ (UIColor *)sdc_alertBackgroundColor;
+ (UIColor *)sdc_alertButtonTextColor;
+ (UIColor *)sdc_disabledAlertButtonTextColor;
+ (UIColor *)sdc_alertSeparatorColor;
+ (UIColor *)sdc_textFieldBackgroundViewColor;
@end
