//
//  SDCAlertController.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/14/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertController.h"

#import "SDCAlertTransition.h"

@interface SDCAlertController ()
@property (nonatomic, strong) NSMutableArray *mutableActions;
@property (nonatomic, strong) NSMutableArray *textFieldConfigurationHandlers;
@property (nonatomic, strong) id<UIViewControllerTransitioningDelegate> transitioningDelegate;
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
		
		self.modalPresentationStyle = UIModalPresentationCustom;
		self.transitioningDelegate = [[SDCAlertTransitioningDelegate alloc] init];
	}
	
	return self;
}

#pragma mark - Style

- (SDCAlertControllerStyle)preferredStyle {
	return SDCAlertControllerStyleAlert;
}

#pragma mark - Alert Actions

- (void)addAction:(SDCAlertAction *)action {
	[self.mutableActions addObject:action];
}

- (NSArray *)actions {
	return [self.mutableActions copy];
}

#pragma mark - Alert Text Fields

- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *))configurationHandler {
	[self.textFieldConfigurationHandlers addObject:[configurationHandler copy]];
}

- (NSArray *)textFields {
	return [NSArray array];
}



@end