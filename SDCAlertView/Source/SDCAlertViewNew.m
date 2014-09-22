//
//  SDCAlertViewNew.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/21/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertViewNew.h"

#import "SDCAlertScrollView.h"
#import "UIView+SDCAutoLayout.h"


@interface SDCAlertViewNew ()
@property (nonatomic, strong) SDCAlertScrollView *scrollView;
@end

@implementation SDCAlertViewNew

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message {
	self = [self init];
	
	if (self) {
		_scrollView = [[SDCAlertScrollView alloc] initWithTitle:title message:message];
		[self setTranslatesAutoresizingMaskIntoConstraints:NO];
	}
	
	return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	if (!newSuperview) {
		return;
	}
	
	[self addSubview:self.scrollView];
	[self.scrollView sdc_alignEdgesWithSuperview:UIRectEdgeAll];
	
	[self.scrollView prepareForDisplay];
	
}

@end
