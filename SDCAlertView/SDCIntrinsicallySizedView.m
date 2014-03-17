//
//  SDCIntrinsicallySizedView.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 3/16/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCIntrinsicallySizedView.h"

@implementation SDCIntrinsicallySizedView

- (CGSize)intrinsicContentSize {
	__block CGFloat minX = CGFLOAT_MAX;
	__block CGFloat maxX = CGFLOAT_MIN;
	__block CGFloat minY = CGFLOAT_MAX;
	__block CGFloat maxY = CGFLOAT_MIN;
	
	[[self subviews] enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
		// Ignore _UILayoutGuide
		if (![subview conformsToProtocol:@protocol(UILayoutSupport)]) {
			// We could use CGRectGet(Min|Max)(X|Y) using the subview.frame, but subview.frame is undefined when a transform is applied. This calculation is transform-friendly.
			minX = MIN(minX, subview.center.x - CGRectGetWidth(subview.bounds) / 2);
			maxX = MAX(maxX, subview.center.x + CGRectGetWidth(subview.bounds) / 2);
			minY = MIN(minY, subview.center.y - CGRectGetHeight(subview.bounds) / 2);
			maxY = MAX(maxY, subview.center.y + CGRectGetHeight(subview.bounds) / 2);
		}
	}];
	
	// If minX is still set to CGFLOAT_MAX, there were no subviews, so just return super's intrinsicContentSize
	if (minX == CGFLOAT_MAX)
		return [super intrinsicContentSize];
	
	return CGSizeMake(maxX - minX, maxY - minY);
}

- (void)layoutSubviews {
	[super layoutSubviews];
	[self invalidateIntrinsicContentSize];
}

@end
