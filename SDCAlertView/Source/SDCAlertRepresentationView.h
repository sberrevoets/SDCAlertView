//
//  SDCAlertRepresentationView.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/21/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

@import UIKit;

@class SDCAlertRepresentationView;
@class SDCAlertAction;

@protocol SDCAlertRepresentationViewDelegate <NSObject>
- (void)alertRepresentationView:(SDCAlertRepresentationView *)sender didPerformAction:(SDCAlertAction *)action;
@end

@protocol SDCAlertControllerVisualStyle;

@interface SDCAlertRepresentationView : UIView

@property (nonatomic, weak) id <SDCAlertRepresentationViewDelegate> delegate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;

@property (nonatomic, copy) NSArray *actions;

@property (nonatomic, strong) id<SDCAlertControllerVisualStyle> visualStyle;

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message;

@end
