//
//  SDCViewController.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/20/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

@import MapKit;

#import "SDCViewController.h"

#import "SDCAlertView.h"
#import "UIView+SDCAutoLayout.h"

@interface SDCViewController () <UITableViewDelegate>

@end

@implementation SDCViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		[[[UIAlertView alloc] initWithTitle:@"Title"
									message:@"This is a message"
								   delegate:nil
						  cancelButtonTitle:@"Cancel"
						  otherButtonTitles:@"OK", nil] show];
	} else if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			[[[SDCAlertView alloc] initWithTitle:@"Title"
										 message:@"This is a message"
										delegate:nil
							   cancelButtonTitle:@"Cancel"
							   otherButtonTitles:@"OK", nil] show];
		} else if (indexPath.row == 1) {
			[[[SDCAlertView alloc] initWithTitle:@"Title"
										 message:@"This is a message"
										delegate:nil
							   cancelButtonTitle:@"Cancel"
							   otherButtonTitles:@"OK", @"Whatever", nil] show];
		} else if (indexPath.row == 2) {
			SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:@"Title"
															  message:@"This is a message"
															 delegate:nil
													cancelButtonTitle:nil
													otherButtonTitles:@"OK", nil];
			alert.alertViewStyle = SDCAlertViewStylePlainTextInput;
			
			[alert show];
		} else if (indexPath.row == 3) {
			SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:@"Title"
															  message:@"This is a message"
															 delegate:nil
													cancelButtonTitle:nil
													otherButtonTitles:@"OK", nil];
			alert.alertViewStyle = SDCAlertViewStyleLoginAndPasswordInput;
			
			[alert show];
		}
	} else if (indexPath.section == 2) {
		if (indexPath.row == 0) {
			
			SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:@"Please wait..."
															  message:@"Please wait until we're done doing what we're doing"
															 delegate:nil
													cancelButtonTitle:nil
													otherButtonTitles:@"OK", nil];
			
			UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
			progressView.progress = 0;
			
			[NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(updateProgressView:) userInfo:progressView repeats:YES];
			
			[progressView setTranslatesAutoresizingMaskIntoConstraints:NO];
			[alert.contentView addSubview:progressView];
			
			[progressView sdc_pinWidthToWidthOfView:alert.contentView offset:-20];
			[progressView sdc_horizontallyCenterInSuperview];
			
			[alert.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[progressView]|"
																					  options:0
																					  metrics:nil
																						views:NSDictionaryOfVariableBindings(progressView)]];
			
			[alert show];			
		} else if (indexPath.row == 1) {
			SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:@"Contacting Server"
															  message:@"We're doing some network stuff. Hang on..."
															 delegate:nil
													cancelButtonTitle:@"OK"
													otherButtonTitles:nil];
			
			UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			[spinner setTranslatesAutoresizingMaskIntoConstraints:NO];
			[spinner startAnimating];
			[alert.contentView addSubview:spinner];
			
			[spinner sdc_horizontallyCenterInSuperview];
			
			[alert.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[spinner]|"
																					  options:0
																					  metrics:nil
																						views:NSDictionaryOfVariableBindings(spinner)]];
			[alert show];
		} else if (indexPath.row == 2) {
			SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:@"Cupertino, CA"
															  message:nil
															 delegate:nil
													cancelButtonTitle:@"OK"
													otherButtonTitles:nil];
			MKMapView *mapView = [[MKMapView alloc] init];
			[mapView setTranslatesAutoresizingMaskIntoConstraints:NO];
			
			MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.3175, -122.041944), MKCoordinateSpanMake(.1, .1));
			[mapView setRegion:region animated:YES];
			[alert.contentView addSubview:mapView];
			
			[mapView sdc_pinWidthToWidthOfView:alert.contentView];
			[mapView sdc_horizontallyCenterInSuperview];
			[mapView sdc_pinHeight:120];
			
			[alert.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mapView]|"
																					  options:0
																					  metrics:nil
																						views:NSDictionaryOfVariableBindings(mapView)]];
			
			[alert show];
		}
        
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)updateProgressView:(NSTimer *)timer {
	UIProgressView *progressView = [timer userInfo];
	
	if (progressView.progress < 1)
		progressView.progress += .05;
	else
		[timer invalidate];
}

@end
