//
//  SDCAlertAction.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/14/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertController.h"

@interface SDCAlertAction ()
@property (nonatomic, copy) void (^handler)(SDCAlertAction *);
@end

@implementation SDCAlertAction

#pragma mark - Initialization

+ (instancetype)actionWithTitle:(NSString *)title style:(SDCAlertActionStyle)style handler:(void (^)(SDCAlertAction *))handler {
	SDCAlertAction *action = [[self alloc] initWithTitle:title style:style handler:handler];
	return action;
}

- (instancetype)initWithTitle:(NSString *)title style:(SDCAlertActionStyle)style handler:(void (^)(SDCAlertAction *))handler {
	self = [self init];
	
	if (self) {
		_title = title;
		_style = style;
		_enabled = YES;
		_handler = handler;
	}
	
	return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
	NSString *title = [self.title copy];
	void (^handler)(SDCAlertAction *) = [self.handler copy];
	
	id copy = [[[self class] alloc] initWithTitle:title style:self.style handler:handler];
	return copy;
}

@end