//
//  SDCAlertView.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/20/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertView.h"

static CGFloat SDCAlertViewWidth = 270;
static UIEdgeInsets SDCAlertViewContentPadding = {20, 15, 20, 15};
static CGFloat SDCAlertViewLabelSpacing = 4;
static CGFloat SDCAlertViewSeparatorThickness = 1;

CGFloat SDCAlertViewGetSeparatorThickness() {
	return SDCAlertViewSeparatorThickness / [[UIScreen mainScreen] scale];
}

@interface SDCAlertView () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *cancelButtonTitle;
@property (nonatomic, strong) NSArray *otherButtonTitles;

@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIView *buttonTopSeparatorView;
@property (nonatomic, strong) UIView *buttonSeparatorView;
@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) UITableView *secondaryTableView;
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
			label.numberOfLines = 0;
			label.preferredMaxLayoutWidth = SDCAlertViewWidth - SDCAlertViewContentPadding.left - SDCAlertViewContentPadding.right;
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
			label.numberOfLines = 0;
			label.preferredMaxLayoutWidth = SDCAlertViewWidth - SDCAlertViewContentPadding.left - SDCAlertViewContentPadding.right;
			label;
		});
	}
	
	return _messageLabel;
}

- (UIView *)separatorView {
	UIView *separatorView = [[UIView alloc] init];
	separatorView.backgroundColor = [UIColor colorWithRed:189/255.0 green:189/255.0 blue:189/255.0 alpha:1];
	[separatorView setTranslatesAutoresizingMaskIntoConstraints:NO];
	return separatorView;
}

- (UIView *)buttonTopSeparatorView {
	if (!_buttonTopSeparatorView)
		_buttonTopSeparatorView = [self separatorView];
	return _buttonTopSeparatorView;
}

- (UIView *)buttonSeparatorView {
	if (!_buttonSeparatorView)
		_buttonSeparatorView = [self separatorView];
	return _buttonSeparatorView;
}

- (UITableView *)buttonTableView {
	UITableView *tableView = [[UITableView alloc] init];
	[tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
	tableView.dataSource = self;
	tableView.delegate = self;
	tableView.backgroundColor = [UIColor clearColor];
	tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
	tableView.separatorColor = [UIColor colorWithRed:189/255.0 green:189/255.0 blue:189/255.0 alpha:1];
	tableView.scrollEnabled = NO;
	return tableView;
}

- (UITableView *)mainTableView {
	if (!_mainTableView)
		_mainTableView = [self buttonTableView];
	return _mainTableView;
}

- (UITableView *)secondaryTableView {
	if (!_secondaryTableView)
		_secondaryTableView = [self buttonTableView];
	return _secondaryTableView;
}

#pragma mark - Initialization

- (instancetype)initWithTitle:(NSString *)title
					  message:(NSString *)message
					 delegate:(id)delegate
			cancelButtonTitle:(NSString *)cancelButtonTitle
			otherButtonTitles:(NSString *)otherButtonTitles, ... {
	self = [super init];
	
	if (self) {
		_title = title;
		_message = message;
		_cancelButtonTitle = cancelButtonTitle;
		
		NSMutableArray *buttonTitles = [NSMutableArray array];
		
		va_list argumentList;
		va_start(argumentList, otherButtonTitles);
		for (NSString *buttonTitle = otherButtonTitles; buttonTitle != nil; buttonTitle = va_arg(argumentList, NSString *))
			[buttonTitles addObject:buttonTitle];
		
		_otherButtonTitles = buttonTitles;
		
		[self setTranslatesAutoresizingMaskIntoConstraints:NO];
		self.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1];
		self.layer.masksToBounds = YES;
		self.layer.cornerRadius = 7;
		self.layer.borderColor = [[UIColor colorWithRed:190/255.0 green:190/255.0 blue:190/255.0 alpha:1] CGColor];
		self.layer.borderWidth = SDCAlertViewGetSeparatorThickness();
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
	
	if ([self numberOfTableViewsToDisplay] == 2) {
		[self addSubview:self.secondaryTableView];
		[self insertSubview:self.buttonSeparatorView aboveSubview:self.secondaryTableView];
	}
	
	[self addSubview:self.buttonTopSeparatorView];
	
	[self.buttonTopSeparatorView addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonTopSeparatorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:SDCAlertViewGetSeparatorThickness()]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonTopSeparatorView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
	
	[[[UIApplication sharedApplication] keyWindow] addSubview:self];
}

#pragma mark - UITableView

- (NSInteger)numberOfTableViewsToDisplay {
	if ([self.otherButtonTitles count] == 1 && self.cancelButtonTitle)
		return 2;
	else
		return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (tableView == self.mainTableView) {
		if ([self numberOfTableViewsToDisplay] == 1) {
			if (self.cancelButtonTitle)
				return [self.otherButtonTitles count] + 1;
			else
				return [self.otherButtonTitles count];
		} else {
			return [self.otherButtonTitles count];
		}
	} else {
		return 1;
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if ((tableView == self.mainTableView && [self numberOfTableViewsToDisplay] == 2) ||
		(tableView == self.mainTableView && [self numberOfTableViewsToDisplay] == 1 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1))
		cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
	else
		cell.textLabel.font = [UIFont systemFontOfSize:17];
	
	cell.backgroundColor = [UIColor clearColor];
	cell.textLabel.textColor = [UIColor colorWithRed:16/255.0 green:144/255.0 blue:248/255.0 alpha:1];
	cell.textLabel.textAlignment = NSTextAlignmentCenter;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	
	if (tableView == self.mainTableView) {
		if ([self numberOfTableViewsToDisplay] == 1) {
			if (indexPath.row < [tableView numberOfRowsInSection:indexPath.section] - 1)
				cell.textLabel.text = self.otherButtonTitles[indexPath.row];
			else
				cell.textLabel.text = self.cancelButtonTitle;
		} else {
			cell.textLabel.text = self.otherButtonTitles[indexPath.row];
		}
	} else {
		cell.textLabel.text = self.cancelButtonTitle;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self removeFromSuperview];
}

#pragma mark - Auto-Layout

- (void)updateConstraints {
	[super updateConstraints];
	
	[self positionLabels];
	[self positionTableViews];
	[self positionAlertElements];
	[self positionSelf];
}

- (void)positionLabels {
	[self addConstraint:
	 [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:-(SDCAlertViewContentPadding.left + SDCAlertViewContentPadding.right)]];
	[self addConstraint:
	 [NSLayoutConstraint constraintWithItem:self.messageLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:-(SDCAlertViewContentPadding.left + SDCAlertViewContentPadding.right)]];
	
	NSDictionary *mapping = @{@"titleLabel": self.titleLabel, @"messageLabel": self.messageLabel};
	NSDictionary *metrics = @{@"leftPadding": @(SDCAlertViewContentPadding.left), @"rightPadding": @(SDCAlertViewContentPadding.right), @"labelSpacing": @(SDCAlertViewLabelSpacing)};
	
	[self.contentScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==leftPadding)-[titleLabel]-(==rightPadding)-|"
																				   options:0
																				   metrics:metrics
																					 views:mapping]];
	[self.contentScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==leftPadding)-[messageLabel]-(==rightPadding)-|"
																				   options:0
																				   metrics:metrics
																					 views:mapping]];
	[self.contentScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[titleLabel]-(==labelSpacing)-[messageLabel]|"
																				   options:0
																				   metrics:metrics
																					 views:mapping]];
}

