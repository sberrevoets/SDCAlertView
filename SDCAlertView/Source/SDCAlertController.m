//
//  SDCAlertController.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/14/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertController.h"

#import "SDCAlertControllerTextFieldViewController.h"
#import "SDCAlertControllerTransition.h"
#import "SDCAlertControllerView.h"
#import "SDCAlertControllerDefaultVisualStyle.h"
#import "SDCIntrinsicallySizedView.h"
#import "SDCAlertView.h"

#import "UIView+SDCAutoLayout.h"
#import "UIViewController+Current.h"

@interface SDCAlertAction (Private)
@property (nonatomic, copy) void (^handler)(SDCAlertAction *action);
@end

@interface SDCAlertController () <SDCAlertControllerViewDelegate>
@property (nonatomic) SDCAlertControllerStyle preferredStyle;
@property (nonatomic, strong) NSMutableArray *mutableActions;
@property (nonatomic, strong) NSMutableArray *mutableTextFields;
@property (nonatomic, strong) id<UIViewControllerTransitioningDelegate> transitioningDelegate;
@property (nonatomic, strong) SDCAlertControllerView *alert;
@property (nonatomic, strong) SDCAlertView *legacyAlertView;
@property (nonatomic) BOOL didAssignFirstResponder;
@property (nonatomic, getter=isPresentingAlert) BOOL presentingAlert;
@end

@implementation SDCAlertController
@dynamic title;

#pragma mark - Initialization

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(SDCAlertControllerStyle)preferredStyle {
	return [[self alloc] initWithTitle:title message:message style:preferredStyle];
}

+ (instancetype)alertControllerWithAttributedTitle:(NSAttributedString *)attributedTitle
								 attributedMessage:(NSAttributedString *)attributedMessage
									preferredStyle:(SDCAlertControllerStyle)preferredStyle {
	return [[self alloc] initWithAttributedTitle:attributedTitle attributedMessage:attributedMessage style:preferredStyle];
}

- (instancetype)initWithStyle:(SDCAlertControllerStyle)style {
	self = [super init];

	if (self) {
		_mutableActions = [NSMutableArray array];
		_mutableTextFields = [NSMutableArray array];

		_preferredStyle = style;
		_visualStyle = [[SDCAlertControllerDefaultVisualStyle alloc] init];
		_actionLayout = SDCAlertControllerActionLayoutAutomatic;

		self.modalPresentationStyle = UIModalPresentationCustom;
		self.transitioningDelegate = [[SDCAlertControllerTransitioningDelegate alloc] init];
	}

	return self;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message style:(SDCAlertControllerStyle)style {
	self = [self initWithStyle:style];

	if (self) {
		self.title = title;
		_message = message;

		[self createAlert];
	}

	return self;
}

- (instancetype)initWithAttributedTitle:(NSAttributedString *)attributedTitle
					  attributedMessage:(NSAttributedString *)attributedMessage
								  style:(SDCAlertControllerStyle)style {
	self = [self initWithStyle:style];

	if (self) {
		_attributedTitle = attributedTitle;
		_attributedMessage = attributedMessage;

		[self createAlert];
	}

	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Alert View

- (NSAttributedString *)attributedStringForString:(NSString *)string {
	return string ? [[NSAttributedString alloc] initWithString:string] : nil;
}

- (void)setTitle:(NSString *)title {
	[super setTitle:title];
	self.alert.title = [self attributedStringForString:title];
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle {
	_attributedTitle = attributedTitle;
	self.alert.title = attributedTitle;
}

- (void)setMessage:(NSString *)message {
	_message = message;
	self.alert.message = [self attributedStringForString:message];
}

- (void)setAttributedMessage:(NSAttributedString *)attributedMessage {
	_attributedMessage = attributedMessage;
	self.alert.message = attributedMessage;
}

- (SDCAlertView *)legacyAlertView {
	if (!_legacyAlertView && self.usesLegacyAlert) {
		_legacyAlertView = [SDCAlertView alertViewWithAlertController:self];
	}
	return _legacyAlertView;
}

- (void)createAlert {
	NSAttributedString *title = self.attributedTitle ? : [self attributedStringForString:self.title];
	NSAttributedString *message = self.attributedMessage ? : [self attributedStringForString:self.message];
	self.alert = [[SDCAlertControllerView alloc] initWithTitle:title message:message];

	self.alert.delegate = self;
	self.alert.contentView = [[SDCIntrinsicallySizedView alloc] init];
	[self.alert.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
}

- (void)showTextFieldsInAlertView:(SDCAlertControllerView *)alertView {
	if (self.textFields.count > 0) {
		SDCAlertControllerTextFieldViewController *textFieldViewController = [[SDCAlertControllerTextFieldViewController alloc] initWithTextFields:self.textFields
																																	   visualStyle:self.visualStyle];
		[self addChildViewController:textFieldViewController];
		[alertView showTextFieldViewController:textFieldViewController];
		[textFieldViewController didMoveToParentViewController:self];
	}
}

- (UIView *)contentView {
	return self.alert.contentView;
}

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardUpdate:) name:UIKeyboardWillChangeFrameNotification object:nil];

	self.alert.visualStyle = self.visualStyle;
	self.alert.actions = self.actions;
	self.alert.actionLayout = self.actionLayout;

	[self showTextFieldsInAlertView:self.alert];

	self.presentingAlert = YES;

	[self.view addSubview:self.alert];
	[self.alert sdc_pinWidth:self.visualStyle.width];
	[self.alert sdc_centerInSuperview];

	[self.alert prepareForDisplay];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];

	// Explanation of why the first responder is set here:
	// http://stackoverflow.com/questions/1132784/iphone-have-the-keyboard-slide-into-view-from-the-right-like-when-editing-a-no

	if (!self.didAssignFirstResponder) {
		[self.textFields.firstObject becomeFirstResponder];
		self.didAssignFirstResponder = YES;
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.presentingAlert = NO;
}

#pragma mark - Alert Actions

- (void)addAction:(SDCAlertAction *)action {
	[self.mutableActions addObject:action];
}

- (NSArray *)actions {
	return [self.mutableActions copy];
}

- (void)alertControllerView:(SDCAlertControllerView *)sender didPerformAction:(SDCAlertAction *)action {
	if (!action.isEnabled || (self.shouldDismissBlock && !self.shouldDismissBlock(action))) {
		return;
	}

	[self dismissWithCompletion:^{
		if (action.handler) {
			action.handler(action);
		}
	}];
}

#pragma mark - Alert Text Fields

- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *))configurationHandler {
	UITextField *textField = [[UITextField alloc] init];
	textField.font = self.visualStyle.textFieldFont;
	textField.autocorrectionType = UITextAutocorrectionTypeNo;
	[self.mutableTextFields addObject:textField];

	if (configurationHandler) {
		configurationHandler(textField);
	}
}

