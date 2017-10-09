//
//  MDLProtocolProxy.h
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/9/14.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 协议代理类，为一个协议绑定多个实现对象，对该协议代理对象的调用，视为对所有绑定实现对象的调用。
 */
@interface MDLProtocolProxy : NSProxy

@property (nonatomic, strong, readonly) Protocol *protocol;//被代理的协议

- (instancetype)initWithProtocol:(Protocol *)protocol;

/**
 增加一个协议的实现对象
 @param clazz 协议实现对象
 */
- (void)addProtocolImplWithClass:(Class)clazz;

/**
 移除指定协议的实现对象
 @param clazz 协议实现对象
 */
- (void)removeImplWithClass:(Class)clazz;

/**
 @return 当前总实现个数
 */
- (NSInteger)implCount;

@end
