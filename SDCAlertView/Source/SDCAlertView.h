//
//  SDCAlertView.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/20/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

@import UIKit;

FOUNDATION_EXPORT CGFloat const SDCAlertViewWidth;

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

/**
 *  To make SDCAlertViewDelegate match all methods from UIAlertView, alertViewCancel: is added to this protocol. However,
 *  since SDCAlertView is not a system alert and this method will only be called if the system dismisses the alert, the
 *  delegate will never receive the alertViewCancel: message.
 */
- (void)alertViewCancel:(SDCAlertView *)alertView DEPRECATED_MSG_ATTRIBUTE("This method will never be called. See SDCAlertView.h for more information.");

- (void)willPresentAlertView:(SDCAlertView *)alertView;
- (void)didPresentAlertView:(SDCAlertView *)alertView;

- (BOOL)alertView:(SDCAlertView *)alertView shouldDismissWithButtonIndex:(NSInteger)buttonIndex;
- (void)alertView:(SDCAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex;
- (void)alertView:(SDCAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;

/**
 *  This method is sent when the user presses a button, but the alert is prevented from being dismissed using either
 *  the \c alertView:shouldDismissWithButtonIndex: delegate method, or the \c shouldDismissHandler property. The return
 *  value of this method (or its corresponding block property \c shouldDeselectButtonHandler) determines whether
 *  the button stays selected after it has been tapped. The default value, which is returned if neither the delegate method
 *  is implemented or the block property set, is YES.
 */
- (BOOL)alertView:(SDCAlertView *)alertView shouldDeselectButtonAtIndex:(NSInteger)buttonIndex;

- (BOOL)alertViewShouldEnableFirstOtherButton:(SDCAlertView *)alertView;

@end

@interface SDCAlertView : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;

@property (nonatomic) NSInteger cancelButtonIndex;
@property (nonatomic, readonly) NSInteger firstOtherButtonIndex;
@property (nonatomic, readonly) NSInteger numberOfButtons;

@property (nonatomic, readonly, getter = isVisible) BOOL visible;

@property (nonatomic) SDCAlertViewStyle alertViewStyle;

/**
 *  The contentView property can be used to display any arbitrary view in an alert view by adding these views to the contentView.
 *  SDCAlertView uses auto-layout to layout all its subviews, including the contentView. That means that you should not
 *  modify the contentView's frame property, as it will do nothing. Use NSLayoutConstraint or helper methods included in
 *  SDCAutoLayout to modify the contentView's dimensions.
 *
 *  The contentView will take up the entire width of the alert. The height cannot be automatically determined and will
 *  need to be explicitly defined.
 *
 *  If there are no subviews, the contentView will not be added to the alert.
 */
@property (nonatomic, readonly) UIView *contentView;

@property (nonatomic, weak) id <SDCAlertViewDelegate> delegate;

/*
 *  The following properties are blocks as alternatives to using delegate methods. It's possible to implement both the 
 *  delegate and set its corresponding block. In that case, the delegate will be called before the block will be executed.
 *
 *  In the case of alertView:shouldDismissWithButtonIndex:/shouldDismissHandler and
 *  alertView:shouldDeselectButtonAtIndex:/shouldDeselectButtonHandler, the delegate will always have precedence. That
 *  meansthat if the delegate is set, the block will NOT be executed.
 */

/// Alternative property for \c didPresentAlertView:
@property (nonatomic, copy) void (^didPresentHandler)();

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
			otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION NS_DESIGNATED_INITIALIZER;

/*
 *  Showing and dismissing an alert works largely the same as it does with UIAlertView. Animations will not be interrupted,
 *  so showing an alert while another alert is already animating will finish the first alert, then show the second. The
 *  behavior is a little bit different in edge cases, like when doing this:
 *
 *		SDCAlertView *alert1 = ...;
 *		SDCAlertView *alert2 = ...;
 *
 *		[alert1 show];
 *		[alert1 dismissWithClickedButtonIndex:0];
 *		[alert2 show];
 *
 *  Take a look at https://github.com/Scott90/SDCAlertView/issues/25 for a discussion of the exact behavior.
 */

- (void)show;

- (NSInteger)addButtonWithTitle:(NSString *)title;
- (NSString *)buttonTitleAtIndex:(NSInteger)index;

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex;

@end

@interface SDCAlertView (SDCAlertViewSpecific)

/**
 *  Set this property to \c YES to show the buttons of a two-button alert stacked on top of each other, as opposed to
 *  horizontally next to each other. Defaults to \c NO.
 */
@property (nonatomic) BOOL alwaysShowsButtonsVertically;
@end

@interface SDCAlertView (SDCAlertViewAttributedStrings)

/*
 *  If a string has a title with attributes, the equivalent UIAppearance properties for that attribute will not work
 *  anymore. For example, the following code will result in a red title:
 *
 *		NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor redColor]};
 *		alert.attributedTitle = [[NSAttributedString alloc] initWithTitle:@"Title" attributes:attributes];
 *		alert.titleLabelTextColor = [UIColor greenColor];
 *
 *  This is an unfortunate side effect of UIAppearance, so it's recommended to use either attributed strings or their
 *  equivalent UIAppearance properties, not both.
 */


/**
 *  The attributed title for the alert. Both \c title and \c attributedTitle can be used to set the title of the alert,
 *  the title will be set to whichever was called last. That means that setting \c title to \c nil after setting the
 *  \c attributedTitle will result in no title showing.
 */
@property (nonatomic, copy) NSAttributedString *attributedTitle;

/**
 *  The attributed message for the alert. Both \c message and \c attributedMessage can be used to set the message of the
 *  alert, but the message will be set to whichever was called last. That means that setting \c mesage to \c nil after
 *  setting the \c attributedMessage will result in no message showing.
 */
@property (nonatomic, copy) NSAttributedString *attributedMessage;

@end

@interface SDCAlertView (Convenience)

/**
 *  Set a dismiss handler and show the alert.
 */
- (void)showWithDismissHandler:(void(^)(NSInteger buttonIndex))dismissHandler;

/*
 *  The methods below are convenience methods to easily make an alert appear. All methods create an alert, show it with
 *  the provided arguments, and return the alert that was shown. The delegate isn't set, but can be changed using the
 *  delegate property.
 *
 *  Methods with a non-nil and non-empty buttons array will add the buttons in order, making the first button of the array
 *  the cancel button. Method calls with a non-nil subview argument will have the subview added to the alert's contentView.
 */
 
+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message;
+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message buttons:(NSArray *)buttons;

+ (instancetype)alertWithSubview:(UIView *)subview;
+ (instancetype)alertWithTitle:(NSString *)title subview:(UIView *)subview;
+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message subview:(UIView *)subview;
+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message subview:(UIView *)subview buttons:(NSArray *)buttons;

@end

@interface SDCAlertView (UIAppearance)

@property (nonatomic, strong) UIFont	*titleLabelFont			UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor	*titleLabelTextColor	UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont	*messageLabelFont		UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor	*messageLabelTextColor	UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont	*textFieldFont			UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor	*textFieldTextColor		UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont	*suggestedButtonFont	UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont	*normalButtonFont		UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor	*buttonTextColor		UI_APPEARANCE_SELECTOR;	// Will override tintColor
@property (nonatomic, assign) UIEdgeInsets contentPadding UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat labelSpacing UI_APPEARANCE_SELECTOR;

@end

@class SDCAlertController;
@interface SDCAlertView (SDCAlertController)
+ (instancetype)alertViewWithAlertController:(SDCAlertController *)alertController;
@end

@interface UIColor (SDCAlertViewColors)
+ (UIColor *)sdc_alertSeparatorColor;
+ (UIColor *)sdc_textFieldBackgroundViewColor;
+ (UIColor *)sdc_dimmedBackgroundColor;
@end
