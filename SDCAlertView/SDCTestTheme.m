//
// Created by Jan Chaloupecky on 12/02/14.
// Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCTestTheme.h"
#import "SDCAlertView_Private.h"


@implementation SDCTestTheme {

}
- (UIColor *)alertButtonTextColor {
    return [UIColor colorWithRed:0.36f green:0.64f blue:0.20f alpha:1.00f];
}



- (UIFont *)messageLabelFont {
    return [UIFont systemFontOfSize:22];
}

- (UIFont *)textFieldFont {
    return [UIFont systemFontOfSize:13];
}

- (UIColor *)messageLabelTextColor {
    return [UIColor redColor];
}

- (UIColor *)titleLabelTextColor {
    return [UIColor purpleColor];
}


- (UIFont *)suggestedButtonFont {
    return [UIFont boldSystemFontOfSize:17];
}

- (UIFont *)normalButtonFont {
    return [UIFont systemFontOfSize:17];
}

@end