//
//  UIView+SDCAutoLayout.h
//  AutoLayout
//
//  Created by Scott Berrevoets on 10/18/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT CGFloat const SDCAutoLayoutStandardSiblingDistance;
FOUNDATION_EXPORT CGFloat const SDCAutoLayoutStandardParentChildDistance;

@interface UIView (SDCAutoLayout)

// Helper method that returns the first common ancestor of self and view
- (UIView *)sdc_commonAncestorWithView:(UIView *)view;

// Aligning a view's edges with its superview
- (NSArray *)sdc_alignEdgesWithSuperview:(UIRectEdge)edges;
- (NSArray *)sdc_alignEdgesWithSuperview:(UIRectEdge)edges insets:(UIEdgeInsets)insets;

// Aligning a view's edges with another view
- (NSArray *)sdc_alignEdges:(UIRectEdge)edges withView:(UIView *)view;
- (NSArray *)sdc_alignEdges:(UIRectEdge)edges withView:(UIView *)view insets:(UIEdgeInsets)insets;

- (NSLayoutConstraint *)sdc_alignEdge:(UIRectEdge)edge withEdge:(UIRectEdge)otherEdge ofView:(UIView *)view;
- (NSLayoutConstraint *)sdc_alignEdge:(UIRectEdge)edge withEdge:(UIRectEdge)otherEdge ofView:(UIView *)view inset:(CGFloat)inset;

// Aligning a view's center with another view
- (NSArray *)sdc_alignCentersWithView:(UIView *)view;
- (NSArray *)sdc_alignCentersWithView:(UIView *)view offset:(UIOffset)offset;
- (NSLayoutConstraint *)sdc_alignHorizontalCenterWithView:(UIView *)view;
- (NSLayoutConstraint *)sdc_alignHorizontalCenterWithView:(UIView *)view offset:(CGFloat)offset;
- (NSLayoutConstraint *)sdc_alignVerticalCenterWithView:(UIView *)view;
- (NSLayoutConstraint *)sdc_alignVerticalCenterWithView:(UIView *)view offset:(CGFloat)offset;

// Centering a view in its superview
- (NSArray *)sdc_centerInSuperview;
- (NSArray *)sdc_centerInSuperviewWithOffset:(UIOffset)offset;
- (NSLayoutConstraint *)sdc_horizontallyCenterInSuperview;
- (NSLayoutConstraint *)sdc_horizontallyCenterInSuperviewWithOffset:(CGFloat)offset;
- (NSLayoutConstraint *)sdc_verticallyCenterInSuperview;
- (NSLayoutConstraint *)sdc_verticallyCenterInSuperviewWithOffset:(CGFloat)offset;

// Align a view's baseline with another view
- (NSLayoutConstraint *)sdc_alignBaselineWithView:(UIView *)view;
- (NSLayoutConstraint *)sdc_alignBaselineWithView:(UIView *)view offset:(CGFloat)offset;

// Pinning a view's dimensions with constants
- (NSLayoutConstraint *)sdc_pinWidth:(CGFloat)width;

- (NSLayoutConstraint *)sdc_setMinimumWidth:(CGFloat)minimumWidth;
- (NSLayoutConstraint *)sdc_setMaximumWidth:(CGFloat)maximumWidth;
- (NSLayoutConstraint *)sdc_setMaximumWidthToSuperviewWidth;
- (NSLayoutConstraint *)sdc_setMaximumWidthToSuperviewWidthWithOffset:(CGFloat)offset;

- (NSLayoutConstraint *)sdc_pinHeight:(CGFloat)height;
- (NSLayoutConstraint *)sdc_setMinimumHeight:(CGFloat)minimumHeight;
- (NSLayoutConstraint *)sdc_setMaximumHeight:(CGFloat)maximumHeight;
- (NSLayoutConstraint *)sdc_setMaximumHeightToSuperviewHeight;
- (NSLayoutConstraint *)sdc_setMaximumHeightToSuperviewHeightWithOffset:(CGFloat)offset;

- (NSArray *)sdc_pinSize:(CGSize)size;

// Pinning a view's dimensions to another view
- (NSLayoutConstraint *)sdc_pinWidthToWidthOfView:(UIView *)view;
- (NSLayoutConstraint *)sdc_pinWidthToWidthOfView:(UIView *)view offset:(CGFloat)offset;
- (NSLayoutConstraint *)sdc_pinHeightToHeightOfView:(UIView *)view;
- (NSLayoutConstraint *)sdc_pinHeightToHeightOfView:(UIView *)view offset:(CGFloat)offset;
- (NSArray *)sdc_pinSizeToSizeOfView:(UIView *)view;
- (NSArray *)sdc_pinSizeToSizeOfView:(UIView *)view offset:(UIOffset)offset;

// Setting the spacing between a view and other view
// A positive spacing (or 0) means self will be placed to the right of view
// A negative spacing means self will be placed to the left of view
- (NSLayoutConstraint *)sdc_pinHorizontalSpacing:(CGFloat)spacing toView:(UIView *)view;

// A positive spacing (or 0) means self will be placed below view
// A negative spacing means self will be placed above view
- (NSLayoutConstraint *)sdc_pinVerticalSpacing:(CGFloat)spacing toView:(UIView *)view;

- (NSArray *)sdc_pinSpacing:(UIOffset)spacing toView:(UIView *)view;

@end
