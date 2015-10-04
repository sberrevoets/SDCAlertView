//
//  SDCAlertViewTransitioning.h
//  SDCAlertView
//
//  Created by Scott Berrevoets on 4/11/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertView.h"

/**
 *  The \c SDCAlertViewTransitioning protocol can be used to define custom ways of transitioning between alerts. This
 *  allows implementers to use different presenting or dismissing animations, change the modality of an alert, etc.
 */
@protocol SDCAlertViewTransitioning <NSObject>

/**
 *  The alert that's currently visible on the screen, or \c nil if there are no visible alerts. Currently, only one alert
 *  can be visible at a time. An alert that's being presented or dismissed is not considered visible.
 *
 *  Most implementers will benefit from making this a private readwrite property that's set from \c presentAlert: and
 *  \c -dismissAlert:withButtonIndex:animated:.
 */
@property (nonatomic, weak, readonly) SDCAlertView *visibleAlert;

/**
 *  Present \c alert on the screen. In this method, add the alert as a subview to some other view and apply the animations
 *  you want (can be UIView-based or Core Animation), if any.
 *
 *  At the beginning of this method, right before the view actually gets added to a subview, send it \c -willBePresented.
 *  After all animations have finished, send it \c -wasPresented. These method calls are required so that the appropriate
 *  \c SDCAlertView delegate methods are called.
 */
- (void)presentAlert:(SDCAlertView *)alert;

/**
 *  Remove \c alert from the screen with \c buttonIndex. Before the alert starts animating (or is simply being removed
 *  if \c animated is \c NO), send it \c -willBeDismissedWithButtonIndex:. When the animations have finished, be sure to
 *  remove the alert from its superview and send it \c -wasDismissedWithButtonIndex:.
 */
- (void)dismissAlert:(SDCAlertView *)alert withButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;
@end


@interface SDCAlertView (SDCAlertViewTransitioning)
/**
 *  The transition coordinator to use for presenting and dismissing alerts. Defaults to the SDCAlertViewCoordinator
 *  singleton if not set to something else.
 */
@property (nonatomic, strong) id <SDCAlertViewTransitioning> transitionCoordinator;

/*
 *  The methods below are only to be called from the transitionCoordinator (see above) when a transition is about to happen
 *  or has just finished. Don't call these methods from anywhere else.
 */

- (void)willBePresented;
- (void)wasPresented;

- (void)willBeDismissedWithButtonIndex:(NSInteger)buttonIndex;
- (void)wasDismissedWithButtonIndex:(NSInteger)buttonIndex;
@end
