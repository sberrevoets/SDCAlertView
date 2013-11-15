//
//  SDCAlertView.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/20/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertView.h"

#import "SDCAlertViewController.h"
#import "SDCAlertViewBackgroundView.h"
#import "SDCAlertViewContentView.h"

#import "UIView+SDCAutoLayout.h"

CGFloat const SDCAlertViewWidth = 270;
static CGFloat const SDCAlertViewSeparatorThickness = 1;
static CGFloat SDCAlertViewCornerRadius = 7;

static UIOffset SDCAlertViewParallaxSlideMagnitude = {15.75, 15.75};

static NSInteger SDCAlertViewUnspecifiedButtonIndex = -1;
static NSInteger SDCAlertViewDefaultFirstButtonIndex = 0;

CGFloat SDCAlertViewGetSeparatorThickness() {
	return SDCAlertViewSeparatorThickness / [[UIScreen mainScreen] scale];
}

#pragma mark - SDCAlertView

@interface SDCAlertView () <SDCAlertViewContentViewDataSource, SDCAlertViewContentViewDelegate>

@property (nonatomic, strong) SDCAlertViewController *alertViewController;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *cancelButtonTitle;
@property (nonatomic, strong) NSMutableArray *otherButtonTitles;

@property (nonatomic, getter = isVisible) BOOL visible;

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

- (UIView *)contentView {
	return self.alertContentView.customContentView;
}

- (UIMotionEffectGroup *)parallaxEffect {
	UIInterpolatingMotionEffect *horizontalParallax;
	UIInterpolatingMotionEffect *verticalParallax;
	
	horizontalParallax = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
	horizontalParallax.minimumRelativeValue = @(-SDCAlertViewParallaxSlideMagnitude.horizontal);
	horizontalParallax.maximumRelativeValue = @(SDCAlertViewParallaxSlideMagnitude.horizontal);
	
	verticalParallax = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
	verticalParallax.minimumRelativeValue = @(-SDCAlertViewParallaxSlideMagnitude.vertical);
	verticalParallax.maximumRelativeValue = @(SDCAlertViewParallaxSlideMagnitude.vertical);
	
	UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
	group.motionEffects = @[horizontalParallax, verticalParallax];

	return group;
}

- (SDCAlertViewBackgroundView *)alertBackgroundView {
	if (!_alertBackgroundView) {
		_alertBackgroundView = [[SDCAlertViewBackgroundView alloc] init];
		[_alertBackgroundView setTranslatesAutoresizingMaskIntoConstraints:NO];
	}
	
	return _alertBackgroundView;
}

