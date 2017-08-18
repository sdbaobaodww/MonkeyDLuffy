//
//  MDLIOCModule.m
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/17.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import "MDLIOCBean.h"

@implementation MDLIOCBean

- (instancetype)initWithProtocol:(Protocol *)aProtocol
                       bindClass:(Class)bindClass
                           scope:(MDLIOCScope)scope
                      moduleName:(NSString *)moduleName{
    if (self = [super init]) {
        _protocol = aProtocol;
        _bindClass = bindClass;
        _scope = scope;
        _moduleName = moduleName;
    }
    return self;
}

- (instancetype)initWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass scope:(MDLIOCScope)scope {
    return [self initWithProtocol:aProtocol bindClass:bindClass scope:scope moduleName:nil];
}

+ (instancetype)beanWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass scope:(MDLIOCScope)scope {
    return [[MDLIOCBean alloc] initWithProtocol:aProtocol bindClass:bindClass scope:scope moduleName:nil];
}

- (instancetype)moduleBeanWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass moduleName:(NSString *)moduleName {
    return [self initWithProtocol:aProtocol bindClass:bindClass scope:MDLIOCScopeModule moduleName:nil];
}

+ (instancetype)moduleBeanWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass moduleName:(NSString *)moduleName {
    return [[MDLIOCBean alloc] initWithProtocol:aProtocol bindClass:bindClass scope:MDLIOCScopeModule moduleName:moduleName];
}

@end
