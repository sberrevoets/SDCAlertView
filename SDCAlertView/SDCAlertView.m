//
//  SDCAlertView.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/20/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertView_Private.h"

#import "SDCAlertViewController.h"
#import "SDCAlertViewCoordinator.h"
#import "SDCAlertViewBackgroundView.h"
#import "SDCAlertViewContentView.h"

#import "UIView+SDCAutoLayout.h"

CGFloat const SDCAlertViewWidth = 270;
static UIEdgeInsets const SDCAlertViewPadding = {3, 0, 3, 0};
static CGFloat const SDCAlertViewCornerRadius = 7;

static UIOffset const SDCAlertViewParallaxSlideMagnitude = {15.75, 15.75};

static NSInteger const SDCAlertViewUnspecifiedButtonIndex = -1;
static NSInteger const SDCAlertViewDefaultFirstButtonIndex = 0;

#pragma mark - SDCAlertView

@interface SDCAlertView () <SDCAlertViewContentViewDelegate>
@property (nonatomic, strong) SDCAlertViewBackgroundView *alertBackgroundView;
@property (nonatomic, strong) SDCAlertViewContentView *alertContentView;
@property (nonatomic, strong) UIToolbar *toolbar;

@property (nonatomic, strong) NSMutableArray *buttonTitles;
@property (nonatomic) NSInteger firstOtherButtonIndex;
@end

@implementation SDCAlertView

#pragma mark - Getters

- (SDCAlertViewBackgroundView *)alertBackgroundView {
	if (!_alertBackgroundView) {
		_alertBackgroundView = [[SDCAlertViewBackgroundView alloc] init];
		[_alertBackgroundView setTranslatesAutoresizingMaskIntoConstraints:NO];
	}
	
	return _alertBackgroundView;
}

- (SDCAlertViewContentView *)alertContentView {
	if (!_alertContentView) {
		_alertContentView = [[SDCAlertViewContentView alloc] initWithDelegate:self];
		[_alertContentView setTranslatesAutoresizingMaskIntoConstraints:NO];
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
		_delegate = delegate;
		
		_cancelButtonIndex = SDCAlertViewUnspecifiedButtonIndex;
		_firstOtherButtonIndex = SDCAlertViewUnspecifiedButtonIndex;
		
		_buttonTitles = [NSMutableArray array];
		
		if (cancelButtonTitle) {
			_buttonTitles[0] = cancelButtonTitle;
			_cancelButtonIndex = SDCAlertViewDefaultFirstButtonIndex;
		}
		
		va_list argumentList;
		va_start(argumentList, otherButtonTitles);
		for (NSString *buttonTitle = otherButtonTitles; buttonTitle != nil; buttonTitle = va_arg(argumentList, NSString *))
			[self addButtonWithTitle:buttonTitle];
		
		[self setTranslatesAutoresizingMaskIntoConstraints:NO];
		
		self.layer.masksToBounds = YES;
		self.layer.cornerRadius = SDCAlertViewCornerRadius;
	}
	
	return self;
}

#pragma mark - Visibility

- (BOOL)isVisible {
	return [[SDCAlertViewCoordinator sharedCoordinator] visibleAlert] == self;
}

#pragma mark - Presenting

- (void)show {
	[self configureForShowing];
	[[SDCAlertViewCoordinator sharedCoordinator] presentAlert:self];
}

- (void)showWithDismissHandler:(void (^)(NSInteger))dismissHandler {
	self.didDismissHandler = dismissHandler;
	[self show];
}

- (void)configureForShowing {
	UIInterpolatingMotionEffect *horizontalParallax;
	UIInterpolatingMotionEffect *verticalParallax;
	
	horizontalParallax = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
	horizontalParallax.minimumRelativeValue = @(-SDCAlertViewParallaxSlideMagnitude.horizontal);
	horizontalParallax.maximumRelativeValue = @(SDCAlertViewParallaxSlideMagnitude.horizontal);
	
	verticalParallax = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
	verticalParallax.minimumRelativeValue = @(-SDCAlertViewParallaxSlideMagnitude.vertical);
	verticalParallax.maximumRelativeValue = @(SDCAlertViewParallaxSlideMagnitude.vertical);
	
	UIMotionEffectGroup *groupMotionEffect = [[UIMotionEffectGroup alloc] init];
	groupMotionEffect.motionEffects = @[horizontalParallax, verticalParallax];
	[self addMotionEffect:groupMotionEffect];
	
	[self insertSubview:self.alertBackgroundView atIndex:0];
	
	[self configureContent];
	[self addSubview:self.alertContentView];
}

