//
//  SDCAlertTextFieldTableViewCell.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/28/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

@import UIKit;

@protocol SDCAlertControllerVisualStyle;

@interface SDCAlertTextFieldTableViewCell : UITableViewCell

@property (nonatomic, strong) id<SDCAlertControllerVisualStyle> visualStyle; // Apply a visual style before setting the text field
@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, readonly) CGFloat requiredHeight;

@end
