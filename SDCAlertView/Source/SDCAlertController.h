//
//  SDCAlertController.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/14/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertController.h"

typedef NS_ENUM(NSInteger, SDCAlertActionStyle) {
	SDCAlertActionStyleDefault = UIAlertActionStyleDefault,
	SDCAlertActionStyleCancel = UIAlertActionStyleCancel,
	SDCAlertActionStyleDestructive = UIAlertActionStyleDestructive
};

typedef NS_ENUM(NSInteger, SDCAlertControllerStyle) {
	SDCAlertControllerStyleAlert = UIAlertControllerStyleAlert
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

@end

@protocol SDCAlertControllerVisualStyle;

@interface SDCAlertController : UIViewController

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(SDCAlertControllerStyle)preferredStyle;
+ (instancetype)alertControllerWithAttributedTitle:(NSAttributedString *)attributedTitle
								 attributedMessage:(NSAttributedString *)attributedMessage
									preferredStyle:(SDCAlertControllerStyle)preferredStyle;

- (void)addAction:(SDCAlertAction *)action;
@property (nonatomic, readonly) NSArray *actions;
@property (nonatomic) SDCAlertControllerActionLayout actionLayout;

- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler;
@property (nonatomic, readonly) NSArray *textFields;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSAttributedString *attributedTitle;

@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSAttributedString *attributedMessage;

@property (nonatomic, readonly) UIView *contentView;

@property (nonatomic, readonly) SDCAlertControllerStyle preferredStyle;
- (void)applyVisualStyle:(id<SDCAlertControllerVisualStyle>)visualStyle;

@property (nonatomic, copy) BOOL (^shouldDismissBlock)(SDCAlertAction *action);

@end

@interface SDCAlertController (Transitioning)

- (void)present;
- (void)presentWithCompletion:(void(^)(void))completion;
- (void)presentFromViewController:(UIViewController *)viewController completionHandler:(void(^)(void))completion;

- (void)dismiss;
- (void)dismissWithCompletion:(void(^)(void))completion;

@end

@interface SDCAlertController (Convenience)

+ (instancetype)showAlertControllerWithTitle:(NSString *)title message:(NSString *)message;
+ (instancetype)showAlertControllerWithTitle:(NSString *)title message:(NSString *)message actionTitle:(NSString *)actionTitle;
+ (instancetype)showAlertControllerWithTitle:(NSString *)title message:(NSString *)message actionTitle:(NSString *)actionTitle subview:(UIView *)subview;

@end