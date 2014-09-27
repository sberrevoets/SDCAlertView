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

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
	NSMutableArray *attributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
	
	[[attributes copy] enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *itemAttributes, NSUInteger idx, BOOL *stop) {
		[attributes addObject:[self layoutAttributesForDecorationViewOfKind:@"separator" atIndexPath:itemAttributes.indexPath]];
	}];
	
	UICollectionViewLayoutAttributes *topSeparatorAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:@"separator"
																														   withIndexPath:nil];
	topSeparatorAttributes.frame = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetWidth(rect), 0.5);
	
	[attributes addObject:topSeparatorAttributes];
	
	return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
	return [super layoutAttributesForItemAtIndexPath:indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
	UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:elementKind
																											   withIndexPath:indexPath];
	
	UICollectionViewLayoutAttributes *itemAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
	attributes.frame = CGRectMake(CGRectGetMaxX(itemAttributes.frame) - 0.5, CGRectGetMinY(itemAttributes.frame), 0.5, CGRectGetHeight(itemAttributes.frame));
	attributes.zIndex = itemAttributes.zIndex + 1;
	
	return attributes;
}

@end