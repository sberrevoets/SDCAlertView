//
//  SDCAlertViewContentView.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 11/5/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertViewContentView.h"

#import "SDCAlertView.h"
#import "UIView+SDCAutoLayout.h"

static UIEdgeInsets SDCAlertViewContentPadding = {19, 15, 18.5, 15};

static CGFloat SDCAlertViewLabelSpacing = 4;

static CGFloat SDCAlertViewTextFieldBackgroundViewCornerRadius = 5;
static UIEdgeInsets SDCAlertViewTextFieldBackgroundViewPadding = {22, 15, 0, 15};
static UIEdgeInsets SDCAlertViewTextFieldBackgroundViewInsets = {0, 2, 0, 2};
static UIEdgeInsets SDCAlertViewTextFieldTextInsets = {0, 4, 0, 4};
static CGFloat SDCAlertViewPrimaryTextFieldHeight = 30;
static CGFloat SDCAlertViewSecondaryTextFieldHeight = 29;

@interface UIFont (SDCAlertViewFonts)
+ (UIFont *)sdc_titleLabelFont;
+ (UIFont *)sdc_messageLabelFont;
+ (UIFont *)sdc_textFieldFont;
@end

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

#pragma mark - Getter

- (NSArray *)textFields {
	NSArray *elements = [self alertViewElementsToDisplay];
	
	NSMutableArray *textFields = [NSMutableArray array];
	
	if ([elements containsObject:self.primaryTextField])	[textFields addObject:self.primaryTextField];
	if ([elements containsObject:self.secondaryTextField])	[textFields addObject:self.secondaryTextField];
	
	return textFields;
}

#pragma mark - Initialization

- (instancetype)initWithDelegate:(id<SDCAlertViewContentViewDelegate>)delegate dataSource:(id<SDCAlertViewContentViewDataSource>)dataSource {
	self = [super init];
	
	if (self) {
		_delegate = delegate;
		_dataSource = dataSource;
		
		[self initializeSubviews];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextChanged:) name:UITextFieldTextDidChangeNotification object:nil];
	}
	
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
	self.titleLabel.font = [UIFont sdc_titleLabelFont];
	self.titleLabel.textAlignment = NSTextAlignmentCenter;
	self.titleLabel.numberOfLines = 0;
	self.titleLabel.preferredMaxLayoutWidth = SDCAlertViewWidth - SDCAlertViewContentPadding.left - SDCAlertViewContentPadding.right;
}

