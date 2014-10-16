//
//  SDCAlertLabel.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/21/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertLabel.h"

@implementation SDCAlertLabel

- (instancetype)init {
	self = [super init];
	
	if (self) {
		[self setTranslatesAutoresizingMaskIntoConstraints:NO];
		self.textAlignment = NSTextAlignmentCenter;
		self.numberOfLines = 0;
	}
	
	return self;
}

- (void)layoutSubviews {
	self.preferredMaxLayoutWidth = CGRectGetWidth(self.bounds);
	[super layoutSubviews];
}

@end
