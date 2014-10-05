//
//  SDCAlertTextFieldViewController.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/28/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

@import UIKit;

@protocol SDCAlertControllerVisualStyle;

@interface SDCAlertTextFieldViewController : UITableViewController

- (instancetype)initWithTextFields:(NSArray *)textFields visualStyle:(id<SDCAlertControllerVisualStyle>)visualStyle;

- (CGFloat)requiredHeightForDisplayingAllTextFields;

@end
