//
//  SDCAlertViewContentView.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 11/5/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertViewContentView.h"

#import "SDCAlertView.h"

static UIEdgeInsets SDCAlertViewContentPadding = {19, 15, 18.5, 15};

static CGFloat SDCAlertViewLabelSpacing = 4;

static UIEdgeInsets SDCAlertViewTextFieldBackgroundViewPadding = {22, 15, 0, 15};
static UIEdgeInsets SDCAlertViewTextFieldBackgroundViewInsets = {0, 2, 0, 2};
static UIEdgeInsets SDCAlertViewTextFieldTextInsets = {0, 4, 0, 4};
static CGFloat SDCAlertViewPrimaryTextFieldHeight = 30;
static CGFloat SDCAlertViewSecondaryTextFieldHeight = 29;

@interface SDCAlertViewTextField : UITextField
@property (nonatomic) UIEdgeInsets textInsets;
@end

@interface SDCAlertViewContentView ()
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) UIView *textFieldBackgroundView;
@property (nonatomic, strong) SDCAlertViewTextField *primaryTextField;
@property (nonatomic, strong) UIView *textFieldSeparatorView;
@property (nonatomic, strong) SDCAlertViewTextField *secondaryTextField;

@property (nonatomic, strong) UIView *buttonTopSeparatorView;
@property (nonatomic, strong) UIView *buttonSeparatorView;
@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) UITableView *secondaryTableView;
@end

@implementation SDCAlertViewContentView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self)
		[self initializeSubviews];
	
	return self;
}

- (void)initializeSubviews {
	[self initializeTitleLabel];
	[self initializeMessageLabel];
	[self initializeContentScrollView];
	[self initializeTextFieldBackgroundView];
	[self initializePrimaryTextField];
	[self initializeTextFieldSeparatorView];
	[self initializeSecondaryTextField];
	[self initializeButtonTopSeparatorView];
	[self initializeMainTableView];
	[self initializeButtonSeparatorView];
	[self initializeSecondaryTableView];
}

