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

- (CGFloat)width {
	return 270;
}

- (CGFloat)actionViewHeight {
	return 44;
}

- (CGFloat)minimumActionViewWidth {
	return 90; // Fits exactly three actions without scrolling
}

- (CGFloat)actionViewTopSpacingWithContentView {
	return 0;
}

- (CGFloat)actionViewTopSpacingWithoutContentView {
	return 20;
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

- (CGFloat)textFieldsTopSpacing {
	return 24;
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
