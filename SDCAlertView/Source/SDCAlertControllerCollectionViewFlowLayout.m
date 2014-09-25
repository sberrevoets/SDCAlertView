//
//  SDCAlertControllerCollectionViewFlowLayout.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/22/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertControllerCollectionViewFlowLayout.h"

@implementation SDCAlertControllerCollectionViewFlowLayout

- (instancetype)init {
	self = [super init];
	
	if (self) {
		self.minimumInteritemSpacing = 0;
	}
	
	return self;
}

@end
