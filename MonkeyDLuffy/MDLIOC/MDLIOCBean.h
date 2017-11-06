//
//  MDLIOCBeanFactory.h
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/17.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Bean组协议

/**
 IOCBean组协议，继承该协议，标识注入bean时使用Bean组，实现对Bean组的调用，会轮流调用所有已注册的该协议的实现对象
 */
@protocol MDLIOCBundle

@end

//判断该协议是否使用Bean组
extern BOOL ProtocolisGroupBean (Protocol *protocol);

//注入对象缓存策略
typedef NS_ENUM(NSInteger, MDLIOCCachePolicy) {
    MDLIOCCachePolicyNone,      //不缓存，每次使用时都重新创建
    MDLIOCCachePolicyCache,     //缓存，如果不清理则创建以后会一直存在
};

/**
 Bean类型，对应Bean的3种使用场景：
 1，通常情况，一个协议只绑定一个实现类；
 2，别名情况，一个协议绑定多个实现类，在不同业务下使用的实现不同，使用别名可进行区分，获取时，使用不同别名，可获取不同业务的实现类；
 3，Bean组情况，一个协议对应多个实现类，但对外表现为一个整体对象，对该对象进行调用方法，可视为对所有绑定类调用方法。
 */
typedef NS_ENUM(NSInteger, MDLIOCBeanType) {
    MDLIOCBeanTypeNormal,       //普通的Bean
    MDLIOCBeanTypeAlias,        //带有别名的Bean，
    MDLIOCBeanTypeGroup         //Bean组
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

#pragma mark - IOC Bean

/**
 IOC注入描述类，在该类中设置关联协议、实现类、以及缓存策略等信息,有3种使用场景：
 1，通常情况，一个协议只绑定一个实现类；
 2，别名情况，一个协议绑定多个实现类，在不同业务下使用的实现不同，使用别名可进行区分，获取时，使用不同别名，可获取不同业务的实现类；
 3，Bean组情况，一个协议对应多个实现类，但对外表现为一个整体对象，对该对象进行调用方法，可视为对所有绑定类调用方法。
 */
@interface MDLIOCBean : NSObject

@property (nonatomic, strong, readonly) Protocol *protocol;//关联的协议

@property (nonatomic, strong, readonly) Class bindClass;//绑定的实现类

@property (nonatomic, assign, readonly) MDLIOCCachePolicy cachePolicy;//缓存策略

/************通常情况的Bean***************/
+ (instancetype)normalBeanWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass cachePolicy:(MDLIOCCachePolicy)cachePolicy;

+ (instancetype)normalBeanWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass;

//通过协议获取Bean的唯一标识
+ (NSString *)normalKeyForProtocol:(Protocol *)aProtocol;

/************别名情况的Bean***************/
+ (instancetype)aliasBeanWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass cachePolicy:(MDLIOCCachePolicy)cachePolicy alias:(NSString *)alias;

+ (instancetype)aliasBeanWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass alias:(NSString *)alias;

//通过协议和别名获取Bean的唯一标识
+ (NSString *)aliasKeyForProtocol:(Protocol *)aProtocol alias:(NSString *)alias;

/************Bean组情况***************/
+ (instancetype)groupBeanWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass cachePolicy:(MDLIOCCachePolicy)cachePolicy;

+ (instancetype)groupBeanWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass;

//通过协议获取Bean组的唯一标识
+ (NSString *)groupKeyForProtocol:(Protocol *)aProtocol;

/**********************************/

//Bean的唯一标识
- (NSString *)beanKey;

//是否是Bean组，YES为Bean组，否则NO
- (BOOL)isGroupBean;

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
