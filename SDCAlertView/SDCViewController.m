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

#import "SDCAlertController.h"
#import "SDCAlertTransition.h"

@interface SDCViewController () <UITableViewDelegate, UIAlertViewDelegate, SDCAlertViewDelegate>
@end

@implementation SDCViewController

- (void)presentNow {

	
	UIAlertController *b = [UIAlertController alertControllerWithTitle:@"Title 2" message:@"Message 2" preferredStyle:UIAlertControllerStyleAlert];
	[b addAction:[UIAlertAction actionWithTitle:@"Button 2" style:UIAlertActionStyleDefault handler:nil]];
	[b addAction:[UIAlertAction actionWithTitle:@"Button 33??" style:UIAlertActionStyleCancel handler:nil]];
	[self presentViewController:b animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		SDCAlertController *ac = [SDCAlertController alertControllerWithTitle:@"Title" message:@"Message" preferredStyle:SDCAlertControllerStyleAlert];
		ac.buttonLayout = SDCAlertControllerButtonLayoutHorizontal;
		[ac addAction:[SDCAlertAction actionWithTitle:@"Cancel" style:SDCAlertActionStyleDestructive handler:nil]];
		[ac addAction:[SDCAlertAction actionWithTitle:@"OK" style:SDCAlertActionStyleCancel handler:^(SDCAlertAction *action) {
			NSLog(@"%@", action.title);
		}]];
		[ac addAction:[SDCAlertAction actionWithTitle:@"Third" style:SDCAlertActionStyleDefault handler:nil]];
		[self presentViewController:ac animated:YES completion:nil];
//		[self presentNow];
		
		} else if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			SDCAlertView *a = [[SDCAlertView alloc] initWithTitle:@"Title"
														  message:@"This is a message"
														 delegate:self
												cancelButtonTitle:@"Cancel"
												otherButtonTitles:@"OK", nil];
			[a show];
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
			
			[spinner sdc_centerInSuperview];
			
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
			[mapView sdc_centerInSuperview];
			[mapView sdc_pinHeight:120];
			
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

- (IBAction)changeAppearance:(UISegmentedControl *)sender {
	if (sender.selectedSegmentIndex == 0) {
		[[SDCAlertView appearance] setTitleLabelFont:[UIFont boldSystemFontOfSize:17]];
		[[SDCAlertView appearance] setMessageLabelFont:[UIFont systemFontOfSize:14]];
		[[SDCAlertView appearance] setTextFieldFont:[UIFont systemFontOfSize:13]];
		[[SDCAlertView appearance] setSuggestedButtonFont:[UIFont boldSystemFontOfSize:17]];
		[[SDCAlertView appearance] setNormalButtonFont:[UIFont systemFontOfSize:17]];
		[[SDCAlertView appearance] setButtonTextColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1]];
		[[SDCAlertView appearance] setTextFieldTextColor:[UIColor blackColor]];
		[[SDCAlertView appearance] setTitleLabelTextColor:[UIColor blackColor]];
		[[SDCAlertView appearance] setMessageLabelTextColor:[UIColor blackColor]];
	}
	else {
		[[SDCAlertView appearance] setTitleLabelFont:[UIFont boldSystemFontOfSize:22]];
		[[SDCAlertView appearance] setMessageLabelFont:[UIFont italicSystemFontOfSize:14]];
		[[SDCAlertView appearance] setNormalButtonFont:[UIFont boldSystemFontOfSize:12]];
		[[SDCAlertView appearance] setSuggestedButtonFont:[UIFont italicSystemFontOfSize:12]];
		[[SDCAlertView appearance] setTextFieldFont:[UIFont italicSystemFontOfSize:12]];
		[[SDCAlertView appearance] setButtonTextColor:[UIColor grayColor]];
		[[SDCAlertView appearance] setTextFieldTextColor:[UIColor purpleColor]];
		[[SDCAlertView appearance] setTitleLabelTextColor:[UIColor greenColor]];
		[[SDCAlertView appearance] setMessageLabelTextColor:[UIColor yellowColor]];
		
	}
}

@end
