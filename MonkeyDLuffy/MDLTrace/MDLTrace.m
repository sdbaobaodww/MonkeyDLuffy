//
//  MDLTrace.m
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/31.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import "MDLTrace.h"
#import "MDLTraceManager.h"

@implementation MDLTrace

- (instancetype)initWithType:(NSString *)traceType startTime:(NSTimeInterval)startTime info:(NSDictionary *)info{
    if (self = [super init]) {
        _traceType = traceType;
        _startTime = startTime;
        _info = info;
        _traceToken = [@(arc4random_uniform(INT32_MAX)) stringValue];
        _traceStatus = MDLTraceStatusStart;
        
        [self _doOnInit];
    }
    return self;
}

- (instancetype)initWithType:(NSString *)traceType info:(NSDictionary *)info {
    return [self initWithType:traceType startTime:[NSDate timeIntervalSinceReferenceDate] info:info];
}

- (instancetype)initWithType:(NSString *)traceType {
    return [self initWithType:traceType startTime:[NSDate timeIntervalSinceReferenceDate] info:nil];
}

- (void)traceSuccess {
    self.traceStatus = MDLTraceStatusSuccess;
    [self _doOnCompletion];
}

- (void)traceCancel {
    self.traceStatus = MDLTraceStatusCancel;
    [self _doOnCompletion];
}

- (void)traceError:(NSDictionary *)errorInfo {
    self.traceStatus = MDLTraceStatusError;
    self.errorInfo = errorInfo;
    [self _doOnCompletion];
}

- (void)_doOnInit {
    [[MDLTraceManager sharedInstance] addTrace:self];
}

- (void)_doOnCompletion {
    self.costTime = ([NSDate timeIntervalSinceReferenceDate] - self.startTime) * 1000;//转换为ms
    [[MDLTraceManager sharedInstance] saveAndRemoveTrace:self];
}

- (void)dealloc {
    if (self.traceStatus <= MDLTraceStatusStart) { //被释放时还未调用任何结束方法，则当作记录取消
        [self traceCancel];
    }
}

@end
