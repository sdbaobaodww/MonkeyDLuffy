//
//  MDLTrace.h
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/31.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

//记录信息的状态
typedef NS_ENUM(NSInteger, MDLTraceStatus) {
    MDLTraceStatusNone,     //默认状态
    MDLTraceStatusStart,    //记录信息开始
    MDLTraceStatusSuccess,  //记录信息成功
    MDLTraceStatusError,    //记录信息失败
    MDLTraceStatusCancel,   //记录信息取消
};

/**
 记录信息，通常用于追踪业务执行状态、时间消耗，一条记录创建以后，可以以成功、取消、异常三种状态结束，未正常结束会抛出异常。
 */
@interface MDLTrace : JSONModel

@property (nonatomic, assign) MDLTraceStatus traceStatus;//记录当前的状态

@property (nonatomic, assign) NSTimeInterval startTime;//记录开始时间

@property (nonatomic, assign) NSTimeInterval costTime;//单位ms

@property (nonatomic, copy) NSString *traceType;//记录标识

@property (nonatomic, copy, readonly) NSString *traceToken;//记录序列号

@property (nonatomic, strong) NSDictionary *info;//创建记录时的附加信息

@property (nonatomic, strong) NSDictionary *errorInfo;//保存记录异常结束时的信息

- (instancetype)initWithType:(NSString *)traceType startTime:(NSTimeInterval)startTime info:(NSDictionary *)info;

- (instancetype)initWithType:(NSString *)traceType info:(NSDictionary *)info;

- (instancetype)initWithType:(NSString *)traceType;

//记录以正常状态结束
- (void)traceSuccess;

//记录被取消
- (void)traceCancel;

//记录以异常状态结束，errorInfo为可传入异常信息
- (void)traceError:(NSDictionary *)errorInfo;

@end
