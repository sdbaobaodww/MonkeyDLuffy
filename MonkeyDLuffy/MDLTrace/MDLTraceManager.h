//
//  MDLTraceManager.h
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/9/1.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MDLTrace;

@interface MDLTraceManager : NSObject

@property (nonatomic, strong, readonly) NSString *currentTraceFile;

+ (instancetype)sharedInstance;

#pragma mark - 记录管理

/**
 添加一条记录，不会对trace进行强引用
 */
- (void)addTrace:(MDLTrace *)trace;

/**
 移除一条记录
 */
- (void)removeTrace:(MDLTrace *)trace;

/**
 记录是否存在
 */
- (BOOL)hasTrace:(MDLTrace *)trace;

#pragma mark - 记录存储

- (void)saveTrace:(MDLTrace *)trace;

- (void)saveAndRemoveTrace:(MDLTrace *)trace;

@end
