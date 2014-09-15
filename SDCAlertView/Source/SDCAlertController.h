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

@interface SDCAlertAction : NSObject <NSCopying>

+ (instancetype)actionWithTitle:(NSString *)title style:(SDCAlertActionStyle)style handler:(void (^)(SDCAlertAction *action))handler;

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) SDCAlertActionStyle style;
@property (nonatomic, getter=isEnabled) BOOL enabled;

@end

@interface SDCAlertController : UIViewController

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(SDCAlertControllerStyle)preferredStyle;

- (void)addAction:(SDCAlertAction *)action;
@property (nonatomic, readonly) NSArray *actions;
- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler;
@property (nonatomic, readonly) NSArray *textFields;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;

@property (nonatomic, readonly) SDCAlertControllerStyle preferredStyle;

@end
