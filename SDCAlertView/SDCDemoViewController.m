//
//  SDCDemoViewController.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 10/6/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCDemoViewController.h"

#import "SDCAlertController.h"
#import "SDCAlertView.h"
#import <UIView+SDCAutoLayout.h>

@import MapKit;

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
	
	if (self.selectedContentViewIndex > 0 && alert.legacyAlertView) {
		[self addContentToView:alert.legacyAlertView.contentView];
		[alert presentWithCompletion:nil];
	} else if (self.selectedContentViewIndex > 0) {
		[self addContentToView:alert.contentView];
		[alert presentWithCompletion:nil];
	} else {
		[alert presentWithCompletion:nil];
	}
}

- (void)addContentToView:(UIView *)contentView {
	switch (self.selectedContentViewIndex) {
		case 1: {
			UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			[spinner setTranslatesAutoresizingMaskIntoConstraints:NO];
			[spinner startAnimating];
			[contentView addSubview:spinner];
			
			[spinner sdc_horizontallyCenterInSuperview];
			[contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[spinner]-(==20)-|"
																					  options:0
																					  metrics:nil
																						views:NSDictionaryOfVariableBindings(spinner)]];
			
			
			break;
		} case 2: {
			UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
			progressView.progress = 0;
			
			[NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(updateProgressView:) userInfo:progressView repeats:YES];
			
			[progressView setTranslatesAutoresizingMaskIntoConstraints:NO];
			[contentView addSubview:progressView];
			
			[progressView sdc_pinWidthToWidthOfView:contentView offset:-20];
			[progressView sdc_horizontallyCenterInSuperview];
			
			[contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[progressView]-|"
																					  options:0
																					  metrics:nil
																						views:NSDictionaryOfVariableBindings(progressView)]];
			break;
		} case 3: {
			MKMapView *mapView = [[MKMapView alloc] init];
			[mapView setTranslatesAutoresizingMaskIntoConstraints:NO];
			
			MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.3175, -122.041944), MKCoordinateSpanMake(.1, .1));
			[mapView setRegion:region animated:YES];
			[contentView addSubview:mapView];
			
			[mapView sdc_pinWidthToWidthOfView:contentView];
			[mapView sdc_centerInSuperview];
			[mapView sdc_pinHeight:120];

			break;
		}
	}
}

- (void)updateProgressView:(NSTimer *)timer {
	UIProgressView *progressView = [timer userInfo];
	
	if (progressView.progress < 1)
		progressView.progress += .05;
	else
		[timer invalidate];
}

- (void)showSystemAlert {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.titleTextField.text
																   message:self.messageTextField.text
															preferredStyle:UIAlertControllerStyleAlert];
	
	NSInteger textFields = self.textFieldsTextField.text.integerValue;
	for (NSInteger i = 0; i < textFields; i++) {
		[alert addTextFieldWithConfigurationHandler:nil];
	}
	
	NSInteger buttons = self.buttonsTextField.text.integerValue;
	for (NSInteger i = 0; i < buttons; i++) {
		UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Button %@", @(i)]
															style:UIAlertActionStyleDefault
													   handler:nil];
		[alert addAction:action];
	}
	
	[self presentViewController:alert animated:YES completion:nil];
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
