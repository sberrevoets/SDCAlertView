//
//  SDCAlertViewBackgroundView.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 11/5/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertViewBackgroundView.h"

static NSString *const SDCAlertViewBackgroundViewImageName = @"SDCAlertViewBackground.png";

@implementation SDCAlertViewBackgroundView

- (id)init {
	self = [super init];
	
	if (self)
		[self addBackgroundImage];
	
	return self;
}

- (void)addBackgroundImage {
	UIImage *image = [UIImage imageNamed:SDCAlertViewBackgroundViewImageName];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	
	[self addSubview:imageView];
}

@end
