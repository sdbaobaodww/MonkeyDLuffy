//
//  MDLIOCRegister.h
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/9/18.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDLIOCBean.h"

#pragma mark - IOC注册

/**
 IOC注册类，调用此类方法进行注册和解除注册
 Bean工厂的概念，工厂会在进入时注册相关的Bean，并在退出时清理该工厂已注册的Bean
 */
@interface MDLIOCRegister : NSObject

/**
 通过IOC注入描述对象注册依赖对象
 @param bean IOC注入描述对象
 @param factory Bean工厂，Bean工厂会影响Bean的生命周期，工厂被销毁时，工厂下的Bean也会被销毁
 */
+ (void)registerBean:(MDLIOCBean * __nonnull)bean fromFactory:(Class<MDLIOCBeanFactory> __nullable)factory;

/**
 @see registerBean:fromFactory:
 */
+ (void)registerBean:(MDLIOCBean * __nonnull)bean;

/**
 通过IOC注入描述对象集合注册依赖对象
 @param beans IOC注入对象描述对象集合
 @param factory Bean工厂，Bean工厂会影响Bean的生命周期，工厂被销毁时，工厂下的Bean也会被销毁
 */
+ (void)registerBeans:(NSArray * __nonnull)beans fromFactory:(Class<MDLIOCBeanFactory> __nullable)factory;

/**
 IOC注册依赖对象
 @param protocol 协议
 @param clazz 协议实现类
 @param cachePolicy 缓存策略
 @param alias 别名
 @param factory Bean工厂，Bean工厂会影响Bean的生命周期，工厂被销毁时，工厂下的Bean也会被销毁
 */
+ (void)registerProtocol:(Protocol * __nonnull)protocol
                   clazz:(Class __nonnull)clazz
             cachePolicy:(MDLIOCCachePolicy)cachePolicy
                   alias:(NSString * __nullable)alias
             fromFactory:(Class<MDLIOCBeanFactory> __nullable)factory;

/**
 @see registerProtocol:clazz:cachePolicy:alias:fromFactory:
 */
+ (void)registerProtocol:(Protocol * __nonnull)protocol
                   clazz:(Class __nonnull)clazz
             cachePolicy:(MDLIOCCachePolicy)cachePolicy
             fromFactory:(Class<MDLIOCBeanFactory> __nullable)factory;

/**
 @see registerProtocol:clazz:cachePolicy:alias:fromFactory:
 */
+ (void)registerProtocol:(Protocol * __nonnull)protocol
                   clazz:(Class __nonnull)clazz
             cachePolicy:(MDLIOCCachePolicy)cachePolicy;

/**
 @see registerProtocol:clazz:cachePolicy:alias:fromFactory:
 */
+ (void)registerProtocol:(Protocol * __nonnull)protocol
                   clazz:(Class __nonnull)clazz;

/**
 取消注册工厂下所有已注册的Bean
 @param factory Bean工厂，Bean工厂会影响Bean的生命周期，工厂被销毁时，工厂下的Bean也会被销毁
 */
+ (void)unRegisterAllBeansFromFactory:(Class<MDLIOCBeanFactory> __nonnull)factory;


/**
 判断是否已经进入该工厂

 @param factory Bean 工厂
 @return 已进入工厂返回YES，否则返回NO
 */
+ (BOOL)isFactoryEntered:(Class<MDLIOCBeanFactory> __nonnull)factory;

/**
 @return 所有已注册的Bean
 */
+ (NSArray<MDLIOCBean *> * __nullable)allRegistedBeans;

/**
 清除所有已注册的Bean
 */
+ (void)cleanAllBeans;

@end

#pragma mark - IOC获取

/**
 IOC依赖对象获取类
 */
@interface MDLIOCGetter : NSObject

/**
 获取注入对象
 @param protocol 协议
 @param alias 别名
 @return 生成的实例
 */
+ (id __nullable)instanceForProtocol:(Protocol * __nonnull)protocol alias:(NSString * __nullable)alias;

/**
 @see instanceForProtocol:alias:
 */
+ (id __nullable)instanceForProtocol:(Protocol * __nonnull)protocol;

/**
 获取协议代理对象MDLProtocolProxy，如果传入alias则获取
 @param protocol 协议
 @param alias 别名
 @return 生成的实例
 */
+ (id __nullable)groupInstanceForProtocol:(Protocol * __nonnull)protocol alias:(NSString * __nullable)alias;

/**
 @see groupInstanceForProtocol:alias:
 */
+ (id __nullable)groupInstanceForProtocol:(Protocol * __nonnull)protocol;

@end

#pragma mark - IOC注入

/**
 IOC依赖注入类，实现依赖对象的注入
 */
@interface MDLIOCInjector : NSObject

/**
 在当前对象注入依赖的对象，如ClassA有两个属性需要使用IOC注入，调用此方法后会将依赖的对象设置进去
 @param obj 可注入的对象实例
 */
+ (void)injector:(NSObject<MDLInjectable> * __nonnull)obj;

@end

/**
 依赖注入快分类
 */
@interface NSObject (MDLIOCInjector)

//调用此方法进行依赖对象注入，需实现MDLInjectable协议
- (void)mdlioc_injector;

@end

