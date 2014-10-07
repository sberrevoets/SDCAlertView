//
//  SDCDemoViewController.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 10/6/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCDemoViewController.h"

#import "SDCAlertController.h"

@interface SDCDemoViewController ()
@property (nonatomic, weak) IBOutlet UISegmentedControl *alertStyleControl;
@property (nonatomic, weak) IBOutlet UITextField *titleTextField;
@property (nonatomic, weak) IBOutlet UITextField *messageTextField;
@property (nonatomic, weak) IBOutlet UITextField *textFieldsTextField;
@property (nonatomic) NSInteger selectedContentViewIndex;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, weak) IBOutlet UITextField *buttonsTextField;
@property (nonatomic, weak) IBOutlet UISegmentedControl *buttonLayoutControl;
@end

@implementation SDCDemoViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.tableView.rowHeight = 44;
	
	self.selectedContentViewIndex = 0;
}

- (IBAction)showAlert:(UIBarButtonItem *)sender {
	switch (self.alertStyleControl.selectedSegmentIndex) {
		case 0:		[self showAlertWithStyle:SDCAlertControllerStyleAlert];	break;
		case 1:		[self showAlertWithStyle:SDCAlertControllerStyleLegacyAlert]; break;
		case 2:		[self showSystemAlert]; break;
  	}
}

- (void)showAlertWithStyle:(SDCAlertControllerStyle)style {
	SDCAlertController *alert = [SDCAlertController alertControllerWithTitle:self.titleTextField.text
																	 message:self.messageTextField.text
															  preferredStyle:style];
	
	NSInteger textFields = self.textFieldsTextField.text.integerValue;
	for (NSInteger i = 0; i < textFields; i++) {
		[alert addTextFieldWithConfigurationHandler:nil];
	}
	
	NSInteger buttons = self.buttonsTextField.text.integerValue;
	for (NSInteger i = 0; i < buttons; i++) {
		SDCAlertAction *action = [SDCAlertAction actionWithTitle:[NSString stringWithFormat:@"Button %@", @(i)]
														   style:SDCAlertActionStyleDefault
														 handler:nil];
		[alert addAction:action];
	}
	
	alert.actionLayout = self.buttonLayoutControl.selectedSegmentIndex;
	
	[alert presentWithCompletion:nil];
}

- (void)showSystemAlert {
	
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath.section == 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	if (indexPath.section == 1 && indexPath.row == self.selectedContentViewIndex) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section != 1) {
		return;
	}
	
	self.selectedContentViewIndex = indexPath.row;
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}

@end
