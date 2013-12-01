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
	if ([self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
		[self.delegate alertView:self clickedButtonAtIndex:index];
	
	if (([self.delegate respondsToSelector:@selector(alertView:shouldDismissWithButtonIndex:)] && [self.delegate alertView:self shouldDismissWithButtonIndex:index]) || ![self.delegate respondsToSelector:@selector(alertView:shouldDismissWithButtonIndex:)]) {
		[self dismissWithClickedButtonIndex:index animated:YES];
	}
    
    if (self.shouldDissmissBlock) {
        self.shouldDissmissBlock(index);
    }
}

- (NSInteger)numberOfButtons {
	return [self.buttonTitles count];
}

@end
