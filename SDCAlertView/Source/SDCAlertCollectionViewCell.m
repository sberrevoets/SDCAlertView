//
//  SDCAlertCollectionViewCell.m
//  SDCAlertView
//
//  Created by Scott Berrevoets on 9/24/14.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import "SDCAlertCollectionViewCell.h"

@implementation SDCAlertCollectionViewCell

- (UILabel *)textLabel {
	if (!_textLabel) {
		_textLabel = [[UILabel alloc] init];
	}
	
	return _textLabel;
}


- (void)layoutSubviews {
	[super layoutSubviews];
	
	[self.textLabel sizeToFit];
	[self.contentView addSubview:self.textLabel];
}

@end
