//
//  MDLIOCInjector.m
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/17.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import "MDLIOCInjector.h"
#import <objc/runtime.h>
#import "MDLIOCContext.h"

@implementation NSObject (MDLIOCInjector)

- (void)mdlioc_injector {
    if (![self conformsToProtocol:@protocol(MDLInjectableProtocol)]) {
        @throw [NSException exceptionWithName:@"MDLIOCInjectorException" reason:@"object must conforms MDLInjectableProtocol!" userInfo:nil];
        return;
    }
    [[MDLIOCInjector shareInstance] injector:(id<MDLInjectableProtocol>)self];
}

@end

@implementation MDLIOCInjector {
    MDLIOCContext *_iocContext;
    
    NSMutableDictionary<NSString *, NSNumber *> *_moduleLifeCycle;
    NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *_procotolsOfModule;
    
    NSLock *_moduleLock;
}

+(instancetype)shareInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(instancetype)init {
    if (self = [super init]) {
        _iocContext = [[MDLIOCContext alloc] init];
        
        _moduleLifeCycle = [[NSMutableDictionary<NSString *, NSNumber *> alloc] init];
        _procotolsOfModule = [[NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> alloc] init];
        
        _moduleLock = [[NSLock alloc] init];
    }
    return self;
}

- (NSDictionary *)cachesWithScope:(MDLIOCScope)scope {
    return [_iocContext cachesWithScope:scope];
}

- (NSDictionary *)allBeans {
    return [_iocContext allBeans];
}

#pragma mark - 获取已注册的依赖对象

- (id)instanceForProtocol:(Protocol *)protocol {
    return [_iocContext instanceForKey:ProtocolKeyForProtocol(protocol)];
}

- (id)_instanceForProtocolKey:(NSString *)protocolKey {
    return [_iocContext instanceForKey:protocolKey];
}

#pragma mark - 注册依赖对象

- (void)loadIOCInstanceFromProviders:(NSArray<NSString *> *)providerClassNames {
    for (NSString *providerClassName in providerClassNames) {
        Class<MDLIOCProvider> provider= NSClassFromString(providerClassName);//IOC注入对象提供类
        NSString *moduleName = [provider moduleName];//模块名称        
        for (MDLIOCBean *bean in [provider buildBeans]) {
            bean.moduleName = moduleName;
            _iocContext[ProtocolKeyForProtocol(bean.protocol)] = bean;
        }
    }
}

- (void)registerBean:(MDLIOCBean *)bean {
    if ([self _isInvalidClass:bean.bindClass protocol:bean.protocol]) {
        return;
    }
    NSString *protocolKey = ProtocolKeyForProtocol(bean.protocol);
    _iocContext[protocolKey] = bean;//缓存Bean对象
    if (bean.scope == MDLIOCScopeModule) {
        [self _addProtocolKey:protocolKey forModule:bean.moduleName];
    }
}

//向模块注册一个协议
- (void)_addProtocolKey:(NSString *)protocolKey forModule:(NSString *)moduleName {
    NSMutableArray<NSString *> *protocols = _procotolsOfModule[moduleName];
    if (!protocols) {
        protocols = [[NSMutableArray<NSString *> alloc] init];
        _procotolsOfModule[moduleName] = protocols;
        _moduleLifeCycle[moduleName] = @0;//设置该模块的模块计数为0
    }
    [protocols addObject:protocolKey];
}

//无效的类或者协议返回YES，有效的返回NO
- (BOOL)_isInvalidClass:(Class)clazz protocol:(Protocol *)protocol {
    if (clazz == Nil || protocol == nil) {
        @throw [NSException exceptionWithName:@"MDLIOCInjectorException" reason:[NSString stringWithFormat:@"Invalid Parameters!"] userInfo:nil];
        return YES;
    }
    return NO;
}

#pragma mark - 依赖注入

- (void)injector:(NSObject<MDLInjectableProtocol> *)obj {
    Class clazz = [obj class];
    if ([clazz respondsToSelector:@selector(mdlioc_injectableProperties)]) {
        NSSet *properties = [clazz mdlioc_injectableProperties];//需要注入的属性集合
        NSMutableDictionary *propertiesDictionary = [NSMutableDictionary dictionaryWithCapacity:properties.count];
        for (NSString *propertyName in properties) {
            NSString *protocolKey = [self _getClassOrProtocolForProperty:class_getProperty(clazz, (const char *)[propertyName UTF8String])];//获取属性对应的协议Key
            id instance = [self _instanceForProtocolKey:protocolKey];//根据协议Key获取对应的实例
            if ([self _isValidInstance:instance]) {//创建的对象是否有效
                propertiesDictionary[propertyName] = instance;
            }
        }
        [obj setValuesForKeysWithDictionary:propertiesDictionary];
    }
}

- (NSString *)_getClassOrProtocolForProperty:(objc_property_t)property {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T') {
            if (strlen(attribute) <= 4) {
                break;
            }
            return [[NSString alloc] initWithBytes:attribute + 3 length:strlen(attribute) - 4 encoding:NSASCIIStringEncoding];
        }
    }
    return nil;
}

- (BOOL)_isValidInstance:(id)instance {
    if (!instance) {
        @throw [NSException exceptionWithName:@"MDLIOCInjectorException" reason:[NSString stringWithFormat:@"Invalid class %@", NSStringFromClass([instance class])] userInfo:nil];
        return NO;
    }
    return YES;
}

#pragma mark - 模块生命周期管理

- (void)enterModule:(NSString *)moduleName {
    [_moduleLock lock];
    NSNumber *lifeCycle = _moduleLifeCycle[moduleName];
    if (lifeCycle) {
        int moduleRetainCount = [lifeCycle intValue] + 1;
        if (moduleRetainCount == 1) {//第一次进入
            [self _createInstanceOnModuleFirstEnter:moduleName];
        }
        _moduleLifeCycle[moduleName] = @(moduleRetainCount);
    }
    [_moduleLock unlock];
}

- (void)exitModule:(NSString *)moduleName {
    [_moduleLock lock];
    NSNumber *lifeCycle = _moduleLifeCycle[moduleName];
    if (lifeCycle) {
        int moduleRetainCount = [lifeCycle intValue] - 1;
        if (moduleRetainCount == 0) {//最后一次退出
            [self _releaseInstanceOnModuleLastExit:moduleName];
        } else {
            _moduleLifeCycle[moduleName] = @(moduleRetainCount);
        }
    }
    [_moduleLock unlock];
}

//模块第一次进入时，创建该模块下对应的注入对象
- (void)_createInstanceOnModuleFirstEnter:(NSString *)moduleName {
    NSArray *protocols = [_procotolsOfModule objectForKey:moduleName];//获取该模块下所有注册的协议
    [_iocContext batchCreateInstanceForKeys:protocols];
}

//模块最后一次退出时，释放该模块下对应的注入对象
- (void)_releaseInstanceOnModuleLastExit:(NSString *)moduleName {
    NSArray *protocols = [_procotolsOfModule objectForKey:moduleName];
    if (protocols) {
        [_iocContext batchRemoveInstanceForKeys:protocols];
    }
    [_procotolsOfModule removeObjectForKey:moduleName];
    [_moduleLifeCycle removeObjectForKey:moduleName];
}

@end
