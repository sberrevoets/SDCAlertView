//
//  SDCAlertViewContentView.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 11/5/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertViewContentView.h"

#import "SDCAlertView_Private.h"
#import "UIView+SDCAutoLayout.h"

static UIEdgeInsets const SDCAlertViewContentPadding = {19, 15, 18.5, 15};

static CGFloat const SDCAlertViewLabelSpacing = 4;

static CGFloat const SDCAlertViewTextFieldBackgroundViewCornerRadius = 5;
static UIEdgeInsets const SDCAlertViewTextFieldBackgroundViewPadding = {20, 15, 0, 15};
static UIEdgeInsets const SDCAlertViewTextFieldBackgroundViewInsets = {0, 2, 0, 2};
static UIEdgeInsets const SDCAlertViewTextFieldTextInsets = {0, 4, 0, 4};
static CGFloat const SDCAlertViewPrimaryTextFieldHeight = 30;
static CGFloat const SDCAlertViewSecondaryTextFieldHeight = 29;

static CGFloat const SDCAlertViewSeparatorThickness = 1;
CGFloat SDCAlertViewGetSeparatorThickness() {
	return SDCAlertViewSeparatorThickness / [[UIScreen mainScreen] scale];
}

@interface UIFont (SDCAlertViewFonts)
+ (UIFont *)sdc_titleLabelFont;
+ (UIFont *)sdc_messageLabelFont;
+ (UIFont *)sdc_textFieldFont;
+ (UIFont *)sdc_suggestedButtonFont;
+ (UIFont *)sdc_normalButtonFont;
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
@property (nonatomic, strong) UITableView *suggestedButtonTableView;
@property (nonatomic, strong) UITableView *otherButtonsTableView;
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

#pragma mark - Setters

- (void)setTitle:(NSString *)title {
	_title = title;
	self.titleLabel.text = title;
}

- (void)setMessage:(NSString *)message {
	_message = message;
	self.messageLabel.text = message;
}

#pragma mark - Initialization

