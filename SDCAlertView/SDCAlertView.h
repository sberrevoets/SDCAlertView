//
//  SDCAlertView.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/20/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import <UIKit/UIKit.h>

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

/**
 *  This method is sent when the user presses a button, but the alert is prevented from being dismissed using either
 *  the \c alertView:shouldDismissWithButtonIndex: delegate method, or the \c shouldDismissHandler property. The return
 *  value of this method (or its corresponding block property \c shouldDeselectButtonHandler) determines whether
 *  the button stays selected after it has been tapped. The default value, which is returned if neither the delegate method is
 *  implemented or the block property set, is YES.
 */
- (BOOL)alertView:(SDCAlertView *)alertView shouldDeselectButtonAtIndex:(NSInteger)buttonIndex;

- (BOOL)alertViewShouldEnableFirstOtherButton:(SDCAlertView *)alertView;

@end

@interface SDCAlertView : UIView

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;

/*
 * UIAlertView has a "bug" that was intentionally not duplicated in SDCAlertView.
 * This code:
 *
 *		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Title" message:@"This is a message" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"B1", @"B2", nil];
 *		NSLog(@"%d", alert.firstOtherButtonIndex);
 *
 * will display 1 in the console, which is correct. When setting alert.cancelButtonIndex = 1, both cancelButtonIndex and firstOtherButtonIndex are 1 (B1).
 *
 * Though it doesn't make much sense, it's not a big deal. However, when returning NO from the delegate method -alertViewShouldEnableFirstOtherButton:, the
 * button with Cancel on it will be disabled. So, alert.firstOtherButtonIndex refers to B1, while the delegate method disables the button with title Cancel.
 *
 * That makes no sense, so when you do the same thing on SDCAlertView, firstOtherButtonIndex will return 0 and the delegate method will disable the Cancel button.
 * In other words, the former Cancel button now got demoted to a normal button at index 0.
 */

@property (nonatomic) NSInteger cancelButtonIndex;
@property (nonatomic, readonly) NSInteger firstOtherButtonIndex;
@property (nonatomic, readonly) NSInteger numberOfButtons;

@property (nonatomic, readonly, getter = isVisible) BOOL visible;

@property (nonatomic) SDCAlertViewStyle alertViewStyle;

/**
 *  The contentView property can be used to display any arbitrary view in an alert view by adding these views to the contentView.
 *  SDCAlertView uses auto-layout to layout all its subviews, including the contentView. That means that you should not modify
 *  the contentView's frame property, as it will do nothing. Use NSLayoutConstraint or helper methods included in SDCAutoLayout
 *  to modify the contentView's dimensions.
 *
 *  The contentView will take up the entire width of the alert. The height cannot be automatically determined and will need to be
 *  explicitly defined.
 *
 *  If there are no subviews, the contentView will not be added to the alert.
 */
@property (nonatomic, readonly) UIView *contentView;

@property (nonatomic, weak) id <SDCAlertViewDelegate> delegate;

/*
 *  The following properties are blocks as alternatives to using delegate methods.
 *  It's possible to implement both the delegate and set its corresponding block. In
 *  that case, the delegate will be called before the block will be executed.
 *
 *  In the case of alertView:shouldDismissWithButtonIndex:/shouldDismissHandler and 
 *  alertView:shouldDeselectButtonAtIndex:/shouldDeselectButtonHandler, the
 *  delegate will always have precedence. That means that if the delegate is set,
 *  the block will NOT be executed.
 */

/// Alternative property for \c alertView:clickedButtonAtIndex:
@property (nonatomic, copy) void (^clickedButtonHandler)(NSInteger buttonIndex);

/// Alternative property for \c alertView:shouldDismissWithButtonIndex:
@property (nonatomic, copy) BOOL (^shouldDismissHandler)(NSInteger buttonIndex);

/// Alternative property for \c alertView:willDismissWithButtonIndex:
@property (nonatomic, copy) void (^willDismissHandler)(NSInteger buttonIndex);

/// Alternative property for \c alertView:didDismissWithButtonIndex:
@property (nonatomic, copy) void (^didDismissHandler)(NSInteger buttonIndex);

/// Alternative property for \c alertView:shouldDeselectButtonAtIndex:
@property (nonatomic, copy) BOOL (^shouldDeselectButtonHandler)(NSInteger buttonIndex);

- (instancetype)initWithTitle:(NSString *)title
					  message:(NSString *)message
					 delegate:(id)delegate
			cancelButtonTitle:(NSString *)cancelButtonTitle
			otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (void)show;

/**
 *  Convenience method that sets the dismiss block while simultaneously showing the alert.
*/
- (void)showWithDismissHandler:(void(^)(NSInteger buttonIndex))dismissHandler;

- (NSInteger)addButtonWithTitle:(NSString *)title;
- (NSString *)buttonTitleAtIndex:(NSInteger)index;

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex;

@end
