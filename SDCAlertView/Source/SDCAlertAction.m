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
	return [[self alloc] initWithTitle:title style:style handler:handler];
}

+ (instancetype)actionWithAttributedTitle:(NSAttributedString *)attributedTitle style:(SDCAlertActionStyle)style handler:(void (^)(SDCAlertAction *))handler {
	return [[self alloc] initWithAttributedTitle:attributedTitle style:style handler:handler];
}

- (instancetype)initWithStyle:(SDCAlertActionStyle)style handler:(void (^)(SDCAlertAction *action))handler {
	self = [super init];
	
	if (self) {
		_style = style;
		_enabled = YES;
		_handler = handler;
	}
	
	return self;
}

- (instancetype)initWithTitle:(NSString *)title style:(SDCAlertActionStyle)style handler:(void (^)(SDCAlertAction *))handler {
	self = [self initWithStyle:style handler:handler];
	
	if (self) {
		_title = title;
	}
	
	return self;
}

- (instancetype)initWithAttributedTitle:(NSAttributedString *)attributedTitle style:(SDCAlertActionStyle)style handler:(void (^)(SDCAlertAction *handler))handler {
	self = [self initWithStyle:style handler:handler];
	
	if (self) {
		_attributedTitle = attributedTitle;
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