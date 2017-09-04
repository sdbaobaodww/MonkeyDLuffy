//
//  OPSocketManager.m
//  OnePiece
//
//  Created by Duanwwu on 16/10/25.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPSocketManager.h"
#import <objc/runtime.h>

@interface OPSocketManagerBase ()

//接收到的数据长度
@property (nonatomic, readwrite) NSInteger receiveBytes;

//socket数据收发器
@property (nonatomic, strong) OPSocketTransceiver *socketTransceiver;

//等待发送队列
@property (nonatomic, strong) NSMutableArray *waitSendQueue;

//等待响应队列
@property (nonatomic, strong) NSMutableArray *waitResponseQueue;

//推送队列
@property (nonatomic, strong) NSMutableArray *pushQueue;

//响应数据
@property (nonatomic, strong) NSMutableData *receiveDatas;

//监控器集合
@property (nonatomic, strong) NSMutableArray *monitors;

@end

@implementation OPSocketManagerBase
{
    dispatch_queue_t                                _operateQueue;
}

- (instancetype)init
{
    return [self initWithMaxWaitSend:10 maxWaitResponse:10 timeout:7];
}

- (instancetype)initWithMaxWaitSend:(int)maxWaitSend maxWaitResponse:(int)maxWaitResponse timeout:(NSTimeInterval)timeout
{
    if (self = [super init])
    {
        self.maxWaitSend                            = maxWaitSend;
        self.maxWaitResponse                        = maxWaitResponse;
        self.timeout                                = timeout;
        
        self.waitSendQueue                          = [NSMutableArray array];
        self.waitResponseQueue                      = [NSMutableArray array];
        self.pushQueue                              = [NSMutableArray array];
        self.receiveDatas                           = [NSMutableData data];
        self.monitors                               = [NSMutableArray array];
        
        _operateQueue                               = dispatch_queue_create("OPSocketManager", DISPATCH_QUEUE_PRIORITY_DEFAULT);
        self.socketTransceiver                      = [[OPSocketTransceiver alloc] initWithDelegateQueue:_operateQueue delegate:self];
    }
    return self;
}

- (void)registerMonitor:(id<OPSocketManagerMonitorProtocol>)monitor
{
    [self.monitors addObject:monitor];
    if ([monitor respondsToSelector:@selector(monitorRegisteredOnSocketManager:)])
        [monitor monitorRegisteredOnSocketManager:self];
}

- (BOOL)isPushHeader:(id<OPPackageHeaderProtocol>)header
{
    [NSException raise:@"UnsupportedOperationException" format:@"该方法为抽象方法，请使用子类"];
    return NO;
}

- (Class<OPPackageHeaderProtocol>)headerClass
{
    [NSException raise:@"UnsupportedOperationException" format:@"该方法为抽象方法，请使用子类"];
    return NULL;
}

- (NSString *)connectedHost
{
    return [self.socketTransceiver host];
}

- (ushort)connectedPort
{
    return [self.socketTransceiver port];
}

- (int)waitSendCount
{
    return (int)self.waitSendQueue.count;
}

- (int)waitResponseCount
{
    return (int)self.waitResponseQueue.count;
}

- (void)connectToHost:(NSString *)host port:(ushort)port
{
    [self.socketTransceiver connectToHost:host port:port timeout:self.timeout];
}

- (void)disconnect
{
    [self.socketTransceiver disconnect];
}

- (BOOL)isConnected
{
    return [self.socketTransceiver isConnected];
}

//通过包序号找出对应的请求包
- (id<OPRequestPackageProtocol>)findRequestPackageWithTag:(long)tag
{
    for (id<OPRequestPackageProtocol> package in self.waitSendQueue)
    {
        if ([package.header packageId] == tag)
            return package;
    }
    return nil;
}

- (id<OPRequestPackageProtocol>)findRequestPackageWithResponseHeader:(id<OPPackageHeaderProtocol>)responseHeader
{
    for (id<OPRequestPackageProtocol> package in self.waitResponseQueue)
    {
        if ([package responseMatch:responseHeader])
            return package;
    }
    return nil;
}

