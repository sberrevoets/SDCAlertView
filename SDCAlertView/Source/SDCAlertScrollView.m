//
//  SDCAlertScrollView.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/21/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertScrollView.h"
#import "SDCAlertLabel.h"
#import "UIView+SDCAutoLayout.h"

static UIEdgeInsets const SDCAlertScrollViewInsets = {19, 15, 18.5, 15};
static CGFloat const SDCAlertScrollViewLabelSpacing = 4;

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
		
		self.contentInset = SDCAlertScrollViewInsets;
		self.scrollIndicatorInsets = SDCAlertScrollViewInsets;
		
		[self setTranslatesAutoresizingMaskIntoConstraints:NO];
	}
	
	return self;
}

- (void)setTitle:(NSString *)title {
	BOOL requiresViewHierarchyUpdate = (_title && !title) || (!_title && title);
	
	_title = title;
	_titleLabel.text = title;
	
	if (requiresViewHierarchyUpdate && self.superview) {
		[self updateViewHierarchy];
	}
}

- (void)setMessage:(NSString *)message {
	BOOL requiresViewHierarchyUpdate = (_message && !message) || (!_message && message);
	
	_message = message;
	_messageLabel.text = message;
	
	if (requiresViewHierarchyUpdate && self.superview) {
		[self updateViewHierarchy];
	}
}

- (void)prepareForDisplay {
	[self updateViewHierarchy];
}

- (void)updateViewHierarchy {
	if (self.title.length > 0) {
		[self addSubview:self.titleLabel];
		[self.titleLabel sdc_alignEdgesWithSuperview:UIRectEdgeLeft|UIRectEdgeTop];
		[self.titleLabel sdc_pinWidthToWidthOfView:self offset:-(SDCAlertScrollViewInsets.left + SDCAlertScrollViewInsets.right)];
	} else {
		[self.titleLabel removeFromSuperview];
	}
	
	if (self.message.length > 0) {
		[self addSubview:self.messageLabel];
		[self.messageLabel sdc_alignEdgesWithSuperview:UIRectEdgeLeft];
		[self.messageLabel sdc_pinWidthToWidthOfView:self offset:-(SDCAlertScrollViewInsets.left + SDCAlertScrollViewInsets.right)];
		
		if (self.title.length > 0) {
			[self.messageLabel sdc_pinVerticalSpacing:SDCAlertScrollViewLabelSpacing toView:self.titleLabel];
		} else {
			[self.messageLabel sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:self inset:SDCAlertScrollViewLabelSpacing];
		}
	} else {
		[self.messageLabel removeFromSuperview];
	}
}


@end
