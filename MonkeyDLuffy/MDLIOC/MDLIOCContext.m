//
//  MDLIOCRegister.m
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/16.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import "MDLIOCContext.h"

@implementation MDLIOCContext {
    NSMutableDictionary<NSString *, id> *_moduleContext;
    NSMutableDictionary<NSString *, id> *_globalContext;
}

- (instancetype)init {
    if (self = [super init]) {
        _moduleContext = [[NSMutableDictionary<NSString *, id> alloc] init];
        _globalContext = [[NSMutableDictionary<NSString *, id> alloc] init];
    }
    return self;
}

#pragma mark - 全局作用域

- (void)addGlobalInstance:(id)instance forProtocol:(NSString *)protocol {
    _globalContext[protocol] = instance;
}

- (id)globalInstanceForProcotol:(NSString *)protocol {
    return _globalContext[protocol];
}

#pragma mark - 模块作用域

- (void)addModuleInstance:(id)instance forProtocol:(NSString *)protocol {
    _moduleContext[protocol] = instance;
}

- (id)moduleInstanceForProtocol:(NSString *)protocol {
    return _moduleContext[protocol];
}

- (void)removeModuleInstancesForProtocols:(NSArray<NSString *> *)protocols{
    [_moduleContext removeObjectsForKeys:protocols];
}

@end
