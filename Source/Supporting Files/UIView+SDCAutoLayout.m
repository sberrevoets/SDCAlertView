//
//  UIView+SDCAutoLayout.m
//  AutoLayout
//
//  Created by Scott Berrevoets on 10/18/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "UIView+SDCAutoLayout.h"

CGFloat const SDCAutoLayoutStandardSiblingDistance = 8;
CGFloat const SDCAutoLayoutStandardParentChildDistance = 20;

@implementation UIView (SDCAutoLayout)

- (UIView *)sdc_commonAncestorWithView:(UIView *)view {
	if ([view isDescendantOfView:self])
		return self;
	
	if ([self isDescendantOfView:view])
		return view;
	
	UIView *commonAncestor;
	
	UIView *superview = self.superview;
	while (![view isDescendantOfView:superview]) {
		superview = superview.superview;
		
		if (!superview)
			break;
	}
		
	commonAncestor = superview;
	
	return commonAncestor;
}

#pragma mark - Edge Alignment

- (NSArray *)sdc_alignEdgesWithSuperview:(UIRectEdge)edges {
	return [self sdc_alignEdgesWithSuperview:edges insets:UIEdgeInsetsZero];
}

- (NSArray *)sdc_alignEdgesWithSuperview:(UIRectEdge)edges insets:(UIEdgeInsets)insets {
	NSAssert(self.superview != nil, @"View does not have a super view");
	return [self sdc_alignEdges:edges withView:self.superview insets:insets];
}

- (NSArray *)sdc_alignEdges:(UIRectEdge)edges withView:(UIView *)view {
	return [self sdc_alignEdges:edges withView:view insets:UIEdgeInsetsZero];
}

- (NSArray *)sdc_alignEdges:(UIRectEdge)edges withView:(UIView *)view insets:(UIEdgeInsets)insets {
	NSMutableArray *constraints = [NSMutableArray array];
	
	if (edges & UIRectEdgeTop)		[constraints addObject:[self sdc_alignEdge:UIRectEdgeTop withView:view inset:insets.top]];
	if (edges & UIRectEdgeRight)	[constraints addObject:[self sdc_alignEdge:UIRectEdgeRight withView:view inset:insets.right]];
	if (edges & UIRectEdgeBottom)	[constraints addObject:[self sdc_alignEdge:UIRectEdgeBottom withView:view inset:insets.bottom]];
	if (edges & UIRectEdgeLeft)		[constraints addObject:[self sdc_alignEdge:UIRectEdgeLeft withView:view inset:insets.left]];
	
	return constraints;
}

- (NSLayoutConstraint *)sdc_alignEdge:(UIRectEdge)edge withView:(UIView *)view inset:(CGFloat)inset {
	return [self sdc_alignEdge:edge withEdge:edge ofView:view inset:inset];
}

- (NSLayoutAttribute)sdc_layoutAttributeFromRectEdge:(UIRectEdge)edge {
	NSLayoutAttribute attribute = NSLayoutAttributeNotAnAttribute;
	switch (edge) {
		case UIRectEdgeTop:		attribute = NSLayoutAttributeTop;		break;
		case UIRectEdgeRight:	attribute = NSLayoutAttributeRight;		break;
		case UIRectEdgeBottom:	attribute = NSLayoutAttributeBottom;	break;
		case UIRectEdgeLeft: 	attribute = NSLayoutAttributeLeft;		break;
		default: break;
	}
	
	return attribute;
}

- (NSLayoutConstraint *)sdc_alignEdge:(UIRectEdge)edge withEdge:(UIRectEdge)otherEdge ofView:(UIView *)view {
	return [self sdc_alignEdge:edge withEdge:otherEdge ofView:view inset:0];
}

- (NSLayoutConstraint *)sdc_alignEdge:(UIRectEdge)edge withEdge:(UIRectEdge)otherEdge ofView:(UIView *)view inset:(CGFloat)inset {
	UIView *commonAncestor = [self sdc_commonAncestorWithView:view];
	
	NSLayoutAttribute attribute = [self sdc_layoutAttributeFromRectEdge:edge];
	NSLayoutAttribute otherAttribute = [self sdc_layoutAttributeFromRectEdge:otherEdge];
	
	if (attribute == NSLayoutAttributeNotAnAttribute || otherAttribute == NSLayoutAttributeNotAnAttribute)
		return nil;
	
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:NSLayoutRelationEqual toItem:view attribute:otherAttribute multiplier:1 constant:inset];
	[commonAncestor addConstraint:constraint];
	
	return constraint;
}

