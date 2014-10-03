//
//  SDCAlertRepresentationView.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/21/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

@import UIKit;

#import "SDCAlertController.h" // SDCAlertControllerButtonLayout

@class SDCAlertRepresentationView;
@class SDCAlertAction;
@class SDCAlertTextFieldViewController;

@protocol SDCAlertRepresentationViewDelegate <NSObject>
- (void)alertRepresentationView:(SDCAlertRepresentationView *)sender didPerformAction:(SDCAlertAction *)action;
@end

@protocol SDCAlertControllerVisualStyle;

@interface SDCAlertRepresentationView : UIView

@property (nonatomic, weak) id <SDCAlertRepresentationViewDelegate> delegate;

@property (nonatomic, copy) NSAttributedString *title;
@property (nonatomic, copy) NSAttributedString *message;

@property (nonatomic, copy) NSArray *actions;
@property (nonatomic) SDCAlertControllerButtonLayout buttonLayout;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) id<SDCAlertControllerVisualStyle> visualStyle;

- (instancetype)initWithTitle:(NSAttributedString *)title message:(NSAttributedString *)message;

- (void)showTextFieldViewController:(SDCAlertTextFieldViewController *)viewController;

@end
