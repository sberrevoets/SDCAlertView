//
//  SDCAlertViewContentView.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 11/5/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SDCAlertView.h" // Required for SDCAlertViewStyle

@class SDCAlertViewContentView;

@protocol SDCAlertViewContentViewDelegate <NSObject>
- (void)alertContentView:(SDCAlertViewContentView *)sender didTapButtonAtIndex:(NSUInteger)index;
- (BOOL)alertContentView:(SDCAlertViewContentView *)sender shouldDeselectButtonAtIndex:(NSUInteger)index;
@end

@interface SDCAlertViewContentView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;

@property (nonatomic, readonly) NSArray *textFields;
@property (nonatomic, strong) UIView *customContentView;

@property (nonatomic, readonly) NSInteger numberOfButtons;
@property (nonatomic) NSInteger cancelButtonIndex;
@property (nonatomic, copy) NSString *cancelButtonTitle;
@property (nonatomic, readonly) NSInteger firstOtherButtonIndex;
@property (nonatomic, getter = isFirstOtherButtonEnabled) BOOL firstOtherButtonEnabled;

@property (nonatomic) CGSize maximumSize;

@property (nonatomic, weak) id <SDCAlertViewContentViewDelegate> delegate;

- (instancetype)initWithDelegate:(id <SDCAlertViewContentViewDelegate>)delegate;

- (void)updateContentForStyle:(SDCAlertViewStyle)style;
- (void)prepareForShowing;

- (NSInteger)addButtonWithTitle:(NSString *)buttonTitle;
- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;

/*
 * Appearance properties
 */

@property (nonatomic, strong) UIFont *titleLabelFont;
@property (nonatomic, strong) UIColor *titleLabelTextColor;
@property (nonatomic, strong) UIFont *messageLabelFont;
@property (nonatomic, strong) UIColor *messageLabelTextColor;
@property (nonatomic, strong) UIFont *textFieldFont;
@property (nonatomic, strong) UIColor *textFieldTextColor;
@property (nonatomic, strong) UIFont *suggestedButtonFont;
@property (nonatomic, strong) UIFont *normalButtonFont;
@property (nonatomic, strong) UIColor *buttonTextColor;

@end