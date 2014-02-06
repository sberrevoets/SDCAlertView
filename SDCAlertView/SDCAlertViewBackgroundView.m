//
//  SDCAlertViewBackgroundView.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 11/5/13.
//  Initial drawRect: implementation/revision by Chris Stroud on 5/2/2014
//
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertViewBackgroundView.h"

@implementation SDCAlertViewBackgroundView

- (BOOL)isOpaque {
	return NO;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Make sure the context is cleared
	CGContextClearRect(context, rect);
	
	// Set the closest matching blend mode for the context. It's really
	// difficult (if possible at all) to discern what Apple is using for this
	// but it produces a nearly identical effect, which serves our needs.
	CGContextSetBlendMode(context, kCGBlendModeOverlay);
	
	// Gray colorspace used for the background color
	CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();
	
	
	// Compensate for whatever the other layer Apple has in the hierachy (or perhaps a color-fill somewhere?) that's darkening the alert:
	//
	// [<CALayer: 0x155faec0> backgroundColor]: <CGColor 0x17551e00> [<CGColorSpace 0x175af850> (kCGColorSpaceDeviceGray)] ( 0.5 0.5 )
	//
	// Darken the alert background prior to filling in the actual background color
	//
	// NOTE: Had to manually tweak this value to compensate for subtle brightness differences. % Grayscale is -0.6f from
	//       Apple's apparent value.
	CGContextSetGrayFillColor(context, 0.44, 0.5);
	CGContextFillRect(context, rect);
	
	
	// Background color components:
	//
	// [<CALayer: 0x155faec0> backgroundColor]: <CGColor 0x15541550> [<CGColorSpace 0x1558f4c0> (kCGColorSpaceDeviceGray)] ( 0.97 0.96 )
	//
	// NOTE: Had to manually tweak this value to compensate for almost-negligible transparency discrepancies.
	//       Alpha value is now +0.1f from Apple's apparent value.
	CGContextSetGrayFillColor(context, 0.97f, 0.97f);
	CGContextFillRect(context, rect);

	// Gradient color components:
	//
	// [<_UIModalItemAlertBackgroundView: 0x15763a60> _gradientImageForBoundsSize:-- withInnerColor:UIDeviceWhiteColorSpace 1 0.5 outerColor:UIDeviceWhiteColorSpace 1 0]
	CGColorRef startColor = [[UIColor colorWithWhite:1.0f alpha:0.5f] CGColor];
	CGColorRef endColor   = [[UIColor colorWithWhite:1.0f alpha:0.0f] CGColor];
	
	// Gradient colors
	NSArray *colors = @[(__bridge id)startColor, (__bridge id)endColor];
	
	// Gradient locations
	CGFloat locations[2] = {0.0f, 1.0f};
	
	// This gradient will default to the +[UIColor colorWithWhite:alpha:] colorspace
	// since UIDeviceWhiteColorSpace is seemingly private
	CGGradientRef gradient = CGGradientCreateWithColors(CGColorGetColorSpace(startColor), (__bridge CFArrayRef)colors, locations);
	
	/*
	 * This trick for transforming the circular gradient is great and is largely derived from: http://stackoverflow.com/a/12665177
	 */
	
	// Scaling transformation and keeping track of the inverse
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(1.0, CGRectGetHeight(rect) / CGRectGetWidth(rect));
    CGAffineTransform inverseScaleTransform = CGAffineTransformInvert(scaleTransform);
	
    // Extract the Sx and Sy elements from the inverse matrix
    // (See the Quartz documentation for the math behind the matrices)
    CGPoint inverseScale = CGPointMake(inverseScaleTransform.a, inverseScaleTransform.d);
	
    // Transform center and radius of gradient with the inverse
    CGPoint center = CGPointMake(CGRectGetMidX(rect) * inverseScale.x, CGRectGetMidY(rect) * inverseScale.y);
    CGFloat radius = CGRectGetMidX(rect) * inverseScale.x;
	
    // Draw the gradient with the scale transform on the context
    CGContextScaleCTM(context, scaleTransform.a, scaleTransform.d);
    CGContextDrawRadialGradient(context, gradient, center, 0, center, radius, kCGGradientDrawsBeforeStartLocation);
    // Reset the context
    CGContextScaleCTM(context, inverseScale.x, inverseScale.y);
	
    // Clean up the memory used by Quartz
    CGGradientRelease(gradient);
	CGColorSpaceRelease(grayColorSpace);
}

@end