- (NSArray *)textFields {
	return [self.mutableTextFields copy];
}

- (void)keyboardUpdate:(NSNotification *)notification {
	NSValue *frameValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
	CGRect frame = [frameValue CGRectValue];

	// Apparently, we are in the middle of an animation block when this method is called, meaning there is no need to create one with the right duration
	// and curve. Probably a bug on Apple's end, but it does work in our favor here.
	self.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetMinY(frame));

	if (!self.isPresentingAlert) {
		[self.alert layoutIfNeeded];
	}
}

@end

@implementation SDCAlertController (Presentation)

- (void)presentWithCompletion:(void(^)(void))completion {
	if (self.usesLegacyAlert) {
		self.legacyAlertView.didPresentHandler = completion;
		[self.legacyAlertView show];
	} else {
		UIViewController *currentViewController = [UIViewController sdc_currentViewController];
		[self presentFromViewController:currentViewController completionHandler:completion];
	}
}

- (void)presentFromViewController:(UIViewController *)viewController completionHandler:(void (^)(void))completionHandler {
	[viewController presentViewController:self animated:YES completion:completionHandler];
}

- (void)dismissWithCompletion:(void (^)(void))completion {
	if (self.usesLegacyAlert) {
		self.legacyAlertView.didDismissHandler = ^(NSInteger buttonIndex) {
			if (completion) {
				completion();
			}
		};

		[self.legacyAlertView dismissWithClickedButtonIndex:NSIntegerMax animated:YES];
	} else {
		[self.presentingViewController dismissViewControllerAnimated:YES completion:completion];
	}
}

@end

@implementation SDCAlertController (Convenience)

+ (instancetype)showAlertControllerWithTitle:(NSString *)title message:(NSString *)message {
	return [self showAlertControllerWithTitle:title message:message actionTitle:nil];
}

+ (instancetype)showAlertControllerWithTitle:(NSString *)title message:(NSString *)message actionTitle:(NSString *)actionTitle {
	return [self showAlertControllerWithTitle:title message:message actionTitle:actionTitle subview:nil];
}

+ (instancetype)showAlertControllerWithTitle:(NSString *)title message:(NSString *)message actionTitle:(NSString *)actionTitle subview:(UIView *)subview {
	SDCAlertController *controller = [SDCAlertController alertControllerWithTitle:title message:message preferredStyle:SDCAlertControllerStyleAlert];
	[controller addAction:[SDCAlertAction actionWithTitle:actionTitle style:SDCAlertActionStyleCancel handler:nil]];

	if (subview) {
		[controller.contentView addSubview:subview];
	}

	[controller presentWithCompletion:nil];
	return controller;
}

@end

@implementation SDCAlertController (Legacy)

- (BOOL)usesLegacyAlert {
	return
	self.preferredStyle == SDCAlertControllerStyleLegacyAlert ||
	![NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)];
}

- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex {
	if (self.legacyAlertView) {
		return [self.legacyAlertView textFieldAtIndex:textFieldIndex];
	} else {
		return [self.textFields objectAtIndex:textFieldIndex];
	}
}

@end
