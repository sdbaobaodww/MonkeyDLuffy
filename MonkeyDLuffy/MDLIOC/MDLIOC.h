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

//注入对象作用范围
typedef NS_ENUM(NSInteger, MDLIOCScope) {
    MDLIOCScopeNormal,  //正常的作用范围，每次使用时都重新创建
    MDLIOCScopeModule,  //模块作用范围，跟模块的生命周期相关
    MDLIOCScopeGlobal,  //全局作用范围，创建以后会常驻内存
};

@protocol MDLInjectableProtocol <NSObject>

+ (NSSet *)mdlioc_injectableProperties;

@end

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

//协议对象生成Key
static NSString * ProtocolKeyForProtocol(Protocol *aProtocol) {
    return [NSString stringWithFormat:@"<%@>",NSStringFromProtocol(aProtocol)];
}

#define mdlioc_requires(args...) \
+ (NSSet *)mdlioc_injectableProperties { \
return BuildDependenciesForClass(self, [NSSet setWithObjects: args, nil]); \
}

#endif /* MDLIOC_h */
