//
//  MDLIOCRegister.h
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/16.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDLIOC.h"

/**
 IOC上下文，所有作用域为模块或者全局的生成对象在此进行绑定缓存
 */
@interface MDLIOCContext : NSObject

#pragma mark - 全局作用域

/**
 通过协议名称绑定对应的全局作用域对象
 @param instance 绑定的对象
 @param protocol 协议名称
 */
- (void)addGlobalInstance:(id)instance forProtocol:(NSString *)protocol;

/**
 通过协议名称获取绑定的全局作用域对象
 @param protocol 协议名称
 @return 协议名称绑定的对象
 */
- (id)globalInstanceForProcotol:(NSString *)protocol;

#pragma mark - 模块作用域

/**
 通过协议名称绑定对应的模块作用域对象
 @param instance 绑定的对象
 @param protocol 协议名称
 */
- (void)addModuleInstance:(id)instance forProtocol:(NSString *)protocol;

/**
 通过协议名称获取绑定的模块作用域对象
 @param protocol 协议名称
 @return 协议名称绑定的对象
 */
- (id)moduleInstanceForProtocol:(NSString *)protocol;

/**
 移除协议名称下所有已绑定的对象
 @param protocols 协议名称集合
 */
- (void)removeModuleInstancesForProtocols:(NSArray<NSString *> *)protocols;

@end
