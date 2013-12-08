//
//  SDCAlertViewTests.m
//  SDCAlertViewTests
//
//  Created by Scott Berrevoets on 9/20/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "SDCAlertView.h"
#import "SDCAlertViewControllerMock.h"

// Category to expose internals of SDCAlertView necessary for testing
@interface SDCAlertView (TestVisibility)
@property (nonatomic, strong) SDCAlertViewController *alertViewController;
- (void)tappedButtonAtIndex:(NSInteger)index;
@end


@interface SDCAlertViewTests : XCTestCase
// 'sut' is the 'System Under Test', i.e. the SDCAlertView class
@property (nonatomic, strong) SDCAlertView *sut;
@end

@implementation SDCAlertViewTests

- (void)setUp {
    [super setUp];
    
    self.sut = [[SDCAlertView alloc]
            initWithTitle:@"Title"
            message:@"Message Here"
            delegate:nil
            cancelButtonTitle:@"Cancel"
            otherButtonTitles:nil];
}

- (void)tearDown {
    self.sut = nil;
    [super tearDown];
}

#pragma mark - ClickedButton test cases
- (void)testClickedButtonBlockCalled {
    __block NSInteger capturedButtonIndex;
    __block BOOL blockWasCalled = NO;
    self.sut.clickedButtonHandler = ^void (NSInteger buttonIndex) {
        blockWasCalled = YES;
        capturedButtonIndex = buttonIndex;
    };
    
    [self.sut tappedButtonAtIndex:2];
    
    XCTAssertTrue(blockWasCalled, @"");
    XCTAssertEqual(capturedButtonIndex, 2, @"");
}

#pragma mark - ShouldDismiss test cases
- (void)testShouldDismissBlockCalled {
    __block NSInteger capturedButtonIndex;
    __block BOOL blockWasCalled = NO;
    self.sut.shouldDismissHandler = ^BOOL (NSInteger buttonIndex) {
        blockWasCalled = YES;
        capturedButtonIndex = buttonIndex;
        return NO;
    };
    
    [self.sut tappedButtonAtIndex:2];
    
    XCTAssertTrue(blockWasCalled, @"");
    XCTAssertEqual(capturedButtonIndex, 2, @"");
}

- (void)testDoesDismissWhenSpecfiedInBlock {
    self.sut.shouldDismissHandler = ^BOOL (NSInteger buttonIndex) {
        return YES;
    };
    
    // Partially mock the alert view so we can verify correct message are sent to it
    id sutPartialMock = [OCMockObject partialMockForObject:self.sut];
    [[sutPartialMock expect] dismissWithClickedButtonIndex:2 animated:YES];
    
    [sutPartialMock tappedButtonAtIndex:2];
    
    [sutPartialMock verify];
}

- (void)testDoesNotDismissWhenSpecfiedInBlock {
    self.sut.shouldDismissHandler = ^BOOL (NSInteger buttonIndex) {
        return NO;
    };
    
    // Partially mock the alert view so we can verify correct message are sent to it
    id sutPartialMock = [OCMockObject partialMockForObject:self.sut];
    [[sutPartialMock reject] dismissWithClickedButtonIndex:2 animated:YES];
    
    [sutPartialMock tappedButtonAtIndex:2];

    [sutPartialMock verify];
}


#pragma mark - WillDissmis test cases
- (void)testWillDismissBlockCalled {
    __block NSInteger capturedButtonIndex;
    __block BOOL blockWasCalled = NO;
    self.sut.willDismissHandler = ^void (NSInteger buttonIndex) {
        blockWasCalled = YES;
        capturedButtonIndex = buttonIndex;
    };
    
    [self.sut dismissWithClickedButtonIndex:2 animated:YES];
    
    XCTAssertTrue(blockWasCalled, @"");
    XCTAssertEqual(capturedButtonIndex, 2, @"");
}


#pragma mark - DidDissmis test cases

- (void)testDidDismissBlockCalled {
    // Use a mock version of the SDCAlertViewController so the completionHandler is called immediately
    SDCAlertViewController *alertViewControllerMock = [[SDCAlertViewControllerMock alloc] init];
    self.sut.alertViewController = alertViewControllerMock;
    
    __block NSInteger capturedButtonIndex;
    __block BOOL blockWasCalled = NO;
    self.sut.didDismissHandler = ^void (NSInteger buttonIndex) {
        blockWasCalled = YES;
        capturedButtonIndex = buttonIndex;
    };
    
    [self.sut dismissWithClickedButtonIndex:2 animated:YES];
    
    XCTAssertTrue(blockWasCalled, @"");
    XCTAssertEqual(capturedButtonIndex, 2, @"");
}


@end
