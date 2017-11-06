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

//测试注解方式注入对象
- (void)testAnnotationRegisterBean {
    NSAssert([[MDLIOCRegister allRegistedBeans] count] == 2, @"当前依赖的Bean个数为2");
    
    id yingxiang = [MDLIOCGetter instanceForProtocol:@protocol(YingXiangProtocol)];
    NSAssert([yingxiang class] == [LufeiUp class], @"当前注入的影响是路飞赏金提高");
    
    id board = [MDLIOCGetter instanceForProtocol:@protocol(Board)];
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

//测试注册Bean
- (void)testRegisterBean {
    [MDLIOCRegister cleanAllBeans];
    
    MDLIOCBean *haizeiBean = [MDLIOCBean beanWithProtocol:@protocol(HaizeiProtocol) bindClass:[Lufei class] cachePolicy:MDLIOCCachePolicyNone alias:nil];
    [MDLIOCRegister registerBean:haizeiBean];
    
    MDLIOCBean *haijunBean = [MDLIOCBean beanWithProtocol:@protocol(HaiJunProtocol) bindClass:[Chiquan class] cachePolicy:MDLIOCCachePolicyNone alias:nil];
    [MDLIOCRegister registerBean:haijunBean];
    
    MDLIOCBean *zhanchangBean = [MDLIOCBean beanWithProtocol:@protocol(ZhanChangProtocol) bindClass:[MaLinFuDuo class] cachePolicy:MDLIOCCachePolicyNone alias:nil];
    [MDLIOCRegister registerBean:zhanchangBean];
    
    MDLIOCBean *jieguoBean = [MDLIOCBean beanWithProtocol:@protocol(JieGuoProtocol) bindClass:[BaiHuziDie class] cachePolicy:MDLIOCCachePolicyNone alias:nil];
    [MDLIOCRegister registerBean:jieguoBean];
    
    MDLIOCBean *yingxiangBean = [MDLIOCBean beanWithProtocol:@protocol(YingXiangProtocol) bindClass:[LufeiUp class] cachePolicy:MDLIOCCachePolicyCache alias:nil];
    [MDLIOCRegister registerBean:yingxiangBean];
    
    NSAssert([[MDLIOCRegister allRegistedBeans] count] == 5, @"当前依赖的Bean个数为5");
    
    id<HaizeiProtocol> lufei = [MDLIOCGetter instanceForProtocol:@protocol(HaizeiProtocol)];
    NSAssert([lufei class] == [Lufei class], @"当前注入的海贼是路飞");
    
    id<HaiJunProtocol> chiquan = [MDLIOCGetter instanceForProtocol:@protocol(HaiJunProtocol)];
    NSAssert([chiquan class] == [Chiquan class], @"当前注入的海军是赤犬");
    
    id<ZhanChangProtocol> malinfuduo = [MDLIOCGetter instanceForProtocol:@protocol(ZhanChangProtocol)];
    NSAssert([malinfuduo class] == [MaLinFuDuo class], @"当前注入的战场是马林福多");
    
    id<JieGuoProtocol> jieguo1 = [MDLIOCGetter instanceForProtocol:@protocol(JieGuoProtocol)];
    NSAssert([jieguo1 class] == [BaiHuziDie class], @"当前事件结果是白胡子死了");
    
    id<YingXiangProtocol> yingxiang1 = [MDLIOCGetter instanceForProtocol:@protocol(YingXiangProtocol)];
    NSAssert([yingxiang1 class] == [LufeiUp class], @"当前影响是路飞赏金变高");
    
    id<JieGuoProtocol> jieguo2 = [MDLIOCGetter instanceForProtocol:@protocol(JieGuoProtocol)];
    NSAssert(jieguo1 != jieguo2, @"未缓存策略每次拿到的对象都不同");
    
    id<YingXiangProtocol> yingxiang2 = [MDLIOCGetter instanceForProtocol:@protocol(YingXiangProtocol)];
    NSAssert(yingxiang1 == yingxiang2, @"缓存策略每次拿到的对象都是同一个");
}

//测试通过工厂注册Bean
- (void)testRegisterBeanFromFactory {
    [MDLIOCRegister cleanAllBeans];
    
    NSAssert([[MDLIOCRegister allRegistedBeans] count] == 0, @"当前依赖的Bean个数为0");
    
    id<HaizeiProtocol> lufei = [MDLIOCGetter instanceForProtocol:@protocol(HaizeiProtocol)];
    NSAssert(lufei == nil, @"未进入模块前，模块作用域对象不能访问");
    
    id<HaiJunProtocol> chiquan = [MDLIOCGetter instanceForProtocol:@protocol(HaiJunProtocol)];
    NSAssert(chiquan == nil, @"未进入模块前，模块作用域对象不能访问");
    
    id<ZhanChangProtocol> malinfuduo = [MDLIOCGetter instanceForProtocol:@protocol(ZhanChangProtocol)];
    NSAssert(malinfuduo == nil, @"未进入模块前，模块作用域对象不能访问");
    
    id<JieGuoProtocol> jieguo = [MDLIOCGetter instanceForProtocol:@protocol(JieGuoProtocol)];
    NSAssert(jieguo == nil, @"未进入模块前，模块作用域对象不能访问");
    
    //多次进入退出模块
    for (int i = 0; i < 4; i ++) {
        [TestFactory enterFactory];
        
        NSAssert([[MDLIOCRegister allRegistedBeans] count] == 4, @"当前依赖的Bean个数为4");
        
        lufei = [MDLIOCGetter instanceForProtocol:@protocol(HaizeiProtocol)];
        NSAssert([lufei class] == [Lufei class], @"当前注入的海贼是路飞");
        
        chiquan = [MDLIOCGetter instanceForProtocol:@protocol(HaiJunProtocol)];
        NSAssert([chiquan class] == [Chiquan class], @"当前注入的海军是赤犬");
        
        malinfuduo = [MDLIOCGetter instanceForProtocol:@protocol(ZhanChangProtocol)];
        NSAssert([malinfuduo class] == [MaLinFuDuo class], @"当前注入的战场是马林福多");
        
        jieguo = [MDLIOCGetter instanceForProtocol:@protocol(JieGuoProtocol)];
        NSAssert([jieguo class] == [BaiHuziDie class], @"当前事件结果是白胡子死了");

        [TestFactory exitFactory];
        
        NSAssert([[MDLIOCRegister allRegistedBeans] count] == 0, @"当前依赖的Bean个数为0");
        
        lufei = [MDLIOCGetter instanceForProtocol:@protocol(HaizeiProtocol)];
        NSAssert(lufei == nil, @"退出模块后，模块作用域对象不能访问");
        
        chiquan = [MDLIOCGetter instanceForProtocol:@protocol(HaiJunProtocol)];
        NSAssert(chiquan == nil, @"退出模块后，模块作用域对象不能访问");
        
        malinfuduo = [MDLIOCGetter instanceForProtocol:@protocol(ZhanChangProtocol)];
        NSAssert(malinfuduo == nil, @"退出模块后，模块作用域对象不能访问");
        
        jieguo = [MDLIOCGetter instanceForProtocol:@protocol(JieGuoProtocol)];
        NSAssert(jieguo == nil, @"退出模块后，模块作用域对象不能访问");
    }
}

//测试Bean组
- (void)testBeanBundle {
    [MDLIOCRegister cleanAllBeans];
    
    [MDLIOCRegister registerBean:[MDLIOCBean beanWithProtocol:@protocol(DevilNut) bindClass:[FireDevilNut class]]];
    [MDLIOCRegister registerBean:[MDLIOCBean beanWithProtocol:@protocol(DevilNut) bindClass:[RubberDevilNut class]]];
    [MDLIOCRegister registerBean:[MDLIOCBean beanWithProtocol:@protocol(DevilNut) bindClass:[DarkDevilNut class]]];
    
    NSAssert([[MDLIOCRegister allRegistedBeans] count] == 3, @"当前依赖的Bean个数为3");
    
    id devilNut = [MDLIOCGetter instanceForProtocol:@protocol(DevilNut)];
    
    NSAssert([devilNut class] == [MDLProtocolProxy class], @"Bean组返回的对象为协议代理类型");
    
    [devilNut eat];
}

- (void)testAliasBean {
    [MDLIOCRegister cleanAllBeans];
    
    [MDLIOCRegister registerBean:[MDLIOCBean beanWithProtocol:@protocol(HaizeiProtocol) bindClass:[Ais class] cachePolicy:MDLIOCCachePolicyNone alias:@"ais"]];
    [MDLIOCRegister registerBean:[MDLIOCBean beanWithProtocol:@protocol(HaizeiProtocol) bindClass:[Lufei class] cachePolicy:MDLIOCCachePolicyNone alias:@"lufei"]];
    [MDLIOCRegister registerBean:[MDLIOCBean beanWithProtocol:@protocol(HaizeiProtocol) bindClass:[Suolong class] cachePolicy:MDLIOCCachePolicyNone alias:@"suolong"]];
    
    NSAssert([[MDLIOCRegister allRegistedBeans] count] == 3, @"当前依赖的Bean个数为3");
    id haizei = [MDLIOCGetter instanceForProtocol:@protocol(DevilNut)];
    NSAssert(haizei == nil, @"需要使用别名才能获取到对象");
    
    haizei = [MDLIOCGetter instanceForProtocol:@protocol(HaizeiProtocol) alias:@"ais"];
    NSAssert([haizei class] == [Ais class], @"别名ais对应Ais");
    
    haizei = [MDLIOCGetter instanceForProtocol:@protocol(HaizeiProtocol) alias:@"lufei"];
    NSAssert([haizei class] == [Lufei class], @"别名lufei对应Lufei");
    
    haizei = [MDLIOCGetter instanceForProtocol:@protocol(HaizeiProtocol) alias:@"suolong"];
    NSAssert([haizei class] == [Suolong class], @"别名suolong对应Suolong");
}

- (void)testPerformanceExample {
    [self measureBlock:^{
        for (int i = 0; i < 100; i ++) {
            [MDLIOCRegister cleanAllBeans];
            
            [MDLIOCRegister registerBean:[MDLIOCBean beanWithProtocol:@protocol(HaizeiProtocol) bindClass:[Lufei class]]];
            [MDLIOCRegister registerBean:[MDLIOCBean beanWithProtocol:@protocol(HaiJunProtocol) bindClass:[Chiquan class]]];
            [MDLIOCRegister registerBean:[MDLIOCBean beanWithProtocol:@protocol(ZhanChangProtocol) bindClass:[MaLinFuDuo class]]];
            [MDLIOCRegister registerBean:[MDLIOCBean beanWithProtocol:@protocol(JieGuoProtocol) bindClass:[BaiHuziDie class]]];
            [MDLIOCRegister registerBean:[MDLIOCBean beanWithProtocol:@protocol(YingXiangProtocol) bindClass:[LufeiUp class]]];
            
            BigBigEvent *bigbigevent = [[BigBigEvent alloc] init];
            [bigbigevent story];
        }
    }];
}

@end
