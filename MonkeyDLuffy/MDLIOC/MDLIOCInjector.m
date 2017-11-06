//
//  MDLIOCRegister.m
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/9/18.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import "MDLIOCInjector.h"
#import "MDLIOCContext.h"
#import <libkern/OSAtomic.h>
#import <objc/runtime.h>

static MDLIOCContext *iocContext = nil;//ioc容器上下文
static NSMutableDictionary<NSString *, NSMutableArray<MDLIOCBean *> *> *factoryBeans;//工厂下面所有的bean，{工厂名称:[bean]}
static void _init_context () {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        iocContext = [[MDLIOCContext alloc] init];
        factoryBeans = [[NSMutableDictionary<NSString *, NSMutableArray<MDLIOCBean *> *> alloc] init];
    });
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
static void mdl_performLocked(dispatch_block_t block) {
    static OSSpinLock mdl_lock = OS_SPINLOCK_INIT;
    OSSpinLockLock(&mdl_lock);
    block();
    OSSpinLockUnlock(&mdl_lock);
}
#pragma clang diagnostic pop

static inline NSString * factoryNameWithFactory(Class<MDLIOCBeanFactory> factory) {
    return factory ? NSStringFromClass(factory) : nil;
}

@implementation MDLIOCRegister

+ (void)load {
    _init_context();
}

+ (void)initialize {
    _init_context();
}

/**
 将Bean与工厂关联起来
 @param bean IOC注入描述对象
 @param factoryName 所属工厂名称
 */
+ (void)_addBean:(MDLIOCBean *)bean forFactoryName:(NSString *)factoryName {
    NSMutableArray *beansOfFactory = [factoryBeans objectForKey:factoryName];//工厂下面的Bean
    if (!beansOfFactory) {
        beansOfFactory = [NSMutableArray array];
        factoryBeans[factoryName] = beansOfFactory;
    }
    [beansOfFactory addObject:bean];
}

/**
 将Bean与工厂关联起来
 @param beans IOC注入描述对象数组
 @param factoryName 所属工厂名称
 */
+ (void)_addBeans:(NSArray *)beans forFactoryName:(NSString *)factoryName {
    NSMutableArray *beansOfFactory = [factoryBeans objectForKey:factoryName];//工厂下面的Bean
    if (!beansOfFactory) {
        beansOfFactory = [NSMutableArray array];
        factoryBeans[factoryName] = beansOfFactory;
    }
    [beansOfFactory addObjectsFromArray:beans];
}

+ (void)registerBean:(MDLIOCBean * __nonnull)bean fromFactory:(Class<MDLIOCBeanFactory> __nullable)factory {
    NSParameterAssert(bean);
    
    mdl_performLocked(^{
        [iocContext registerBean:bean forKey:[bean beanKey]];
        
        if (factory) {
            [self _addBean:bean forFactoryName:factoryNameWithFactory(factory)];
        }
    });
}

+ (void)registerBean:(MDLIOCBean * __nonnull)bean {
    [self registerBean:bean fromFactory:nil];
}

+ (void)registerBeans:(NSArray * __nonnull)beans fromFactory:(Class<MDLIOCBeanFactory> __nullable)factory {
    NSParameterAssert(beans);
    
    mdl_performLocked(^{
        for (MDLIOCBean *bean in beans) {
            [iocContext registerBean:bean forKey:[bean beanKey]];
        }
        if (factory) {
            [self _addBeans:beans forFactoryName:factoryNameWithFactory(factory)];
        }
    });
}

+ (void)registerProtocol:(Protocol * __nonnull)protocol
                   clazz:(Class __nonnull)clazz
             cachePolicy:(MDLIOCCachePolicy)cachePolicy
                   alias:(NSString * __nullable)alias
             fromFactory:(Class<MDLIOCBeanFactory> __nullable)factory {
    
    mdl_performLocked(^{
        MDLIOCBean *bean = [MDLIOCBean beanWithProtocol:protocol bindClass:clazz cachePolicy:cachePolicy alias:alias];
        [iocContext registerBean:bean forKey:[bean beanKey]];
        if (factory) {
            [self _addBean:bean forFactoryName:factoryNameWithFactory(factory)];
        }
    });
}

+ (void)registerProtocol:(Protocol * __nonnull)protocol
                   clazz:(Class __nonnull)clazz
             cachePolicy:(MDLIOCCachePolicy)cachePolicy
             fromFactory:(Class<MDLIOCBeanFactory> __nullable)factory {
    [self registerProtocol:protocol clazz:clazz cachePolicy:cachePolicy alias:nil fromFactory:factory];
}

+ (void)registerProtocol:(Protocol * __nonnull)protocol
                   clazz:(Class __nonnull)clazz
             cachePolicy:(MDLIOCCachePolicy)cachePolicy {
    [self registerProtocol:protocol clazz:clazz cachePolicy:cachePolicy alias:nil fromFactory:Nil];
}

