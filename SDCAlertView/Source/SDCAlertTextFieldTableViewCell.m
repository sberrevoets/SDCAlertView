//
//  SDCAlertTextFieldTableViewCell.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/28/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertTextFieldTableViewCell.h"

#import "UIView+SDCAutoLayout.h"

@implementation SDCAlertTextFieldTableViewCell

- (void)setTextField:(UITextField *)textField {
	_textField = textField;
	[textField setTranslatesAutoresizingMaskIntoConstraints:NO];
	
	UIView *borderView = [[UIView alloc] init];
	[borderView setTranslatesAutoresizingMaskIntoConstraints:NO];
	borderView.backgroundColor = [UIColor colorWithRed:64.f/255 green:64.f/255 blue:64.f/255 alpha:1];
	
	[self.contentView addSubview:borderView];
	[borderView sdc_alignEdgesWithSuperview:UIRectEdgeAll];
	
	UIView *textFieldView = [[UIView alloc] init];
	textFieldView.backgroundColor = [UIColor whiteColor];
	[textFieldView setTranslatesAutoresizingMaskIntoConstraints:NO];

	[borderView addSubview:textFieldView];
	[textFieldView sdc_alignEdgesWithSuperview:UIRectEdgeAll insets:UIEdgeInsetsMake(0.5, 0.5, -0.5, -0.5)];
	[textFieldView sdc_centerInSuperview];
	
	[textFieldView addSubview:textField];
	[textField sdc_centerInSuperview];
	[textField sdc_pinWidthToWidthOfView:textFieldView offset:-8];
}

@end
