//
//  OPThreadTimer.m
//  OnePiece
//
//  Created by Duanwwu on 2016/12/7.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPThreadTimer.h"

@implementation OPThreadTimer
{
    dispatch_source_t                   _timer;
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)ti block:(dispatch_block_t)block queue:(dispatch_queue_t)queue
{
    if (self = [super init])
    {
        dispatch_source_t timer         = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_event_handler(timer, block);
        
#if !OS_OBJECT_USE_OBJC
        dispatch_source_t theTimer      = timer;
        dispatch_source_set_cancel_handler(timer, ^{
#pragma clang diagnostic push
#pragma clang diagnostic warning "-Wimplicit-retain-self"
            dispatch_release(theTimer);
            
#pragma clang diagnostic pop
        });
#endif
        
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, ti * NSEC_PER_SEC, 0);
        _timer                          = timer;
    }
    return self;
}

+ (instancetype)timerWithTimeInterval:(NSTimeInterval)ti block:(dispatch_block_t)block queue:(dispatch_queue_t)queue
{
    return [[OPThreadTimer alloc] initWithTimeInterval:ti block:block queue:queue];
}

- (void)fire
{
    dispatch_resume(_timer);
}

- (void)suspend
{
    dispatch_suspend(_timer);
}

- (void)invalidate
{
    dispatch_source_cancel(_timer);
}

@end
