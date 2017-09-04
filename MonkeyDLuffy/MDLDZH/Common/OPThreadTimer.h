//
//  OPThreadTimer.h
//  OnePiece
//
//  Created by Duanwwu on 2016/12/7.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPThreadTimer : NSObject

- (instancetype)initWithTimeInterval:(NSTimeInterval)ti block:(dispatch_block_t)block queue:(dispatch_queue_t)queue;

+ (instancetype)timerWithTimeInterval:(NSTimeInterval)ti block:(dispatch_block_t)block queue:(dispatch_queue_t)queue;

- (void)fire;

- (void)suspend;

- (void)invalidate;

@end
