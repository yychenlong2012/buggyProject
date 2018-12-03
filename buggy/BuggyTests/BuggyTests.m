//
//  BuggyTests.m
//  BuggyTests
//
//  Created by ningwu on 16/2/22.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface BuggyTests : XCTestCase

@end

@implementation BuggyTests

/*
 * 每次测试前调用，可以在测试之前，创建可能在test case方法中需要用到的一些对象等
 */
- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}


/*
 * 每次测试结束时调用tearDown方法
 */
- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/*
 * 大部分的测试方法使用断言决定的测试结果。所有断言都有一个类似的形式：比较，表达式为真假，强行失败等。
 */
- (void)testExample {
    
    NSLog(@"自定义测试testExample");
    int  a= 3;
    XCTAssertTrue(a == 0,"a 不能等于 0");
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}


/*
 * 性能测试方法，通过测试block中方法执行的时间，比对设定的标准值和偏差觉得是否可以通过测试
 */
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
