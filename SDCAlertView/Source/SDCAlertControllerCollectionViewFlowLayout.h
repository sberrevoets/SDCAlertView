//
//  SDCAlertControllerCollectionViewFlowLayout.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/22/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

@import UIKit;

#import "SDCAlertControllerVisualStyle.h"

extern NSString *const SDCAlertControllerDecorationKindHorizontalSeparator;
extern NSString *const SDCAlertControllerDecorationKindVerticalSeparator;

@interface SDCAlertControllerCollectionViewFlowLayout : UICollectionViewFlowLayout
@property (nonatomic, strong) id<SDCAlertControllerVisualStyle> visualStyle;
@end