- (void)initializeMessageLabel {
	self.messageLabel = [[UILabel alloc] init];
	[self.messageLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
	self.messageLabel.font = [UIFont sdc_messageLabelFont];
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
	self.textFieldBackgroundView.layer.borderColor = [[UIColor sdc_textFieldBackgroundViewColor] CGColor];
	self.textFieldBackgroundView.layer.borderWidth = SDCAlertViewGetSeparatorThickness();
	self.textFieldBackgroundView.layer.masksToBounds = YES;
	self.textFieldBackgroundView.layer.cornerRadius = SDCAlertViewTextFieldBackgroundViewCornerRadius;
}

- (void)initializePrimaryTextField {
	self.primaryTextField = [[SDCAlertViewTextField alloc] init];
	[self.primaryTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
	self.primaryTextField.font = [UIFont sdc_textFieldFont];
	self.primaryTextField.textInsets = SDCAlertViewTextFieldTextInsets;
	self.primaryTextField.secureTextEntry = [self.delegate alertContentViewShouldUseSecureEntryForPrimaryTextField:self];
	[self.primaryTextField becomeFirstResponder];
}

- (void)initializeTextFieldSeparatorView {
	self.textFieldSeparatorView = [self separatorView];
}

- (void)initializeSecondaryTextField {
	self.secondaryTextField = [[SDCAlertViewTextField alloc] init];
	[self.secondaryTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
	self.secondaryTextField.font = [UIFont sdc_textFieldFont];
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
		
		if (otherButtonCount != 1 && [self.dataSource titleForCancelButtonInAlertContentView:self])
			return otherButtonCount + 1;
		else
			return otherButtonCount;
	} else {
		return 1;
	}
}

- (BOOL)isButtonAtIndexPathEnabled:(NSIndexPath *)indexPath {
	NSInteger firstOtherButtonRow = [self.mainTableView numberOfRowsInSection:indexPath.section] - 1;
	BOOL firstOtherButtonEnabled = [self.delegate alertContentViewShouldEnableFirstOtherButton:self];
	return (firstOtherButtonEnabled || (!firstOtherButtonEnabled && indexPath.row != firstOtherButtonRow));
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger otherButtonCount = [self.dataSource numberOfOtherButtonsInAlertContentView:self];
	
	if ((tableView == self.mainTableView && otherButtonCount) ||
		(tableView == self.mainTableView && otherButtonCount != 1 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1))
		cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
	else
		cell.textLabel.font = [UIFont systemFontOfSize:17];
	
	cell.backgroundColor = [UIColor clearColor];
	cell.textLabel.textColor = (tableView == self.secondaryTableView || [self isButtonAtIndexPathEnabled:indexPath]) ? [UIColor sdc_alertButtonTextColor] : [UIColor sdc_disabledAlertButtonTextColor];
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

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == self.secondaryTableView)
		return YES;
	
	return [self isButtonAtIndexPathEnabled:indexPath];
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
		
		if (otherButtonCount == 1 && cancelButtonTitle) {
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

#pragma mark - Custom Behavior

- (void)willMoveToSuperview:(UIView *)newSuperview {
	[super willMoveToSuperview:newSuperview];
	
	NSArray *elements = [self alertViewElementsToDisplay];
	
	if ([elements containsObject:self.titleLabel])			[self.contentScrollView addSubview:self.titleLabel];
	if ([elements containsObject:self.messageLabel])		[self.contentScrollView addSubview:self.messageLabel];
	if ([elements containsObject:self.contentScrollView])	[self addSubview:self.contentScrollView];
	
	if ([elements containsObject:self.textFieldBackgroundView]) {
		[self addSubview:self.textFieldBackgroundView];
		[self.textFieldBackgroundView addSubview:self.primaryTextField];
		
		self.primaryTextField.secureTextEntry = [self.delegate alertContentViewShouldUseSecureEntryForPrimaryTextField:self];
		
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

- (void)textFieldTextChanged:(NSNotification *)notification {
	if (notification.object == self.primaryTextField || notification.object == self.secondaryTextField)
		[self.mainTableView reloadData];
}

- (BOOL)resignFirstResponder {
	[super resignFirstResponder];
	
	[self.primaryTextField resignFirstResponder];
	[self.secondaryTextField resignFirstResponder];
	
	return YES;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Content View Layout

- (void)positionContentScrollView {
	NSMutableString *verticalVFL = [@"V:|" mutableCopy];
	NSArray *elements = [self alertViewElementsToDisplay];
	
	if ([elements containsObject:self.titleLabel]) {
		[self.titleLabel sdc_pinWidthToWidthOfView:self.contentScrollView offset:-(SDCAlertViewContentPadding.left + SDCAlertViewContentPadding.right)];
		[self.titleLabel sdc_horizontallyCenterInSuperview];
		[verticalVFL appendString:@"-(==topPadding)-[titleLabel]"];
	}
	
	if ([elements containsObject:self.messageLabel]) {
		[self.messageLabel sdc_pinWidthToWidthOfView:self.contentScrollView offset:-(SDCAlertViewContentPadding.left + SDCAlertViewContentPadding.right)];
		[self.messageLabel sdc_horizontallyCenterInSuperview];
		[verticalVFL appendString:@"-(==labelSpacing)-[messageLabel]"];
	}
	
	[verticalVFL appendString:@"|"];
	
	NSDictionary *mapping = @{@"titleLabel": self.titleLabel, @"messageLabel": self.messageLabel};
	NSDictionary *metrics = @{@"topPadding": @(SDCAlertViewContentPadding.top), @"labelSpacing": @(SDCAlertViewLabelSpacing)};
	[self.contentScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalVFL options:0 metrics:metrics views:mapping]];
}

- (void)positionTextFields {
	NSDictionary *mapping = @{@"primaryTextField": self.primaryTextField, @"textFieldSeparator": self.textFieldSeparatorView, @"secondaryTextField": self.secondaryTextField};
	NSDictionary *metrics = @{@"primaryTextFieldHeight": @(SDCAlertViewPrimaryTextFieldHeight), @"secondaryTextFieldHeight": @(SDCAlertViewSecondaryTextFieldHeight), @"separatorHeight": @(SDCAlertViewGetSeparatorThickness())};
	
	UIEdgeInsets insets = SDCAlertViewTextFieldBackgroundViewInsets;
	insets.right = -insets.right;
	
	[self.primaryTextField sdc_pinWidthToWidthOfView:self.textFieldBackgroundView offset:insets.left + insets.right];
	[self.primaryTextField sdc_horizontallyCenterInSuperview];
	
	NSMutableString *verticalVFL = [@"V:|[primaryTextField(==primaryTextFieldHeight)]" mutableCopy];
	
	if ([[self alertViewElementsToDisplay] containsObject:self.secondaryTextField]) {
		[self.secondaryTextField sdc_pinWidthToWidthOfView:self.textFieldBackgroundView offset:insets.left + insets.right];
		[self.secondaryTextField sdc_horizontallyCenterInSuperview];
		
		[self.textFieldSeparatorView sdc_pinHeight:SDCAlertViewGetSeparatorThickness()];
		[self.textFieldSeparatorView sdc_alignEdges:UIRectEdgeLeft|UIRectEdgeRight withView:self.textFieldBackgroundView];
		[self.textFieldSeparatorView sdc_alignEdges:UIRectEdgeTop withView:self.secondaryTextField];
		
		[verticalVFL appendString:@"[secondaryTextField(==secondaryTextFieldHeight)]"];
	}
	
	[verticalVFL appendString:@"|"];
	[self.textFieldBackgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalVFL options:0 metrics:metrics views:mapping]];
}

- (void)positionButtons {
	[self.mainTableView sdc_pinHeight:self.mainTableView.rowHeight * [self.mainTableView numberOfRowsInSection:0]];
	
	NSArray *elements = [self alertViewElementsToDisplay];
	if ([elements containsObject:self.secondaryTableView]) {
		[self.secondaryTableView sdc_pinHeightToHeightOfView:self.mainTableView];
		[self.secondaryTableView sdc_alignEdges:UIRectEdgeTop withView:self.mainTableView];
		
		[self.buttonSeparatorView sdc_pinHeightToHeightOfView:self.mainTableView];
		[self.buttonSeparatorView sdc_alignEdges:UIRectEdgeTop withView:self.mainTableView];
		[self.buttonSeparatorView sdc_pinWidth:SDCAlertViewGetSeparatorThickness()];
	}
	
	if ([elements containsObject:self.contentScrollView]) {
		[self.buttonTopSeparatorView sdc_horizontallyCenterInSuperview];
		[self.buttonTopSeparatorView sdc_pinWidthToWidthOfView:self];
		[self.buttonTopSeparatorView sdc_pinHeight:SDCAlertViewGetSeparatorThickness()];
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
		[self.contentScrollView sdc_pinHeight:[self heightForContentScrollView]];
		[self.contentScrollView sdc_alignEdges:UIRectEdgeLeft|UIRectEdgeRight withView:self];
		
		[verticalVFL appendString:@"[scrollView]"];
	}
	
	if ([elements containsObject:self.textFieldBackgroundView]) {
		UIEdgeInsets insets = SDCAlertViewTextFieldBackgroundViewPadding;
		insets.right = -insets.right;
		
		[self.textFieldBackgroundView sdc_alignEdges:UIRectEdgeLeft|UIRectEdgeRight withView:self insets:insets];
		[verticalVFL appendString:@"-(==textFieldBackgroundViewTopSpacing)-[textFieldBackgroundView]"];
	}
	
	if ([elements containsObject:self.mainTableView]) {
		if ([elements containsObject:self.secondaryTableView]) {
			[self.secondaryTableView sdc_alignEdges:UIRectEdgeLeft withView:self];
			[self.secondaryTableView sdc_pinWidth:SDCAlertViewWidth / 2];
			[self.mainTableView sdc_alignEdges:UIRectEdgeRight withView:self];
			[self.mainTableView sdc_pinWidth:SDCAlertViewWidth / 2];
			
			[self.buttonSeparatorView sdc_alignEdges:UIRectEdgeLeft withView:self.mainTableView];
		} else {
			[self.mainTableView sdc_alignEdges:UIRectEdgeLeft|UIRectEdgeRight withView:self];
		}
		
		[verticalVFL appendString:@"-(==bottomSpacing)-[buttonTopSeparatorView][mainTableView]"];
	}
	
	[verticalVFL appendString:@"|"];
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalVFL options:0 metrics:@{@"textFieldBackgroundViewTopSpacing": @(SDCAlertViewTextFieldBackgroundViewPadding.top), @"bottomSpacing": @(SDCAlertViewContentPadding.bottom)} views:@{@"scrollView": self.contentScrollView, @"textFieldBackgroundView": self.textFieldBackgroundView, @"buttonTopSeparatorView": self.buttonTopSeparatorView, @"mainTableView": self.mainTableView}]];
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

@implementation UIFont (SDCAlertViewFonts)

+ (UIFont *)sdc_titleLabelFont {
	return [UIFont boldSystemFontOfSize:17];
}

+ (UIFont *)sdc_messageLabelFont {
	return [UIFont systemFontOfSize:14];
}

+ (UIFont *)sdc_textFieldFont {
	return [UIFont systemFontOfSize:13];
}

@end
