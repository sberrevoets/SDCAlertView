//
//  SDCAlertView.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/20/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertView.h"

@interface SDCAlertView () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;

@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIView *buttonSeparatorView;
@property (nonatomic, strong) UITableView *mainTableView;
@end

@implementation SDCAlertView

#pragma mark - Getters

- (UILabel *)titleLabel {
	if (!_titleLabel) {
		_titleLabel = ({
			UILabel *label = [[UILabel alloc] init];
			[label setTranslatesAutoresizingMaskIntoConstraints:NO];
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
			label.text = self.message;
			label.font = [UIFont systemFontOfSize:14];
			label.textAlignment = NSTextAlignmentCenter;
			label;
		});
	}
	
	return _messageLabel;
}

- (UITableView *)mainTableView {
	if (!_mainTableView) {
		_mainTableView = [[UITableView alloc] init];
		[_mainTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
		_mainTableView.delegate = self;
		_mainTableView.dataSource = self;
		_mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		_mainTableView.backgroundColor = [UIColor clearColor];
	}
	
	return _mainTableView;
}

#pragma mark - Initialization

- (instancetype)initWithTitle:(NSString *)title
					  message:(NSString *)message
					 delegate:(id)delegate
			cancelButtonTitle:(NSString *)cancelButtonTitle
			otherButtonTitles:(NSString *)otherButtonTitles {
	self = [super init];
	
	if (self) {
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
	[self addSubview:self.mainTableView];
	
	self.buttonSeparatorView = [[UIView alloc] init];
	self.buttonSeparatorView.backgroundColor = [UIColor colorWithRed:189/255.0 green:189/255.0 blue:189/255.0 alpha:1];
	[self.buttonSeparatorView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self addSubview:self.buttonSeparatorView];
	
	[self.buttonSeparatorView addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonSeparatorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0.5]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonSeparatorView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
	
	[[[UIApplication sharedApplication] keyWindow] addSubview:self];
}

#pragma mark - UITableView

- (NSInteger)numberOfTableViewsToDisplay {
	if ([self.otherButtonTitles count] == 1)
		return 2;
	else
		return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.backgroundColor = [UIColor clearColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	cell.textLabel.textAlignment = NSTextAlignmentCenter;
	cell.textLabel.text = @"Button";
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self removeFromSuperview];
}

#pragma mark - Auto-Layout

- (void)updateConstraints {
	[super updateConstraints];
	
	[self positionLabels];
	[self positionTableView];
	[self positionAlertElements];
	[self positionSelf];
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

- (void)positionTableView {
	[self.mainTableView addConstraint:[NSLayoutConstraint constraintWithItem:self.mainTableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44]];
}

- (void)positionAlertElements {
	[self.contentScrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentScrollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeHeight multiplier:1 constant:66-21]];
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[scrollView]|" options:0 metrics:nil views:@{@"scrollView": self.contentScrollView}]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[mainTableView]|" options:0 metrics:nil views:@{@"mainTableView": self.mainTableView}]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[buttonSeparatorView]|" options:0 metrics:nil views:@{@"buttonSeparatorView": self.buttonSeparatorView}]];
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]-[buttonSeparatorView][mainTableView]|" options:0 metrics:nil views:@{@"scrollView": self.contentScrollView, @"buttonSeparatorView": self.buttonSeparatorView, @"mainTableView": self.mainTableView}]];
}

- (void)positionSelf {
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:270]];
	[self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	[self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

@end
