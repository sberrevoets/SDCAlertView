//
// Created by Jan Chaloupecky on 12/02/14.
// Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SDCTheme <NSObject>

@optional
- (UIColor *)alertButtonTextColor;
- (UIColor *)disabledAlertButtonTextColor;
- (UIColor *)alertSeparatorColor;
- (UIColor *)textFieldBackgroundViewColor;
- (UIColor *)dimmedBackgroundColor;

- (UIFont *)titleLabelFont;
- (UIFont *)messageLabelFont;
- (UIFont *)textFieldFont;
- (UIFont *)suggestedButtonFont;
- (UIFont *)normalButtonFont;


@end