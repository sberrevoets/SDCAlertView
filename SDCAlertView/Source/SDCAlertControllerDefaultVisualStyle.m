//
//  SDCAlertControllerDefaultVisualStyle.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/27/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertControllerDefaultVisualStyle.h"

@implementation SDCAlertControllerDefaultVisualStyle

- (CGFloat)width {
	return 270;
}

- (CGFloat)buttonHeight {
	return 44;
}

- (UIEdgeInsets)contentPadding {
	return UIEdgeInsetsMake(19, 15, 18.5, 15);
}

- (CGFloat)labelSpacing {
	return 4;
}

- (UIView *)buttonHighlightBackgroundView {
	UIView *view = [[UIView alloc] init];
	view.backgroundColor = [UIColor colorWithWhite:.80 alpha:.7];
	return view;
}

- (UIColor *)buttonTextColor {
	return [[[UIView alloc] init] tintColor];
}

- (UIFont *)titleLabelFont {
	return [UIFont boldSystemFontOfSize:17];
}

- (UIFont *)messageLabelFont {
	return [UIFont systemFontOfSize:14];
}

@end
