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
		[self addSubview:_titleLabel];
		
		_messageLabel = [[SDCAlertLabel alloc] init];
		[self addSubview:_messageLabel];
		
		self.title = title;
		self.message = message;
		
		[self setTranslatesAutoresizingMaskIntoConstraints:NO];
	}
	
	return self;
}

- (void)setTitle:(NSString *)title {
	_title = title;
	_titleLabel.text = title;
}

- (void)setMessage:(NSString *)message {
	_message = message;
	_messageLabel.text = message;
}

- (void)setVisualStyle:(id<SDCAlertControllerVisualStyle>)visualStyle {
	_visualStyle = visualStyle;
	
	self.titleLabel.font = visualStyle.titleLabelFont;
	self.messageLabel.font = visualStyle.messageLabelFont;
	
	[self setNeedsLayout];
}

- (void)setTextFieldViewController:(SDCAlertTextFieldViewController *)textFieldViewController {
	_textFieldViewController = textFieldViewController;
	
	[textFieldViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self addSubview:textFieldViewController.view];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	[self.titleLabel sdc_alignEdgesWithSuperview:UIRectEdgeLeft insets:self.visualStyle.contentPadding];
	[self.titleLabel sdc_pinWidthToWidthOfView:self offset:-(self.visualStyle.contentPadding.left + self.visualStyle.contentPadding.right)];
	
	[self.messageLabel sdc_alignEdges:UIRectEdgeLeft|UIRectEdgeRight withView:self.titleLabel];
	
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeFirstBaseline relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:self.visualStyle.contentPadding.top]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel attribute:NSLayoutAttributeLastBaseline relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeFirstBaseline multiplier:1 constant:self.visualStyle.labelSpacing]];
	
	if (self.textFieldViewController) {
		[self.textFieldViewController.view sdc_alignEdges:UIRectEdgeLeft|UIRectEdgeRight withView:self.titleLabel];
		[self.textFieldViewController.view sdc_pinHeight:25 + self.visualStyle.contentPadding.bottom];
		[self addConstraint:[NSLayoutConstraint constraintWithItem:self.textFieldViewController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.messageLabel attribute:NSLayoutAttributeLastBaseline multiplier:1 constant:self.visualStyle.textFieldsTopSpacing]];
	}
	
	[self invalidateIntrinsicContentSize];
}

- (CGSize)intrinsicContentSize {
	UIView *lastView = (self.textFieldViewController) ? self.textFieldViewController.view : self.messageLabel;
	CGFloat intrinsicHeight = CGRectGetMaxY(lastView.frame);
	
	return CGSizeMake(UIViewNoIntrinsicMetric, intrinsicHeight);
}

@end
