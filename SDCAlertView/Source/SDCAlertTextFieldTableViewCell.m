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
	
	[self.contentView addSubview:textField];
	[textField sdc_alignEdgesWithSuperview:UIRectEdgeAll];
}

@end
