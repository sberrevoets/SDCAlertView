//
//  SDCAlertCollectionViewCell.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/24/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertCollectionViewCell.h"

#import "UIView+SDCAutoLayout.h"

@implementation SDCAlertCollectionViewCell

- (UILabel *)textLabel {
	if (!_textLabel) {
		_textLabel = [[UILabel alloc] init];
		[_textLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
	}
	
	return _textLabel;
}


- (void)layoutSubviews {
	[super layoutSubviews];
	
	[self.contentView addSubview:self.textLabel];
	[self.textLabel sdc_centerInSuperview];
}

@end
