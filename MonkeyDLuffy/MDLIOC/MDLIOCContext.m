//
//  MDLIOCRegister.m
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/16.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import "MDLIOCContext.h"

@implementation MDLIOCContext
{
    NSMutableDictionary *_moduleContext;
    NSMutableDictionary *_globalContext;
    NSMutableDictionary<id <NSCopying>, MDLIOCBean *> *_allBeans;
}

- (instancetype)init {
    if (self = [super init]) {
        _moduleContext = [[NSMutableDictionary alloc] init];
        _globalContext = [[NSMutableDictionary alloc] init];
        _allBeans = [[NSMutableDictionary<id <NSCopying>, MDLIOCBean *> alloc] init];
    }
    return self;
}

- (NSDictionary *)cachesWithScope:(MDLIOCScope)scope {
    switch (scope) {
        case MDLIOCScopeGlobal:
            return _globalContext;
        case MDLIOCScopeModule:
            return _moduleContext;
        default:
            return nil;
    }
}

- (NSDictionary *)allBeans {
    return _allBeans;
}

- (void)registerBean:(MDLIOCBean *)bean forKey:(id <NSCopying>)beanKey {
    _allBeans[beanKey] = bean;
}

- (id)instanceForKey:(id <NSCopying>)beanKey {
    MDLIOCBean *bean = _allBeans[beanKey];
    if (!bean) {
        return nil;
    }
    switch (bean.scope) {
        case MDLIOCScopeGlobal: {
            id instance = _globalContext[beanKey];
            if (!instance) {
                instance = [[bean.bindClass alloc] init];
                _globalContext[beanKey] = instance;
            }
            return instance;
        }
        case MDLIOCScopeModule:
            return _moduleContext[beanKey];
        default:
            return [[bean.bindClass alloc] init];
    }
}

- (void)batchCreateInstanceForKeys:(NSArray *)beanKeys {
    for (id <NSCopying> beanKey in beanKeys) {
        MDLIOCBean *bean = _allBeans[beanKey];//通过beanKey获取对应的Bean
        id instance = [[bean.bindClass alloc] init];//根据Bean创建对象
        if (!instance) {
            @throw [NSException exceptionWithName:@"MDLIOCInjectorException" reason:[NSString stringWithFormat:@"Invalid class %@", NSStringFromClass(bean.bindClass)] userInfo:nil];
        }
        _moduleContext[beanKey] = instance;
    }
}

- (void)batchRemoveInstanceForKeys:(NSArray *)beanKeys {
    [_allBeans removeObjectsForKeys:beanKeys];
    [_moduleContext removeObjectsForKeys:beanKeys];
}

#pragma mark - Subscripting

- (MDLIOCBean *)objectForKeyedSubscript:(id <NSCopying>)key {
    return _allBeans[key];
}

- (void)setObject:(MDLIOCBean *)anObject forKeyedSubscript:(id <NSCopying>)aKey {
    _allBeans[aKey] = anObject;
}

@end
