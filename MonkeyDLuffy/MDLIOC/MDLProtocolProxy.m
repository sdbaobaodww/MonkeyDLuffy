//
//  MDLProtocolProxy.m
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/9/14.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import "MDLProtocolProxy.h"
#import <objc/runtime.h>

@implementation MDLProtocolProxy {
    NSMutableDictionary *_impls;//所有的转发对象
    CFMutableDictionaryRef _signatures;//保存所有的方法签名
    CFMutableArrayRef _classMethods;//保存类方法
}

- (instancetype)initWithProtocol:(Protocol *)protocol {
    NSParameterAssert(protocol);
    if (self) {
        _protocol = protocol;
        _impls = [[NSMutableDictionary alloc] init];
        _signatures = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
        _classMethods = CFArrayCreateMutable(NULL, 0, NULL);
        [self _analyzeProtocol:protocol outMethodSignatures:_signatures andClassMethods:_classMethods];
    }
    return self;
}

- (void)addProtocolImplWithClass:(Class)clazz {
    _impls[NSStringFromClass(clazz)] = [[clazz alloc] init];
}

- (void)removeImplWithClass:(Class)clazz {
    [_impls removeObjectForKey:NSStringFromClass(clazz)];
}

- (NSInteger)implCount {
    return [_impls count];
}

#pragma mark - 消息转发

- (BOOL)respondsToSelector:(SEL)selector {
    return CFDictionaryContainsKey(_signatures, selector);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return CFDictionaryGetValue(_signatures, selector);
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if ([_impls count] > 0) {
        SEL selector = invocation.selector;
        BOOL isClassMethod = CFArrayContainsValue(_classMethods, CFRangeMake(0, CFArrayGetCount(_classMethods)), invocation.selector);//是否是类方法
        
        [_impls enumerateKeysAndObjectsUsingBlock:^(id key, id imp, BOOL * _Nonnull stop) {
            id target = isClassMethod ? [imp class] : imp;//获取最终的执行对象
            if ([target respondsToSelector:selector]) {//判断方法是否实现
                [invocation invokeWithTarget:target];
            }
        }];
    }
}

/**
 分析协议(包括所有父协议)，将协议下面所有的方法签名，与类方法信息找出来存入缓存中
 
 @param protocol 需要进行分析的协议
 @param signatures 保存方法签名数据
 @param classMethods 保存所有的类方法名字
 */
- (void)_analyzeProtocol:(Protocol *)protocol outMethodSignatures:(CFMutableDictionaryRef)signatures andClassMethods:(CFMutableArrayRef)classMethods {
    
    /**
     根据控制参数isRequiredMethod，isInstanceMethod遍历协议下声明的方法，并将MethodSignature数据存入cache，类方法名称存入classMethods
     
     @param BOOL isRequiredMethod 是否是必选方法，YES为required，NO为optional
     @param BOOL isInstanceMethod 是否是实例方法，YES实例方法，NO类方法
     */
    void (^enumerateRequiredMethods)(BOOL,BOOL) = ^(BOOL isRequiredMethod, BOOL isInstanceMethod) {
        unsigned int methodCount;
        struct objc_method_description *descr = protocol_copyMethodDescriptionList(protocol, isRequiredMethod, isInstanceMethod, &methodCount);
        for (NSUInteger idx = 0; idx < methodCount; idx++) {
            NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:descr[idx].types];
            CFDictionarySetValue(signatures, descr[idx].name, (__bridge const void *)(signature));
            if (!isInstanceMethod) {
                CFArrayAppendValue(classMethods, descr[idx].name);
            }
        }
        free(descr);
    };
    //遍历协议所有的方法，包括实例方法、类方法、必须和可选方法
    enumerateRequiredMethods(NO, NO);
    enumerateRequiredMethods(NO, YES);
    enumerateRequiredMethods(YES, NO);
    enumerateRequiredMethods(YES, YES);
    
    //遍历子协议
    unsigned int inheritedProtocolCount;
    Protocol *__unsafe_unretained* inheritedProtocols = protocol_copyProtocolList(protocol, &inheritedProtocolCount);
    for (NSUInteger idx = 0; idx < inheritedProtocolCount; idx++) {
        [self _analyzeProtocol:inheritedProtocols[idx] outMethodSignatures:signatures andClassMethods:classMethods];
    }
    free(inheritedProtocols);
}

@end
