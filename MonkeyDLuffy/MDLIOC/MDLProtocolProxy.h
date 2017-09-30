//
//  MDLProtocolProxy.h
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/9/14.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import <Foundation/Foundation.h>

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