- (id<OPRequestPackageProtocol>)findPushRequestPackageWithResponseHeader:(id<OPPackageHeaderProtocol>)responseHeader
{
    for (id<OPPushablePackageProtocol> package in self.pushQueue)
    {
        if ([package responseMatch:responseHeader])
            return package;
    }
    return nil;
}

- (void)_onWriteDataSuccess:(long)tag
{
    id<OPRequestPackageProtocol> package            = [self findRequestPackageWithTag:tag];
    if (package)
    {
        package.status                              = OPRequestStatusSended;//请求状态置为已发送
        
        if ([package conformsToProtocol:@protocol(OPPushablePackageProtocol)])//推送请求
        {
            id<OPRequestPackageProtocol> oldPushPackage   = [self findPushRequestPackageWithResponseHeader:package.header];
            if ([(id<OPPushablePackageProtocol>)package isUnRegisterPushPackage])//取消推送请求
            {
                [self.pushQueue removeObject:oldPushPackage];
                OPLOG_DEBUG(OPLogModuleSocket, @"移除推送请求:%ld", [package.header packageId]);
                [package setResponseStatus:OPResponseStatusSucess];//响应状态置为Success
            }
            else//注册推送请求
            {
                if (oldPushPackage)//如果有同类型旧的推送请求包，则先进行移除
                {
                    OPLOG_DEBUG(OPLogModuleSocket, @"移除推送请求:%ld", [package.header packageId]);
                    [self.pushQueue removeObject:oldPushPackage];
                }
                
                OPLOG_DEBUG(OPLogModuleSocket, @"添加推送请求:%ld", [package.header packageId]);
                [self.pushQueue addObject:package];
            }
        }
        else if (package.ignorResponse)//不需要等待响应数据的请求发送完成后，直接结束请求流程
        {
            [package setResponseStatus:OPResponseStatusSucess];//响应状态置为Success
        }
        else
        {
            //加入待响应队列
            [self.waitResponseQueue addObject:package];
        }
        //从待发送队列移除
        [self.waitSendQueue removeObject:package];
        OPLOG_DEBUG(OPLogModuleSocket, @"从待发送队列移除:%ld", [package.header packageId]);
        [self _notifyPackageCountChange];
    }
    [self notifySendPackage];//如果可能，发送请求数据
}

- (void)_onReadDataSuccess:(NSData *)readedData
{
    self.receiveBytes                               += [readedData length];
    [self.receiveDatas appendData:readedData];
    
    NSData *data                                    = self.receiveDatas;
    Class headerClass                               = [self headerClass];
    int pos                                         = 0;
    while ([self.receiveDatas length] > pos + [headerClass validHeaderMinSize])
    {
        int itemPos                                 = pos;
        
        id<OPPackageHeaderProtocol> header          = [[headerClass alloc] init];
        int length                                  = [header deserialize:data pos:&itemPos];//反序列化包头数据
        if (itemPos + length > data.length)//缺少数据情况，忽略掉该头部数据，以便接受完数据后继续处理
        {
            OPLOG_DEBUG(OPLogModuleSocket, @"数据未完全返回:%ld", [header packageId]);
            break;
        }
        else//数据正常
        {
            if (length == 0)
                OPLOG_WARN(OPLogModuleSocket, @"接收到空包:%ld", [header packageId]);
            
            if ([self isPushHeader:header])
                [self _doWithPushData:data pos:itemPos length:length header:header];
            else
                [self _doWithNormalData:data pos:itemPos length:length header:header];
            pos                                     = itemPos + length;
        }
    }
    [self.receiveDatas replaceBytesInRange:NSMakeRange(0, pos) withBytes:nil length:0];
    [self _notifyPackageCountChange];
}

