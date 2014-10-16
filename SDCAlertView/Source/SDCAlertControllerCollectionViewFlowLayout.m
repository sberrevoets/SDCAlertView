//
//  SDCAlertControllerCollectionViewFlowLayout.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/22/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertControllerCollectionViewFlowLayout.h"

NSString *const SDCAlertControllerDecorationKindHorizontalSeparator = @"SDCAlertControllerDecorationKindHorizontalSeparator";
NSString *const SDCAlertControllerDecorationKindVerticalSeparator = @"SDCAlertControllerDecorationKindVerticalSeparator";

@interface SDCAlertControllerCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes
@property (nonatomic, strong) UIColor *backgroundColor;
@end

@implementation SDCAlertControllerCollectionViewFlowLayout

+ (Class)layoutAttributesClass {
	return [SDCAlertControllerCollectionViewLayoutAttributes class];
}

- (instancetype)init {
	self = [super init];
	
	if (self) {
		self.minimumInteritemSpacing = 0;
		self.minimumLineSpacing = 0;
	}
	
	return self;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
	NSMutableArray *attributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
	
	[[attributes copy] enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *itemAttributes, NSUInteger idx, BOOL *stop) {
		NSIndexPath *indexPath = itemAttributes.indexPath;
		
		[attributes addObject:[self layoutAttributesForDecorationViewOfKind:SDCAlertControllerDecorationKindHorizontalSeparator atIndexPath:indexPath]];
		
		if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal && indexPath.item > 0) {
			[attributes addObject:[self layoutAttributesForDecorationViewOfKind:SDCAlertControllerDecorationKindVerticalSeparator atIndexPath:indexPath]];
		}
	}];
	
	return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
	SDCAlertControllerCollectionViewLayoutAttributes *attributes = [SDCAlertControllerCollectionViewLayoutAttributes
																	layoutAttributesForDecorationViewOfKind:elementKind
																	withIndexPath:indexPath];
	
	UICollectionViewLayoutAttributes *itemAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
	attributes.zIndex = itemAttributes.zIndex + 1;
	attributes.backgroundColor = self.visualStyle.actionViewSeparatorColor;
	
	CGRect decorationFrame = itemAttributes.frame;
	if (elementKind == SDCAlertControllerDecorationKindHorizontalSeparator) {
		decorationFrame.size.height = self.visualStyle.actionViewSeparatorThickness;
	} else {
		decorationFrame.size.width = self.visualStyle.actionViewSeparatorThickness;
	}
	
	attributes.frame = decorationFrame;
	
	return attributes;
}

@end

@implementation SDCAlertControllerCollectionViewLayoutAttributes
@end