//
//  SDCAlertView.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/20/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertView.h"

#pragma mark - Constants

static CGFloat SDCAlertViewWidth = 270;
static CGFloat SDCAlertViewSeparatorThickness = 1;
static CGFloat SDCAlertViewCornerRadius = 7;

static UIEdgeInsets SDCAlertViewContentPadding = {19, 15, 18.5, 15};

static CGFloat SDCAlertViewLabelSpacing = 4;

static UIEdgeInsets SDCAlertViewTextFieldBackgroundViewPadding = {22, 15, 0, 15};
static UIEdgeInsets SDCAlertViewTextFieldBackgroundViewInsets = {0, 2, 0, 2};
static UIEdgeInsets SDCAlertViewTextFieldTextInsets = {0, 4, 0, 4};
static CGFloat SDCAlertViewPrimaryTextFieldHeight = 30;
static CGFloat SDCAlertViewSecondaryTextFieldHeight = 29;

static CGFloat SDCAlertViewGetSeparatorThickness() {
	return SDCAlertViewSeparatorThickness / [[UIScreen mainScreen] scale];
}

#pragma mark - UIKit Categories

@interface UIWindow (WindowLookup)
+ (UIWindow *)sdc_alertWindow;
@end

@interface UIColor (SDCAlertViewColors)
+ (UIColor *)sdc_alertBackgroundColor;
+ (UIColor *)sdc_alertButtonTextColor;
+ (UIColor *)sdc_alertSeparatorColor;
@end

#pragma mark - Private Class Interfaces

@interface SDCAlertViewController : UIViewController

@property (nonatomic, strong) UIWindow *previousWindow;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIView *rootView;
@property (nonatomic, strong) NSMutableOrderedSet *alertViews;

+ (instancetype)currentController;

- (void)showAlert:(SDCAlertView *)alert;
- (void)removeAlert:(SDCAlertView *)alert;

@end

@interface SDCAlertViewBackgroundView : UIView
@end

@class SDCAlertViewContentView;

@protocol SDCAlertViewContentViewDelegate <NSObject>
- (BOOL)alertContentViewShouldShowPrimaryTextField:(SDCAlertViewContentView *)sender;
- (BOOL)alertContentViewShouldShowSecondaryTextField:(SDCAlertViewContentView *)sender;

- (CGFloat)maximumHeightForAlertContentView:(SDCAlertViewContentView *)sender;

- (void)alertContentView:(SDCAlertViewContentView *)sender didTapButtonAtIndex:(NSUInteger)index;
- (void)alertContentViewDidTapCancelButton:(SDCAlertViewContentView *)sender;
@end

@protocol SDCAlertViewContentViewDataSource <NSObject>

- (NSString *)alertTitleInAlertContentView:(SDCAlertViewContentView *)sender;
- (NSString *)alertMessageInAlertContentView:(SDCAlertViewContentView *)sender;

- (NSString *)titleForCancelButtonInAlertContentView:(SDCAlertViewContentView *)sender;

- (NSUInteger)numberOfOtherButtonsInAlertContentView:(SDCAlertViewContentView *)sender;
- (NSString *)alertContentView:(SDCAlertViewContentView *)sender titleForButtonAtIndex:(NSUInteger)index;

@end

@interface SDCAlertViewTextField : UITextField
@property (nonatomic) UIEdgeInsets textInsets;
@end

@interface SDCAlertViewContentView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id <SDCAlertViewContentViewDelegate> delegate;
@property (nonatomic, weak) id <SDCAlertViewContentViewDataSource> dataSource;

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

#pragma mark - SDCAlertView

@interface SDCAlertView () <SDCAlertViewContentViewDataSource, SDCAlertViewContentViewDelegate>

@property (nonatomic, strong) SDCAlertViewController *alertViewController;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *cancelButtonTitle;
@property (nonatomic, strong) NSArray *otherButtonTitles;

@property (nonatomic, strong) SDCAlertViewBackgroundView *alertBackgroundView;
@property (nonatomic, strong) SDCAlertViewContentView *alertContentView;
@end

@implementation SDCAlertView

#pragma mark - Getters