- (void)willBePresented {
	if ([self.delegate respondsToSelector:@selector(willPresentAlertView:)])
		[self.delegate willPresentAlertView:self];
}

- (void)wasPresented {
	if ([self.delegate respondsToSelector:@selector(didPresentAlertView:)])
		[self.delegate didPresentAlertView:self];
}

#pragma mark - Dismissing

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
	[[SDCAlertViewCoordinator sharedCoordinator] dismissAlert:self withButtonIndex:buttonIndex];
}

- (void)willBeDismissedWithButtonIndex:(NSInteger)buttonIndex {
	if ([self.delegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)])
		[self.delegate alertView:self willDismissWithButtonIndex:buttonIndex];
    
    if (self.willDismissHandler)
        self.willDismissHandler(buttonIndex);
}

- (void)wasDismissedWithButtonIndex:(NSInteger)buttonIndex {
	if ([self.delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)])
		[self.delegate alertView:self didDismissWithButtonIndex:buttonIndex];
	
	if (self.didDismissHandler)
		self.didDismissHandler(buttonIndex);
}

#pragma mark - First Responder

- (BOOL)becomeFirstResponder {
	[super becomeFirstResponder];
	[self.alertContentView becomeFirstResponder];
	
	return YES;
}

- (BOOL)resignFirstResponder {
	[super resignFirstResponder];
	[self.alertContentView resignFirstResponder];
	
	return YES;
}

#pragma mark - Content

- (void)setTitle:(NSString *)title {
	_title = title;
	self.alertContentView.title = title;
}

- (void)setMessage:(NSString *)message {
	_message = message;
	self.alertContentView.message = message;
}

- (UIView *)contentView {
	return self.alertContentView.customContentView;
}

- (void)setCancelButtonIndex:(NSInteger)cancelButtonIndex {
	_cancelButtonIndex = cancelButtonIndex;
	if (cancelButtonIndex != SDCAlertViewDefaultFirstButtonIndex)
		self.firstOtherButtonIndex = SDCAlertViewDefaultFirstButtonIndex;
}

- (NSArray *)buttonTitlesForAlertContentView {
	NSMutableArray *buttonTitles = [self.buttonTitles mutableCopy];
	
	// The cancel button is always the last button, except when there are two buttons, then it is the first (or the one on the left)
	if (self.cancelButtonIndex != SDCAlertViewUnspecifiedButtonIndex && self.numberOfButtons != 2) {
		NSString *cancelButtonTitle = buttonTitles[self.cancelButtonIndex];
		[buttonTitles removeObjectIdenticalTo:cancelButtonTitle];
		[buttonTitles addObject:cancelButtonTitle];
	}
	
	return buttonTitles;
}

- (NSInteger)convertAlertContentViewButtonIndexToRealButtonIndex:(NSInteger)buttonIndex {
	NSMutableArray *buttonTitles = [self.alertContentView.buttonTitles mutableCopy];
	return [self.buttonTitles indexOfObjectIdenticalTo:buttonTitles[buttonIndex]];
}

- (void)configureContent {
	self.alertContentView.title = self.title;
	self.alertContentView.message = self.message;
	
	switch (self.alertViewStyle) {
		case SDCAlertViewStyleDefault:					self.alertContentView.numberOfTextFields = 0; break;
		case SDCAlertViewStylePlainTextInput:
		case SDCAlertViewStyleSecureTextInput:			self.alertContentView.numberOfTextFields = 1; break;
		case SDCAlertViewStyleLoginAndPasswordInput:	self.alertContentView.numberOfTextFields = 2; break;
	}
	
	self.alertContentView.buttonTitles = [self buttonTitlesForAlertContentView];
}

#pragma mark - SDCAlertViewContentViewDelegate

- (BOOL)alertContentViewShouldUseSecureEntryForPrimaryTextField:(SDCAlertViewContentView *)sender {
	return self.alertViewStyle == SDCAlertViewStyleSecureTextInput;
}

- (CGFloat)maximumHeightForAlertContentView:(SDCAlertViewContentView *)sender {
	return CGRectGetHeight(self.superview.bounds) - SDCAlertViewPadding.top - SDCAlertViewPadding.bottom;
}

- (void)alertContentView:(SDCAlertViewContentView *)sender didTapButtonAtIndex:(NSUInteger)index {
	[self tappedButtonAtIndex:[self convertAlertContentViewButtonIndexToRealButtonIndex:index]];
}

