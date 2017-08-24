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

#ifdef PreRegisterFlag
//测试注解方式注入对象，必须在第一个resetContext方法调用之前，防止数据被清空
- (void)testAnnotationRegisterBean {
    MDLIOCInjector *injector = [MDLIOCInjector shareInstance];
    NSAssert([[injector allBeans] count] == 2, @"当前依赖的Bean个数为2");
    
    id<YingXiangProtocol> yingxiang = [injector instanceForProtocol:@protocol(YingXiangProtocol)];
    NSAssert([yingxiang class] == [LufeiUp class], @"当前注入的影响是路飞赏金提高");
    
    id<Board> board = [injector instanceForProtocol:@protocol(Board)];
    NSAssert([board class] == [MaliHao class], @"当前注入的船是梅里号");
}
#endif

//测试依赖输入的属性个数
- (void)testBuildDependenciesForClass {
    NSSet *eventSet = [[Event class] mdlioc_injectableProperties];
    NSAssert([eventSet count] == 3, @"事件依赖注入的属性个数为3");
    
    NSSet *bigEventSet = [[BigEvent class] mdlioc_injectableProperties];
    NSAssert([bigEventSet count] == 4, @"大事件依赖注入的属性个数为4");
    
    NSSet *bigbigEvnetSet = [[BigBigEvent class] mdlioc_injectableProperties];
    NSAssert([bigbigEvnetSet count] == 5, @"大大事件依赖注入的属性个数为5");
}

//测试注册正常作用域Bean
- (void)testRegisterNormalScopeBean {
    MDLIOCInjector *injector = [MDLIOCInjector shareInstance];
    [injector resetContext];
   
    MDLIOCBean *haizeiBean = [MDLIOCBean beanWithProtocol:@protocol(HaizeiProtocol) bindClass:[Lufei class] scope:MDLIOCScopeNormal];
    [injector registerBean:haizeiBean];
    
    MDLIOCBean *haijunBean = [MDLIOCBean beanWithProtocol:@protocol(HaiJunProtocol) bindClass:[Chiquan class] scope:MDLIOCScopeNormal];
    [injector registerBean:haijunBean];
    
    MDLIOCBean *zhanchangBean = [MDLIOCBean beanWithProtocol:@protocol(ZhanChangProtocol) bindClass:[MaLinFuDuo class] scope:MDLIOCScopeNormal];
    [injector registerBean:zhanchangBean];
    
    MDLIOCBean *jieguoBean = [MDLIOCBean beanWithProtocol:@protocol(JieGuoProtocol) bindClass:[BaiHuziDie class] scope:MDLIOCScopeNormal];
    [injector registerBean:jieguoBean];
    
    NSAssert([[injector allBeans] count] == 4, @"当前依赖的Bean个数为4");
    
    id<HaizeiProtocol> lufei = [injector instanceForProtocol:@protocol(HaizeiProtocol)];
    NSAssert([lufei class] == [Lufei class], @"当前注入的海贼是路飞");
    
    id<HaiJunProtocol> chiquan = [injector instanceForProtocol:@protocol(HaiJunProtocol)];
    NSAssert([chiquan class] == [Chiquan class], @"当前注入的海军是赤犬");
    
    id<ZhanChangProtocol> malinfuduo = [injector instanceForProtocol:@protocol(ZhanChangProtocol)];
    NSAssert([malinfuduo class] == [MaLinFuDuo class], @"当前注入的战场是马林福多");
    
    id<JieGuoProtocol> jieguo = [injector instanceForProtocol:@protocol(JieGuoProtocol)];
    NSAssert([jieguo class] == [BaiHuziDie class], @"当前事件结果是白胡子死了");
    
    NSAssert([injector cachesWithScope:MDLIOCScopeNormal] == nil, @"正常作用域的缓存为nil");
}

