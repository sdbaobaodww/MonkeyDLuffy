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

inline BOOL ProtocolIsBundleBean (Protocol *protocol) {
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
    return [[MDLIOCBean alloc] initWithProtocol:aProtocol bindClass:bindClass cachePolicy:cachePolicy alias:alias];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@-%@ cache:%ld>",[self beanKey],NSStringFromClass(_bindClass),(long)_cachePolicy];
}

- (NSString *)beanKey {
    return [MDLIOCBean beanKeyForProtocol:self.protocol alias:self.alias];
}

+ (NSString *)beanKeyForProtocol:(Protocol *)aProtocol alias:(NSString *)alias {
    return alias ? [NSString stringWithFormat:@"%@:%@",NSStringFromProtocol(aProtocol), alias] : NSStringFromProtocol(aProtocol);
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
    return ProtocolIsBundleBean(self.protocol);
}

@end

@implementation MDLIOCBeanKey

- (id)copyWithZone:(nullable NSZone *)zone {
    MDLIOCBeanKey *key = [self copyWithZone:zone];
    key.protocol = self.protocol;
    key.alias = self.alias;
    key.factoryName = self.factoryName;
    return key;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:%@:%@",self.protocol,self.alias ?: @"" ,self.factoryName ?: @""];
}

- (NSUInteger)hash {
    return [[self description] hash];
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    
    if (![object isKindOfClass:[MDLIOCBeanKey class]]) {
        return NO;
    }
    
    if ([[self description] isEqual:[object description]]) {
        return YES;
    }
    
    return NO;
}

@end

@implementation MDLIOCBeanFactoryAbstract

+ (NSArray<MDLIOCBean *> *)buildBeans {
    @throw [NSException exceptionWithName:@"MDLIOCInjectorException" reason:@"method buildBeans must be override" userInfo:nil];
}

+ (NSString *)factoryName {
    return NSStringFromClass(self);
}

+ (void)enterFactory {
    
}

+ (void)exitFactory {
    
}

@end
