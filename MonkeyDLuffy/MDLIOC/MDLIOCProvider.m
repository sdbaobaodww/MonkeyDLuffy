//
//  MDLIOCModule.m
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/17.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import "MDLIOCProvider.h"

@implementation MDLIOCBean

- (instancetype)initWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass scope:(MDLIOCScope)scope {
    if (self = [super init]) {
        _protocol = aProtocol;
        _bindClass = bindClass;
        _scope = scope;
    }
    return self;
}

+ (instancetype)beanWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass scope:(MDLIOCScope)scope {
    return [[MDLIOCBean alloc] initWithProtocol:aProtocol bindClass:bindClass scope:scope];
}

@end
