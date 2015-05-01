//
//  SDCAlertController.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/14/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

@import UIKit;

typedef NS_OPTIONS(NSInteger, SDCAlertActionStyle) {
	SDCAlertActionStyleDefault = 1 << 0,
	/// The recommended action style stands out more than the other buttons to indicate to the user this
	/// action is the recommended option. The recommended and default styles are mutually exclusive--the cancel
	/// style will have precedence over the default style if both are provided.
	SDCAlertActionStyleRecommended = 1 << 1,
	/// Give the action a visual appearance that cautions the user it will destroy (delete, remove, log out,
    /// etc.) something. Can be used
	SDCAlertActionStyleDestructive = 1 << 2,
	/// The cancel style is included here for backwards compatibility and to match the API to UIAlertController
	SDCAlertActionStyleCancel = SDCAlertActionStyleRecommended
};

typedef NS_ENUM(NSInteger, SDCAlertControllerStyle) {
	/// Default alert. Shows the correct alert based on iOS version.
	SDCAlertControllerStyleAlert = UIAlertControllerStyleAlert,
	/// Use the iOS 7 alert regardless of the current iOS version
	SDCAlertControllerStyleLegacyAlert
};

typedef NS_ENUM(NSInteger, SDCAlertControllerActionLayout) {
	SDCAlertControllerActionLayoutAutomatic,
	SDCAlertControllerActionLayoutHorizontal,
	SDCAlertControllerActionLayoutVertical
};

@interface SDCAlertAction : NSObject <NSCopying>

+ (instancetype)actionWithTitle:(NSString *)title style:(SDCAlertActionStyle)style handler:(void (^)(SDCAlertAction *action))handler;
+ (instancetype)actionWithAttributedTitle:(NSAttributedString *)attributedTitle style:(SDCAlertActionStyle)style handler:(void (^)(SDCAlertAction *action))handler;

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSAttributedString *attributedTitle;

@property (nonatomic, readonly) SDCAlertActionStyle style;
@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic, copy, readonly) void (^handler)(SDCAlertAction *action);

@end

@protocol SDCAlertControllerVisualStyle;

@interface SDCAlertController : UIViewController

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(SDCAlertControllerStyle)preferredStyle;
+ (instancetype)alertControllerWithAttributedTitle:(NSAttributedString *)attributedTitle
								 attributedMessage:(NSAttributedString *)attributedMessage
									preferredStyle:(SDCAlertControllerStyle)preferredStyle;

- (void)addAction:(SDCAlertAction *)action;
@property (nonatomic, readonly) NSArray *actions;

/**
 *  Force the actions to lay out either horizontally or vertically. Default is SDCAlertControllerActionLayoutAutomatic, resulting in 2 actions being
 *  displayed horizontally, and any other number of actions vertically.
 */
@property (nonatomic) SDCAlertControllerActionLayout actionLayout;

- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler;

/**
 *  Use this property only if the deployment target of your app is set to iOS 8 or above. If you support iOS 7, please see -textFieldAtIndex: below.
 */
@property (nonatomic, readonly) NSArray *textFields;

@property (nonatomic, copy) NSString *title;

/**
 *  The attributed title for the alert. Both \c title and \c attributedTitle can be used to set the title of the alert,
 *  the title will be set to whichever was called last. That means that setting \c title to \c nil after setting the
 *  \c attributedTitle will result in no title showing.
 */
@property (nonatomic, copy) NSAttributedString *attributedTitle;

@property (nonatomic, copy) NSString *message;

/**
 *  The attributed message for the alert. Both \c message and \c attributedMessage can be used to set the message of the
 *  alert, but the message will be set to whichever was called last. That means that setting \c mesage to \c nil after
 *  setting the \c attributedMessage will result in no message showing.
 */
@property (nonatomic, copy) NSAttributedString *attributedMessage;

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

@property (nonatomic, readonly) SDCAlertControllerStyle preferredStyle;


/**
 *  The alert's visual style defines how the different alert elements will look. Any class that implements this protocol and returns valid values can
 *  be assigned to this property. This deprecates UIAppearance support in SDCAlertView 1.0, as all old UIAppearance-enabled properties are part of the
 *  visual style.
 */
@property (nonatomic, strong) id<SDCAlertControllerVisualStyle> visualStyle;

/**
 *  A block that determines whether an action should dismiss the alert or not. The \c action parameter is the action that originally called this block.
 */
@property (nonatomic, copy) BOOL (^shouldDismissBlock)(SDCAlertAction *action);

@end

@interface SDCAlertController (Presentation)

/**
 *  Instead of calling \c presentViewController:animated:completion: on some view controller, you can use this method and the alert will figure out
 *  what view controller to present itself from. This enables you to show alerts directly from, for example, network layers that don't necessarily know
 *  about any view controllers but need to present an error or info message.
 *
 *  This method is what brings backwards compatibility to SDCAlertView. It will smartly show a 1.0 (iOS 7) or 2.0 (iOS 8) alert based on the iOS version
 *  of the user.
 */
- (void)presentWithCompletion:(void(^)(void))completion;

/**
 *  This method can be used as any easy way to dismiss an alert without having to know exactly which view controller it was presented from. This brings
 *  backwards compatibility to SDCAlertView, and will cause a call to \c dismissWithClickedButtonIndex:animated: on an iOS 7 alert.
 */
- (void)dismissWithCompletion:(void(^)(void))completion;

@end

@class SDCAlertView;

@interface SDCAlertController (Legacy)
/*
 *  SDCAlertController is backwards compatible with SDCAlertView. This means that you can simply create an SDCAlertController instance and use that to
 *  display an alert on both iOS 7 and iOS 8. Most, if not all, functionality that is present in SDCAlertView has been ported back from
 *  SDCAlertController.
 *
 *  In a case where some functionality is not ported back, you'll be able to make the customization yourself by using the \c legacyAlertView property,
 *  which will return the SDCAlertView instance that is presented. For example, this could be an initialization pattern for an alert that needs to be
 *  shown on iOS 7 and iOS 8:
 *
 *		SDCAlertController *alert = [SDCAlertController alertWithTitle:@"Title" message:@"Message" preferredStyle:SDCAlertControllerStyleAlert];
 *		// ... configure alert with content view, text fields, buttons, etc ...
 *
 *		if (alert.usesLegacyAlert) {
 *			// ... use alert.legacyAlertView to make iOS 7 modifications
 *		} else {
 *			// Keep using original alert
 *		}
 *
 *		[alert presentWithCompletion:nil];
 */

/**
 *  Returns whether this alert controller will use the iOS 7-style alert (SDCAlertView) when this alert is presented.
 */
@property (nonatomic, readonly) BOOL usesLegacyAlert;

/**
 *  Returns the SDCAlertView instance that will be presented IF it will be presented (based on preferred alert style or iOS version), otherwise \c nil.
 */
@property (nonatomic, readonly) SDCAlertView *legacyAlertView;

/**
 *  The backwards-compatible method to retrieve a text field. You may use the textFields property if the deployment target is iOS 8 or above.
 */
- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex;

@end

@interface SDCAlertController (Convenience)

+ (instancetype)showAlertControllerWithTitle:(NSString *)title message:(NSString *)message;
+ (instancetype)showAlertControllerWithTitle:(NSString *)title message:(NSString *)message actionTitle:(NSString *)actionTitle;
+ (instancetype)showAlertControllerWithTitle:(NSString *)title message:(NSString *)message actionTitle:(NSString *)actionTitle subview:(UIView *)subview;

@end
