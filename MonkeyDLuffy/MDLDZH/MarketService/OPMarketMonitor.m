//
//  OPMarketMonitor.m
//  OnePiece
//
//  Created by Duanwwu on 16/10/27.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPMarketMonitor.h"
#import "OPPackageProtocol.h"
#import <objc/runtime.h>
#import "OPThreadTimer.h"
#import "OPMarketPackageImpl.h"

@interface OPSocketManagerBase (Monitor)

//请求超时计数
@property (nonatomic) int monitor_timeoutCount;

@end

@implementation OPSocketManagerBase (Monitor)

- (int)monitor_timeoutCount
{
    return [objc_getAssociatedObject(self, @selector(monitor_timeoutCount)) intValue];
}

- (void)setMonitor_timeoutCount:(int)timeoutCount
{
    objc_setAssociatedObject(self, @selector(monitor_timeoutCount), @(timeoutCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation OPSocketMonitorTimeout
{
    NSHashTable                             *_socketManagers;
    int                                     _maxAllowTimeout;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _socketManagers                     = [NSHashTable weakObjectsHashTable];
        _maxAllowTimeout                    = 1;
    }
    return self;
}

- (void)monitorRegisteredOnSocketManager:(OPSocketManagerBase *)socketManager
{
    [_socketManagers addObject:socketManager];
}

- (void)socketManager:(OPSocketManagerBase *)socketManager packageReceiveResponse:(id<OPRequestPackageProtocol>)requestPackage
{
    unsigned short type                     = requestPackage.header.type;
    if (type >= 1000 && type < 3000 )//行情接口
    {
        socketManager.monitor_timeoutCount  = 0;
    }
}

- (void)socketManager:(OPSocketManagerBase *)socketManager requestPackageTimeout:(id<OPRequestPackageProtocol>)requestPackage
{
    unsigned short type                     = requestPackage.header.type;
    if (type >= 1000 && type < 3000 )//行情接口
    {
        socketManager.monitor_timeoutCount  += 1;
        
        if (socketManager.monitor_timeoutCount > _maxAllowTimeout)//超时超过限制次数，断开socket重新连接当前服务器
        {
            [socketManager disconnect];
            [socketManager connectToHost:[socketManager connectedHost] port:[socketManager connectedPort]];
            OPLOG_INFO(OPLogModuleSocket, @"超时超过最大限制次数，重新连接行情服务器 %@:%d", [socketManager connectedHost], [socketManager connectedPort]);
        }
    }
}

- (void)socketManager:(OPSocketManagerBase *)socketManager
        waitSendCount:(int)waitSendCount
    waitResponseCount:(int)waitResponseCount
{
    int waitSend                            = 0;
    int waitResponse                        = 0;
    for (OPSocketManagerBase *manager in _socketManagers)
    {
        waitSend                            += [manager waitSendCount];
        waitResponse                        += [manager waitResponseCount];
    }
    OPLOG_INFO(OPLogModuleSocket, @"待发送队列数:%d 待接收队列数:%d",waitSend, waitResponse);
}

@end

@implementation OPSocketMonitorNetLog
{
    NSMutableArray                          *_logs;
    OPThreadTimer                           *_timer;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _logs                               = [NSMutableArray array];
    }
    return self;
}

- (void)invalidateLogTimer
{
    [_timer invalidate];
}

- (void)buildLogTimer
{
    [self invalidateLogTimer];
    __weak typeof(self) wself = self;
    _timer                                  = [OPThreadTimer timerWithTimeInterval:30.
                                                                             block:^{
                                                                                 [wself uploadNetLog];
                                                                             }
                                                                             queue:dispatch_get_global_queue(0, 0)];
    
    [_timer fire];
}

- (void)uploadNetLog
{
    OPLOG_INFO(OPLogModuleSocket, @"---%@------",NSStringFromSelector(_cmd));
}

- (void)socketManager:(OPSocketManagerBase *)socketManager sendRequestPackage:(id<OPRequestPackageProtocol>)requestPackage
{
    OPLOG_INFO(OPLogModuleSocket, @"---%@------",NSStringFromSelector(_cmd));
}

- (void)socketManager:(OPSocketManagerBase *)socketManager packageReceiveResponse:(id<OPRequestPackageProtocol>)requestPackage
{
    OPLOG_INFO(OPLogModuleSocket, @"---%@------",NSStringFromSelector(_cmd));
}

- (void)socketManager:(OPSocketManagerBase *)socketManager didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [self buildLogTimer];
}

- (void)socketManager:(OPSocketManagerBase *)socketManager didDisconnectWithError:(NSError *)error
{
    [self invalidateLogTimer];
}

@end

@implementation OPSocketMonitorHeartBeat
{
    OPThreadTimer                           *_heartTimer;
}

- (void)invalidateHeartTimer
{
    [_heartTimer invalidate];
}

- (void)buildHeartTimer
{
    [self invalidateHeartTimer];
    __weak typeof(self) wself = self;
    _heartTimer                             = [OPThreadTimer timerWithTimeInterval:30.
                                                                             block:^{
                                                                                 [wself heartBeat];
                                                                             }
                                                                             queue:dispatch_get_global_queue(0, 0)];
    
    [_heartTimer fire];
}

- (void)heartBeat
{
    OPRequestPackage2963 *package          = [[OPRequestPackage2963 alloc] init];
    [package sendRequest];
}

- (void)socketManager:(OPSocketManagerBase *)socketManager didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [self buildHeartTimer];
}

- (void)socketManager:(OPSocketManagerBase *)socketManager didDisconnectWithError:(NSError *)error
{
    [self invalidateHeartTimer];
}

@end
