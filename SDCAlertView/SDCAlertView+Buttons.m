//
//  SDCAlertView+Buttons.m
//  SDCAlertView
//
//  Created by Luke Stringer on 01/12/2013.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertView+Buttons.h"
#import <objc/runtime.h>

static NSString * const PropertyKey_ButtonTitles            = @"ButtonTitle";
static NSString * const PropertyKey_FirstOtherButtonIndex   = @"FirstOtherButtonIndex";

@interface SDCAlertView ()
@property (nonatomic, strong) NSMutableArray *buttonTitles;
@property (nonatomic, assign) NSInteger firstOtherButtonIndex;
@end

@implementation SDCAlertView (Buttons)

#pragma mark - Properties
- (NSMutableArray *)buttonTitles {
    return objc_getAssociatedObject(self, (__bridge const void *)(PropertyKey_ButtonTitles));
}

- (void)setButtonTitles:(NSMutableArray *)buttonTitles {
    objc_setAssociatedObject(self, (__bridge const void *)(PropertyKey_ButtonTitles), buttonTitles, OBJC_ASSOCIATION_RETAIN);
}

- (NSInteger)firstOtherButtonIndex {
    NSNumber *firstOtherButtonIndexNumber = objc_getAssociatedObject(self, (__bridge const void *)(PropertyKey_FirstOtherButtonIndex));
    return [firstOtherButtonIndexNumber integerValue];
}

- (void)setFirstOtherButtonIndex:(NSInteger)firstOtherButtonIndex {
    NSNumber *firstOtherButtonIndexNumber = @(firstOtherButtonIndex);
    objc_setAssociatedObject(self, (__bridge const void *)(PropertyKey_FirstOtherButtonIndex), firstOtherButtonIndexNumber, OBJC_ASSOCIATION_RETAIN);
}

#pragma mark - Public methods
- (void)tappedButtonAtIndex:(NSInteger)index {
    
    // Call delegate and block to let them know button was clicked
	if ([self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
         [self.delegate alertView:self clickedButtonAtIndex:index];
    }
    if (self.clickedButtonBlock) {
        self.clickedButtonBlock(index);
    }
    
	
    // If there is a delegate respodning to the correct selector
    // then ask the delegate whether we should dismiss or not
	if ([self.delegate respondsToSelector:@selector(alertView:shouldDismissWithButtonIndex:)]) {
        // Call the delegate afer we are sure it responds to the selector to avoid a crash
        if ([self.delegate alertView:self shouldDismissWithButtonIndex:index]) {
            [self dismissWithClickedButtonIndex:index animated:YES];
        }
	}
    
    // If there is a block
    // then ask the block whether we should dismiss or not
    else if (self.shouldDismissBlock) {
        // Call the block afer we are sure it exists to avoid a crash
        if (self.shouldDismissBlock(index)) {
            [self dismissWithClickedButtonIndex:index animated:YES];
        };
        
    }
    
    // If we cannot ask a delegate or a block then default to always dismissing
    else {
        [self dismissWithClickedButtonIndex:index animated:YES];

    }
    
}

- (NSInteger)numberOfButtons {
	return [self.buttonTitles count];
}

@end
