//
//  SDCAlertRepresentationView.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/21/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertRepresentationView.h"

#import "SDCAlertController.h"
#import "SDCAlertScrollView.h"
#import "SDCAlertControllerCollectionViewFlowLayout.h"
#import "SDCAlertCollectionViewCell.h"

#import "UIView+SDCAutoLayout.h"

static NSString *const SDCAlertControllerCellReuseIdentifier = @"SDCAlertControllerCellReuseIdentifier";

@interface SDCAlertRepresentationView () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
@property (nonatomic, strong) SDCAlertScrollView *scrollView;
@property (nonatomic, strong) UICollectionView *buttonCollectionView;
@property (nonatomic, strong) SDCAlertControllerCollectionViewFlowLayout *collectionViewLayout;
@end

@implementation SDCAlertRepresentationView

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message {
	self = [self init];
	
	if (self) {
		_scrollView = [[SDCAlertScrollView alloc] initWithTitle:title message:message];
		
		_collectionViewLayout = [[SDCAlertControllerCollectionViewFlowLayout alloc] init];
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

- (void)willMoveToSuperview:(UIView *)newSuperview {
	if (!newSuperview) {
		return;
	}
	
	[self addSubview:self.scrollView];
	[self.scrollView sdc_alignEdgesWithSuperview:UIRectEdgeAll];
	
	[self addSubview:self.buttonCollectionView];
	[self.buttonCollectionView sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeBottom ofView:self.scrollView];
	[self.buttonCollectionView sdc_alignEdgesWithSuperview:UIRectEdgeLeft|UIRectEdgeRight];
	[self.buttonCollectionView sdc_pinHeight:44];
	
	[self.scrollView prepareForDisplay];
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return self.actions.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	SDCAlertCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SDCAlertControllerCellReuseIdentifier
																				 forIndexPath:indexPath];
	
	SDCAlertAction *action = self.actions[indexPath.item];
	cell.textLabel.text = action.title;
	
	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
				  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	return CGSizeMake(270, 44);
}




@end