+ (void)registerProtocol:(Protocol * __nonnull)protocol
                   clazz:(Class __nonnull)clazz {
    [self registerProtocol:protocol clazz:clazz cachePolicy:MDLIOCCachePolicyNone alias:nil fromFactory:Nil];
}

+ (void)unRegisterAllBeansFromFactory:(Class<MDLIOCBeanFactory> __nonnull)factory {
    NSParameterAssert(factory);
    
    mdl_performLocked(^{
        NSString *factoryName = factoryNameWithFactory(factory);
        NSArray *beans = [factoryBeans objectForKey:factoryName];
        if (beans) {
            [iocContext unRegisterBeans:beans];
            [factoryBeans removeObjectForKey:factoryName];
        }
    });
}

+ (BOOL)isFactoryEntered:(Class<MDLIOCBeanFactory> __nonnull)factory {
    __block BOOL isEntered = NO;
    mdl_performLocked(^{
        isEntered = [factoryBeans objectForKey:factoryNameWithFactory(factory)] != nil;
    });
    return isEntered;
}

+ (NSArray<MDLIOCBean *> * __nullable)allRegistedBeans {
    __block NSArray<MDLIOCBean *> *beans = nil;
    mdl_performLocked(^{
        beans = [iocContext allBeans];
    });
    return beans;
}

+ (void)cleanAllBeans {
    mdl_performLocked(^{
        iocContext = [[MDLIOCContext alloc] init];
    });
}

@end

@implementation MDLIOCGetter

+ (id __nullable)instanceForProtocol:(Protocol * __nonnull)protocol alias:(NSString * __nullable)alias {
    NSParameterAssert(protocol);
    
    __block id obj = nil;
    mdl_performLocked(^{
        obj = [iocContext instanceForKey:[MDLIOCBean beanKeyForProtocol:protocol alias:alias] beanBunlde:ProtocolisGroupBean(protocol)];
    });
    return obj;
}

+ (id __nullable)instanceForProtocol:(Protocol * __nonnull)protocol {
    return [self instanceForProtocol:protocol alias:nil];
}

@end

@interface NSObject (IOC)

@property (nonatomic, assign) BOOL isInjected;//对象是否已经注入了依赖对象

@end

@implementation NSObject (IOC)

- (BOOL)isInjected {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setIsInjected:(BOOL)isInjected {
    objc_setAssociatedObject(self, @selector(isInjected), [NSNumber numberWithBool:isInjected], OBJC_ASSOCIATION_RETAIN);
}

@end

@implementation MDLIOCInjector

+ (void)injector:(NSObject<MDLInjectable> * __nonnull)obj {
    Class clazz = [obj class];
    if ([clazz respondsToSelector:@selector(mdlioc_injectableProperties)]) {
        mdl_performLocked(^{
            if (obj.isInjected) {//不进行重复注入
                return;
            }
            
            NSSet *properties = [clazz mdlioc_injectableProperties];//需要注入的属性集合
            NSMutableDictionary *propertiesDictionary = [NSMutableDictionary dictionaryWithCapacity:properties.count];//保存KVC数据字典
            for (NSString *propertyName in properties) {
                //获取属性对应的协议
                Protocol *protocol = NSProtocolFromString([self _getClassOrProtocolForProperty:class_getProperty(clazz, (const char *)[propertyName UTF8String])]);
                //根据协议Key获取对应的实例
                propertiesDictionary[propertyName] = [iocContext instanceForKey:[MDLIOCBean beanKeyForProtocol:protocol alias:nil] beanBunlde:ProtocolisGroupBean(protocol)];
            }
            [obj setValuesForKeysWithDictionary:propertiesDictionary];//KVC设置属性值
            
            obj.isInjected = YES;
        });
    }
}

/**
 获取属性对应的协议名称
 @param property 属性结构体
 @return 实现的协议名称
 */
+ (NSString *)_getClassOrProtocolForProperty:(objc_property_t)property {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T') {
            if (strlen(attribute) <= 4) {
                break;
            }
            return [[NSString alloc] initWithBytes:attribute + 4 length:strlen(attribute) - 6 encoding:NSASCIIStringEncoding];
        }
    }
    return nil;
}

@end

@implementation NSObject (MDLIOCInjector)

- (void)mdlioc_injector {
    if (![self respondsToSelector:@selector(mdlioc_injectableProperties)]) {
        @throw [NSException exceptionWithName:@"MDLIOCInjectorException" reason:@"object must conforms protocol MDLInjectable!" userInfo:nil];
    }
    [MDLIOCInjector injector:(NSObject<MDLInjectable> *)self];
}

@end