- (SDCAlertViewController *)alertViewController {
	if (!_alertViewController)
		_alertViewController = [SDCAlertViewController currentController];
	return _alertViewController;
}

- (SDCAlertViewBackgroundView *)alertBackgroundView {
	if (!_alertBackgroundView) {
		_alertBackgroundView = [[SDCAlertViewBackgroundView alloc] init];
		[_alertBackgroundView setTranslatesAutoresizingMaskIntoConstraints:NO];
		[self insertSubview:_alertBackgroundView atIndex:0];
	}
	
	return _alertBackgroundView;
}

- (SDCAlertViewContentView *)alertContentView {
	if (!_alertContentView) {
		_alertContentView = [[SDCAlertViewContentView alloc] init];
		[_alertContentView setTranslatesAutoresizingMaskIntoConstraints:NO];
		_alertContentView.delegate = self;
		_alertContentView.dataSource = self;
		[self addSubview:_alertContentView];
	}
	
	return _alertContentView;
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
		self.backgroundColor = [UIColor sdc_alertBackgroundColor];
		self.layer.masksToBounds = YES;
		self.layer.cornerRadius = SDCAlertViewCornerRadius;
		self.layer.borderColor = [[UIColor sdc_alertSeparatorColor] CGColor];
		self.layer.borderWidth = SDCAlertViewGetSeparatorThickness();
	}
	
	return self;
}


- (void)show {
	[self.alertViewController showAlert:self];
}

#pragma mark - SDCAlertViewContentViewDataSource

- (NSString *)alertTitleInAlertContentView:(SDCAlertViewContentView *)sender {
	return self.title;
}

- (NSString *)alertMessageInAlertContentView:(SDCAlertViewContentView *)sender {
	return self.message;
}

- (NSUInteger)numberOfOtherButtonsInAlertContentView:(SDCAlertViewContentView *)sender {
	return [self.otherButtonTitles count];
}

- (NSString *)alertContentView:(SDCAlertViewContentView *)sender titleForButtonAtIndex:(NSUInteger)index {
	return self.otherButtonTitles[index];
}

- (NSString *)titleForCancelButtonInAlertContentView:(SDCAlertViewContentView *)sender {
	return self.cancelButtonTitle;
}

#pragma mark - SDCAlertViewContentViewDelegate

- (BOOL)alertContentViewShouldShowPrimaryTextField:(SDCAlertViewContentView *)sender {
	return self.alertViewStyle != SDCAlertViewStyleDefault;
}

- (BOOL)alertContentViewShouldShowSecondaryTextField:(SDCAlertViewContentView *)sender {
	return self.alertViewStyle == SDCAlertViewStyleLoginAndPasswordInput;
}

- (CGFloat)maximumHeightForAlertContentView:(SDCAlertViewContentView *)sender {
	return CGRectGetHeight(self.superview.bounds);
}

- (void)alertContentView:(SDCAlertViewContentView *)sender didTapButtonAtIndex:(NSUInteger)index {
	NSLog(@"Tapped %@", self.otherButtonTitles[index]);
	[self.alertViewController removeAlert:self];
}

- (void)alertContentViewDidTapCancelButton:(SDCAlertViewContentView *)sender {
	NSLog(@"Tapped cancel");
	[self.alertViewController removeAlert:self];
}

#pragma mark - Auto-Layout

- (void)updateConstraints {
	[self positionBackgroundView];
	[self positionAlertContentView];
	[self positionSelf];
	
	[super updateConstraints];
}

- (void)positionBackgroundView {
	NSDictionary *views = @{@"backgroundView": self.alertBackgroundView};
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundView]|" options:0 metrics:nil views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundView]|" options:0 metrics:nil views:views]];
}

- (void)positionAlertContentView {
	NSDictionary *views = @{@"alertContentView": self.alertContentView};
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[alertContentView]|" options:0 metrics:nil views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[alertContentView]|" options:0 metrics:nil views:views]];
}