- (void)initializeTitleLabel {
	self.titleLabel = [[UILabel alloc] init];
	[self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
	self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
	self.titleLabel.textAlignment = NSTextAlignmentCenter;
	self.titleLabel.numberOfLines = 0;
	self.titleLabel.preferredMaxLayoutWidth = SDCAlertViewWidth - SDCAlertViewContentPadding.left - SDCAlertViewContentPadding.right;
}

- (void)initializeMessageLabel {
	self.messageLabel = [[UILabel alloc] init];
	[self.messageLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
	self.messageLabel.font = [UIFont systemFontOfSize:14];
	self.messageLabel.textAlignment = NSTextAlignmentCenter;
	self.messageLabel.numberOfLines = 0;
	self.messageLabel.preferredMaxLayoutWidth = SDCAlertViewWidth - SDCAlertViewContentPadding.left - SDCAlertViewContentPadding.right;
}

- (void)initializeContentScrollView {
	self.contentScrollView = [[UIScrollView alloc] init];
	[self.contentScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
}

- (void)initializeTextFieldBackgroundView {
	self.textFieldBackgroundView = [[UIView alloc] init];
	[self.textFieldBackgroundView setTranslatesAutoresizingMaskIntoConstraints:NO];
	self.textFieldBackgroundView.backgroundColor = [UIColor whiteColor];
	self.textFieldBackgroundView.layer.borderColor = [[UIColor colorWithWhite:0.5 alpha:0.5] CGColor];
	self.textFieldBackgroundView.layer.borderWidth = SDCAlertViewGetSeparatorThickness();
	self.textFieldBackgroundView.layer.masksToBounds = YES;
	self.textFieldBackgroundView.layer.cornerRadius = 5;
}

- (void)initializePrimaryTextField {
	self.primaryTextField = [[SDCAlertViewTextField alloc] init];
	[self.primaryTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
	self.primaryTextField.font = [UIFont systemFontOfSize:13];
	self.primaryTextField.textInsets = SDCAlertViewTextFieldTextInsets;
	[self.primaryTextField becomeFirstResponder];
}

- (void)initializeTextFieldSeparatorView {
	self.textFieldSeparatorView = [self separatorView];
}

- (void)initializeSecondaryTextField {
	self.secondaryTextField = [[SDCAlertViewTextField alloc] init];
	[self.secondaryTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
	self.secondaryTextField.font = [UIFont systemFontOfSize:13];
	self.secondaryTextField.textInsets = SDCAlertViewTextFieldTextInsets;
	self.secondaryTextField.secureTextEntry = YES;
}

- (UIView *)separatorView {
	UIView *separatorView = [[UIView alloc] init];
	[separatorView setTranslatesAutoresizingMaskIntoConstraints:NO];
	separatorView.backgroundColor = [UIColor sdc_alertSeparatorColor];
	return separatorView;
}

- (void)initializeButtonTopSeparatorView {
	self.buttonTopSeparatorView = [self separatorView];
}

- (UITableView *)buttonTableView {
	UITableView *tableView = [[UITableView alloc] init];
	[tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.backgroundColor = [UIColor clearColor];
	tableView.separatorInset = UIEdgeInsetsZero;
	tableView.separatorColor = [UIColor sdc_alertSeparatorColor];
	tableView.scrollEnabled = NO;
	return tableView;
}

- (void)initializeMainTableView {
	self.mainTableView = [self buttonTableView];
}

- (void)initializeButtonSeparatorView {
	self.buttonSeparatorView = [self separatorView];
}

- (void)initializeSecondaryTableView {
	self.secondaryTableView = [self buttonTableView];
}

#pragma mark - UITableViewDataSource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (BOOL)isCancelButtonAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
	BOOL isMainTableView = tableView == self.mainTableView;
	BOOL showsSecondaryTableView = [self.dataSource numberOfOtherButtonsInAlertContentView:self] == 1;
	BOOL isLastRowOfTableView = indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1;
	
	return !isMainTableView || (isMainTableView && !showsSecondaryTableView && isLastRowOfTableView);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (tableView == self.mainTableView) {
		NSUInteger otherButtonCount = [self.dataSource numberOfOtherButtonsInAlertContentView:self];
		
		if (otherButtonCount == 1 && [self.dataSource titleForCancelButtonInAlertContentView:self])
			return otherButtonCount;
		else
			return otherButtonCount + 1;
	} else {
		return 1;
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger otherButtonCount = [self.dataSource numberOfOtherButtonsInAlertContentView:self];
	
	if ((tableView == self.mainTableView && otherButtonCount) ||
		(tableView == self.mainTableView && otherButtonCount != 1 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1))
		cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
	else
		cell.textLabel.font = [UIFont systemFontOfSize:17];
	
	cell.backgroundColor = [UIColor clearColor];
	cell.textLabel.textColor = [UIColor sdc_alertButtonTextColor];
	cell.textLabel.textAlignment = NSTextAlignmentCenter;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	if ([self isCancelButtonAtIndexPath:indexPath inTableView:tableView])
		cell.textLabel.text = [self.dataSource titleForCancelButtonInAlertContentView:self];
	else
		cell.textLabel.text = [self.dataSource alertContentView:self titleForButtonAtIndex:indexPath.row];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self isCancelButtonAtIndexPath:indexPath inTableView:tableView])
		[self.delegate alertContentViewDidTapCancelButton:self];
	else
		[self.delegate alertContentView:self didTapButtonAtIndex:indexPath.row];
}

#pragma mark - Layout

- (void)updateContentToReflectChanges {
	self.titleLabel.text = [self.dataSource alertTitleInAlertContentView:self];
	self.messageLabel.text = [self.dataSource alertMessageInAlertContentView:self];
}

- (NSArray *)alertViewElementsToDisplay {
	[self updateContentToReflectChanges];
	
	NSMutableArray *elements = [NSMutableArray array];
	
	if ([self.titleLabel.text length] > 0)					[elements addObject:self.titleLabel];
	if ([self.messageLabel.text length] > 0)				[elements addObject:self.messageLabel];
	if ([elements count] > 0)								[elements addObject:self.contentScrollView];
	
	if ([self.delegate alertContentViewShouldShowPrimaryTextField:self]) {
		[elements addObject:self.textFieldBackgroundView];
		
		if ([self.delegate alertContentViewShouldShowSecondaryTextField:self]) {
			[elements addObject:self.textFieldSeparatorView];
			[elements addObject:self.secondaryTextField];
		}
	}
	
	NSUInteger otherButtonCount = [self.dataSource numberOfOtherButtonsInAlertContentView:self];
	NSString *cancelButtonTitle = [self.dataSource titleForCancelButtonInAlertContentView:self];
	if (otherButtonCount > 0 || cancelButtonTitle) {
		[elements addObject:self.mainTableView];
		[elements addObject:self.buttonTopSeparatorView];
		
		if (otherButtonCount == 1) {
			[elements addObject:self.secondaryTableView];
			[elements addObject:self.buttonSeparatorView];
		}
	}
	
	return elements;
}

- (void)updateConstraints {
	NSArray *elements = [self alertViewElementsToDisplay];
	
	if ([elements containsObject:self.contentScrollView])		[self positionContentScrollView];
	if ([elements containsObject:self.textFieldBackgroundView])	[self positionTextFields];
	if ([elements containsObject:self.mainTableView])			[self positionButtons];
	
	[self positionAlertElements];
	
	[super updateConstraints];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	[super willMoveToSuperview:newSuperview];
	
	NSArray *elements = [self alertViewElementsToDisplay];
	
	if ([elements containsObject:self.titleLabel])			[self.contentScrollView addSubview:self.titleLabel];
	if ([elements containsObject:self.messageLabel])		[self.contentScrollView addSubview:self.messageLabel];
	if ([elements containsObject:self.contentScrollView])	[self addSubview:self.contentScrollView];
	
	if ([elements containsObject:self.textFieldBackgroundView]) {
		[self addSubview:self.textFieldBackgroundView];
		[self.textFieldBackgroundView addSubview:self.primaryTextField];
		
		if ([self.delegate alertContentViewShouldShowSecondaryTextField:self]) {
			[self.textFieldBackgroundView addSubview:self.textFieldSeparatorView];
			[self.textFieldBackgroundView addSubview:self.secondaryTextField];
			
			self.primaryTextField.placeholder = NSLocalizedString(@"Login", nil);
			self.secondaryTextField.placeholder = NSLocalizedString(@"Password", nil);
		}
	}
	
	if ([elements containsObject:self.mainTableView]) {
		[self addSubview:self.mainTableView];
		[self addSubview:self.buttonTopSeparatorView];
	}
	
	if ([elements containsObject:self.secondaryTableView]) {
		[self addSubview:self.secondaryTableView];
		[self insertSubview:self.buttonSeparatorView aboveSubview:self.secondaryTableView];
	}
}

#pragma mark - Content View Layout

- (void)positionContentScrollView {
	NSDictionary *mapping = @{@"titleLabel": self.titleLabel, @"messageLabel": self.messageLabel};
	NSDictionary *metrics = @{@"leftPadding": @(SDCAlertViewContentPadding.left), @"labelWidth": @(SDCAlertViewWidth - SDCAlertViewContentPadding.left - SDCAlertViewContentPadding.right), @"topPadding": @(SDCAlertViewContentPadding.top), @"rightPadding": @(SDCAlertViewContentPadding.right), @"labelSpacing": @(SDCAlertViewLabelSpacing)};
	
	NSMutableString *verticalVFL = [@"V:|" mutableCopy];
	NSArray *elements = [self alertViewElementsToDisplay];
	
	if ([elements containsObject:self.titleLabel]) {
		[self.contentScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==leftPadding)-[titleLabel(==labelWidth)]-(==rightPadding)-|" options:0 metrics:metrics views:mapping]];
		[verticalVFL appendString:@"-(==topPadding)-[titleLabel]"];
	}
	
	if ([elements containsObject:self.messageLabel]) {
		[self.contentScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==leftPadding)-[messageLabel(==labelWidth)]-(==rightPadding)-|" options:0 metrics:metrics views:mapping]];
		[verticalVFL appendString:@"-(==labelSpacing)-[messageLabel]"];
	}
	
	[verticalVFL appendString:@"|"];
	[self.contentScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalVFL options:0 metrics:metrics views:mapping]];
}

- (void)positionTextFields {
	NSDictionary *mapping = @{@"primaryTextField": self.primaryTextField, @"textFieldSeparator": self.textFieldSeparatorView, @"secondaryTextField": self.secondaryTextField};
	NSDictionary *metrics = @{@"leftTextFieldSpace": @(SDCAlertViewTextFieldBackgroundViewInsets.left), @"rightTextFieldSpace": @(SDCAlertViewTextFieldBackgroundViewInsets.right), @"primaryTextFieldHeight": @(SDCAlertViewPrimaryTextFieldHeight), @"secondaryTextFieldHeight": @(SDCAlertViewSecondaryTextFieldHeight), @"separatorHeight": @(SDCAlertViewGetSeparatorThickness())};
	
	[self.textFieldBackgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==leftTextFieldSpace)-[primaryTextField]-(==rightTextFieldSpace)-|" options:0 metrics:metrics views:mapping]];
	
	NSMutableString *verticalVFL = [@"V:|[primaryTextField(==primaryTextFieldHeight)]" mutableCopy];
	
	if ([[self alertViewElementsToDisplay] containsObject:self.secondaryTextField]) {
		[self.textFieldBackgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==leftTextFieldSpace)-[secondaryTextField]-(==rightTextFieldSpace)-|" options:0 metrics:metrics views:mapping]];
		
		[self.textFieldBackgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[textFieldSeparator]|" options:0 metrics:nil views:mapping]];
		
		[verticalVFL appendString:@"[textFieldSeparator(==separatorHeight)][secondaryTextField(==secondaryTextFieldHeight)]"];
	}
	
	[verticalVFL appendString:@"|"];
	[self.textFieldBackgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalVFL options:0 metrics:metrics views:mapping]];
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
	CGFloat scrollViewHeight = SDCAlertViewContentPadding.top + titleLabelHeight + SDCAlertViewLabelSpacing + messageLabelHeight;
	
	CGFloat maximumScrollViewHeight = [self.delegate maximumHeightForAlertContentView:self] - self.mainTableView.rowHeight * [self.mainTableView numberOfRowsInSection:0] - SDCAlertViewContentPadding.bottom - SDCAlertViewGetSeparatorThickness();
	
	return MIN(scrollViewHeight, maximumScrollViewHeight);
}

- (void)positionAlertElements {
	NSArray *elements = [self alertViewElementsToDisplay];
	
	NSMutableString *verticalVFL = [@"V:|" mutableCopy];
	
	if ([elements containsObject:self.contentScrollView]) {
		CGFloat scrollViewHeight = [self heightForContentScrollView];
		[self.contentScrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentScrollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:scrollViewHeight]];
		
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[scrollView]|" options:0 metrics:nil views:@{@"scrollView": self.contentScrollView}]];
		
		[verticalVFL appendString:@"[scrollView]"];
	}
	
	if ([elements containsObject:self.textFieldBackgroundView]) {
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(==leftPadding)-[textFieldBackgroundView(==textFieldWidth)]-(==rightPadding)-|" options:0 metrics:@{@"leftPadding": @(SDCAlertViewContentPadding.left), @"textFieldWidth": @(SDCAlertViewWidth - SDCAlertViewContentPadding.left - SDCAlertViewContentPadding.right), @"rightPadding": @(SDCAlertViewContentPadding.right)} views:@{@"textFieldBackgroundView": self.textFieldBackgroundView}]];
		
		[verticalVFL appendString:@"-(==textFieldBackgroundViewTopSpacing)-[textFieldBackgroundView]"];
	}
	
	if ([elements containsObject:self.mainTableView]) {
		if ([elements containsObject:self.secondaryTableView]) {
			[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[secondaryTableView(==half)][mainTableView(==half)]|" options:0 metrics:@{@"half": @(SDCAlertViewWidth / 2)} views:@{@"mainTableView": self.mainTableView, @"secondaryTableView": self.secondaryTableView}]];
			[self addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonSeparatorView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.mainTableView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
		} else {
			[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[mainTableView]|" options:0 metrics:nil views:@{@"mainTableView": self.mainTableView}]];
		}
		
		[verticalVFL appendString:@"-(==bottomSpacing)-[buttonTopSeparatorView][mainTableView]"];
	}
	
	[verticalVFL appendString:@"|"];
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalVFL options:0 metrics:@{@"textFieldBackgroundViewTopSpacing": @(SDCAlertViewTextFieldBackgroundViewPadding.top), @"bottomSpacing": @(SDCAlertViewContentPadding.bottom - 4)} views:@{@"scrollView": self.contentScrollView, @"textFieldBackgroundView": self.textFieldBackgroundView, @"buttonTopSeparatorView": self.buttonTopSeparatorView, @"mainTableView": self.mainTableView}]];
}

@end

@implementation SDCAlertViewTextField

- (CGRect)textRectForBounds:(CGRect)bounds {
	return [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, self.textInsets)];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
	return [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, self.textInsets)];
}

@end
