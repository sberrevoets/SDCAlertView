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
#import "SDCAlertViewContentView.h"

// Category to expose internals of SDCAlertView necessary for testing
@interface SDCAlertView (TestVisibility) <SDCAlertViewContentViewDelegate>
@property (nonatomic, strong) SDCAlertViewController *alertViewController;
@property (nonatomic, strong) SDCAlertViewContentView *alertContentView;
- (void)tappedButtonAtIndex:(NSInteger)index;
@end

@interface SDCAlertViewTests : XCTestCase
// 'sut' is the 'System Under Test', i.e. the SDCAlertView class
@property (nonatomic, strong) SDCAlertView *sut;
@end


@implementation SDCAlertViewTests

- (void)setUp {
	[super setUp];
    
    self.sut = [[SDCAlertView alloc] initWithTitle:@"Title"
										   message:@"Message Here"
										  delegate:nil
								 cancelButtonTitle:@"Cancel"
								 otherButtonTitles:nil];
}

- (void)tearDown {
	self.sut = nil;
	[super tearDown];
}

- (NSInteger)simulateButtonTapped:(id)object {
	NSInteger simulatedButtonTapped = 2;
	[object tappedButtonAtIndex:simulatedButtonTapped];
	
	return simulatedButtonTapped;
}

#pragma mark - ClickedButton test cases

- (void)testClickedButtonHandlerCalled {
	__block NSInteger capturedButtonIndex;
	__block BOOL blockWasCalled = NO;
	self.sut.clickedButtonHandler = ^void (NSInteger buttonIndex) {
		blockWasCalled = YES;
		capturedButtonIndex = buttonIndex;
	};
	
	NSInteger simulatedButtonTapped = [self simulateButtonTapped:self.sut];
	
	XCTAssertTrue(blockWasCalled, @"");
	XCTAssertEqual(capturedButtonIndex, simulatedButtonTapped, @"");
}

#pragma mark - ShouldDismiss test cases

- (void)testShouldDismissHandlerCalled {
	__block NSInteger capturedButtonIndex;
	__block BOOL blockWasCalled = NO;
	self.sut.shouldDismissHandler = ^BOOL (NSInteger buttonIndex) {
		blockWasCalled = YES;
		capturedButtonIndex = buttonIndex;
		return NO;
	};
	
	NSInteger simulatedButtonTapped = [self simulateButtonTapped:self.sut];
	
	XCTAssertTrue(blockWasCalled, @"");
	XCTAssertEqual(capturedButtonIndex, simulatedButtonTapped, @"");
}

- (void)testDoesDismissWhenSpecfiedInBlock {
	self.sut.shouldDismissHandler = ^BOOL (NSInteger buttonIndex) {
		return YES;
	};
	
	// Partially mock the alert view so we can verify correct message are sent to it
	id sutPartialMock = [OCMockObject partialMockForObject:self.sut];
	[[sutPartialMock expect] dismissWithClickedButtonIndex:2 animated:YES];
	
	[self simulateButtonTapped:sutPartialMock];
	[sutPartialMock verify];
}

- (void)testDoesNotDismissWhenSpecfiedInBlock {
	self.sut.shouldDismissHandler = ^BOOL (NSInteger buttonIndex) {
		return NO;
	};
	
	// Partially mock the alert view so we can verify correct message are sent to it
	id sutPartialMock = [OCMockObject partialMockForObject:self.sut];
	[[sutPartialMock reject] dismissWithClickedButtonIndex:2 animated:YES];
	
	[self simulateButtonTapped:sutPartialMock];
	[sutPartialMock verify];
}


#pragma mark - WillDissmis test cases

- (void)testWillDismissHandlerCalled {
	__block NSInteger capturedButtonIndex;
	__block BOOL blockWasCalled = NO;
	self.sut.willDismissHandler = ^void (NSInteger buttonIndex) {
		blockWasCalled = YES;
		capturedButtonIndex = buttonIndex;
	};
	
	NSInteger simulatedButtonIndex = 2;
	[self.sut dismissWithClickedButtonIndex:simulatedButtonIndex animated:YES];
	
	XCTAssertTrue(blockWasCalled, @"");
	XCTAssertEqual(capturedButtonIndex, simulatedButtonIndex, @"");
}


#pragma mark - DidDissmis test cases

- (void)testDidDismissHandlerCalled {
	// Use a mock version of the SDCAlertViewController so the completionHandler is called immediately
	SDCAlertViewController *alertViewControllerMock = [[SDCAlertViewControllerMock alloc] init];
	self.sut.alertViewController = alertViewControllerMock;
	
	__block NSInteger capturedButtonIndex;
	__block BOOL blockWasCalled = NO;
	self.sut.didDismissHandler = ^void (NSInteger buttonIndex) {
		blockWasCalled = YES;
		capturedButtonIndex = buttonIndex;
	};
	
	NSInteger simulatedButtonIndex = 2;
	[self.sut dismissWithClickedButtonIndex:simulatedButtonIndex animated:YES];
	
	XCTAssertTrue(blockWasCalled, @"");
	XCTAssertEqual(capturedButtonIndex, simulatedButtonIndex, @"");
}

#pragma mark - ShouldDeselectButton test cases

- (void)testShouldDeselectButtonDelegateMessageReceived {
    id delegateMock = [OCMockObject niceMockForProtocol:@protocol(SDCAlertViewDelegate)];
    self.sut.delegate = delegateMock;
    
    [[delegateMock expect] alertView:self.sut shouldDeselectButtonAtIndex:2];
    
    [self.sut alertContentView:self.sut.alertContentView shouldDeselectButtonAtIndex:2];
    
    [delegateMock verify];
}

- (void)testShouldDeselectButtonHandlerCalled {
    NSInteger expectedButtonIndex = 2;
	
	__block NSInteger capturedButtonIndex;
	__block BOOL blockWasCalled = NO;
	self.sut.shouldDeselectButtonHandler = ^BOOL (NSInteger buttonIndex) {
		blockWasCalled = YES;
		capturedButtonIndex = buttonIndex;
        return YES;
	};
	
    [self.sut alertContentView:self.sut.alertContentView shouldDeselectButtonAtIndex:expectedButtonIndex];
	
	XCTAssertTrue(blockWasCalled, @"");
	XCTAssertEqual(capturedButtonIndex, expectedButtonIndex, @"");
}

@end
