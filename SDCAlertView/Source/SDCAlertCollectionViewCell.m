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
@property (nonatomic, strong) UIView *highlightedBackgroundView;
@end

@implementation SDCAlertCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		_textLabel = [[UILabel alloc] init];
		[_textLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
		self.isAccessibilityElement = YES;
	}
	
	return self;
}

- (void)setGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
	[self removeGestureRecognizer:_gestureRecognizer];
	
	_gestureRecognizer = gestureRecognizer;
	gestureRecognizer.enabled = self.isEnabled;
	[self addGestureRecognizer:gestureRecognizer];
}

- (void)setEnabled:(BOOL)enabled {
	_enabled = enabled;
	
	self.highlightedBackgroundView.hidden = YES; // Still hide when enabling
	self.textLabel.enabled = enabled;
	self.gestureRecognizer.enabled = enabled;
}

- (void)setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];
	
	if (self.isEnabled) {
		self.highlightedBackgroundView.hidden = !highlighted;
	}
}

#pragma mark - User Interface

- (void)tintColorDidChange {
	self.textLabel.textColor = self.tintColor;
}

- (void)updateWithAction:(SDCAlertAction *)action visualStyle:(id<SDCAlertControllerVisualStyle>)visualStyle {
	self.textLabel.font = [visualStyle fontForAction:action];
	self.textLabel.textColor = [visualStyle textColorForAction:action];
	
	if (action.attributedTitle) {
		self.textLabel.attributedText = action.attributedTitle;
		self.accessibilityLabel = [action.attributedTitle string];
	} else {
		self.textLabel.text = action.title;
		self.accessibilityLabel = action.title;
	}
	
	self.enabled = action.isEnabled;
	
	self.highlightedBackgroundView = visualStyle.actionViewHighlightBackgroundView;
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