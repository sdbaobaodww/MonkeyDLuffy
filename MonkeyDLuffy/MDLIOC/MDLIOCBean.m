//
//  MDLIOCBeanFactory.m
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/17.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import "MDLIOCBean.h"
#import "MDLIOCInjector.h"
#import <objc/runtime.h>

BOOL ProtocolIsBundleBean (Protocol *protocol) {
    return protocol_conformsToProtocol(protocol, @protocol(MDLIOCBundle));
}

@implementation MDLIOCBean

- (instancetype)initWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass cachePolicy:(MDLIOCCachePolicy)cachePolicy alias:(NSString *)alias{
    if (bindClass == Nil || aProtocol == nil) {
        @throw [NSException exceptionWithName:@"MDLIOCInjectorException" reason:@"Invalid Parameters!" userInfo:nil];
    }
    
    if (self = [super init]) {
        _protocol = aProtocol;
        _bindClass = bindClass;
        _cachePolicy = cachePolicy;
        _alias = alias;
    }
    return self;
}

+ (instancetype)beanWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass cachePolicy:(MDLIOCCachePolicy)cachePolicy alias:(NSString *)alias {
    return [[self alloc] initWithProtocol:aProtocol bindClass:bindClass cachePolicy:cachePolicy alias:alias];
}

+ (instancetype)beanWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass {
    return [[self alloc] initWithProtocol:aProtocol bindClass:bindClass cachePolicy:MDLIOCCachePolicyNone alias:nil];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@-%@ cache:%ld>",[self beanKey],NSStringFromClass(_bindClass),(long)_cachePolicy];
}

- (NSString *)beanKey {
    return [[self class] beanKeyForProtocol:self.protocol alias:self.alias];
}

+ (NSString *)beanKeyForProtocol:(Protocol *)aProtocol alias:(NSString *)alias {
    return [NSString stringWithFormat:@"%@:%@",NSStringFromProtocol(aProtocol), alias ? alias : @""];
}

- (NSUInteger)hash {
    return [[self beanKey] hash];
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    
    if (![object isKindOfClass:[MDLIOCBean class]]) {
        return NO;
    }
    
    if ([[self beanKey] isEqual:[object beanKey]]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isBundleBean {
    return NO;
}

@end

@implementation MDLIOCBundleBean

- (BOOL)isBundleBean {
    return YES;
}

+ (NSString *)beanKeyForProtocol:(Protocol *)aProtocol alias:(NSString *)alias {
    return [NSString stringWithFormat:@"_G_:%@",NSStringFromProtocol(aProtocol)];
}

@end

@implementation MDLIOCBeanFactoryAbstract

+ (int)enterCount {
    return [objc_getAssociatedObject(self, _cmd) intValue];
}

+ (void)setEnterCount:(int)count {
    objc_setAssociatedObject(self, @selector(enterCount), @(count), OBJC_ASSOCIATION_RETAIN);
}

+ (NSArray<MDLIOCBean *> *)buildBeans {
    @throw [NSException exceptionWithName:@"MDLIOCInjectorException" reason:@"method buildBeans must be override" userInfo:nil];
}

+ (void)enterFactory {
    [self setEnterCount:([self enterCount] + 1)];
    if (![MDLIOCRegister isFactoryEntered:self]) {
        [MDLIOCRegister registerBeans:[self buildBeans] fromFactory:self];
    }
}

+ (void)exitFactory {
    [self setEnterCount:([self enterCount] - 1)];
    if ([self enterCount] == 0) {
        [MDLIOCRegister unRegisterAllBeansFromFactory:self];
    }
}

@end
