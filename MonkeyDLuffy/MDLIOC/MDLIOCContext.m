//
//  MDLIOCRegister.m
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/16.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import "MDLIOCContext.h"
#import "MDLProtocolProxy.h"
#import "MDLIOCBean.h"

@implementation MDLIOCContext
{
    NSMutableDictionary *_instanceCache;//对象缓存
    NSMutableDictionary<id<NSCopying>, NSMutableArray<MDLIOCBean *> *> *_bundleBeans;//bean束，协议与实现一对多，{beanKey:[bean]}
    NSMutableDictionary<id<NSCopying>, MDLIOCBean *> *_normalBeans;//通用的bean集合，无别名时协议与实现一对一，有别名时协议与实现一对多。{beanKey:bean}
}

- (instancetype)init {
    if (self = [super init]) {
        _instanceCache = [[NSMutableDictionary alloc] init];
        _bundleBeans = [[NSMutableDictionary<id<NSCopying>, NSMutableArray<MDLIOCBean *> *> alloc] init];
        _normalBeans = [[NSMutableDictionary<id <NSCopying>, MDLIOCBean *> alloc] init];
    }
    return self;
}

- (NSDictionary *)allBeans {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:_normalBeans];
    [dic addEntriesFromDictionary:_bundleBeans];
    return dic;
}

- (void)registerBean:(MDLIOCBean * __nonnull)bean forKey:(NSString * __nonnull)beanKey {
    if ([bean isBundleBean]) {
        NSMutableArray *bunleBeans = _bundleBeans[beanKey];//该协议对应的bean束是否存在
        MDLProtocolProxy *proxy = _instanceCache[beanKey];//每个bean束会创建一个MDLProtocolProxy并在_instanceCache进行缓存
        if (!bunleBeans) {//bean束不存在
            //创建并绑定bean束
            bunleBeans = [NSMutableArray array];
            _bundleBeans[beanKey] = bunleBeans;
            
            //创建并缓存MDLProtocolProxy代理对象
            proxy = [[MDLProtocolProxy alloc] initWithProtocol:bean.protocol];
            _instanceCache[beanKey] = proxy;
        }
        
        [bunleBeans addObject:bean];
        [proxy addProtocolImplWithClass:bean.bindClass];
    }else{
        _normalBeans[beanKey] = bean;
    }
}

- (void)unRegisterBeanForKey:(NSString * __nonnull)beanKey {
    MDLIOCBean *bean = _normalBeans[beanKey];//查找已注册的Bean
    if (bean.cachePolicy == MDLIOCCachePolicyCache) {//可能有缓存对象
        [_instanceCache removeObjectForKey:beanKey];
    }
    [_normalBeans removeObjectForKey:beanKey];
}

- (void)unRegisterBeanBundleForKey:(NSString * __nonnull)beanKey clazz:(Class __nullable)clazz {
    if (clazz) {//解除注册bean束内指定class
        //获取代理对象，移除该bean在代理对象中的实现
        MDLProtocolProxy *proxy = _instanceCache[beanKey];
        [proxy removeImplWithClass:clazz];
        
        //查找该class对应的bean
        NSMutableArray *bundleBean = _bundleBeans[beanKey];
        MDLIOCBean *findBean = nil;
        NSInteger idx = 0;
        for (MDLIOCBean *bean in bundleBean) {
            if ([bean.bindClass isEqual:clazz]) {
                findBean = bean;
                break;
            }
            idx ++;
        }
        
        if (findBean) {
            [bundleBean removeObjectAtIndex:idx];//从bean束中移除bean
            //当bean束不存在任何bean时，移除bean束，移除缓存的MDLProtocolProxy代理对象
            if ([bundleBean count] == 0) {
                [_bundleBeans removeObjectForKey:beanKey];//移除bean束
                [_instanceCache removeObjectForKey:beanKey];//移除缓存的代理对象
            }
        }
    }else{//解除注册bean束
        [_bundleBeans removeObjectForKey:beanKey];//移除bean束
        [_instanceCache removeObjectForKey:beanKey];//移除缓存的代理对象
    }
}

- (void)unRegisterBeans:(NSArray * __nonnull)beans {
    for (MDLIOCBean *bean in beans) {
        id<NSCopying> beanKey = [bean beanKey];
        
        if ([bean isBundleBean]) {
            //获取代理对象，移除该bean在代理对象中的实现
            MDLProtocolProxy *proxy = _instanceCache[beanKey];
            [proxy removeImplWithClass:bean.bindClass];
            
            //从bean束中移除bean
            NSMutableArray *bundleBean = _bundleBeans[beanKey];
            [bundleBean removeObject:bean];
            
            //当bean束不存在任何bean时，移除bean束，移除缓存的MDLProtocolProxy代理对象
            if ([bundleBean count] == 0) {
                [_bundleBeans removeObjectForKey:beanKey];//移除bean束
                [_instanceCache removeObjectForKey:beanKey];//移除缓存的代理对象
            }
        }else{
            [_normalBeans removeObjectForKey:beanKey];
            if (bean.cachePolicy == MDLIOCCachePolicyCache) {//可能有缓存对象
                [_instanceCache removeObjectForKey:beanKey];
            }
        }
    }
}

- (id __nullable)instanceForKey:(NSString * __nonnull)beanKey beanBunlde:(BOOL)beanBundle {
    if (beanBundle) {//bean束
        return _instanceCache[beanKey];
    }
    
    MDLIOCBean *bean = _normalBeans[beanKey];
    if (!bean)
        return nil;
    
    switch (bean.cachePolicy) {//需缓存时，先看缓存中是否存在实现对象，否则创建并缓存；其它情况，每次都重新创建
        case MDLIOCCachePolicyCache: {
            id instance = _instanceCache[beanKey];
            if (!instance) {
                instance = [[bean.bindClass alloc] init];
                _instanceCache[beanKey] = instance;
            }
            return instance;
        }
        default:
            return [[bean.bindClass alloc] init];
    }
}

#pragma mark - Subscripting 下标赋值取值

- (MDLIOCBean * __nullable)objectForKeyedSubscript:(id<NSCopying> __nonnull)beanKey {
    return _normalBeans[beanKey];
}

- (void)setObject:(MDLIOCBean * __nullable)anObject forKeyedSubscript:(id<NSCopying> __nonnull)beanKey {
    _normalBeans[beanKey] = anObject;
}

@end
