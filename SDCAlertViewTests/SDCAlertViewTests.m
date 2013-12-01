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
    
    [_sut tappedButtonAtIndex:2];
    
    XCTAssertTrue(blockWasCalled, @"");
    XCTAssertEqual(capturedButtonIndex, 2, @"");

}

#pragma mark - WillDissmis test cases

- (void)testWillDismissBlockAndDelegateCalled {

    __block NSInteger capturedButtonIndex;
    __block BOOL blockWasCalled = NO;
    _sut.willDissmissBlock = ^BOOL (NSInteger buttonIndex) {
        blockWasCalled = YES;
        capturedButtonIndex = buttonIndex;
        return YES;
    };
    
    [_sut dismissWithClickedButtonIndex:2 animated:YES];
    
    XCTAssertTrue(blockWasCalled, @"");
    XCTAssertEqual(capturedButtonIndex, 2, @"");
    
}



@end
