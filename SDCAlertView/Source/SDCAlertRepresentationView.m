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
		[_collectionViewLayout registerClass:[SDCAlertControllerSeparatorView class] forDecorationViewOfKind:SDCAlertControllerDecorationKindHorizontalSeparator];
		[_collectionViewLayout registerClass:[SDCAlertControllerSeparatorView class] forDecorationViewOfKind:SDCAlertControllerDecorationKindVerticalSeparator];
		
		_buttonCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_collectionViewLayout];
		[_buttonCollectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
		[_buttonCollectionView registerClass:[SDCAlertCollectionViewCell class] forCellWithReuseIdentifier:SDCAlertControllerCellReuseIdentifier];
		
		_buttonCollectionView.delegate = self;
		_buttonCollectionView.dataSource = self;
		_buttonCollectionView.backgroundColor = [UIColor clearColor];
		
		[self setTranslatesAutoresizingMaskIntoConstraints:NO];
	}
	
	return self;
}

- (void)setButtonLayout:(SDCAlertControllerButtonLayout)buttonLayout {
	_buttonLayout = buttonLayout;
	
	UICollectionViewScrollDirection direction = UICollectionViewScrollDirectionHorizontal;
	
	if (buttonLayout == SDCAlertControllerButtonLayoutVertical || (buttonLayout == SDCAlertControllerButtonLayoutAutomatic && self.actions.count != 2)) {
		direction = UICollectionViewScrollDirectionVertical;
	}
	
	self.collectionViewLayout.scrollDirection = direction;
}

- (void)showTextFieldViewController:(SDCAlertTextFieldViewController *)viewController {
	self.scrollView.textFieldViewController = viewController;
}

- (CGFloat)maximumHeightForScrollView {
	CGFloat maximumHeight = CGRectGetHeight(self.superview.bounds) - self.visualStyle.margins.top - self.visualStyle.margins.bottom;
	maximumHeight -= self.visualStyle.contentPadding.top - self.visualStyle.contentPadding.bottom;
	
	if (self.actions.count > 0) {
		if (self.collectionViewLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
			maximumHeight -= self.visualStyle.buttonHeight;
		} else {
			maximumHeight -= self.visualStyle.buttonHeight * [self.buttonCollectionView numberOfItemsInSection:0];
		}
	}
	
	return maximumHeight;
}

- (CGFloat)heightForButtonCollectionView {
	CGFloat horizontalLayoutHeight = self.visualStyle.buttonHeight;
	CGFloat verticalLayoutHeight = self.visualStyle.buttonHeight * [self.buttonCollectionView numberOfItemsInSection:0];
	
	switch (self.buttonLayout) {
		case SDCAlertControllerButtonLayoutAutomatic:		return (self.actions.count == 2) ? horizontalLayoutHeight : verticalLayoutHeight;
		case SDCAlertControllerButtonLayoutHorizontal:		return horizontalLayoutHeight;
		case SDCAlertControllerButtonLayoutVertical:		return verticalLayoutHeight;
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	[self applyCurrentStyleToAlertElements];
	
	[self.visualEffectView sdc_pinWidth:self.visualStyle.width];
	
	[self.visualEffectView.contentView addSubview:self.scrollView];
	[self.scrollView setNeedsLayout];
	[self.scrollView layoutIfNeeded];
	
	[self.scrollView sdc_alignEdgesWithSuperview:UIRectEdgeLeft|UIRectEdgeTop|UIRectEdgeRight insets:self.visualStyle.contentPadding];
	[self.scrollView sdc_setMaximumHeight:[self maximumHeightForScrollView]];
	self.scrollView.contentSize = CGSizeMake(self.visualStyle.width - self.visualStyle.contentPadding.left + self.visualStyle.contentPadding.right, [self.scrollView intrinsicContentSize].height);
	
	[self.visualEffectView.contentView addSubview:self.buttonCollectionView];
	[self.buttonCollectionView sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeBottom ofView:self.scrollView inset:self.visualStyle.contentPadding.top];
	[self.buttonCollectionView sdc_alignEdgesWithSuperview:UIRectEdgeLeft|UIRectEdgeBottom|UIRectEdgeRight];
	[self.buttonCollectionView sdc_pinHeight:[self heightForButtonCollectionView]];
	
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
	if (self.collectionViewLayout.scrollDirection == UICollectionViewScrollDirectionVertical) {
		return CGSizeMake(CGRectGetWidth(self.bounds), self.visualStyle.buttonHeight);
	} else {
		CGFloat width = MAX(CGRectGetWidth(self.bounds) / self.actions.count, self.visualStyle.minimumButtonWidth);
		return CGSizeMake(width, self.visualStyle.buttonHeight);
	}
}

@end
