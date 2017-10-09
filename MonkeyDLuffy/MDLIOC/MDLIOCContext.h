//
//  MDLIOCRegister.h
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/16.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MDLIOCBean;

/**
 IOC上下文，上下文的作用：1，缓存所有的注入Bean；2，缓存使用缓存策略Bean生成的对象；3，提供工厂使用的批量注册、解除注册方法
 */
@interface MDLIOCContext : NSObject

/**
 @return 所有的注入Bean
 */
- (NSDictionary * __nonnull)allBeans;

/**
 注册IOCBean，有3种使用类型：
 1，Bean束。protocol继承MDLIOCBundle协议，表示该协议使用Bean束，Bean束指为协议绑定多个实现对象的情形，Bean束注册时会生成一个协议代理对象MDLProtocolProxy，Bean束的获取会返回该协议代理对象，使用时对代理对象进行调用方法，可视为对所有绑定对象调用方法
 2，Bean有别名。一个协议在不同业务使用不同的实现类，使用别名可进行区分，获取时，使用不同别名，可获取各业务的实现类。
 3，通常情况下协议只绑定一个实现类
 
 @param bean IOC注入描述对象
 @param key Bean或Bean束关键字
 */
- (void)registerBean:(MDLIOCBean * __nonnull)bean forKey:(NSString * __nonnull)key;

/**
 非Bean束取消注册方法
 @param beanKey Bean关键字
 */
- (void)unRegisterBeanForKey:(NSString * __nonnull)beanKey;

/**
 Bean束取消注册方法，clazz为Nil时，表示取消注册Bean束，clazz不为Nil时，表示取消注册Bean束中指定clazz实现
 @param beanKey Bean束关键字
 @param clazz 指定类，bean束时用到，如果有指定，则移除bean束绑定clazz的bean，否则移除整个bean束
 */
- (void)unRegisterBeanBundleForKey:(NSString * __nonnull)beanKey clazz:(Class __nullable)clazz;

/**
 取消注册工厂下所有已注册的Bean，退出工厂时调用
 @param beans IOC注入对象描述对象集合
 */
- (void)unRegisterBeans:(NSArray * __nonnull)beans;

/**
 一、protocol未注册过，则返回nil。
 二、Bean束，protocol继承MDLIOCBundle协议，则会返回协议代理对象（MDLProtocolProxy），对代理对象的方法调用，视为对Bean束所有对象的调用；
 三、非Bean束：
 1，使用缓存策略的第一次调用时创建，创建后只要上下文未释放就会一直存在；
 2，不使用缓存策略的每次调用时都会创建；
 
 @param beanKey Bean或Bean束关键字
 @param beanBundle 是否是Bean束
 @return 生成的实例
 */
- (id __nullable)instanceForKey:(NSString * __nonnull)beanKey beanBunlde:(BOOL)beanBundle;

#pragma mark - Subscripting

- (MDLIOCBean * __nullable)objectForKeyedSubscript:(id<NSCopying> __nonnull)beanKey;

- (void)setObject:(MDLIOCBean * __nullable)anObject forKeyedSubscript:(id<NSCopying> __nonnull)beanKey;

@end
