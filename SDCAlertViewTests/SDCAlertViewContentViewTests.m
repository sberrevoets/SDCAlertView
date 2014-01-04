//
//  SDCAlertViewContentViewTests.m
//  SDCAlertView
//
//  Created by Luke Stringer on 04/01/2014.
//  Copyright (c) 2014 Scotty Doesn't Code. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SDCAlertViewContentView.h"
#import <OCMock/OCMock.h>

@interface SDCAlertViewContentView (TestVisibility)
@property (nonatomic, strong) UITableView *otherButtonsTableView;
@end

@interface SDCAlertViewContentViewTests : XCTestCase

@end

@implementation SDCAlertViewContentViewTests

- (void)testAsksDelegateWhetherToDeslectButton {
    id delegateMock = [OCMockObject niceMockForProtocol:@protocol(SDCAlertViewContentViewDelegate)];
    
    SDCAlertViewContentView *sut = [[SDCAlertViewContentView alloc] initWithDelegate:delegateMock];
    
    [[delegateMock expect] alertContentView:sut shouldDeselectButtonAtIndex:0];
    
    [sut tableView:sut.otherButtonsTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    [delegateMock verify];
}

@end