//测试注册模块作用域Bean
- (void)testRegisterModuleScopeBean {
    MDLIOCInjector *injector = [MDLIOCInjector shareInstance];
    [injector resetContext];
    
    MDLIOCBean *haizeiBean = [MDLIOCBean moduleBeanWithProtocol:@protocol(HaizeiProtocol) bindClass:[Lufei class] moduleName:@"module"];
    [injector registerBean:haizeiBean];
    
    MDLIOCBean *haijunBean = [MDLIOCBean moduleBeanWithProtocol:@protocol(HaiJunProtocol) bindClass:[Chiquan class] moduleName:@"module"];
    [injector registerBean:haijunBean];
    
    MDLIOCBean *zhanchangBean = [MDLIOCBean moduleBeanWithProtocol:@protocol(ZhanChangProtocol) bindClass:[MaLinFuDuo class] moduleName:@"module"];
    [injector registerBean:zhanchangBean];
    
    MDLIOCBean *jieguoBean = [MDLIOCBean moduleBeanWithProtocol:@protocol(JieGuoProtocol) bindClass:[BaiHuziDie class] moduleName:@"module"];
    [injector registerBean:jieguoBean];
    
    NSAssert([[injector allBeans] count] == 4, @"当前依赖的Bean个数为4");
    
    id<HaizeiProtocol> lufei = [injector instanceForProtocol:@protocol(HaizeiProtocol)];
    NSAssert(lufei == nil, @"未进入模块前，模块作用域对象不能访问");
    
    id<HaiJunProtocol> chiquan = [injector instanceForProtocol:@protocol(HaiJunProtocol)];
    NSAssert(chiquan == nil, @"未进入模块前，模块作用域对象不能访问");
    
    id<ZhanChangProtocol> malinfuduo = [injector instanceForProtocol:@protocol(ZhanChangProtocol)];
    NSAssert(malinfuduo == nil, @"未进入模块前，模块作用域对象不能访问");
    
    id<JieGuoProtocol> jieguo = [injector instanceForProtocol:@protocol(JieGuoProtocol)];
    NSAssert(jieguo == nil, @"未进入模块前，模块作用域对象不能访问");
    
    NSAssert([[injector cachesWithScope:MDLIOCScopeModule] count] == 0, @"未进入模块前，模块作用域对象不能访问");
    
    //多次进入退出模块
    for (int i = 0; i < 4; i ++) {
        [injector enterModule:@"module"];
        
        NSAssert([[injector allBeans] count] == 4, @"当前依赖的Bean个数为4");
        
        lufei = [injector instanceForProtocol:@protocol(HaizeiProtocol)];
        NSAssert([lufei class] == [Lufei class], @"当前注入的海贼是路飞");
        
        chiquan = [injector instanceForProtocol:@protocol(HaiJunProtocol)];
        NSAssert([chiquan class] == [Chiquan class], @"当前注入的海军是赤犬");
        
        malinfuduo = [injector instanceForProtocol:@protocol(ZhanChangProtocol)];
        NSAssert([malinfuduo class] == [MaLinFuDuo class], @"当前注入的战场是马林福多");
        
        jieguo = [injector instanceForProtocol:@protocol(JieGuoProtocol)];
        NSAssert([jieguo class] == [BaiHuziDie class], @"当前事件结果是白胡子死了");
        
        NSAssert([[injector cachesWithScope:MDLIOCScopeModule] count] == 4, @"模块作用域的缓存长度为4");
        
        [injector exitModule:@"module"];
        
        NSAssert([[injector allBeans] count] == 4, @"当前依赖的Bean个数为4");
        
        lufei = [injector instanceForProtocol:@protocol(HaizeiProtocol)];
        NSAssert(lufei == nil, @"退出模块后，模块作用域对象不能访问");
        
        chiquan = [injector instanceForProtocol:@protocol(HaiJunProtocol)];
        NSAssert(chiquan == nil, @"退出模块后，模块作用域对象不能访问");
        
        malinfuduo = [injector instanceForProtocol:@protocol(ZhanChangProtocol)];
        NSAssert(malinfuduo == nil, @"退出模块后，模块作用域对象不能访问");
        
        jieguo = [injector instanceForProtocol:@protocol(JieGuoProtocol)];
        NSAssert(jieguo == nil, @"退出模块后，模块作用域对象不能访问");
        
        NSAssert([[injector cachesWithScope:MDLIOCScopeModule] count] == 0, @"未进入模块前，模块作用域对象不能访问");
    }
}