#pragma mark - Center Alignment

- (NSArray *)sdc_alignCentersWithView:(UIView *)view {
	return [self sdc_alignCentersWithView:view offset:UIOffsetZero];
}

- (NSArray *)sdc_alignCentersWithView:(UIView *)view offset:(UIOffset)offset {
	return @[[self sdc_alignHorizontalCenterWithView:view offset:offset.horizontal], [self sdc_alignVerticalCenterWithView:view offset:offset.vertical]];
}

- (NSLayoutConstraint *)sdc_alignHorizontalCenterWithView:(UIView *)view {
	return [self sdc_alignHorizontalCenterWithView:view offset:UIOffsetZero.horizontal];
}

- (NSLayoutConstraint *)sdc_alignHorizontalCenterWithView:(UIView *)view offset:(CGFloat)offset {
	UIView *commonAncestor = [self sdc_commonAncestorWithView:view];
	
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1 constant:offset];
	[commonAncestor addConstraint:constraint];
	
	return constraint;
}

- (NSLayoutConstraint *)sdc_alignVerticalCenterWithView:(UIView *)view {
	return [self sdc_alignVerticalCenterWithView:view offset:UIOffsetZero.vertical];
}

- (NSLayoutConstraint *)sdc_alignVerticalCenterWithView:(UIView *)view offset:(CGFloat)offset {
	UIView *commonAncestor = [self sdc_commonAncestorWithView:view];
	
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1 constant:offset];
	[commonAncestor addConstraint:constraint];
	
	return constraint;
}

#pragma mark Superview

- (NSArray *)sdc_centerInSuperview {
	return [self sdc_centerInSuperviewWithOffset:UIOffsetZero];
}

- (NSArray *)sdc_centerInSuperviewWithOffset:(UIOffset)offset {
	return @[[self sdc_horizontallyCenterInSuperviewWithOffset:offset.horizontal],
	[self sdc_verticallyCenterInSuperviewWithOffset:offset.vertical]];
}

- (NSLayoutConstraint *)sdc_horizontallyCenterInSuperview {
	return [self sdc_horizontallyCenterInSuperviewWithOffset:0];
}

- (NSLayoutConstraint *)sdc_horizontallyCenterInSuperviewWithOffset:(CGFloat)offset {
	NSAssert(self.superview != nil, @"View does not have a super view");
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:offset];
	[self.superview addConstraint:constraint];
	
	return constraint;
}

- (NSLayoutConstraint *)sdc_verticallyCenterInSuperview {
	return [self sdc_verticallyCenterInSuperviewWithOffset:0];
}

- (NSLayoutConstraint *)sdc_verticallyCenterInSuperviewWithOffset:(CGFloat)offset {
	NSAssert(self.superview != nil, @"View does not have a super view");
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:offset];
	
	[self.superview addConstraint:constraint];
	return constraint;
}

#pragma mark - Baseline Alignment

- (NSLayoutConstraint *)sdc_alignBaselineWithView:(UIView *)view {
	return [self sdc_alignBaselineWithView:view offset:0];
}
- (NSLayoutConstraint *)sdc_alignBaselineWithView:(UIView *)view offset:(CGFloat)offset {
	UIView *commonAncestor = [self sdc_commonAncestorWithView:view];
	
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBaseline relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBaseline multiplier:1 constant:offset];
	[commonAncestor addConstraint:constraint];
	
	return constraint;
}

#pragma mark - Pinning Constants

- (NSLayoutConstraint *)sdc_pinWidth:(CGFloat)width {
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:width];
	[self addConstraint:constraint];
	
	return constraint;
}

- (NSLayoutConstraint *)sdc_setMinimumWidth:(CGFloat)minimumWidth {
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:minimumWidth];
	[self addConstraint:constraint];
	
	return constraint;
}

- (NSLayoutConstraint *)sdc_setMaximumWidth:(CGFloat)maximumWidth {
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:maximumWidth];
	[self addConstraint:constraint];
	
	return constraint;
}

- (NSLayoutConstraint *)sdc_setMaximumWidthToSuperviewWidth {
	return [self sdc_setMaximumWidthToSuperviewWidthWithOffset:0];
}

