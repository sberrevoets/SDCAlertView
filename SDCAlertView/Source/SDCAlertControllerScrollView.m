//
//  SDCAlertControllerScrollView.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/21/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertControllerScrollView.h"

#import "SDCAlertControllerTextFieldViewController.h"
#import "SDCAlertLabel.h"

#import "UIView+SDCAutoLayout.h"

@interface SDCAlertControllerScrollView ()
@property (nonatomic, strong) SDCAlertLabel *titleLabel;
@property (nonatomic, strong) SDCAlertLabel *messageLabel;
@end

@implementation SDCAlertControllerScrollView

- (instancetype)initWithTitle:(NSAttributedString *)title message:(NSAttributedString *)message {
	self = [self init];
	
	if (self) {
		_titleLabel = [[SDCAlertLabel alloc] init];
		_titleLabel.attributedText = title;
		[self addSubview:_titleLabel];
		
		_messageLabel = [[SDCAlertLabel alloc] init];
		_messageLabel.attributedText = message;
		[self addSubview:_messageLabel];
		
		[self setTranslatesAutoresizingMaskIntoConstraints:NO];
	}
	
	return self;
}

- (NSAttributedString *)title {
	return self.titleLabel.attributedText;
}

- (void)setTitle:(NSAttributedString *)title {
	self.titleLabel.attributedText = title;
}

- (NSAttributedString *)message {
	return self.messageLabel.attributedText;
}

- (void)setMessage:(NSAttributedString *)message {
	self.messageLabel.attributedText = message;
}

- (void)setVisualStyle:(id<SDCAlertControllerVisualStyle>)visualStyle {
	_visualStyle = visualStyle;
	
	self.titleLabel.font = visualStyle.titleLabelFont;
	self.messageLabel.font = visualStyle.messageLabelFont;
	self.messageLabel.textAlignment = visualStyle.messageTextAlignment;
	
	self.titleLabel.textColor = visualStyle.titleLabelColor;
	self.messageLabel.textColor = visualStyle.messageLabelColor;
	
	[self setNeedsLayout];
}

- (void)setTextFieldViewController:(SDCAlertControllerTextFieldViewController *)textFieldViewController {
	_textFieldViewController = textFieldViewController;
	
	[textFieldViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self addSubview:textFieldViewController.view];
}

#pragma mark - Layout

- (void)finalizeElements {
	[self.titleLabel sdc_alignEdgesWithSuperview:UIRectEdgeLeft insets:self.visualStyle.contentPadding];
	[self.titleLabel sdc_pinWidthToWidthOfView:self offset:-(self.visualStyle.contentPadding.left + self.visualStyle.contentPadding.right)];
	
	[self.messageLabel sdc_alignEdges:UIRectEdgeLeft|UIRectEdgeRight withView:self.titleLabel];
	
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
													 attribute:NSLayoutAttributeFirstBaseline
													 relatedBy:NSLayoutRelationEqual
														toItem:self
													 attribute:NSLayoutAttributeTop
													multiplier:1
													  constant:self.visualStyle.contentPadding.top]];
	
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
													 attribute:NSLayoutAttributeFirstBaseline
													 relatedBy:NSLayoutRelationEqual
														toItem:self.titleLabel
													 attribute:NSLayoutAttributeLastBaseline
													multiplier:1
													  constant:self.visualStyle.labelSpacing]];
	
	if (self.textFieldViewController) {
		[self.textFieldViewController.view sdc_alignEdges:UIRectEdgeLeft|UIRectEdgeRight withView:self.titleLabel];
		
		CGFloat height = self.textFieldViewController.requiredHeightForDisplayingAllTextFields + self.visualStyle.contentPadding.bottom;
		[self.textFieldViewController.view sdc_pinHeight:height];
		
		[self addConstraint:[NSLayoutConstraint constraintWithItem:self.textFieldViewController.view
														 attribute:NSLayoutAttributeTop
														 relatedBy:NSLayoutRelationEqual
															toItem:self.messageLabel
														 attribute:NSLayoutAttributeLastBaseline
														multiplier:1
														  constant:self.visualStyle.messageLabelBottomSpacing]];
	}
	
	[self setNeedsLayout];
	[self layoutIfNeeded];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	[self invalidateIntrinsicContentSize];
}

- (void)invalidateIntrinsicContentSize {
	[super invalidateIntrinsicContentSize];

	// -needsUpdateConstraints returns YES after -invalidateIntrinsicContentSize. On some versions of iOS 8,
	// this leads to an infinite loop if we don't call -updateConstraintsIfNeeded.
	[self updateConstraintsIfNeeded];

	self.contentSize = CGSizeMake(self.contentSize.width, [self intrinsicContentSize].height);
}

- (CGSize)intrinsicContentSize {
	CGFloat intrinsicHeight = 0;
	if (self.textFieldViewController) {
		intrinsicHeight = CGRectGetMaxY(self.textFieldViewController.view.frame);
	} else {
		intrinsicHeight = CGRectGetMaxY(self.messageLabel.frame) + self.visualStyle.messageLabelBottomSpacing; // Not perfect, as padding it added from the bottom of the label, not its baseline
	}
	
	return CGSizeMake(UIViewNoIntrinsicMetric, intrinsicHeight);
}

@end
