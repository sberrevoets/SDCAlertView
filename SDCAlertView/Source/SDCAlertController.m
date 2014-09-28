//
//  SDCAlertController.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/14/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertController.h"

#import "SDCAlertTransition.h"
#import "SDCAlertRepresentationView.h"
#import "SDCAlertControllerDefaultVisualStyle.h"

#import "UIView+SDCAutoLayout.h"

@interface SDCAlertAction (Private)
@property (nonatomic, copy) void (^handler)(SDCAlertAction *);
@end

@interface SDCAlertController () <SDCAlertRepresentationViewDelegate>
@property (nonatomic, strong) NSMutableArray *mutableActions;
@property (nonatomic, strong) NSMutableArray *textFieldConfigurationHandlers;
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
		_textFieldConfigurationHandlers = [NSMutableArray array];
		
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
	
	self.alert = [[SDCAlertRepresentationView alloc] initWithTitle:self.title message:self.message];
	self.alert.delegate = self;
	self.alert.visualStyle = self.visualStyle;
	self.alert.actions = self.actions;
	self.alert.buttonLayout = self.buttonLayout;
	
	[self.view addSubview:self.alert];
	[self.alert sdc_centerInSuperview];
	
	[self.view addSubview:self.alert];
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
	[self.textFieldConfigurationHandlers addObject:[configurationHandler copy]];
}

- (NSArray *)textFields {
	return [NSArray array];
}

@end