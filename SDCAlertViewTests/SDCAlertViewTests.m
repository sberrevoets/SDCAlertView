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
@property (nonatomic, strong) SDCAlertView *sut;
@end

@implementation SDCAlertViewTests

- (void)setUp {
    [super setUp];
    
    _sut = [[SDCAlertView alloc]
            initWithTitle:@"Title"
            message:@"Message Here"
            delegate:nil
            cancelButtonTitle:@"Cancel"
            otherButtonTitles:nil];
}

- (void)tearDown {
    _sut = nil;
    [super tearDown];
}

#pragma mark - ShouldDismiss test cases
- (void)testShouldDismissBlockAndDelegateCalled {
    
    __block NSInteger capturedButtonIndex;
    __block BOOL blockWasCalled = NO;
    _sut.shouldDissmissBlock = ^BOOL (NSInteger buttonIndex) {
        blockWasCalled = YES;
        capturedButtonIndex = buttonIndex;
        return NO;
    };
    
    NSInteger simulatedClickButtonIndex = 2;
    [_sut tappedButtonAtIndex:simulatedClickButtonIndex];
    
    XCTAssertTrue(blockWasCalled, @"");
    XCTAssertEqual(capturedButtonIndex, simulatedClickButtonIndex, @"");

    
}



@end
