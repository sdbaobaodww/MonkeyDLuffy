//
//  MDLTraceTest.m
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/9/4.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MDLTrace.h"
#import "MDLTraceManager.h"

@interface MDLTraceTest : XCTestCase

@end

@implementation MDLTraceTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTraceCreate {
    MDLTrace *trace1 = [[MDLTrace alloc] initWithType:@"mdltrace_test1"];
    MDLTrace *trace2 = [[MDLTrace alloc] initWithType:@"mdltrace_test2"];
    XCTestExpectation *expect = [self expectationWithDescription:@"异步调用"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:2.]; ; //延迟两秒向下执行
        [expect fulfill];//告知异步测试结束
    });
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        [trace1 traceSuccess];
        [trace2 traceSuccess];
        
        NSString *traceFile = [MDLTraceManager sharedInstance].currentTraceFile;
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:traceFile];
        NSAssert(isExist, @"记录保存失败");
    }];
}

@end
