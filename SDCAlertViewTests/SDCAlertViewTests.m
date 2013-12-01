//
//  SDCAlertViewTests.m
//  SDCAlertViewTests
//
//  Created by Scott Berrevoets on 9/20/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SDCAlertView+Buttons.h"

@interface SDCAlertViewTests : XCTestCase

@end

@implementation SDCAlertViewTests

- (void)testCallsShouldDismissBlockWithoutDelegate {
    SDCAlertView *sut = [[SDCAlertView alloc]
                         initWithTitle:@"Title"
                         message:@"Message Here"
                         delegate:nil
                         cancelButtonTitle:@"Cancel"
                         otherButtonTitles:nil];
    
    __block NSInteger capturedButtonIndex;
    __block BOOL blockWasCalled = NO;
    sut.shouldDissmissBlock = ^BOOL (NSInteger buttonIndex) {
        blockWasCalled = YES;
        capturedButtonIndex = buttonIndex;
        return NO;
    };
    
    [sut tappedButtonAtIndex:2];
    
    XCTAssertTrue(blockWasCalled, @"");
    XCTAssertEqual(capturedButtonIndex, 2, @"");
}

- (void)testCallsShouldDismissBlockAndDelegate {
    
}

@end