- (NSLayoutConstraint *)sdc_setMaximumWidthToSuperviewWidthWithOffset:(CGFloat)offset {
	NSAssert(self.superview != nil, @"View does not have a super view");
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.superview attribute:NSLayoutAttributeWidth multiplier:1 constant:offset];
	[self.superview addConstraint:constraint];
	
	return constraint;
}

- (NSLayoutConstraint *)sdc_pinHeight:(CGFloat)height {
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:height];
	[self addConstraint:constraint];
	
	return constraint;
}

- (NSLayoutConstraint *)sdc_setMinimumHeight:(CGFloat)minimumHeight {
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:minimumHeight];
	[self addConstraint:constraint];
	
	return constraint;
}

- (NSLayoutConstraint *)sdc_setMaximumHeight:(CGFloat)maximumHeight {
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:maximumHeight];
	[self addConstraint:constraint];
	
	return constraint;
}

- (NSLayoutConstraint *)sdc_setMaximumHeightToSuperviewHeight {
	return [self sdc_setMaximumHeightToSuperviewHeightWithOffset:0];
}

- (NSLayoutConstraint *)sdc_setMaximumHeightToSuperviewHeightWithOffset:(CGFloat)offset {
	NSAssert(self.superview != nil, @"View does not have a super view");
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.superview attribute:NSLayoutAttributeHeight multiplier:1 constant:offset];
	[self.superview addConstraint:constraint];
	
	return constraint;
}

- (NSArray *)sdc_pinSize:(CGSize)size {
	return @[[self sdc_pinWidth:size.width], [self sdc_pinHeight:size.height]];
}

#pragma mark - Pinning Views

- (NSLayoutConstraint *)sdc_pinWidthToWidthOfView:(UIView *)view {
	return [self sdc_pinWidthToWidthOfView:view offset:0];
}

- (NSLayoutConstraint *)sdc_pinWidthToWidthOfView:(UIView *)view offset:(CGFloat)offset {
	UIView *commonAncestor = [self sdc_commonAncestorWithView:view];
	
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeWidth multiplier:1 constant:offset];
	[commonAncestor addConstraint:constraint];
	
	return constraint;
}

- (NSLayoutConstraint *)sdc_pinHeightToHeightOfView:(UIView *)view {
	return [self sdc_pinHeightToHeightOfView:view offset:0];
}

- (NSLayoutConstraint *)sdc_pinHeightToHeightOfView:(UIView *)view offset:(CGFloat)offset {
	UIView *commonAncestor = [self sdc_commonAncestorWithView:view];
	
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeHeight multiplier:1 constant:offset];
	[commonAncestor addConstraint:constraint];
	
	return constraint;
}

- (NSArray *)sdc_pinSizeToSizeOfView:(UIView *)view {
	return [self sdc_pinSizeToSizeOfView:view offset:UIOffsetZero];
}

- (NSArray *)sdc_pinSizeToSizeOfView:(UIView *)view offset:(UIOffset)offset {
	return @[[self sdc_pinWidthToWidthOfView:view offset:offset.horizontal],	[self sdc_pinHeightToHeightOfView:view offset:offset.vertical]];
}

#pragma mark - Pinning Spacing

- (NSLayoutConstraint *)sdc_pinHorizontalSpacing:(CGFloat)spacing toView:(UIView *)view {
	UIView *commonAncestor = [self sdc_commonAncestorWithView:view];
	
	NSLayoutConstraint *constraint;
	
	if (spacing >= 0) {
		constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeRight multiplier:1 constant:spacing];
	} else {
		constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeft multiplier:1 constant:fabs(spacing)];
	}
	
	[commonAncestor addConstraint:constraint];
	return constraint;
}

- (NSLayoutConstraint *)sdc_pinVerticalSpacing:(CGFloat)spacing toView:(UIView *)view {
	UIView *commonAncestor = [self sdc_commonAncestorWithView:view];
	
	NSLayoutConstraint *constraint;
	
	if (spacing >= 0) {
		constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1 constant:spacing];
	} else {
		constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1 constant:fabs(spacing)];
	}
	
	[commonAncestor addConstraint:constraint];
	return constraint;
}

- (NSArray *)sdc_pinSpacing:(UIOffset)spacing toView:(UIView *)view {
	return @[[self sdc_pinHorizontalSpacing:spacing.horizontal toView:view], [self sdc_pinVerticalSpacing:spacing.vertical toView:view]];
}

@end