- (void)positionSelf {
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:SDCAlertViewWidth]];
	[self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.superview attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
	[self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	[self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

@end

#pragma mark - Private Class Implementations

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

@implementation SDCAlertViewController

+ (instancetype)currentController {
	UIViewController *currentController = [[UIWindow sdc_alertWindow] rootViewController];
	
	if ([currentController isKindOfClass:[SDCAlertViewController class]])
		return (SDCAlertViewController *)currentController;
	else
		return [[self alloc] init];
}

- (instancetype)init {
	self = [super init];
	
	if (self) {
		_alertViews = [[NSMutableOrderedSet alloc] init];
		[self initializeWindow];
	}
	
	return self;
}

- (NSMutableOrderedSet *)alertViews {
	if (!_alertViews)
		_alertViews = [NSMutableOrderedSet orderedSet];
	return _alertViews;
}

- (void)initializeWindow {
	self.previousWindow = [[UIApplication sharedApplication] keyWindow];
	
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.rootViewController = self;
	self.window.windowLevel = UIWindowLevelAlert;
	
	self.rootView = [[UIView alloc] initWithFrame:self.window.bounds];
	[self.window addSubview:self.rootView];
	
	UIView *backgroundColorView = [[UIView alloc] initWithFrame:self.rootView.bounds];
	[backgroundColorView setTranslatesAutoresizingMaskIntoConstraints:NO];
	backgroundColorView.backgroundColor = [UIColor colorWithWhite:0 alpha:.4];
	[self.rootView addSubview:backgroundColorView];
	
	NSDictionary *backgroundColorViewDictionary = @{@"backgroundColorView": backgroundColorView};
	[self.rootView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundColorView]|" options:0 metrics:nil views:backgroundColorViewDictionary]];
	[self.rootView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundColorView]|" options:0 metrics:nil views:backgroundColorViewDictionary]];
}

- (void)showAlert:(SDCAlertView *)alert {
	[self.alertViews addObject:alert];
	[self.rootView addSubview:alert];
	
	if ([[UIApplication sharedApplication] keyWindow] != self.window) {
		[[[UIApplication sharedApplication] keyWindow] setTintAdjustmentMode:UIViewTintAdjustmentModeDimmed];
		[self.window makeKeyAndVisible];
		[self.window bringSubviewToFront:self.rootView];
	}
}

- (void)removeAlert:(SDCAlertView *)alert {
	[alert removeFromSuperview];
	[self.alertViews removeObject:alert];
	
	if ([self.alertViews count] == 0) {
		self.window = nil;
		
		self.previousWindow.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
		[self.previousWindow makeKeyAndVisible];
	}
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

@implementation SDCAlertViewBackgroundView

- (id)init {
	self = [super init];
	
	if (self)
		[self addBackgroundImage];
	
	return self;
}

- (void)addBackgroundImage {
	CGFloat scale = [[UIScreen mainScreen] scale];
	
	NSData *imageData;
	if (scale == 2.0)
		imageData = [[NSData alloc] initWithBase64EncodedString:[self imageData] options:0];
	else
		return; // TODO: Non-Retina image data
	
	UIImage *image = [UIImage imageWithData:imageData];
	image = [UIImage imageWithCGImage:image.CGImage scale:scale orientation:image.imageOrientation];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	
	[self addSubview:imageView];
}

- (NSString *)imageData {
	return @"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";
}

@end

#pragma mark - UIKit Category Implementations

@implementation UIWindow (WindowLookup)

+ (UIWindow *)sdc_alertWindow {
	NSArray *windows = [[UIApplication sharedApplication] windows];
	NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(UIWindow *window, NSDictionary *bindings) {
		return [window.rootViewController isKindOfClass:[SDCAlertViewController class]];
	}];
	
	NSArray *alertWindows = [windows filteredArrayUsingPredicate:predicate];
	NSAssert([alertWindows count] <= 1, @"At most one alert window should be active at any point");
	
	return [alertWindows firstObject];
}

@end

@implementation UIColor (SDCAlertViewColors)

+ (UIColor *)sdc_alertBackgroundColor {
	return [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1];
}

+ (UIColor *)sdc_alertButtonTextColor {
	return [UIColor colorWithRed:16/255.0 green:144/255.0 blue:248/255.0 alpha:1];
}

+ (UIColor *)sdc_alertSeparatorColor {
	return [UIColor colorWithRed:189/255.0 green:189/255.0 blue:189/255.0 alpha:1];
}

@end
