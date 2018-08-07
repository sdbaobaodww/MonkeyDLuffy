//
//  MDLIOCBeanFactory.h
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/17.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Bean束协议

/**
 IOCBean束协议，继承该协议，标识注入bean时使用bean束，实现对bean束的调用，会轮流调用所有已注册的该协议的实现对象
 */
@protocol MDLIOCBundle

@end

//判断该协议是否使用bean束
extern BOOL ProtocolIsBundleBean (Protocol *protocol);

//注入对象缓存策略
typedef NS_ENUM(NSInteger, MDLIOCCachePolicy) {
    MDLIOCCachePolicyNone,      //不缓存，每次使用时都重新创建
    MDLIOCCachePolicyCache,     //缓存，如果不清理则创建以后会一直存在
};

#pragma mark - 可注入协议

/**
 可注入协议，依赖注入的对象必须实现此协议
 */
@protocol MDLInjectable <NSObject>

/**
 @return 依赖注入的属性集合
 */
+ (NSSet *)mdlioc_injectableProperties;

@end

@protocol IOCBean

- (Protocol *)protocol;
- (Class)bindClass;
- (MDLIOCCachePolicy)cachePolicy;
- (NSString *)alias;
- (BOOL)isBundleBean;

- (NSString *)beanKey;

+ (NSString *)beanKeyForProtocol:(Protocol *)aProtocol alias:(NSString *)alias;

@end

#pragma mark - IOC Bean

/**
 IOC注入描述类，在该类中设置关联协议、实现类、以及缓存策略等信息
 */
@interface MDLIOCBean : NSObject
//关联的协议
@property (nonatomic, strong, readonly) Protocol *protocol;
//绑定的实现类
@property (nonatomic, strong, readonly) Class bindClass;
//缓存策略
@property (nonatomic, assign, readonly) MDLIOCCachePolicy cachePolicy;
//别名
@property (nonatomic, strong, readonly) NSString *alias;

- (instancetype)initWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass cachePolicy:(MDLIOCCachePolicy)cachePolicy alias:(NSString *)alias;

+ (instancetype)beanWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass cachePolicy:(MDLIOCCachePolicy)cachePolicy alias:(NSString *)alias;

+ (instancetype)beanWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass;

/**
 Bean的唯一标识
 */
- (NSString *)beanKey;

/**
 通过协议和别名获取Bean的唯一标识
 @param aProtocol 协议
 @param alias 别名
 @return bean的唯一标识
 */
+ (NSString *)beanKeyForProtocol:(Protocol *)aProtocol alias:(NSString *)alias;

/**
 是否是Bean束
 @return YES为Bean束，否则NO
 */
- (BOOL)isBundleBean;

@end

/**
 Bean组
 */
@interface MDLIOCBundleBean : MDLIOCBean

@end

#pragma mark - IOCBean工厂协议

/**
 IOCBean工厂，通常一个业务模块对应一个IOCBean工厂
 */
@protocol MDLIOCBeanFactory

/**
 进入工厂，可多次调用，因为每个工厂可能有多个入口，只有第一次进入时会注册该工厂下所有的注入对象
 */
+ (void)enterFactory;

/**
 退出工厂，可多次调用，因为每个工厂可能有多个出口，只有最后一次退出时会注销该工厂下所有的注入对象
 */
+ (void)exitFactory;

/**
 @return 需注册的IOC注入描述对象集合
 */
+ (NSArray<MDLIOCBean *> *)buildBeans;

@end

/**
 注册IOC依赖对象模块抽象实现类，buildBeans方法必须重载
 */
@interface MDLIOCBeanFactoryAbstract : NSObject<MDLIOCBeanFactory>

@end
