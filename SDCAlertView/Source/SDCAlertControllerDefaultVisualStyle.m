//
//  SDCAlertControllerDefaultVisualStyle.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/27/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertControllerDefaultVisualStyle.h"

#import "SDCAlertController.h"

@implementation SDCAlertControllerDefaultVisualStyle

- (CGFloat)cornerRadius {
	return 7;
}

- (UIOffset)parallax {
	return UIOffsetMake(15.75, 15.75);
}

- (CGFloat)width {
	return 270;
}

- (CGFloat)actionViewHeight {
	return 44;
}

- (CGFloat)minimumActionViewWidth {
	return 90; // Fits exactly three actions without scrolling
}

- (UIEdgeInsets)margins {
	return UIEdgeInsetsMake(3, 0, 3, 0);
}

- (UIEdgeInsets)contentPadding {
	return UIEdgeInsetsMake(36, 16, 12, 16);
}

- (CGFloat)labelSpacing {
	return 18;
}

- (CGFloat)estimatedTextFieldHeight {
	return 25;
}

- (CGFloat)textFieldsTopSpacing {
	return 24;
}

- (CGFloat)textFieldBorderWidth {
	return 1 / [UIScreen mainScreen].scale;
}

- (UIColor *)textFieldBorderColor {
	return [UIColor colorWithRed:64.f/255 green:64.f/255 blue:64.f/255 alpha:1];
}

- (UIEdgeInsets)textFieldMargins {
	return UIEdgeInsetsMake(4, 4, 4, 4);
}

- (UIView *)actionViewHighlightBackgroundView {
	UIView *view = [[UIView alloc] init];
	view.backgroundColor = [UIColor colorWithWhite:.80 alpha:.7];
	return view;
}

- (UIColor *)actionViewSeparatorColor {
	return [UIColor colorWithWhite:0.5 alpha:0.5];
}

- (CGFloat)actionViewSeparatorThickness {
	return 1 / [UIScreen mainScreen].scale;
}

- (UIFont *)titleLabelFont {
	return [UIFont boldSystemFontOfSize:17];
}

- (UIFont *)messageLabelFont {
	return [UIFont systemFontOfSize:13];
}

- (UIFont *)textFieldFont {
	return [UIFont systemFontOfSize:13];
}

- (UIColor *)textColorForAction:(SDCAlertAction *)action {
	if (action.style == SDCAlertActionStyleDestructive) {
		return [UIColor redColor];
	} else {
		return [[[UIView alloc] init] tintColor];
	}
}

- (UIFont *)fontForAction:(SDCAlertAction *)action {
	if (action.style == SDCAlertActionStyleCancel) {
		return [UIFont boldSystemFontOfSize:17];
	} else {
		return [UIFont systemFontOfSize:17];
	}
}

@end
