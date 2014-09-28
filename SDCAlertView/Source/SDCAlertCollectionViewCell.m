//
//  SDCAlertCollectionViewCell.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/24/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertCollectionViewCell.h"

#import "UIView+SDCAutoLayout.h"

@interface SDCAlertCollectionViewCell ()
@property (nonatomic, strong) UIView *highlightedBackgroundView;
@end

@implementation SDCAlertCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		_textLabel = [[UILabel alloc] init];
		[_textLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
	}
	
	return self;
}

- (void)setVisualStyle:(id<SDCAlertControllerVisualStyle>)visualStyle {
	_visualStyle = visualStyle;
	
	self.highlightedBackgroundView = visualStyle.buttonHighlightBackgroundView;
	[self.highlightedBackgroundView setTranslatesAutoresizingMaskIntoConstraints:NO];
	self.highlightedBackgroundView.hidden = !self.isHighlighted;
}

- (void)setGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
	[self removeGestureRecognizer:_gestureRecognizer];
	
	_gestureRecognizer = gestureRecognizer;
	[self addGestureRecognizer:gestureRecognizer];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	[self.contentView addSubview:self.highlightedBackgroundView];
	[self.highlightedBackgroundView sdc_alignEdgesWithSuperview:UIRectEdgeAll];
	
	[self.contentView addSubview:self.textLabel];
	[self.textLabel sdc_centerInSuperview];
}

- (void)setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];
	self.highlightedBackgroundView.hidden = !highlighted;
}

@end

@implementation SDCAlertControllerSeparatorView

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		self.backgroundColor = [UIColor grayColor];
	}
	
	return self;
}

@end