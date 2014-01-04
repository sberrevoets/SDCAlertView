//
//  SDCAlertViewContentView.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 11/5/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDCAlertViewContentView;

@protocol SDCAlertViewContentViewDelegate <NSObject>
- (BOOL)alertContentViewShouldUseSecureEntryForPrimaryTextField:(SDCAlertViewContentView *)sender;

- (CGFloat)maximumHeightForAlertContentView:(SDCAlertViewContentView *)sender;

- (void)alertContentView:(SDCAlertViewContentView *)sender didTapButtonAtIndex:(NSUInteger)index;
- (BOOL)alertContentView:(SDCAlertViewContentView *)sender shouldEnableButtonAtIndex:(NSUInteger)index;
- (BOOL)alertContentView:(SDCAlertViewContentView *)sender shouldDeselectButtonAtIndex:(NSUInteger)index;
@end

@interface SDCAlertViewContentView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;

@property (nonatomic) NSInteger numberOfTextFields;
@property (nonatomic, readonly) NSArray *textFields;
@property (nonatomic, strong) UIView *customContentView;

@property (nonatomic, copy) NSArray *buttonTitles; // The last button title is always the "suggested" button

@property (nonatomic, weak) id <SDCAlertViewContentViewDelegate> delegate;

- (instancetype)initWithDelegate:(id <SDCAlertViewContentViewDelegate>)delegate;

@end
