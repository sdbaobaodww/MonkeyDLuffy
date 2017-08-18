//
//  MDLIOCInjector.h
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/17.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDLIOC.h"

@interface NSObject (MDLIOCInjector)

- (void)mdlioc_injector;

@end

@interface MDLIOCInjector : NSObject

//返回单例对象
+(instancetype)shareInstance;

#pragma mark - 获取已注册的依赖对象

/**
 通过协议名称获取对象
 @param protocol 协议名称
 @return 该协议绑定的对象
 */
- (id)instanceForProtocol:(Protocol *)protocol;

#pragma mark - 注册依赖对象

/**
 通过对象提供类加载需要注入的实例
 @param providerClassNames IOC注入对象提供类类名集合，需根据类名创建提供对象
 */
- (void)loadIOCInstanceFromProviders:(NSArray<NSString *> *)providerClassNames;

/**
 给协议注册全局作用域对象，全局作用域对象调用该方法注册时就会创建并缓存
 @param clazz 要注册的类
 @param protocol 协议名称
 */
- (void)registerGlobalClass:(Class)clazz forProtocol:(Protocol *)protocol;

/**
 给协议注册模块作用域对象，模块作用域对象调用该方法注册时不会创建，只有进入模块时才会统一进行创建，模块退出则相关对象都会释放
 @param clazz 要注册的类
 @param protocol 协议名称
 @param moduleName 模块名称，模块如果有子类化MDLIOCProvider，则必须跟子类化MDLIOCProvider返回的moduleName一致
 */
- (void)registerModuleClass:(Class)clazz forProtocol:(Protocol *)protocol moduleName:(NSString *)moduleName;

/**
 给协议注册正常作用域对象，正常作用域对象调用该方法注册时不会创建，只有使用时才会创建，生命周期管理由用户控制，IOC框架并不会进行缓存
 @param clazz 要注册的类
 @param protocol 协议名称
 */
- (void)registerNormalClass:(Class)clazz forProtocol:(Protocol *)protocol;

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
