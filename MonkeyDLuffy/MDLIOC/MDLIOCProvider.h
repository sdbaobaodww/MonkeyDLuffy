//
//  MDLIOCModule.h
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/17.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDLIOC.h"

/**
 协议实现类关联对象，关联协议名称与实现类
 */
@interface MDLIOCBean : NSObject
//关联的协议
@property (nonatomic, strong, readonly) Protocol *protocol;
//绑定的实现类
@property (nonatomic, strong, readonly) Class bindClass;
//作用域
@property (nonatomic, assign, readonly) MDLIOCScope scope;

- (instancetype)initWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass scope:(MDLIOCScope)scope;

+ (instancetype)beanWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass scope:(MDLIOCScope)scope;

@end

/**
 IOC注入对象提供者协议，个业务模块可对应一个或多个注入对象提供者
 */
@protocol MDLIOCProvider <NSObject>

/**
 创建关联对象
 @return 关联对象集合
 */
+ (NSArray<MDLIOCBean *> *)buildBeans;

/**
 模块名称，默认使用当前对象的类名作为模块名称
 @return 模块名称
 */
+ (NSString *)moduleName;

@end
