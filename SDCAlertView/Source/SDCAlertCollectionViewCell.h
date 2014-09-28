//
//  SDCAlertCollectionViewCell.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/24/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SDCAlertControllerVisualStyle.h"

@interface SDCAlertControllerSeparatorView : UICollectionReusableView
@end


@interface SDCAlertCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) id<SDCAlertControllerVisualStyle> visualStyle;
@property (nonatomic, strong) UILabel *textLabel;
@end
