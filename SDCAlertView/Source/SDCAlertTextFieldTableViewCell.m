//
//  SDCAlertTextFieldTableViewCell.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/28/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertTextFieldTableViewCell.h"

#import "SDCAlertControllerVisualStyle.h"

#import "UIView+SDCAutoLayout.h"

@implementation SDCAlertTextFieldTableViewCell

- (void)setTextField:(UITextField *)textField {
	_textField = textField;
	[textField setTranslatesAutoresizingMaskIntoConstraints:NO];
	
	UIView *borderView = [[UIView alloc] init];
	borderView.backgroundColor = self.visualStyle.textFieldBorderColor;
	[borderView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[borderView sdc_pinHeight:self.requiredHeight];
	
	[self.contentView addSubview:borderView];
	[borderView sdc_alignEdgesWithSuperview:UIRectEdgeAll];
	
	UIView *textFieldView = [[UIView alloc] init];
	textFieldView.backgroundColor = [UIColor whiteColor];
	[textFieldView setTranslatesAutoresizingMaskIntoConstraints:NO];

	[borderView addSubview:textFieldView];
	
	CGFloat borderWidth = self.visualStyle.textFieldBorderWidth;
	[textFieldView sdc_alignEdgesWithSuperview:UIRectEdgeAll insets:UIEdgeInsetsMake(borderWidth, borderWidth, -borderWidth, -borderWidth)];
	[textFieldView sdc_centerInSuperview];
	
	[textFieldView addSubview:textField];
	[textField sdc_centerInSuperview];
	[textField sdc_pinWidthToWidthOfView:textFieldView offset:-(self.visualStyle.textFieldMargins.left + self.visualStyle.textFieldMargins.right)];
}

- (CGFloat)requiredHeight {
	return [self.textField intrinsicContentSize].height + self.visualStyle.textFieldMargins.top + self.visualStyle.textFieldMargins.bottom;
}

@end
