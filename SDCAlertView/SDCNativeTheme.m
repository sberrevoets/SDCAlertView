//
// Created by Jan on 12/02/14.
// Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCNativeTheme.h"
#import "SDCAlertView_Private.h"


@implementation SDCNativeTheme {

}
- (UIColor *)alertButtonTextColor {
    return [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1];
}

- (UIColor *)disabledAlertButtonTextColor {
    return [UIColor colorWithRed:143/255.0 green:143/255.0 blue:143/255.0 alpha:1];
}
- (UIColor *)messageLabelTextColor {
    return [UIColor blackColor];
};
- (UIColor *)titleLabelTextColor {
    return [UIColor blackColor];
}

- (UIColor *)alertSeparatorColor {
    return [UIColor colorWithWhite:0.5 alpha:0.5];
}

- (UIColor *)textFieldBackgroundViewColor {
    return [UIColor colorWithWhite:0.5 alpha:0.5];
}

- (UIColor *)dimmedBackgroundColor {
    return [UIColor colorWithWhite:0 alpha:.4];
}

- (UIFont *)titleLabelFont {
    return [UIFont boldSystemFontOfSize:17];
}

- (UIFont *)messageLabelFont {
    return [UIFont systemFontOfSize:14];
}

- (UIFont *)textFieldFont {
    return [UIFont systemFontOfSize:13];
}

- (UIFont *)suggestedButtonFont {
    return [UIFont boldSystemFontOfSize:17];
}

- (UIFont *)normalButtonFont {
    return [UIFont systemFontOfSize:17];
}

@end