- (SDCAlertViewContentView *)alertContentView {
	if (!_alertContentView) {
		_alertContentView = [[SDCAlertViewContentView alloc] initWithDelegate:self dataSource:self];
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
		
		if (cancelButtonTitle) {
			_cancelButtonTitle = cancelButtonTitle;
			_cancelButtonIndex = SDCAlertViewDefaultFirstButtonIndex;
		} else {
			_cancelButtonIndex = SDCAlertViewUnspecifiedButtonIndex;
		}
		
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

#pragma mark - Visibility

- (void)show {
	[self addMotionEffect:[self parallaxEffect]];
	[self insertSubview:self.alertBackgroundView atIndex:0];
	[self addSubview:self.alertContentView];
	
	if ([self.delegate respondsToSelector:@selector(willPresentAlertView:)])
		[self.delegate willPresentAlertView:self];
	
	[self.alertViewController showAlert:self completion:^{
		self.visible = YES;
		
		if ([self.delegate respondsToSelector:@selector(didPresentAlertView:)])
			[self.delegate didPresentAlertView:self];
	}];
}


- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
	[self tappedButtonAtIndex:buttonIndex];
}

- (BOOL)resignFirstResponder {
	[super resignFirstResponder];
	[self.alertContentView resignFirstResponder];
	
	return YES;
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

- (BOOL)alertContentViewShouldUseSecureEntryForPrimaryTextField:(SDCAlertViewContentView *)sender {
	return self.alertViewStyle == SDCAlertViewStyleSecureTextInput;
}

- (BOOL)alertContentViewShouldShowSecondaryTextField:(SDCAlertViewContentView *)sender {
	return self.alertViewStyle == SDCAlertViewStyleLoginAndPasswordInput;
}

- (CGFloat)maximumHeightForAlertContentView:(SDCAlertViewContentView *)sender {
	return CGRectGetHeight(self.superview.bounds);
}

- (void)alertContentView:(SDCAlertViewContentView *)sender didTapButtonAtIndex:(NSUInteger)index {
	[self tappedButtonAtIndex:index];
}

- (BOOL)alertContentViewShouldEnableFirstOtherButton:(SDCAlertViewContentView *)sender {
	if ([self.delegate respondsToSelector:@selector(alertViewShouldEnableFirstOtherButton:)])
		return [self.delegate alertViewShouldEnableFirstOtherButton:self];
	else
		return YES;
}

- (void)alertContentViewDidTapCancelButton:(SDCAlertViewContentView *)sender {
	[self tappedButtonAtIndex:self.cancelButtonIndex];
}

#pragma mark - Buttons & Text Fields

- (void)tappedButtonAtIndex:(NSInteger)index {
	if ([self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
		[self.delegate alertView:self clickedButtonAtIndex:index];
	
	if (([self.delegate respondsToSelector:@selector(alertView:shouldDismissWithButtonIndex:)] && [self.delegate alertView:self shouldDismissWithButtonIndex:index]) || ![self.delegate respondsToSelector:@selector(alertView:shouldDismissWithButtonIndex:)]) {
		
		if ([self.delegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)])
			[self.delegate alertView:self willDismissWithButtonIndex:index];
		
		[self.alertViewController dismissAlert:self completion:^{
			if ([self.delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)])
				[self.delegate alertView:self didDismissWithButtonIndex:index];
		}];
	}
}

- (NSInteger)firstOtherButtonIndex {
	if ([self.otherButtonTitles count] > 0 && self.cancelButtonIndex == 0)
		return self.cancelButtonIndex + 1;
	else if ([self.otherButtonTitles count] > 0 && !self.cancelButtonTitle)
		return SDCAlertViewDefaultFirstButtonIndex;
	
	return SDCAlertViewUnspecifiedButtonIndex;
}

- (NSInteger)numberOfButtons {
	NSInteger buttonCount = [self.otherButtonTitles count];
	
	if (self.cancelButtonTitle)
		buttonCount++;
	
	return buttonCount;
}

- (NSInteger)addButtonWithTitle:(NSString *)title {
	[self.otherButtonTitles addObject:title];
	return [self.otherButtonTitles indexOfObject:title];
}

- (NSString *)buttonTitleAtIndex:(NSInteger)index {
	return self.otherButtonTitles[index];
}

- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex {
	return self.alertContentView.textFields[textFieldIndex];
}

#pragma mark - Auto-Layout

- (void)updateConstraints {
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
	[self sdc_setMaximumHeightToSuperviewHeight];
}

#pragma mark - Cleanup

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@implementation UIColor (SDCAlertViewColors)

+ (UIColor *)sdc_alertBackgroundColor {
	return [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1];
}

+ (UIColor *)sdc_alertButtonTextColor {
	return [UIColor colorWithRed:16/255.0 green:144/255.0 blue:248/255.0 alpha:1];
}

+ (UIColor *)sdc_disabledAlertButtonTextColor {
	return [UIColor colorWithRed:143/255.0 green:143/255.0 blue:143/255.0 alpha:1];
}

+ (UIColor *)sdc_alertSeparatorColor {
	return [UIColor colorWithRed:189/255.0 green:189/255.0 blue:189/255.0 alpha:1];
}

+ (UIColor *)sdc_textFieldBackgroundViewColor {
	return [UIColor colorWithWhite:0.5 alpha:0.5];
}

@end
