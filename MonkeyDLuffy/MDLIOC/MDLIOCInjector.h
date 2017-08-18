//
//  MDLIOCInjector.h
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/17.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDLIOCBean.h"

@interface NSObject (MDLIOCInjector)

//调用此方法进行依赖对象注入，需实现MDLInjectableProtocol协议
- (void)mdlioc_injector;

@end

/**
 单例对象，IOC注入器，
 */
@interface MDLIOCInjector : NSObject

//返回单例对象
+(instancetype)shareInstance;

/**
 @param scope 注入对象作用范围
 @return 不同作用范围缓存的注入对象
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
 通过IOC注入描述对象注入依赖对象
 @param bean IOC注入描述对象
 */
- (void)registerBean:(MDLIOCBean *)bean;

#pragma mark - 依赖注入

/**
 在当前对象注入依赖的对象，如ClassA有两个属性需要使用IOC注入，调用此方法后会将依赖的对象设置进去
 @param obj 可注入的对象实例
 */
- (void)injector:(NSObject<MDLInjectableProtocol> *)obj;

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