- (void)positionTableViews {
	[self.mainTableView addConstraint:[NSLayoutConstraint constraintWithItem:self.mainTableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.mainTableView.rowHeight * [self.mainTableView numberOfRowsInSection:0]]];
	if ([self numberOfTableViewsToDisplay] == 2) {
		[self addConstraint:[NSLayoutConstraint constraintWithItem:self.secondaryTableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.mainTableView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
		[self addConstraint:[NSLayoutConstraint constraintWithItem:self.secondaryTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.mainTableView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
		
		[self addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonSeparatorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.mainTableView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
		[self addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonSeparatorView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.mainTableView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
		[self addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonSeparatorView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:SDCAlertViewGetSeparatorThickness()]];
	}
}

- (void)positionAlertElements {
	CGFloat titleLabelHeight = [self.titleLabel intrinsicContentSize].height;
	CGFloat messageLabelHeight = [self.messageLabel intrinsicContentSize].height;
	CGFloat scrollViewHeight = SDCAlertViewContentPadding.top + titleLabelHeight + SDCAlertViewLabelSpacing + messageLabelHeight + SDCAlertViewContentPadding.bottom;
	CGFloat trueHeight = MIN(scrollViewHeight, CGRectGetHeight(self.superview.bounds) - self.mainTableView.rowHeight * [self.mainTableView numberOfRowsInSection:0] - SDCAlertViewContentPadding.bottom - SDCAlertViewGetSeparatorThickness());
	
	[self.contentScrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentScrollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:trueHeight]];
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[scrollView]|" options:0 metrics:nil views:@{@"scrollView": self.contentScrollView}]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[buttonTopSeparatorView]|" options:0 metrics:nil views:@{@"buttonTopSeparatorView": self.buttonTopSeparatorView}]];
	
	if ([self numberOfTableViewsToDisplay] == 2) {
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[secondaryTableView(==half)][mainTableView(==half)]|" options:0 metrics:@{@"half": @(270/2)} views:@{@"mainTableView": self.mainTableView, @"secondaryTableView": self.secondaryTableView}]];
		[self addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonSeparatorView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.mainTableView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
	} else {
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[mainTableView]|" options:0 metrics:nil views:@{@"mainTableView": self.mainTableView}]];
	}
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]-[buttonTopSeparatorView][mainTableView]|" options:0 metrics:nil views:@{@"scrollView": self.contentScrollView, @"buttonTopSeparatorView": self.buttonTopSeparatorView, @"mainTableView": self.mainTableView}]];
}

- (void)positionSelf {
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:SDCAlertViewWidth]];
	[self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.superview attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
	[self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	[self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

@end
