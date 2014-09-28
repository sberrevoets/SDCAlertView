//
//  SDCAlertRepresentationView.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/21/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertRepresentationView.h"

#import "SDCAlertController.h"
#import "SDCAlertViewBackgroundView.h"
#import "SDCAlertScrollView.h"
#import "SDCAlertControllerCollectionViewFlowLayout.h"
#import "SDCAlertCollectionViewCell.h"

#import "UIView+SDCAutoLayout.h"

static NSString *const SDCAlertControllerCellReuseIdentifier = @"SDCAlertControllerCellReuseIdentifier";

@interface SDCAlertRepresentationView () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
@property (nonatomic, strong) UIVisualEffectView *visualEffectView;
@property (nonatomic, strong) SDCAlertScrollView *scrollView;
@property (nonatomic, strong) UICollectionView *buttonCollectionView;
@property (nonatomic, strong) SDCAlertControllerCollectionViewFlowLayout *collectionViewLayout;
@end

@implementation SDCAlertRepresentationView

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message {
	self = [self init];
	
	if (self) {
		UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
		_visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
		_visualEffectView.layer.masksToBounds = YES;
		_visualEffectView.layer.cornerRadius = 5;
		[_visualEffectView setTranslatesAutoresizingMaskIntoConstraints:NO];
		
		_scrollView = [[SDCAlertScrollView alloc] initWithTitle:title message:message];
		
		_collectionViewLayout = [[SDCAlertControllerCollectionViewFlowLayout alloc] init];
		_buttonCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_collectionViewLayout];
		[_buttonCollectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
		
		[_buttonCollectionView registerClass:[SDCAlertCollectionViewCell class] forCellWithReuseIdentifier:SDCAlertControllerCellReuseIdentifier];
		[_buttonCollectionView.collectionViewLayout registerClass:[SDCAlertControllerSeparatorView class] forDecorationViewOfKind:@"separator"];
		
		_buttonCollectionView.delegate = self;
		_buttonCollectionView.dataSource = self;
		_buttonCollectionView.backgroundColor = [UIColor clearColor];
		
		[self setTranslatesAutoresizingMaskIntoConstraints:NO];
	}
	
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	[self applyCurrentStyleToAlertElements];
	
	[self.visualEffectView sdc_pinSize:CGSizeMake(self.visualStyle.width, 120)];
	
	[self.visualEffectView.contentView addSubview:self.scrollView];
	[self.scrollView setNeedsLayout];
	[self.scrollView layoutIfNeeded];
	
	[self.scrollView sdc_alignEdgesWithSuperview:UIRectEdgeLeft|UIRectEdgeTop|UIRectEdgeRight];
	[self.scrollView sdc_setMaximumHeight:76];
	
	[self.visualEffectView.contentView addSubview:self.buttonCollectionView];
	[self.buttonCollectionView sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeBottom ofView:self.scrollView];
	[self.buttonCollectionView sdc_alignEdgesWithSuperview:UIRectEdgeLeft|UIRectEdgeRight];
	[self.buttonCollectionView sdc_pinHeight:self.visualStyle.buttonHeight];
	
	[self addSubview:self.visualEffectView];
	[self.visualEffectView sdc_alignEdgesWithSuperview:UIRectEdgeAll];
}

- (void)applyCurrentStyleToAlertElements {
	self.scrollView.visualStyle = self.visualStyle;
	self.collectionViewLayout.visualStyle = self.visualStyle;
}

- (void)actionButtonTapped:(UITapGestureRecognizer *)sender {
	SDCAlertCollectionViewCell *cell = (SDCAlertCollectionViewCell *)sender.view;
	NSIndexPath *indexPath = [self.buttonCollectionView indexPathForCell:cell];
	SDCAlertAction *action = self.actions[indexPath.row];
	
	[self.delegate alertRepresentationView:self didPerformAction:action];
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return self.actions.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	SDCAlertCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SDCAlertControllerCellReuseIdentifier
																				 forIndexPath:indexPath];
	
	SDCAlertAction *action = self.actions[indexPath.item];
	cell.visualStyle = self.visualStyle;
	cell.textLabel.font = [self.visualStyle fontForButtonRepresentingAction:action];
	cell.textLabel.text = action.title;
	cell.textLabel.textColor = [self.visualStyle textColorForButtonRepresentingAction:action];
	cell.textLabel.enabled = action.isEnabled;
	
	cell.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionButtonTapped:)];
	
	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	return CGSizeMake(CGRectGetWidth(self.bounds) / self.actions.count, CGRectGetHeight(collectionView.bounds));
}

@end
