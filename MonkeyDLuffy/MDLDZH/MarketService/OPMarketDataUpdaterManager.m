//
//  OPMarketDataUpdaterManager.m
//  OnePiece
//
//  Created by Duanwwu on 2016/12/13.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPMarketDataUpdaterManager.h"
#import "OPLog.h"

@interface OPUpdaterManagerContext ()

@property (nonatomic, strong) OPDataUpdaterBase *specifyUpdater;

@end

@implementation OPUpdaterManagerContext

- (void)allReady
{
    
}

@end

@implementation OPDataUpdaterBase

- (instancetype)initWithSecurityModel:(OPMarketSecurityModel *)securityModel
{
    if (self = [super init])
    {
        self.securityModel                  = securityModel;
        self.tag                            = kUpdaterDefaultTag;
    }
    return self;
}

- (void)updateDataWithType:(OPDataUpdateType)updateType context:(OPUpdaterManagerContext *)context
{
    
}

- (void)onReceiveDataComplete:(OPDataUpdaterBase *)updater
{
    if (self.updateCompleted)
        self.updateCompleted(self);
}

@end

@implementation OPDataUpdaterManager
{
    NSMutableArray                          *_group;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _group                              = [[NSMutableArray alloc] init];
    }
    return self;
}

- (OPUpdaterManagerContext *)buildContext
{
    return [[OPUpdaterManagerContext alloc] init];
}

- (void)addDateUpdater:(OPDataUpdaterBase *)updater
{
    [_group addObject:updater];
}

- (void)addDateUpdaters:(NSArray *)updaters
{
    [_group addObjectsFromArray:updaters];
}

- (void)removeDateUpdater:(OPDataUpdaterBase *)updater
{
    if (updater)
        [_group removeObject:updater];
}

- (void)removeDateUpdaters:(NSArray *)updaters
{
    if (updaters)
        [_group removeObjectsInArray:updaters];
}

- (BOOL)removeDateUpdaterWithTag:(int)tag
{
    if (tag == kUpdaterDefaultTag)
        return NO;
    
    for (int i = 0; i < [_group count]; i ++)
    {
        OPDataUpdaterBase *updater          = [_group objectAtIndex:i];
        if (updater.tag == tag)
        {
            [_group removeObjectAtIndex:i];
            return YES;
        }
    }
    return NO;
}

- (void)updateDataWithType:(OPDataUpdateType)updateType
{
    [self updateDataWithType:updateType updaters:_group];
}

- (void)updateDataWithType:(OPDataUpdateType)updateType updater:(OPDataUpdaterBase *)updater
{
    OPUpdaterManagerContext *context        = [self buildContext];//每次生成一个上下文
    context.delegate                        = self;
    [updater updateDataWithType:updateType context:context];
    [context allReady];
}

- (void)updateDataWithType:(OPDataUpdateType)updateType updaters:(NSArray *)updaters
{
    OPUpdaterManagerContext *context        = [self buildContext];//每次生成一个上下文
    context.delegate                        = self;
    for (OPDataUpdaterBase *updater in updaters)
    {
        [updater updateDataWithType:updateType context:context];
    }
    [context allReady];
}

- (void)updateCompletedWithContext:(OPUpdaterManagerContext *)context
{
    NSTimeInterval start                    = [NSDate timeIntervalSinceReferenceDate];
    
    if ([self.delegate respondsToSelector:@selector(updateCompleted:context:)])//数据完成以后执行delegate回调
        [self.delegate updateCompleted:self context:context];
    
    OPLOG_DEBUG(OPLogModuleModel, @"耗费时间：%f秒",[NSDate timeIntervalSinceReferenceDate] - start);
}

@end
