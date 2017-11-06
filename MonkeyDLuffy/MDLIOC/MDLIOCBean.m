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

BOOL ProtocolisGroupBean (Protocol *protocol) {
    return protocol_conformsToProtocol(protocol, @protocol(MDLIOCBundle));
}

#pragma mark - Bean 类簇

//Bean初始化方法
@interface MDLIOCBean (Initialize)

- (instancetype)initWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass cachePolicy:(MDLIOCCachePolicy)cachePolicy;

+ (instancetype)beanWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass cachePolicy:(MDLIOCCachePolicy)cachePolicy;

+ (instancetype)beanWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass;

@end

//普通的Bean
@interface MDLIOCNormalBean : MDLIOCBean

@end

//有别名的Bean
@interface MDLIOCAliasBean : MDLIOCBean

@property (nonatomic, strong, readonly) NSString *alias;//别名

- (instancetype)initWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass cachePolicy:(MDLIOCCachePolicy)cachePolicy alias:(NSString *)alias;

+ (instancetype)beanWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass cachePolicy:(MDLIOCCachePolicy)cachePolicy alias:(NSString *)alias;

+ (instancetype)beanWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass alias:(NSString *)alias;

@end

//Bean组
@interface MDLIOCGroupBean : MDLIOCBean

@end

@implementation MDLIOCNormalBean

- (BOOL)isGroupBean {
    return NO;
}

@end

@implementation MDLIOCAliasBean

- (instancetype)initWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass cachePolicy:(MDLIOCCachePolicy)cachePolicy alias:(NSString *)alias{
    if (aProtocol == nil || bindClass == Nil || alias == nil) {
        @throw [NSException exceptionWithName:@"MDLIOCInjectorException" reason:@"Invalid Parameters!" userInfo:nil];
    }
    if (self = [super initWithProtocol:aProtocol bindClass:bindClass cachePolicy:cachePolicy]) {
        _alias = alias;
    }
    return self;
}

+ (instancetype)beanWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass cachePolicy:(MDLIOCCachePolicy)cachePolicy alias:(NSString *)alias {
    return [[self alloc] initWithProtocol:aProtocol bindClass:bindClass cachePolicy:cachePolicy];
}

+ (instancetype)beanWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass alias:(NSString *)alias {
    return [[self alloc] initWithProtocol:aProtocol bindClass:bindClass cachePolicy:MDLIOCCachePolicyNone alias:nil];
}

+ (NSString *)beanKeyForProtocol:(Protocol *)aProtocol alias:(NSString *)alias {
    return [NSString stringWithFormat:@"%@:%@",NSStringFromProtocol(aProtocol), alias];
}

- (BOOL)isGroupBean {
    return NO;
}

@end

@implementation MDLIOCGroupBean

- (BOOL)isGroupBean {
    return YES;
}

@end

#pragma mark - MDLIOCBean

@implementation MDLIOCBean

+ (instancetype)normalBeanWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass cachePolicy:(MDLIOCCachePolicy)cachePolicy {
    return [[MDLIOCNormalBean alloc] initWithProtocol:aProtocol bindClass:bindClass cachePolicy:cachePolicy];
}

+ (instancetype)normalBeanWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass {
    return [[MDLIOCNormalBean alloc] initWithProtocol:aProtocol bindClass:bindClass cachePolicy:MDLIOCCachePolicyNone];
}

+ (instancetype)aliasBeanWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass cachePolicy:(MDLIOCCachePolicy)cachePolicy alias:(NSString *)alias {
    return [[MDLIOCAliasBean alloc] initWithProtocol:aProtocol bindClass:bindClass cachePolicy:cachePolicy alias:alias];
}

+ (instancetype)aliasBeanWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass alias:(NSString *)alias {
    return [[MDLIOCAliasBean alloc] initWithProtocol:aProtocol bindClass:bindClass cachePolicy:MDLIOCCachePolicyNone alias:alias];
}

+ (instancetype)groupBeanWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass cachePolicy:(MDLIOCCachePolicy)cachePolicy {
    return [[MDLIOCGroupBean alloc] initWithProtocol:aProtocol bindClass:bindClass cachePolicy:cachePolicy];
}

+ (instancetype)groupBeanWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass {
    return [[MDLIOCGroupBean alloc] initWithProtocol:aProtocol bindClass:bindClass cachePolicy:MDLIOCCachePolicyNone];
}

- (instancetype)init {
    return nil;
}

- (instancetype)initWithProtocol:(Protocol *)aProtocol bindClass:(Class)bindClass cachePolicy:(MDLIOCCachePolicy)cachePolicy {
    if ( aProtocol == nil || bindClass == Nil) {
        @throw [NSException exceptionWithName:@"MDLIOCInjectorException" reason:@"Invalid Parameters!" userInfo:nil];
    }
    if (self = [super init]) {
        _protocol = aProtocol;
        _bindClass = bindClass;
        _cachePolicy = cachePolicy;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@-%@ cache:%ld>",[self beanKey],NSStringFromClass(_bindClass),(long)_cachePolicy];
}

- (NSString *)beanKey {
    return [MDLIOCBean beanKeyForProtocol:self.protocol alias:nil];
}

+ (NSString *)beanKeyForProtocol:(Protocol *)aProtocol alias:(NSString *)alias {
    return alias ? [MDLIOCAliasBean beanKeyForProtocol:aProtocol alias:alias] : [self beanKeyForProtocol:aProtocol];
}

+ (NSString *)beanKeyForProtocol:(Protocol *)aProtocol {
    return NSStringFromProtocol(aProtocol);
}

- (NSUInteger)hash {
    return [[self beanKey] hash];
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    if ([[self beanKey] isEqual:[object beanKey]]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isGroupBean {
    return NO;
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
