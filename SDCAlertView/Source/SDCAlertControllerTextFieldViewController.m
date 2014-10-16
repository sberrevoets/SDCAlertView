//
//  SDCAlertControllerTextFieldViewController.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/28/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertControllerTextFieldViewController.h"

#import "SDCAlertControllerVisualStyle.h"
#import "SDCAlertTextFieldTableViewCell.h"

static NSString *const SDCAlertTextFieldCellIdentifier = @"SDCAlertTextFieldCellIdentifier";

@interface SDCAlertControllerTextFieldViewController ()
@property (nonatomic, strong) NSArray *textFields;
@property (nonatomic, strong) id<SDCAlertControllerVisualStyle> visualStyle;
@end

@implementation SDCAlertControllerTextFieldViewController

- (instancetype)initWithTextFields:(NSArray *)textFields visualStyle:(id<SDCAlertControllerVisualStyle>)visualStyle {
	self = [self init];
	
	if (self) {
		_textFields = textFields;
		_visualStyle = visualStyle;
		
		[self.tableView registerClass:[SDCAlertTextFieldTableViewCell class] forCellReuseIdentifier:SDCAlertTextFieldCellIdentifier];
		
		self.tableView.scrollEnabled = NO;
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		self.tableView.backgroundColor = [UIColor clearColor];
		
		self.tableView.estimatedRowHeight = visualStyle.estimatedTextFieldHeight;
		
		[self.tableView setNeedsLayout];
		[self.tableView layoutIfNeeded];
	}
	
	return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.textFields.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SDCAlertTextFieldTableViewCell *textFieldCell = [tableView dequeueReusableCellWithIdentifier:SDCAlertTextFieldCellIdentifier
																					forIndexPath:indexPath];
	textFieldCell.visualStyle = self.visualStyle;
	textFieldCell.textField = self.textFields[indexPath.row];
	return textFieldCell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (CGFloat)requiredHeightForDisplayingAllTextFields {
	CGFloat totalHeight = 0;
	
	for (NSUInteger i = 0; i < self.textFields.count; i++) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
		SDCAlertTextFieldTableViewCell *cell = (SDCAlertTextFieldTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
		totalHeight += cell.requiredHeight;
	}
	
	return totalHeight;
}

@end