- (BOOL)alertContentView:(SDCAlertViewContentView *)sender shouldEnableButtonAtIndex:(NSUInteger)index {
	NSInteger convertedIndex = [self convertAlertContentViewButtonIndexToRealButtonIndex:index];
	
	if (convertedIndex == self.firstOtherButtonIndex && [self.delegate respondsToSelector:@selector(alertViewShouldEnableFirstOtherButton:)])
		return [self.delegate alertViewShouldEnableFirstOtherButton:self];
	
	return YES;
}

- (BOOL)alertContentView:(SDCAlertViewContentView *)sender shouldDeselectButtonAtIndex:(NSUInteger)index {
	if ([self.delegate respondsToSelector:@selector(alertView:shouldDeselectButtonAtIndex:)])
		return [self.delegate alertView:self shouldDeselectButtonAtIndex:index];
	else if (self.shouldDeselectButtonHandler)
		return self.shouldDeselectButtonHandler(index);

	return YES;
}

#pragma mark - Buttons & Text Fields

- (void)tappedButtonAtIndex:(NSInteger)index {
	if ([self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
		[self.delegate alertView:self clickedButtonAtIndex:index];
	
	if (self.clickedButtonHandler)
		self.clickedButtonHandler(index);
	
	if ([self.delegate respondsToSelector:@selector(alertView:shouldDismissWithButtonIndex:)]) {
		if ([self.delegate alertView:self shouldDismissWithButtonIndex:index])
			[self dismissWithClickedButtonIndex:index animated:YES];
	} else if (self.shouldDismissHandler) {
		if (self.shouldDismissHandler(index))
			[self dismissWithClickedButtonIndex:index animated:YES];
	} else {
		[self dismissWithClickedButtonIndex:index animated:YES];
	}
}

- (NSInteger)addButtonWithTitle:(NSString *)title {
	[self.buttonTitles addObject:title];
	
	if (self.firstOtherButtonIndex == SDCAlertViewUnspecifiedButtonIndex) {
		if (self.cancelButtonIndex == SDCAlertViewUnspecifiedButtonIndex)
			self.firstOtherButtonIndex = SDCAlertViewDefaultFirstButtonIndex;
		else
			self.firstOtherButtonIndex = self.cancelButtonIndex + 1;
	}
	
	return [self.buttonTitles indexOfObject:title];
}

- (NSInteger)numberOfButtons {
	return [self.buttonTitles count];
}

- (NSString *)buttonTitleAtIndex:(NSInteger)index {
	return self.buttonTitles[index];
}

- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex {
	return self.alertContentView.textFields[textFieldIndex];
}

#pragma mark - Layout

- (void)layoutSubviews {
	[super layoutSubviews];
	[self applyBlurEffect];
	[super layoutSubviews];
}

- (void)applyBlurEffect {
	self.toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
	self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[self insertSubview:self.toolbar atIndex:0];
}

- (void)updateConstraints {
	[self removeConstraints:[self constraints]];
	
	[self.alertBackgroundView sdc_centerInSuperview];
	[self.alertBackgroundView sdc_pinWidthToWidthOfView:self];
	[self.alertBackgroundView sdc_pinHeightToHeightOfView:self];
	
	[self.alertContentView sdc_centerInSuperview];
	[self.alertContentView sdc_pinWidthToWidthOfView:self];
	[self.alertContentView sdc_pinHeightToHeightOfView:self];
	
	[self positionSelf];
	
	[super updateConstraints];
}

- (void)positionSelf {
	[self sdc_pinWidth:SDCAlertViewWidth];
	[self sdc_centerInSuperview];
}

#pragma mark - Cleanup

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@implementation UIColor (SDCAlertViewColors)

+ (UIColor *)sdc_alertButtonTextColor {
	return [UIColor colorWithRed:16/255.0 green:144/255.0 blue:248/255.0 alpha:1];
}

+ (UIColor *)sdc_disabledAlertButtonTextColor {
	return [UIColor colorWithRed:143/255.0 green:143/255.0 blue:143/255.0 alpha:1];
}

+ (UIColor *)sdc_alertSeparatorColor {
	return [UIColor colorWithWhite:0.5 alpha:0.5];
}

+ (UIColor *)sdc_textFieldBackgroundViewColor {
	return [UIColor colorWithWhite:0.5 alpha:0.5];
}

+ (UIColor *)sdc_dimmedBackgroundColor {
	return [UIColor colorWithWhite:0 alpha:.4];
}

@end