- (void)testRegisterGlobalScopeBean {
    MDLIOCInjector *injector = [MDLIOCInjector shareInstance];
    [injector resetContext];
    
    MDLIOCBean *haizeiBean = [MDLIOCBean beanWithProtocol:@protocol(HaizeiProtocol) bindClass:[Lufei class] scope:MDLIOCScopeGlobal];
    [injector registerBean:haizeiBean];
    
    MDLIOCBean *haijunBean = [MDLIOCBean beanWithProtocol:@protocol(HaiJunProtocol) bindClass:[Chiquan class] scope:MDLIOCScopeGlobal];
    [injector registerBean:haijunBean];
    
    MDLIOCBean *zhanchangBean = [MDLIOCBean beanWithProtocol:@protocol(ZhanChangProtocol) bindClass:[MaLinFuDuo class] scope:MDLIOCScopeGlobal];
    [injector registerBean:zhanchangBean];
    
    MDLIOCBean *jieguoBean = [MDLIOCBean beanWithProtocol:@protocol(JieGuoProtocol) bindClass:[BaiHuziDie class] scope:MDLIOCScopeGlobal];
    [injector registerBean:jieguoBean];
    
    NSAssert([[injector allBeans] count] == 4, @"当前依赖的Bean个数为4");
    
    id<HaizeiProtocol> lufei = [injector instanceForProtocol:@protocol(HaizeiProtocol)];
    NSAssert([lufei class] == [Lufei class], @"当前注入的海贼是路飞");
    
    id<HaiJunProtocol> chiquan = [injector instanceForProtocol:@protocol(HaiJunProtocol)];
    NSAssert([chiquan class] == [Chiquan class], @"当前注入的海军是赤犬");
    
    id<ZhanChangProtocol> malinfuduo = [injector instanceForProtocol:@protocol(ZhanChangProtocol)];
    NSAssert([malinfuduo class] == [MaLinFuDuo class], @"当前注入的战场是马林福多");
    
    id<JieGuoProtocol> jieguo = [injector instanceForProtocol:@protocol(JieGuoProtocol)];
    NSAssert([jieguo class] == [BaiHuziDie class], @"当前事件结果是白胡子死了");
    
    NSDictionary *dic = [injector cachesWithScope:MDLIOCScopeGlobal];
    NSAssert([dic count] == 4, @"当前缓存的全局作用域注册对象为4个");
}

- (void)testPerformanceExample {
    [self measureBlock:^{
        for (int i = 0; i < 100; i ++) {
            MDLIOCInjector *injector = [MDLIOCInjector shareInstance];
            [injector resetContext];
            
            [injector registerBean:[MDLIOCBean beanWithProtocol:@protocol(HaizeiProtocol) bindClass:[Lufei class] scope:MDLIOCScopeNormal]];
            [injector registerBean:[MDLIOCBean beanWithProtocol:@protocol(HaiJunProtocol) bindClass:[Chiquan class] scope:MDLIOCScopeNormal]];
            [injector registerBean:[MDLIOCBean beanWithProtocol:@protocol(ZhanChangProtocol) bindClass:[MaLinFuDuo class] scope:MDLIOCScopeNormal]];
            [injector registerBean:[MDLIOCBean beanWithProtocol:@protocol(JieGuoProtocol) bindClass:[BaiHuziDie class] scope:MDLIOCScopeNormal]];
            [injector registerBean:[MDLIOCBean beanWithProtocol:@protocol(YingXiangProtocol) bindClass:[LufeiUp class] scope:MDLIOCScopeNormal]];
            
            NSAssert([[injector allBeans] count] == 5, @"大大事件依赖注入的属性个数为5");
            
            BigBigEvent *bigbigevent = [[BigBigEvent alloc] init];
            
            [bigbigevent story];
        }
    }];
}

@end
