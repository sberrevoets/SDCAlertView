//
//  SDCAlertCollectionViewCell.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/24/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

@import UIKit;

@class SDCAlertAction;
@protocol SDCAlertControllerVisualStyle;

@interface SDCAlertControllerSeparatorView : UICollectionReusableView
@end


@interface SDCAlertCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIGestureRecognizer *gestureRecognizer;
@property (nonatomic, getter=isEnabled) BOOL enabled;

- (void)updateWithAction:(SDCAlertAction *)action visualStyle:(id<SDCAlertControllerVisualStyle>)visualStyle;

@end