- (instancetype)initWithDelegate:(id<SDCAlertViewContentViewDelegate>)delegate {
	self = [super init];
	
	if (self) {
		_delegate = delegate;
		
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
	[self initializeCustomContentView];
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

- (void)initializeCustomContentView {
	self.customContentView = [[UIView alloc] init];
	[self.customContentView setTranslatesAutoresizingMaskIntoConstraints:NO];
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
	self.suggestedButtonTableView = [self buttonTableView];
}

- (void)initializeButtonSeparatorView {
	self.buttonSeparatorView = [self separatorView];
}

- (void)initializeSecondaryTableView {
	self.otherButtonsTableView = [self buttonTableView];
}

#pragma mark - UITableViewDataSource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (tableView == self.suggestedButtonTableView)
		return 1;
	else
		return [self.buttonTitles count] - 1;
}

- (BOOL)isButtonAtIndexPathEnabled:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
	NSUInteger buttonIndex = (tableView == self.suggestedButtonTableView) ? [self.buttonTitles count] - 1 : indexPath.row;
	return [self.delegate alertContentView:self shouldEnableButtonAtIndex:buttonIndex];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == self.suggestedButtonTableView)
		cell.textLabel.font = [UIFont sdc_suggestedButtonFont];
	else
		cell.textLabel.font = [UIFont sdc_normalButtonFont];
	
	cell.backgroundColor = [UIColor clearColor];
	cell.textLabel.textAlignment = NSTextAlignmentCenter;
	
	if ([self isButtonAtIndexPathEnabled:indexPath tableView:tableView])
		cell.textLabel.textColor = [UIColor sdc_alertButtonTextColor];
	else
		cell.textLabel.textColor = [UIColor sdc_disabledAlertButtonTextColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	
	if (tableView == self.suggestedButtonTableView)
		cell.textLabel.text = self.buttonTitles[[self.buttonTitles count] - 1];
	else
		cell.textLabel.text = self.buttonTitles[indexPath.row];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger buttonIndex = (tableView == self.suggestedButtonTableView) ? [self.buttonTitles count] - 1 : indexPath.row;
	
	if ([self.delegate respondsToSelector:@selector(alertContentView:shouldDeselectButtonAtIndex:)]) {
		if ([self.delegate alertContentView:self shouldDeselectButtonAtIndex:buttonIndex])
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
    
	[self.delegate alertContentView:self didTapButtonAtIndex:buttonIndex];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	return [self isButtonAtIndexPathEnabled:indexPath tableView:tableView];
}

#pragma mark - Layout

- (NSArray *)alertViewElementsToDisplay {
	NSMutableArray *elements = [NSMutableArray array];
	
	if ([self.titleLabel.text length] > 0)		[elements addObject:self.titleLabel];
	if ([self.messageLabel.text length] > 0)	[elements addObject:self.messageLabel];
	if ([elements count] > 0)					[elements addObject:self.contentScrollView];
	
	if (self.numberOfTextFields > 0) {
		[elements addObject:self.textFieldBackgroundView];
		[elements addObject:self.primaryTextField];
		
		if (self.numberOfTextFields == 2) {
			[elements addObject:self.textFieldSeparatorView];
			[elements addObject:self.secondaryTextField];
		}
	}
	
	if ([[self.customContentView subviews] count] > 0)		[elements addObject:self.customContentView];
	
	if ([self.buttonTitles count] > 0) {
		// There is at least one button, so we want to display the top separator for sure
		[elements addObject:self.buttonTopSeparatorView];
		
		if ([self.buttonTitles count] > 1) {
			// There is more than one button, so also display the table view that holds the button(s) that is/are not suggested
			[elements addObject:self.otherButtonsTableView];
			
			if ([self.buttonTitles count] == 2)
				[elements addObject:self.buttonSeparatorView]; // There are exactly two buttons, display the thin separator
		}

		// And lastly, add the suggested button (this line is at the end because the suggested button is also at the "end" of the alert)
		[elements addObject:self.suggestedButtonTableView];
	}
		
	return elements;
}

- (void)updateConstraints {
	NSArray *elements = [self alertViewElementsToDisplay];
	
	if ([elements containsObject:self.contentScrollView])			[self positionContentScrollView];
	if ([elements containsObject:self.textFieldBackgroundView])		[self positionTextFields];
	if ([elements containsObject:self.customContentView])			[self positionCustomContentView];
	if ([elements containsObject:self.suggestedButtonTableView])	[self positionButtons];
	
	[self positionAlertElements];
	
	[super updateConstraints];
}

#pragma mark - Custom Behavior

- (BOOL)becomeFirstResponder {
	[super becomeFirstResponder];
	[self.primaryTextField becomeFirstResponder];
	
	return YES;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	[super willMoveToSuperview:newSuperview];
	
	NSArray *elements = [self alertViewElementsToDisplay];
	
	if ([elements containsObject:self.titleLabel])			[self.contentScrollView addSubview:self.titleLabel];
	if ([elements containsObject:self.messageLabel])		[self.contentScrollView addSubview:self.messageLabel];
	if ([elements containsObject:self.contentScrollView])	[self addSubview:self.contentScrollView];
	
	if ([elements containsObject:self.primaryTextField]) {
		[self addSubview:self.textFieldBackgroundView];
		[self.textFieldBackgroundView addSubview:self.primaryTextField];
		
		self.primaryTextField.secureTextEntry = [self.delegate alertContentViewShouldUseSecureEntryForPrimaryTextField:self];
		
		if ([elements containsObject:self.secondaryTextField]) {
			[self.textFieldBackgroundView addSubview:self.textFieldSeparatorView];
			[self.textFieldBackgroundView addSubview:self.secondaryTextField];
			
			self.primaryTextField.placeholder = NSLocalizedString(@"Login", nil);
			self.secondaryTextField.placeholder = NSLocalizedString(@"Password", nil);
		}
	}
	
	if ([elements containsObject:self.customContentView])
		[self addSubview:self.customContentView];
	
	if ([elements containsObject:self.suggestedButtonTableView]) {
		[self addSubview:self.suggestedButtonTableView];
		[self addSubview:self.buttonTopSeparatorView];
	}
	
	if ([elements containsObject:self.otherButtonsTableView]) {
		[self addSubview:self.otherButtonsTableView];
		[self insertSubview:self.buttonSeparatorView aboveSubview:self.otherButtonsTableView];
	}
}

- (void)textFieldTextChanged:(NSNotification *)notification {
	if (notification.object == self.primaryTextField || notification.object == self.secondaryTextField)
		[self.suggestedButtonTableView reloadData];
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
	NSMutableString *verticalVFL = [@"V:|-(==topSpace)" mutableCopy];
	NSArray *elements = [self alertViewElementsToDisplay];
	
	CGFloat topSpace = SDCAlertViewContentPadding.top;
	if (![elements containsObject:self.titleLabel]) topSpace += SDCAlertViewLabelSpacing;
	
	if ([elements containsObject:self.titleLabel]) {
		[self.titleLabel sdc_pinWidthToWidthOfView:self.contentScrollView offset:-(SDCAlertViewContentPadding.left + SDCAlertViewContentPadding.right)];
		[self.titleLabel sdc_horizontallyCenterInSuperview];
		[verticalVFL appendString:@"-[titleLabel]"];
	}
	
	if ([elements containsObject:self.messageLabel]) {
		[self.messageLabel sdc_pinWidthToWidthOfView:self.contentScrollView offset:-(SDCAlertViewContentPadding.left + SDCAlertViewContentPadding.right)];
		[self.messageLabel sdc_horizontallyCenterInSuperview];
		
		if ([elements containsObject:self.titleLabel])
			[verticalVFL appendString:@"-(==labelSpace)"];
		
		[verticalVFL appendString:@"-[messageLabel]"];
	}
	
	[verticalVFL appendString:@"|"];
	
	NSDictionary *mapping = @{@"titleLabel": self.titleLabel, @"messageLabel": self.messageLabel};
	NSDictionary *metrics = @{@"topSpace": @(topSpace), @"labelSpace": @(SDCAlertViewLabelSpacing)};
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

- (void)positionCustomContentView {
	[self.customContentView sdc_pinWidthToWidthOfView:self];
	[self.customContentView sdc_horizontallyCenterInSuperview];
}

- (BOOL)showsTableViewsSideBySide {
	// Returns YES when the two buttons are shown side by side, NO when they are stacked on top of each other
	return [self.buttonTitles count] == 2;
}

- (void)positionButtons {
	NSArray *elements = [self alertViewElementsToDisplay];
	
	if ([elements containsObject:self.contentScrollView]) {
		[self.buttonTopSeparatorView sdc_horizontallyCenterInSuperview];
		[self.buttonTopSeparatorView sdc_pinWidthToWidthOfView:self];
		[self.buttonTopSeparatorView sdc_pinHeight:SDCAlertViewGetSeparatorThickness()];
	}
	
	[self.suggestedButtonTableView sdc_pinHeight:self.suggestedButtonTableView.rowHeight];
		
	if ([elements containsObject:self.otherButtonsTableView]) {
		[self.otherButtonsTableView sdc_pinHeight:self.otherButtonsTableView.rowHeight * [self.otherButtonsTableView numberOfRowsInSection:0]];
		
		if ([self showsTableViewsSideBySide]) {
			[self.suggestedButtonTableView sdc_alignEdges:UIRectEdgeRight withView:self];
			[self.suggestedButtonTableView sdc_pinWidth:SDCAlertViewWidth / 2];
			
			[self.otherButtonsTableView sdc_alignEdges:UIRectEdgeLeft withView:self];
			[self.otherButtonsTableView sdc_pinWidth:SDCAlertViewWidth / 2];
			[self.otherButtonsTableView sdc_alignEdges:UIRectEdgeTop withView:self.suggestedButtonTableView];
			
			[self.buttonSeparatorView sdc_pinHeightToHeightOfView:self.suggestedButtonTableView];
			[self.buttonSeparatorView sdc_alignEdges:UIRectEdgeTop|UIRectEdgeLeft withView:self.suggestedButtonTableView];
			[self.buttonSeparatorView sdc_pinWidth:SDCAlertViewGetSeparatorThickness()];
		} else {
			[self.suggestedButtonTableView sdc_alignEdges:UIRectEdgeLeft|UIRectEdgeRight withView:self];
			[self.otherButtonsTableView sdc_alignEdges:UIRectEdgeLeft|UIRectEdgeRight withView:self];
		}
	} else {
		[self.suggestedButtonTableView sdc_alignEdges:UIRectEdgeLeft|UIRectEdgeRight withView:self];
	}
}

- (CGFloat)heightForContentScrollView {
	NSArray *elements = [self alertViewElementsToDisplay];
	
	CGFloat scrollViewHeight = SDCAlertViewContentPadding.top + [self.titleLabel intrinsicContentSize].height + [self.messageLabel intrinsicContentSize].height;
	if ([[self alertViewElementsToDisplay] containsObject:self.messageLabel])	scrollViewHeight += SDCAlertViewLabelSpacing;
		
	CGFloat maximumScrollViewHeight = [self.delegate maximumHeightForAlertContentView:self] - SDCAlertViewContentPadding.bottom;
	if ([elements containsObject:self.suggestedButtonTableView])
		maximumScrollViewHeight -= (self.suggestedButtonTableView.rowHeight * [self.suggestedButtonTableView numberOfRowsInSection:0] + SDCAlertViewGetSeparatorThickness());
	
	if ([elements containsObject:self.primaryTextField])
		maximumScrollViewHeight -= (SDCAlertViewTextFieldBackgroundViewPadding.top + SDCAlertViewTextFieldBackgroundViewPadding.bottom + SDCAlertViewPrimaryTextFieldHeight);
	
	return MIN(scrollViewHeight, maximumScrollViewHeight);
}

- (void)positionAlertElements {
	NSArray *elements = [self alertViewElementsToDisplay];
	
	NSMutableString *verticalVFL = [@"V:|" mutableCopy];
	BOOL hasContentOtherThanButtons = NO;
	
	if ([elements containsObject:self.contentScrollView]) {
		[self.contentScrollView sdc_pinHeight:[self heightForContentScrollView]];
		[self.contentScrollView sdc_alignEdges:UIRectEdgeLeft|UIRectEdgeRight withView:self];
		
		[verticalVFL appendString:@"[scrollView]"];
		hasContentOtherThanButtons = YES;
	}
	
	if ([elements containsObject:self.textFieldBackgroundView]) {
		UIEdgeInsets insets = SDCAlertViewTextFieldBackgroundViewPadding;
		insets.right = -insets.right;
		
		[self.textFieldBackgroundView sdc_alignEdges:UIRectEdgeLeft|UIRectEdgeRight withView:self insets:insets];
		[verticalVFL appendString:@"-(==textFieldBackgroundViewTopSpacing)-[textFieldBackgroundView]"];
		hasContentOtherThanButtons = YES;
	}
	
	if ([elements containsObject:self.customContentView]) {
		[verticalVFL appendString:@"-[customContentView]"];
		hasContentOtherThanButtons = YES;
	}
	
	if ([elements containsObject:self.suggestedButtonTableView]) {
		if (hasContentOtherThanButtons)
			[verticalVFL appendString:@"-(==bottomSpacing)-[buttonTopSeparatorView]"];
		
		if ([elements containsObject:self.otherButtonsTableView])
			[verticalVFL appendString:@"[otherButtonsTableView]"];
		
		if (![self showsTableViewsSideBySide])
			[verticalVFL appendString:@"[suggestedButtonTableView]"];
	}
	
	[verticalVFL appendString:@"|"];
	
	NSDictionary *metrics = @{@"textFieldBackgroundViewTopSpacing": @(SDCAlertViewTextFieldBackgroundViewPadding.top), @"bottomSpacing": @(SDCAlertViewContentPadding.bottom)};
	NSDictionary *views = @{@"scrollView": self.contentScrollView, @"textFieldBackgroundView": self.textFieldBackgroundView, @"customContentView": self.customContentView, @"buttonTopSeparatorView": self.buttonTopSeparatorView, @"suggestedButtonTableView": self.suggestedButtonTableView, @"otherButtonsTableView": self.otherButtonsTableView};
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalVFL options:0 metrics:metrics views:views]];
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

+ (UIFont *)sdc_suggestedButtonFont {
	return [UIFont boldSystemFontOfSize:17];
}

+ (UIFont *)sdc_normalButtonFont {
	return [UIFont systemFontOfSize:17];
}

@end
