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

CGFloat const SDCAlertViewWidth = 270;
static CGFloat const SDCAlertViewSeparatorThickness = 1;
static CGFloat SDCAlertViewCornerRadius = 7;

static UIOffset SDCAlertViewParallaxSlideMagnitude = {15.75, 15.75};

CGFloat SDCAlertViewGetSeparatorThickness() {
	return SDCAlertViewSeparatorThickness / [[UIScreen mainScreen] scale];
}

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
	[self addMotionEffect:[self parallaxEffect]];
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

#pragma mark - UIKit Category Implementations

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
