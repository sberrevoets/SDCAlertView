//
//  SDCAlertController.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/14/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertController.h"

#import "SDCAlertTextFieldViewController.h"
#import "SDCAlertTransition.h"
#import "SDCAlertRepresentationView.h"
#import "SDCAlertControllerDefaultVisualStyle.h"

#import "UIView+SDCAutoLayout.h"

@interface SDCAlertAction (Private)
@property (nonatomic, copy) void (^handler)(SDCAlertAction *);
@end

@interface SDCAlertController () <SDCAlertRepresentationViewDelegate>
@property (nonatomic, strong) NSMutableArray *mutableActions;
@property (nonatomic, strong) NSMutableArray *mutableTextFields;
@property (nonatomic, strong) id<UIViewControllerTransitioningDelegate> transitioningDelegate;
@property (nonatomic, strong) id<SDCAlertControllerVisualStyle> visualStyle;
@property (nonatomic, strong) SDCAlertRepresentationView *alert;
@end

@implementation SDCAlertController

#pragma mark - Creation

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(SDCAlertControllerStyle)preferredStyle {
	SDCAlertController *alert = [[self alloc] initWithTitle:title message:message preferredStyle:preferredStyle];
	return alert;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(SDCAlertControllerStyle)preferredStyle {
	self = [self init];
	
	NSAssert(preferredStyle == SDCAlertControllerStyleAlert, @"Only SDCAlertControllerStyleAlert is supported by %@", NSStringFromClass([self class]));
	
	if (self) {
		self.title = title;
		_message = message;
		
		_mutableActions = [NSMutableArray array];
		_mutableTextFields = [NSMutableArray array];
		
		_visualStyle = [[SDCAlertControllerDefaultVisualStyle alloc] init];
		_buttonLayout = SDCAlertControllerButtonLayoutAutomatic;
		
		self.modalPresentationStyle = UIModalPresentationCustom;
		self.transitioningDelegate = [[SDCAlertTransitioningDelegate alloc] init];
	}
	
	return self;
}

#pragma mark - Alert View

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.alert = [self createAlertView];
	
	[self.view addSubview:self.alert];
	[self.alert sdc_centerInSuperview];
}

- (void)showTextFieldsInAlertView:(SDCAlertRepresentationView *)alertView {
	if (self.textFields.count > 0) {
		SDCAlertTextFieldViewController *textFieldViewController = [[SDCAlertTextFieldViewController alloc] init];
		textFieldViewController.textFields = self.textFields;
		
		[self addChildViewController:textFieldViewController];
		[alertView showTextFieldViewController:textFieldViewController];
		[textFieldViewController didMoveToParentViewController:self];
	}
}

- (SDCAlertRepresentationView *)createAlertView {
	SDCAlertRepresentationView *alert = [[SDCAlertRepresentationView alloc] initWithTitle:self.title message:self.message];
	alert.delegate = self;
	alert.visualStyle = self.visualStyle;
	alert.actions = self.actions;
	alert.buttonLayout = self.buttonLayout;
	
	[self showTextFieldsInAlertView:alert];
	
	return alert;
}

#pragma mark - Style

- (SDCAlertControllerStyle)preferredStyle {
	return SDCAlertControllerStyleAlert;
}

- (void)applyVisualStyle:(id<SDCAlertControllerVisualStyle>)visualStyle {
	_visualStyle = visualStyle;
}

#pragma mark - Alert Actions

- (void)addAction:(SDCAlertAction *)action {
	[self.mutableActions addObject:action];
}

- (NSArray *)actions {
	return [self.mutableActions copy];
}

- (void)alertRepresentationView:(SDCAlertRepresentationView *)sender didPerformAction:(SDCAlertAction *)action {
	if (!action.isEnabled) {
		return;
	}
	
	[self.presentingViewController dismissViewControllerAnimated:YES completion:^{
		if (action.handler) {
			action.handler(action);
		}
	}];
}

#pragma mark - Alert Text Fields

- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *))configurationHandler {
	UITextField *textField = [[UITextField alloc] init];
	textField.font = self.visualStyle.textFieldFont;
	[self.mutableTextFields addObject:textField];
	
	if (configurationHandler) {
		configurationHandler(textField);
	}
}

- (NSArray *)textFields {
	return [self.mutableTextFields copy];
}

@end