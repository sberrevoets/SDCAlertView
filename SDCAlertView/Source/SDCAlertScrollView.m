//
//  SDCAlertScrollView.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/21/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertScrollView.h"

#import "SDCAlertTextFieldViewController.h"
#import "SDCAlertLabel.h"

#import "UIView+SDCAutoLayout.h"

@interface SDCAlertScrollView ()
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) SDCAlertLabel *titleLabel;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) SDCAlertLabel *messageLabel;
@end

@implementation SDCAlertScrollView

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message {
	self = [self init];
	
	if (self) {
		_titleLabel = [[SDCAlertLabel alloc] init];
		_messageLabel = [[SDCAlertLabel alloc] init];
		
		self.title = title;
		self.message = message;
		
		[self setTranslatesAutoresizingMaskIntoConstraints:NO];
	}
	
	return self;
}

- (void)setTitle:(NSString *)title {
	BOOL requiresViewHierarchyUpdate = (_title && !title) || (!_title && title);
	
	_title = title;
	_titleLabel.text = title;
	
	if (requiresViewHierarchyUpdate && self.superview) {
		[self setNeedsLayout];
	}
}

- (void)setMessage:(NSString *)message {
	BOOL requiresViewHierarchyUpdate = (_message && !message) || (!_message && message);
	
	_message = message;
	_messageLabel.text = message;
	
	if (requiresViewHierarchyUpdate && self.superview) {
		[self setNeedsLayout];
	}
}

- (void)setVisualStyle:(id<SDCAlertControllerVisualStyle>)visualStyle {
	_visualStyle = visualStyle;
	
	self.titleLabel.font = visualStyle.titleLabelFont;
	self.messageLabel.font = visualStyle.messageLabelFont;
	
	[self setNeedsLayout];
}

- (void)setTextFieldViewController:(SDCAlertTextFieldViewController *)textFieldViewController {
	[self addSubview:textFieldViewController.view];
	[textFieldViewController.view sdc_alignEdgesWithSuperview:UIRectEdgeAll];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	if (self.title.length > 0) {
		[self addSubview:self.titleLabel];
		[self.titleLabel sdc_alignEdgesWithSuperview:UIRectEdgeLeft|UIRectEdgeTop];
		[self.titleLabel sdc_pinWidthToWidthOfView:self offset:-(self.visualStyle.contentPadding.left + self.visualStyle.contentPadding.right)];
	} else {
		[self.titleLabel removeFromSuperview];
	}
	
	if (self.message.length > 0) {
		[self addSubview:self.messageLabel];
		[self.messageLabel sdc_alignEdgesWithSuperview:UIRectEdgeLeft];
		[self.messageLabel sdc_pinWidthToWidthOfView:self offset:-(self.visualStyle.contentPadding.left + self.visualStyle.contentPadding.right)];
		
		if (self.title.length > 0) {
			[self.messageLabel sdc_pinVerticalSpacing:self.visualStyle.labelSpacing toView:self.titleLabel];
		} else {
			[self.messageLabel sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:self inset:self.visualStyle.labelSpacing];
		}
	} else {
		[self.messageLabel removeFromSuperview];
	}
	
	[self invalidateIntrinsicContentSize];
}

- (CGSize)intrinsicContentSize {
	CGFloat intrinsicHeight = 0;
	
	if (self.message.length > 0) {
		intrinsicHeight = CGRectGetMaxY(self.messageLabel.frame);
	} else if (self.title.length > 0) {
		intrinsicHeight = CGRectGetMaxY(self.titleLabel.frame);
	}
	
	return CGSizeMake(UIViewNoIntrinsicMetric, intrinsicHeight);
}

@end
