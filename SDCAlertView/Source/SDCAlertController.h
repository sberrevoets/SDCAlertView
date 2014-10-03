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

typedef NS_ENUM(NSInteger, SDCAlertControllerButtonLayout) {
	SDCAlertControllerButtonLayoutAutomatic,
	SDCAlertControllerButtonLayoutHorizontal,
	SDCAlertControllerButtonLayoutVertical
};

@interface SDCAlertAction : NSObject <NSCopying>

+ (instancetype)actionWithTitle:(NSString *)title style:(SDCAlertActionStyle)style handler:(void (^)(SDCAlertAction *action))handler;

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) SDCAlertActionStyle style;
@property (nonatomic, getter=isEnabled) BOOL enabled;

@end

@protocol SDCAlertControllerVisualStyle;

@interface SDCAlertController : UIViewController

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(SDCAlertControllerStyle)preferredStyle;

- (void)addAction:(SDCAlertAction *)action;
@property (nonatomic, readonly) NSArray *actions;
@property (nonatomic) SDCAlertControllerButtonLayout buttonLayout;

- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler;
@property (nonatomic, readonly) NSArray *textFields;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;

@property (nonatomic, readonly) UIView *contentView;

@property (nonatomic, readonly) SDCAlertControllerStyle preferredStyle;

- (void)applyVisualStyle:(id<SDCAlertControllerVisualStyle>)visualStyle;

@end