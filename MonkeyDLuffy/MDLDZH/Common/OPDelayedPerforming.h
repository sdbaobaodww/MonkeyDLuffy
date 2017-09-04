//
//  OPDelayedPerforming.h
//  OnePiece
//
//  Created by Duanwwu on 2016/12/7.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPDelayedPerforming : NSObject

/**
 * 初始化方法，创建一个延迟执行的任务，不会立即开始计时，需调用resume后才会开始
 * @param block 延迟执行block
 * @param delay 延迟时间
 * @param queue 线程队列
 */
- (instancetype)initWithBlock:(dispatch_block_t)block afterDelay:(NSTimeInterval)delay queue:(dispatch_queue_t)queue;

/**
 * 延迟执行某段任务，调用后会立即开始计时
 * @param block 延迟执行block
 * @param delay 延迟时间
 * @param queue 线程队列
 */
- (void)performBlock:(dispatch_block_t)block afterDelay:(NSTimeInterval)delay queue:(dispatch_queue_t)queue;

/**
 * 唤醒任务
 */
- (void)resume;

/**
 * 暂停任务
 */
- (void)suspend;

/**
 * 取消延迟执行的任务
 */
- (void)cancelPreviousPerformRequest;

@end