//推送数据处理
- (void)_doWithPushData:(NSData *)data pos:(int)itemPos length:(int)length header:(id<OPPackageHeaderProtocol>)header
{
    __strong id<OPRequestPackageProtocol> requestPackage    = [self findPushRequestPackageWithResponseHeader:header];
    if (!requestPackage)
    {
        OPLOG_DEBUG(OPLogModuleSocket, @"找不到推送请求包:%ld", [header packageId]);
    }
    else
    {
        OPLOG_DEBUG(OPLogModuleSocket, @"接收到推送响应数据:%ld", [header packageId]);
        
        //取消掉超时处理
        if (requestPackage.status != OPRequestStatusReceived)
            [self cancelTimeoutHandle:requestPackage];
        
        requestPackage.status                      = OPRequestStatusReceived;//请求状态置为已收到数据
        [requestPackage receiveBodyData:length > 0 ? [data subdataWithRange:NSMakeRange(itemPos, length)] : nil responseHeader:header];
        [requestPackage setResponseStatus:OPResponseStatusSucess];//响应状态置为Success
        
        for (id<OPSocketManagerMonitorProtocol> monitor in self.monitors)
        {
            if ([monitor respondsToSelector:@selector(socketManager:packageReceiveResponse:)])
                [monitor socketManager:self packageReceiveResponse:requestPackage];
        }
    }
}

//正常数据处理
- (void)_doWithNormalData:(NSData *)data pos:(int)itemPos length:(int)length header:(id<OPPackageHeaderProtocol>)header
{
    __strong id<OPRequestPackageProtocol> requestPackage    = [self findRequestPackageWithResponseHeader:header];
    if (!requestPackage)
    {
        OPLOG_DEBUG(OPLogModuleSocket, @"找不到请求包:%ld", [header packageId]);
    }
    else
    {
        OPLOG_DEBUG(OPLogModuleSocket, @"接收到响应数据:%ld", [header packageId]);
        
        //需要响应数据的请求在此取消掉超时处理
        if (!requestPackage.ignorResponse && requestPackage.status != OPRequestStatusReceived)
            [self cancelTimeoutHandle:requestPackage];
        
        [requestPackage receiveBodyData:length > 0 ? [data subdataWithRange:NSMakeRange(itemPos, length)] : nil responseHeader:header];
        
        if ([requestPackage isFinished])//接收结束
        {
            OPLOG_DEBUG(OPLogModuleSocket, @"从待响应队列移除:%ld", [requestPackage.header packageId]);
            
            [self.waitResponseQueue removeObject:requestPackage];//已接收完成数据，将包从等待响应队列移除
            
            [requestPackage setResponseStatus:OPResponseStatusSucess];//响应状态置为Success
            
            for (id<OPSocketManagerMonitorProtocol> monitor in self.monitors)
            {
                if ([monitor respondsToSelector:@selector(socketManager:packageReceiveResponse:)])
                    [monitor socketManager:self packageReceiveResponse:requestPackage];
            }
        }
    }
}

//包个数变更处理
- (void)_notifyPackageCountChange
{
    for (id<OPSocketManagerMonitorProtocol> monitor in self.monitors)
    {
        if ([monitor respondsToSelector:@selector(socketManager:waitSendCount:waitResponseCount:)])
            [monitor socketManager:self waitSendCount:[self waitSendCount] waitResponseCount:[self waitResponseCount]];
    }
}

- (void)_onSocketDisconnect
{
    [self removeAllPackage:self.waitSendQueue];//清除待发送队列
    [self removeAllPackage:self.waitResponseQueue];//清除待响应队列
    [self removeAllPackage:self.pushQueue];//清除推送队列
    [self _notifyPackageCountChange];
}

- (void)removeAllPackage:(NSMutableArray *)arr
{
    for (id<OPRequestPackageProtocol> package in arr)
    {
        [self cancelTimeoutHandle:package];//取消超时处理
        [package setResponseStatus:OPResponseStatusSocketClose];//响应状态置为SocketClose
    }
    [arr removeAllObjects];
}

