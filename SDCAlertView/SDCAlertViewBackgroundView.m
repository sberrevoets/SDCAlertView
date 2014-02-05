//
//  SDCAlertViewBackgroundView.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 11/5/13.
//  Initial drawRect: implementation/revision by Chris Stroud on 4/2/2014
//
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertViewBackgroundView.h"

@implementation SDCAlertViewBackgroundView

- (BOOL)isOpaque
{
	return NO;
}

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Gray colorspace used for the background color
	CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();
	
	// Background color components:
	//
	// [<CALayer: 0x155faec0> backgroundColor]: <CGColor 0x15541550> [<CGColorSpace 0x1558f4c0> (kCGColorSpaceDeviceGray)] ( 0.97 0.96 )
	//
	CGFloat backgroundColorComponents[2] = {0.97f, 0.96f};
	
	// Fill the BG color
	CGColorRef alertBackgroundColor = CGColorCreate(grayColorSpace, backgroundColorComponents);
	CGContextSetFillColorWithColor(context, alertBackgroundColor);
	CGContextFillRect(context, rect);
	
	//
	// Gradient color components:
	//
	// [<_UIModalItemAlertBackgroundView: 0x15763a60> _gradientImageForBoundsSize:-- withInnerColor:UIDeviceWhiteColorSpace 1 0.5 outerColor:UIDeviceWhiteColorSpace 1 0]
	//
	CGColorRef startColor = [[UIColor colorWithWhite:1.0f alpha:0.5f] CGColor];
	CGColorRef endColor   = [[UIColor colorWithWhite:1.0f alpha:0.0f] CGColor];
	
	// Gradient colors
	NSArray * colors = @[(__bridge id)startColor, (__bridge id)endColor];
	
	// Gradient locations
	CGFloat locations[2] = {0.0f, 1.0f};
	
	// This gradient will default to the +[UIColor colorWithWhite: alpha:] colorspace
	// since UIDeviceWhiteColorSpace is seemingly private
	CGGradientRef gradient = CGGradientCreateWithColors(CGColorGetColorSpace(startColor), (__bridge CFArrayRef)colors, locations);
	
	/*
	 *
	 * This trick for transforming the circular gradient is great and is largely derived from: http://stackoverflow.com/a/12665177
	 *
	 */
	
	// Scaling transformation and keeping track of the inverse
    CGAffineTransform scaleT = CGAffineTransformMakeScale(1.0, CGRectGetHeight(rect) / CGRectGetWidth(rect));
    CGAffineTransform invScaleT = CGAffineTransformInvert(scaleT);
	
    // Extract the Sx and Sy elements from the inverse matrix
    // (See the Quartz documentation for the math behind the matrices)
    CGPoint invS = CGPointMake(invScaleT.a, invScaleT.d);
	
    // Transform center and radius of gradient with the inverse
    CGPoint center = CGPointMake(CGRectGetMidX(rect) * invS.x, CGRectGetMidY(rect) * invS.y);
    CGFloat radius = CGRectGetMidX(rect) * invS.x;
	
    // Draw the gradient with the scale transform on the context
    CGContextScaleCTM(context, scaleT.a, scaleT.d);
    CGContextDrawRadialGradient(context, gradient, center, 0, center, radius, kCGGradientDrawsBeforeStartLocation);
	
    // Reset the context
    CGContextScaleCTM(context, invS.x, invS.y);
	
    // Clean up the memory used by Quartz
    CGGradientRelease(gradient);
	CGColorSpaceRelease(grayColorSpace);
	CGColorRelease(alertBackgroundColor);
}
@end
