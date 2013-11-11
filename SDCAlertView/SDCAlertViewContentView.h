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
- (BOOL)alertContentViewShouldShowPrimaryTextField:(SDCAlertViewContentView *)sender;
- (BOOL)alertContentViewShouldUseSecureEntryForPrimaryTextField:(SDCAlertViewContentView *)sender;
- (BOOL)alertContentViewShouldShowSecondaryTextField:(SDCAlertViewContentView *)sender;

- (CGFloat)maximumHeightForAlertContentView:(SDCAlertViewContentView *)sender;

- (void)alertContentView:(SDCAlertViewContentView *)sender didTapButtonAtIndex:(NSUInteger)index;
- (void)alertContentViewDidTapCancelButton:(SDCAlertViewContentView *)sender;

- (BOOL)alertContentViewShouldEnableFirstOtherButton:(SDCAlertViewContentView *)sender;
@end

@protocol SDCAlertViewContentViewDataSource <NSObject>

- (NSString *)alertTitleInAlertContentView:(SDCAlertViewContentView *)sender;
- (NSString *)alertMessageInAlertContentView:(SDCAlertViewContentView *)sender;

- (NSString *)titleForCancelButtonInAlertContentView:(SDCAlertViewContentView *)sender;

- (NSUInteger)numberOfOtherButtonsInAlertContentView:(SDCAlertViewContentView *)sender;
- (NSString *)alertContentView:(SDCAlertViewContentView *)sender titleForButtonAtIndex:(NSUInteger)index;

@end

@interface SDCAlertViewContentView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id <SDCAlertViewContentViewDelegate> delegate;
@property (nonatomic, weak) id <SDCAlertViewContentViewDataSource> dataSource;

- (instancetype)initWithDelegate:(id <SDCAlertViewContentViewDelegate>)delegate dataSource:(id <SDCAlertViewContentViewDataSource>)dataSource;

@end