- (void)sendRequestPackage:(id<OPRequestPackageProtocol>)requestPackage
{
    dispatch_async(_operateQueue, ^{
        if ([self.socketTransceiver isConnected])
        {
            OPLOG_DEBUG(OPLogModuleSocket, @"加入待发送队列:%ld", [requestPackage.header packageId]);
            
            [self.waitSendQueue addObject:requestPackage];
            
            for (id<OPSocketManagerMonitorProtocol> monitor in self.monitors)
            {
                if ([monitor respondsToSelector:@selector(socketManager:addNewRequestPackage:)])
                    [monitor socketManager:self addNewRequestPackage:requestPackage];
            }
            
            requestPackage.status                   = OPRequestStatusEnqueue;//请求状态置为已入发送队列
            
            //只有需要响应数据的请求才有超时处理
            if (![requestPackage ignorResponse])
                [self addTimeoutHandle:requestPackage];
            
            if (self.waitSendQueue.count > self.maxWaitSend)//移除最前面的请求包
            {
                id<OPRequestPackageProtocol> oldPackage = [self.waitSendQueue firstObject];
                [self cancelTimeoutHandle:oldPackage];
                [self.waitSendQueue removeObjectAtIndex:0];
                
                OPLOG_DEBUG(OPLogModuleSocket, @"待发送队列过长，移除最早请求包:%ld", [oldPackage.header packageId]);
            }
            
            [self _notifyPackageCountChange];
            [self notifySendPackage];//如果可能，发送请求数据
        }
        else
        {
            [requestPackage setResponseStatus:OPResponseStatusSocketClose];//响应状态置为SocketClose
        }
    });
}

//如果可能，发送请求数据
- (void)notifySendPackage
{
    for (id<OPRequestPackageProtocol> requestPackage in self.waitSendQueue)
    {
        if ([requestPackage status] == OPRequestStatusEnqueue)
        {
            //1，不需要返回数据，直接发送；2，需要返回数据，则判断等待响应队列是否超出阀值
            if ([requestPackage ignorResponse] || self.waitResponseQueue.count < self.maxWaitResponse)
            {
                OPLOG_DEBUG(OPLogModuleSocket, @"发送请求包:%ld", [requestPackage.header packageId]);
                
                [self.socketTransceiver sendData:[requestPackage serialize] tag:[requestPackage.header packageId]];
                
                for (id<OPSocketManagerMonitorProtocol> monitor in self.monitors)
                {
                    if ([monitor respondsToSelector:@selector(socketManager:sendRequestPackage:)])
                        [monitor socketManager:self sendRequestPackage:requestPackage];
                }
                break;
            }
        }
    }
}

#pragma mark -------------超时处理--------------

- (void)addTimeoutHandle:(id<OPRequestPackageProtocol>)requestPackage
{
    dispatch_source_t timeoutTimer              = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _operateQueue);
    __weak OPSocketManagerBase *weakSelf        = self;
    dispatch_source_set_event_handler(timeoutTimer, ^{ @autoreleasepool {
#pragma clang diagnostic push
#pragma clang diagnostic warning "-Wimplicit-retain-self"
        __strong OPSocketManagerBase *strong    = weakSelf;
        if (strong == nil)
            return;
        
        [strong requestTimeout:requestPackage];
        
#pragma clang diagnostic pop
    }});
    
#if !OS_OBJECT_USE_OBJC
    dispatch_source_t theTimer                  = timeoutTimer;
    dispatch_source_set_cancel_handler(timeoutTimer, ^{
#pragma clang diagnostic push
#pragma clang diagnostic warning "-Wimplicit-retain-self"
        dispatch_release(theTimer);
        
#pragma clang diagnostic pop
    });
#endif
    
    dispatch_time_t tt                      = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.timeout * NSEC_PER_SEC));
    dispatch_source_set_timer(timeoutTimer, tt, DISPATCH_TIME_FOREVER, 0);
    dispatch_resume(timeoutTimer);
    
    objc_setAssociatedObject(requestPackage, @"__timeoutTimer", timeoutTimer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self performSelector:@selector(requestTimeout:) withObject:requestPackage afterDelay:self.timeout inModes:@[NSRunLoopCommonModes]];
