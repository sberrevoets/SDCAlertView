//
//  SDCAlertViewTests.m
//  SDCAlertViewTests
//
//  Created by Scott Berrevoets on 9/20/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "SDCAlertView+Buttons.h"
#import "SDCAlertView+SDCAlertViewController.h"
#import "SDCAlertViewControllerMock.h"

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
- (void)testShouldDismissBlockCalled {
    
    __block NSInteger capturedButtonIndex;
    __block BOOL blockWasCalled = NO;
    _sut.shouldDismissBlock = ^BOOL (NSInteger buttonIndex) {
        blockWasCalled = YES;
        capturedButtonIndex = buttonIndex;
        return NO;
    };
    
    [_sut tappedButtonAtIndex:2];
    
    XCTAssertTrue(blockWasCalled, @"");
    XCTAssertEqual(capturedButtonIndex, 2, @"");

}

- (void)testDoesDismissWhenSpecfiedInBlock {
    
    _sut.shouldDismissBlock = ^BOOL (NSInteger buttonIndex) {
        return YES;
    };
    
    id sutMock = [OCMockObject partialMockForObject:_sut];
    [[sutMock expect] dismissWithClickedButtonIndex:2 animated:YES];
    
    [sutMock tappedButtonAtIndex:2];
    
    [sutMock verify];
}

- (void)testDoesNotDismissWhenSpecfiedInBlock {
    
    _sut.shouldDismissBlock = ^BOOL (NSInteger buttonIndex) {
        return NO;
    };
    
    id sutMock = [OCMockObject partialMockForObject:_sut];
    
    [sutMock tappedButtonAtIndex:2];
    
    // Verfiy a mock not expecting any methods
    // This in-effect verifies no methods were called
    [sutMock verify];
}


#pragma mark - WillDissmis test cases
- (void)testWillDismissBlockCalled {

    __block NSInteger capturedButtonIndex;
    __block BOOL blockWasCalled = NO;
    _sut.willDismissBlock = ^BOOL (NSInteger buttonIndex) {
        blockWasCalled = YES;
        capturedButtonIndex = buttonIndex;
        return YES;
    };
    
    [_sut dismissWithClickedButtonIndex:2 animated:YES];
    
    XCTAssertTrue(blockWasCalled, @"");
    XCTAssertEqual(capturedButtonIndex, 2, @"");
    
}


#pragma mark - DidDissmis test cases

- (void)testDidDismissBlockCalled {
    
    // Use a mock version of the SDCAlertViewController so the completionHandler is called immediately
    SDCAlertViewController *alertViewControllerMock = [[SDCAlertViewControllerMock alloc] init];
    _sut.alertViewController = alertViewControllerMock;
    
    __block NSInteger capturedButtonIndex;
    __block BOOL blockWasCalled = NO;
    _sut.didDismissBlock = ^BOOL (NSInteger buttonIndex) {
        blockWasCalled = YES;
        capturedButtonIndex = buttonIndex;
        return YES;
    };
    
    [_sut dismissWithClickedButtonIndex:2 animated:YES];
    
    XCTAssertTrue(blockWasCalled, @"");
    XCTAssertEqual(capturedButtonIndex, 2, @"");
    
}


@end
