//
//  MDLIOCInjector.h
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/17.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDLIOCBean.h"

#pragma mark - 可注入协议

/**
 可注入协议，依赖注入的对象必须实现此协议
 */
@protocol MDLInjectable <NSObject>

+ (NSSet *)mdlioc_injectableProperties;

@end

#pragma mark - 依赖注入快分类

/**
 依赖注入快分类
 */
@interface NSObject (MDLIOCInjector)

//调用此方法进行依赖对象注入，需实现MDLInjectable协议
- (void)mdlioc_injector;

@end

#pragma mark - IOC注入器

/**
 IOC注入器，单例对象，管理依赖对象的注册、获取、注入，只有注册过的对象才能被获取及注入。
 */
@interface MDLIOCInjector : NSObject

//返回单例对象
+(instancetype)sharedInstance;

/**
 重置当前上下文，清空所有已注册和生成的缓存对象
 */
- (void)resetContext;

/**
 通过类似注解的方式注册依赖对象，注册对象应在+load方法中进行注解注册，注入器初始化时，会将注解注册的对象统一进行注册
 @param bean IOC注入描述对象
 */
+ (void)annotationRegisterBean:(MDLIOCBean *)bean;

/**
 @param scope 注入对象作用范围
 @return 不同作用范围缓存的注入对象，正常作用域范围的对象每次都会重新创建不会进行缓存，所以返回的是nil
 */
- (NSDictionary *)cachesWithScope:(MDLIOCScope)scope;

/**
 @return 所有的注入Bean
 */
- (NSDictionary *)allBeans;

#pragma mark - 获取已注册的依赖对象

/**
 通过协议名称获取对象
 @param protocol 协议名称
 @return 该协议绑定的对象
 */
- (id)instanceForProtocol:(Protocol *)protocol;

#pragma mark - 注册依赖对象

/**
 通过IOC注入对象提供者加载需要注入的实例
 @param providerClassNames IOC注入对象提供者类名集合
 */
- (void)loadIOCInstanceFromProviders:(NSArray<NSString *> *)providerClassNames;

/**
 通过IOC注入描述对象注册依赖对象，一个协议重复注册会报错
 @param bean IOC注入描述对象
 */
- (void)registerBean:(MDLIOCBean *)bean;

#pragma mark - 依赖注入

/**
 在当前对象注入依赖的对象，如ClassA有两个属性需要使用IOC注入，调用此方法后会将依赖的对象设置进去
 @param obj 可注入的对象实例
 */
- (void)injector:(NSObject<MDLInjectable> *)obj;

#pragma mark - 模块生命周期管理

/**
 进入模块，可调用多次，每进入一次模块的计数会增加
 @param moduleName 模块名称
 */
- (void)enterModule:(NSString *)moduleName;

/**
 退出模块，可调用多次，每退出一次模块的计数会减少
 @param moduleName 模块名称
 */
- (void)exitModule:(NSString *)moduleName;

@end