//    });
}

- (void)cancelTimeoutHandle:(id<OPRequestPackageProtocol>)requestPackage
{
    dispatch_source_t timeoutTimer          = objc_getAssociatedObject(requestPackage, @"__timeoutTimer");
    if (timeoutTimer)
        dispatch_source_cancel(timeoutTimer);
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestTimeout:) object:requestPackage];
//    });
}

- (void)requestTimeout:(id<OPRequestPackageProtocol>)requestPackage
{
    OPLOG_DEBUG(OPLogModuleSocket, @"请求包超时:%ld", [requestPackage.header packageId]);
    
    if (requestPackage.status == OPRequestStatusSerialized)//如果已经序列化了，则请求包位于等待响应队列，否则位于等待发送队列
        [self.waitResponseQueue removeObject:requestPackage];
    else
        [self.waitSendQueue removeObject:requestPackage];
    
    [requestPackage setResponseStatus:OPResponseStatusTimeout];//响应状态置为Timeout
    
    for (id<OPSocketManagerMonitorProtocol> monitor in self.monitors)
    {
        if ([monitor respondsToSelector:@selector(socketManager:requestPackageTimeout:)])
            [monitor socketManager:self requestPackageTimeout:requestPackage];
    }
}

#pragma mark --------------OPSocketTransceiverProtocol-------------------

- (void)didConnectToHost:(NSString *)host port:(uint16_t)port
{
    OPLOG_DEBUG(OPLogModuleSocket, @"socket连接成功 %@:%d", host, port);
    if (self.connectedSuccess)
        self.connectedSuccess(host, port);
    
    for (id<OPSocketManagerMonitorProtocol> monitor in self.monitors)
    {
        if ([monitor respondsToSelector:@selector(socketManager:didConnectToHost:port:)])
            [monitor socketManager:self didConnectToHost:host port:port];
    }
}

- (void)connectFailureToHost:(NSString *)host port:(uint16_t)port error:(NSError *)error
{
    OPLOG_DEBUG(OPLogModuleSocket, @"socket连接失败 %@:%d", host, port);
    if (self.connectedFailure)
        self.connectedFailure(host, port, error);
}

- (void)didDisconnectHost:(NSString *)host port:(uint16_t)port error:(NSError *)error
{
    if (error.code == 3)//socket连接的时候超时，1秒后重新进行连接
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1. * NSEC_PER_SEC)), _operateQueue, ^{
            
            [self connectToHost:self.socketTransceiver.host port:self.socketTransceiver.port];
        });
        return;
    }
    
    OPLOG_DEBUG(OPLogModuleSocket, @"socket断开连接 %@:%d %@", host, port, [error localizedDescription]);
    [self _onSocketDisconnect];
    
    if (self.socketDisconnected)
        self.socketDisconnected(error);
    
    for (id<OPSocketManagerMonitorProtocol> monitor in self.monitors)
    {
        if ([monitor respondsToSelector:@selector(socketManager:didDisconnectWithError:)])
            [monitor socketManager:self didDisconnectWithError:error];
    }
}

- (void)didWriteDataWithTag:(long)tag
{
    [self _onWriteDataSuccess:tag];
}

- (void)didReadData:(NSData *)data withTag:(long)tag
{
    [self _onReadDataSuccess:data];
}

@end

@interface OPReuqestPackageSenderBase ()

@property (nonatomic, strong) OPSocketManagerBase *socketManager;

@end

@implementation OPReuqestPackageSenderBase

- (OPSocketManagerBase *)currentSocketManager
{
    return self.socketManager;
}

- (void)registerSocketManager:(OPSocketManagerBase *)socketManager
{
    self.socketManager          = socketManager;
}

- (void)sendPackage:(id<OPRequestPackageProtocol>)package
{
    [self.socketManager sendRequestPackage:package];
}

@end
