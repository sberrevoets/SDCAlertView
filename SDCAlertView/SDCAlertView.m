//
//  SDCAlertView.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/20/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertView.h"

@interface SDCAlertView ()
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;

@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@end

@implementation SDCAlertView

- (UILabel *)titleLabel {
	if (!_titleLabel) {
		_titleLabel = ({
			UILabel *label = [[UILabel alloc] init];
			[label setTranslatesAutoresizingMaskIntoConstraints:NO];
			label.backgroundColor = [UIColor greenColor];
			label.text = self.title;
			label.font = [UIFont boldSystemFontOfSize:17];
			label.textAlignment = NSTextAlignmentCenter;
			label;
		});
	}
	
	return _titleLabel;
}

- (UILabel *)messageLabel {
	if (!_messageLabel) {
		_messageLabel = ({
			UILabel *label = [[UILabel alloc] init];
			[label setTranslatesAutoresizingMaskIntoConstraints:NO];
			label.backgroundColor = [UIColor redColor];
			label.text = self.message;
			label.font = [UIFont systemFontOfSize:14];
			label.textAlignment = NSTextAlignmentCenter;
			label;
		});
	}
	
	return _messageLabel;
}

- (instancetype)initWithTitle:(NSString *)title
					  message:(NSString *)message
					 delegate:(id)delegate
			cancelButtonTitle:(NSString *)cancelButtonTitle
			otherButtonTitles:(NSString *)otherButtonTitles {
	self = [super init];
	
	if (self) {
		[self setTranslatesAutoresizingMaskIntoConstraints:NO];
		self.backgroundColor = [UIColor lightGrayColor];
		_title = title;
		_message = message;
	}
	
	return self;
}

- (void)show {
	self.contentScrollView = [[UIScrollView alloc] init];
	[self.contentScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self.contentScrollView addSubview:self.titleLabel];
	[self.contentScrollView addSubview:self.messageLabel];
	
	[self addSubview:self.contentScrollView];
	
	[self updateConstraints];
	
	[[[UIApplication sharedApplication] keyWindow] addSubview:self];
}

- (void)updateConstraints {
	[super updateConstraints];
	
	[self positionSelf];
	[self positionContentScrollView];
	[self positionLabels];
}

- (void)positionSelf {
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:270]];
	[self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	[self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

- (void)positionContentScrollView {
	[self.contentScrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentScrollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeHeight multiplier:1 constant:66-21]];
	
	NSDictionary *scrollViewMapping = @{@"scrollView": self.contentScrollView};
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[scrollView]|" options:0 metrics:nil views:scrollViewMapping]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:0 metrics:nil views:scrollViewMapping]];
}

- (void)positionLabels {
	[self addConstraint:
	 [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:-30]];
	[self addConstraint:
	 [NSLayoutConstraint constraintWithItem:self.messageLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:-30]];
	
	NSDictionary *mapping = @{@"titleLabel": self.titleLabel, @"messageLabel": self.messageLabel};
	[self.contentScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[titleLabel]-15-|" options:0 metrics:nil views:mapping]];
	[self.contentScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[messageLabel]-15-|" options:0 metrics:nil views:mapping]];
	[self.contentScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[titleLabel]-4-[messageLabel]|" options:0 metrics:nil views:mapping]];
}


@end
