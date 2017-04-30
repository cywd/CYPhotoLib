//
//  PhotoLibDemoTests.m
//  PhotoLibDemoTests
//
//  Created by Cyrill on 16/6/20.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface PhotoLibDemoTests : XCTestCase

@end

@implementation PhotoLibDemoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//- (void)testExample {
//    // This is an example of a functional test case.
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//    
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);  
//}

- (void)testTrue2 {
    NSLog(@"2222222222222222222222");
    XCTAssert(1, @"Can not be zero");
}

- (void)testTrue1 {
    NSLog(@"1111111111111111111111");
    XCTAssert(1, @"Can not be zero");
}

- (void)testTrue3 {
    NSLog(@"3333333333333333333333");
    XCTAssert(1, @"Can not be zero");
}

- (void)testAtrue {
    NSLog(@"0000000000000000000000");
    XCTAssert(1, @"Can not be zero");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        
        
        
    }];
}

@end

