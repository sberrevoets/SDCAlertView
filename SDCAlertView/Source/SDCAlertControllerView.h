//
//  SDCAlertControllerView.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/21/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

@import UIKit;

#import "SDCAlertController.h" // SDCAlertControllerActionLayout

@class SDCAlertControllerView;
@class SDCAlertAction;
@class SDCAlertControllerTextFieldViewController;

@protocol SDCAlertControllerViewDelegate <NSObject>
- (void)alertControllerView:(SDCAlertControllerView *)sender didPerformAction:(SDCAlertAction *)action;
@end

@protocol SDCAlertControllerVisualStyle;

@interface SDCAlertControllerView : UIView

@property (nonatomic, weak) id <SDCAlertControllerViewDelegate> delegate;

@property (nonatomic, copy) NSAttributedString *title;
@property (nonatomic, copy) NSAttributedString *message;

@property (nonatomic, copy) NSArray *actions;
@property (nonatomic) SDCAlertControllerActionLayout actionLayout;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) id<SDCAlertControllerVisualStyle> visualStyle;

- (instancetype)initWithTitle:(NSAttributedString *)title message:(NSAttributedString *)message;

- (void)showTextFieldViewController:(SDCAlertControllerTextFieldViewController *)viewController;
- (void)prepareForDisplay;
@end
