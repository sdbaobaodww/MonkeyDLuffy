//
//  MDLIOCTest.m
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/18.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MDLIOCInjector.h"
#import "MDLIOCTestModel.h"

@interface MDLIOCTest : XCTestCase

@end

@implementation MDLIOCTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBuildDependenciesForClass {
    NSSet *eventSet = [[Event class] mdlioc_injectableProperties];
    NSAssert([eventSet count] == 3, @"事件依赖注入的属性个数为3");
    
    NSSet *bigEventSet = [[BigEvent class] mdlioc_injectableProperties];
    NSAssert([bigEventSet count] == 4, @"大事件依赖注入的属性个数为4");
    
    NSSet *bigbigEvnetSet = [[BigBigEvent class] mdlioc_injectableProperties];
    NSAssert([bigbigEvnetSet count] == 5, @"大大事件依赖注入的属性个数为5");
}

- (void)testInjector {
    MDLIOCInjector *injector = [MDLIOCInjector shareInstance];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
