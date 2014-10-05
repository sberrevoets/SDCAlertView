//
//  SDCAlertControllerTextFieldViewController.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/28/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

@import UIKit;

@protocol SDCAlertControllerVisualStyle;

@interface SDCAlertControllerTextFieldViewController : UITableViewController

- (instancetype)initWithTextFields:(NSArray *)textFields visualStyle:(id<SDCAlertControllerVisualStyle>)visualStyle;

@property (nonatomic, readonly) CGFloat requiredHeightForDisplayingAllTextFields;

@end
