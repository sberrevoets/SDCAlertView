//
//  SDCAlertCollectionViewCell.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/24/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertCollectionViewCell.h"

#import "SDCAlertController.h" // SDCAlertAction
#import "SDCAlertControllerVisualStyle.h"

#import "UIView+SDCAutoLayout.h"

@interface SDCAlertCollectionViewCell ()
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, getter=isEnabled) BOOL enabled;
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

- (void)setGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
	[self removeGestureRecognizer:_gestureRecognizer];
	
	_gestureRecognizer = gestureRecognizer;
	[self addGestureRecognizer:gestureRecognizer];
}

- (void)updateWithAction:(SDCAlertAction *)action visualStyle:(id<SDCAlertControllerVisualStyle>)visualStyle {
	if (action.attributedTitle) {
		self.textLabel.attributedText = action.attributedTitle;
	} else {
		self.textLabel.text = action.title;
	}
	
	self.enabled = action.isEnabled;
	
	self.textLabel.font = [visualStyle fontForButtonRepresentingAction:action];
	self.textLabel.textColor = [visualStyle textColorForButtonRepresentingAction:action];
	
	self.highlightedBackgroundView = visualStyle.buttonHighlightBackgroundView;
	[self.highlightedBackgroundView setTranslatesAutoresizingMaskIntoConstraints:NO];
	self.highlightedBackgroundView.hidden = !self.isHighlighted;
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

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
	[super applyLayoutAttributes:layoutAttributes];
	
	// By keeping this very generic, this class doesn't have to know about the class name of the custom layout attributes
	if ([layoutAttributes respondsToSelector:@selector(backgroundColor)]) {
		self.backgroundColor = [layoutAttributes performSelector:@selector(backgroundColor)];
	}
}

@end