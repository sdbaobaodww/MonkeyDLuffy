//
//  MDLIOC.h
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/17.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#ifndef MDLIOC_h
#define MDLIOC_h

#import <objc/runtime.h>
#import "MDLIOCInjector.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"
//获取该类需要进行依赖注入的属性名称
static NSSet * BuildDependenciesForClass(Class clazz, NSSet *requirements) {
    Class superClass = class_getSuperclass([clazz class]);
    if([superClass respondsToSelector:@selector(mdlioc_injectableProperties)]) {
        NSSet *parentsRequirements = [superClass mdlioc_injectableProperties];
        NSMutableSet *dependencies = [NSMutableSet setWithSet:parentsRequirements];
        [dependencies unionSet:requirements];
        requirements = dependencies;
    }
    return requirements;
}
#pragma clang diagnostic pop

#pragma mark - 便捷方法宏定义

//声明依赖注入的属性
#define mdlioc_requires(args...) \
+ (NSSet *)mdlioc_injectableProperties { \
    return BuildDependenciesForClass(self, [NSSet setWithObjects: args, nil]); \
}

//声明依赖注入的属性，并生成init方法，调用依赖注入，适用于不重载init方法的对象
#define mdlioc_injection_init(args...) \
+ (NSSet *)mdlioc_injectableProperties { \
    return BuildDependenciesForClass(self, [NSSet setWithObjects: args, nil]); \
} \
- (instancetype)init { \
    if (self = [super init]) { \
        [[MDLIOCInjector shareInstance] injector:self]; \
    } \
    return self; \
}

//注解方式注册正常作用域对象
#define mdlioc_register_normal(protocol)			\
+ (void)load { \
    [MDLIOCInjector annotationRegisterBean:[MDLIOCBean beanWithProtocol:protocol bindClass:self scope:MDLIOCScopeNormal]]; \
}

//注解方式注册模块作用域对象
#define mdlioc_register_module(protocol, module) \
+ (void)load { \
    [MDLIOCInjector annotationRegisterBean:[MDLIOCBean moduleBeanWithProtocol:protocol bindClass:self moduleName:module]]; \
}

//注解方式注册全局作用域对象
#define mdlioc_register_global(protocol) \
+ (void)load { \
    [MDLIOCInjector annotationRegisterBean:[MDLIOCBean beanWithProtocol:protocol bindClass:self scope:MDLIOCScopeGlobal]]; \
}

#endif /* MDLIOC_h */
