//
//  UIView+Parallax.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 10/5/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "UIView+Parallax.h"

@implementation UIView (Parallax)

- (void)sdc_addParallax:(UIOffset)magnitude {
	UIInterpolatingMotionEffect *horizontalParallax;
	UIInterpolatingMotionEffect *verticalParallax;
	
	horizontalParallax = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
	horizontalParallax.minimumRelativeValue = @(-magnitude.horizontal);
	horizontalParallax.maximumRelativeValue = @(magnitude.horizontal);
	
	verticalParallax = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
	verticalParallax.minimumRelativeValue = @(-magnitude.vertical);
	verticalParallax.maximumRelativeValue = @(magnitude.vertical);
	
	UIMotionEffectGroup *groupMotionEffect = [[UIMotionEffectGroup alloc] init];
	groupMotionEffect.motionEffects = @[horizontalParallax, verticalParallax];

	[self addMotionEffect:groupMotionEffect];
}

@end
