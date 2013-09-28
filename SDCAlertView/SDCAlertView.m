//
//  SDCAlertView.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/20/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertView.h"

static CGFloat SDCAlertViewWidth = 270;
static CGFloat SDCAlertViewLabelSpacing = 4;
static CGFloat SDCAlertViewSeparatorThickness = 1;

static UIEdgeInsets SDCAlertViewContentPadding = {20, 15, 20, 15};

static CGFloat SDCAlertViewGetSeparatorThickness() {
	return SDCAlertViewSeparatorThickness / [[UIScreen mainScreen] scale];
}

static UIColor *SDCAlertViewGetButtonTextColor() {
	return [UIColor colorWithRed:16/255.0 green:144/255.0 blue:248/255.0 alpha:1];
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

- (NSArray *)alertViewElementsToDisplay {
	NSMutableArray *elements = [NSMutableArray array];
	
	if ([self.titleLabel.text length] > 0)			[elements addObject:self.titleLabel];
	if ([self.messageLabel.text length] > 0)		[elements addObject:self.messageLabel];
	if ([elements count] > 0)						[elements addObject:self.contentScrollView];
	
	if ([self.otherButtonTitles count] > 0) {
		[elements addObject:self.mainTableView];
		[elements addObject:self.buttonTopSeparatorView];
	}
	
	if ([self.otherButtonTitles count] == 0 && self.cancelButtonTitle) {
		[elements addObject:self.secondaryTableView];
		[elements addObject:self.buttonSeparatorView];
	}
	
	return elements;
}

- (void)show {
	self.contentScrollView = [[UIScrollView alloc] init];
	[self.contentScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
	NSArray *elements = [self alertViewElementsToDisplay];
	
	if ([elements containsObject:self.titleLabel])			[self.contentScrollView addSubview:self.titleLabel];
	if ([elements containsObject:self.messageLabel])		[self.contentScrollView addSubview:self.messageLabel];
	if ([elements containsObject:self.contentScrollView])	[self addSubview:self.contentScrollView];
	
	if ([elements containsObject:self.mainTableView]) {
		[self addSubview:self.mainTableView];
		[self addSubview:self.buttonTopSeparatorView];
	}
	
	if ([elements containsObject:self.secondaryTableView]) {
		[self addSubview:self.secondaryTableView];
		[self insertSubview:self.buttonSeparatorView aboveSubview:self.secondaryTableView];
	}
	
	[[[UIApplication sharedApplication] keyWindow] addSubview:self];
}
#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (tableView == self.mainTableView) {
		if (![[self alertViewElementsToDisplay] containsObject:self.secondaryTableView]) {
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
	NSArray *elements = [self alertViewElementsToDisplay];
	if ((tableView == self.mainTableView && [elements containsObject:self.secondaryTableView] == 2) ||
		(tableView == self.mainTableView && ![elements containsObject:self.secondaryTableView] == 1 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1))
		cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
	else
		cell.textLabel.font = [UIFont systemFontOfSize:17];
	
	cell.backgroundColor = [UIColor clearColor];
	cell.textLabel.textColor = SDCAlertViewGetButtonTextColor();
	cell.textLabel.textAlignment = NSTextAlignmentCenter;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	
	if (tableView == self.mainTableView) {
		if (![[self alertViewElementsToDisplay] containsObject:self.secondaryTableView]) {
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
	
	NSArray *elements = [self alertViewElementsToDisplay];
	
	if ([elements containsObject:self.contentScrollView])		[self positionContentScrollView];
	if ([elements containsObject:self.mainTableView])			[self positionButtons];
	
	[self positionAlertElements];
	[self positionSelf];
}

- (void)positionContentScrollView {
	NSDictionary *mapping = @{@"titleLabel": self.titleLabel, @"messageLabel": self.messageLabel};
	NSDictionary *metrics = @{@"leftPadding": @(SDCAlertViewContentPadding.left), @"labelWidth": @(SDCAlertViewWidth - SDCAlertViewContentPadding.left - SDCAlertViewContentPadding.right), @"rightPadding": @(SDCAlertViewContentPadding.right), @"labelSpacing": @(SDCAlertViewLabelSpacing)};
	
	NSMutableString *verticalVFL = [@"V:|" mutableCopy];
	NSArray *elements = [self alertViewElementsToDisplay];
	
	if ([elements containsObject:self.titleLabel]) {
		[self.contentScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==leftPadding)-[titleLabel(==labelWidth)]-(==rightPadding)-|" options:0 metrics:metrics views:mapping]];
		[verticalVFL appendString:@"-[titleLabel]"];
	}
	
	if ([elements containsObject:self.messageLabel]) {
		[self.contentScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==leftPadding)-[messageLabel(==labelWidth)]-(==rightPadding)-|" options:0 metrics:metrics views:mapping]];
		[verticalVFL appendString:@"-(==labelSpacing)-[messageLabel]"];
	}
		
	[verticalVFL appendString:@"|"];
	[self.contentScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalVFL options:0 metrics:metrics views:mapping]];
}

- (void)positionButtons {
	[self.mainTableView addConstraint:[NSLayoutConstraint constraintWithItem:self.mainTableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.mainTableView.rowHeight * [self.mainTableView numberOfRowsInSection:0]]];
	
	NSArray *elements = [self alertViewElementsToDisplay];
	if ([elements containsObject:self.secondaryTableView]) {
		[self addConstraint:[NSLayoutConstraint constraintWithItem:self.secondaryTableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.mainTableView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
		[self addConstraint:[NSLayoutConstraint constraintWithItem:self.secondaryTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.mainTableView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
		
		[self addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonSeparatorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.mainTableView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
		[self addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonSeparatorView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.mainTableView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
		[self addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonSeparatorView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:SDCAlertViewGetSeparatorThickness()]];
	}
	
	if ([elements containsObject:self.contentScrollView]) {
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[buttonTopSeparatorView]|" options:0 metrics:nil views:@{@"buttonTopSeparatorView": self.buttonTopSeparatorView}]];
		[self addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonTopSeparatorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:SDCAlertViewGetSeparatorThickness()]];
	}
}

- (CGFloat)heightForContentScrollView {
	CGFloat titleLabelHeight = [self.titleLabel intrinsicContentSize].height;
	CGFloat messageLabelHeight = [self.messageLabel intrinsicContentSize].height;
	CGFloat scrollViewHeight = SDCAlertViewContentPadding.top + titleLabelHeight + SDCAlertViewLabelSpacing + messageLabelHeight + SDCAlertViewContentPadding.bottom;
	return MIN(scrollViewHeight, CGRectGetHeight(self.superview.bounds) - self.mainTableView.rowHeight * [self.mainTableView numberOfRowsInSection:0] - SDCAlertViewContentPadding.bottom - SDCAlertViewGetSeparatorThickness());
}

- (void)positionAlertElements {
	NSArray *elements = [self alertViewElementsToDisplay];
	
	NSMutableString *verticalVFL = [@"V:|" mutableCopy];
	
	if ([elements containsObject:self.contentScrollView]) {
		CGFloat scrollViewHeight = [self heightForContentScrollView];
		[self.contentScrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentScrollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:scrollViewHeight]];
		
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[scrollView]|" options:0 metrics:nil views:@{@"scrollView": self.contentScrollView}]];
		
		[verticalVFL appendString:@"[scrollView]-"];
	}
	
	if ([elements containsObject:self.mainTableView]) {
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[mainTableView]|" options:0 metrics:nil views:@{@"mainTableView": self.mainTableView}]];
		
		if ([elements containsObject:self.secondaryTableView]) {
			[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[secondaryTableView(==half)][mainTableView(==half)]|" options:0 metrics:@{@"half": @(SDCAlertViewWidth / 2)} views:@{@"mainTableView": self.mainTableView, @"secondaryTableView": self.secondaryTableView}]];
			[self addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonSeparatorView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.mainTableView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
		}
		
		[verticalVFL appendString:@"[buttonTopSeparatorView][mainTableView]"];
	}
	
	[verticalVFL appendString:@"|"];
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalVFL options:0 metrics:nil views:@{@"scrollView": self.contentScrollView, @"buttonTopSeparatorView": self.buttonTopSeparatorView, @"mainTableView": self.mainTableView}]];
}

- (void)positionSelf {
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:SDCAlertViewWidth]];
	[self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.superview attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
	[self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	[self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

@end
