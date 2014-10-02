//
//  SDCAlertTextFieldViewController.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/28/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

@import UIKit;

@interface SDCAlertTextFieldViewController : UITableViewController

@property (nonatomic, strong) NSArray *textFields;

- (CGFloat)requiredHeightForDisplayingAllTextFields;

@end
