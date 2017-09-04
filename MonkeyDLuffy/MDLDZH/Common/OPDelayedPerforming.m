//
//  OPDelayedPerforming.m
//  OnePiece
//
//  Created by Duanwwu on 2016/12/7.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPDelayedPerforming.h"

@implementation OPDelayedPerforming
{
    dispatch_source_t                   _timer;
}

- (instancetype)initWithBlock:(dispatch_block_t)block afterDelay:(NSTimeInterval)delay queue:(dispatch_queue_t)queue
{
    if (self = [super init])
    {
        [self _buildWithBlock:block afterDelay:delay queue:queue];
    }
    return self;
}

- (void)dealloc
{
    if (_timer)
        dispatch_source_cancel(_timer);
}

- (void)performBlock:(dispatch_block_t)block afterDelay:(NSTimeInterval)delay queue:(dispatch_queue_t)queue
{
    [self _buildWithBlock:block afterDelay:delay queue:queue];
    [self resume];
}

- (void)_buildWithBlock:(dispatch_block_t)block afterDelay:(NSTimeInterval)delay queue:(dispatch_queue_t)queue
{
    if (_timer)
    {
        dispatch_source_cancel(_timer);
        _timer                          = nil;
    }
    
    dispatch_source_t timer             = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_event_handler(timer, block);
    
#if !OS_OBJECT_USE_OBJC
    dispatch_source_t theTimer          = timer;
    dispatch_source_set_cancel_handler(timer, ^{
#pragma clang diagnostic push
#pragma clang diagnostic warning "-Wimplicit-retain-self"
        dispatch_release(theTimer);
        
#pragma clang diagnostic pop
    });
#endif
    
    dispatch_time_t tt                  = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_source_set_timer(timer, tt, DISPATCH_TIME_FOREVER, 0);
    _timer                              = timer;
}

- (void)resume
{
    dispatch_resume(_timer);
}

- (void)suspend
{
    dispatch_suspend(_timer);
}

- (void)cancelPreviousPerformRequest
{
    dispatch_source_cancel(_timer);
}

@end
