//
//  SDCAlertTextFieldViewController.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/28/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertTextFieldViewController.h"

#import "SDCAlertTextFieldTableViewCell.h"

static NSString *const SDCAlertTextFieldCellIdentifier = @"SDCAlertTextFieldCellIdentifier";

@implementation SDCAlertTextFieldViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.tableView registerClass:[SDCAlertTextFieldTableViewCell class] forCellReuseIdentifier:SDCAlertTextFieldCellIdentifier];
	
	self.tableView.rowHeight = 25;
	self.tableView.scrollEnabled = NO;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.backgroundColor = [UIColor clearColor];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.textFields.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SDCAlertTextFieldTableViewCell *textFieldCell = [tableView dequeueReusableCellWithIdentifier:SDCAlertTextFieldCellIdentifier
																					forIndexPath:indexPath];
	textFieldCell.textField = self.textFields[indexPath.row];
	return textFieldCell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (CGFloat)requiredHeightForDisplayingAllTextFields {
	return self.tableView.rowHeight * [self.tableView numberOfRowsInSection:0];
}

@end
