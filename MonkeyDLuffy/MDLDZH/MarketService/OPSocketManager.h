//
//  OPSocketManager.h
//  OnePiece
//
//  Created by Duanwwu on 16/10/25.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPPackageProtocol.h"
#import "OPSocketTransceiver.h"

/**
 * socket管理类监控器协议
 */
@protocol OPSocketManagerMonitorProtocol <NSObject>

@optional

//当该监控器被注册到socketManager时调用
- (void)monitorRegisteredOnSocketManager:(OPSocketManagerBase *)socketManager;

//新的请求包加入
- (void)socketManager:(OPSocketManagerBase *)socketManager addNewRequestPackage:(id<OPRequestPackageProtocol>)requestPackage;

//发送请求包
- (void)socketManager:(OPSocketManagerBase *)socketManager sendRequestPackage:(id<OPRequestPackageProtocol>)requestPackage;

//请求包超时
- (void)socketManager:(OPSocketManagerBase *)socketManager requestPackageTimeout:(id<OPRequestPackageProtocol>)requestPackage;

//请求包收到响应数据
- (void)socketManager:(OPSocketManagerBase *)socketManager packageReceiveResponse:(id<OPRequestPackageProtocol>)requestPackage;

//请求队列、响应队列变更
- (void)socketManager:(OPSocketManagerBase *)socketManager waitSendCount:(int)waitSendCount waitResponseCount:(int)waitResponseCount;

//连接成功
- (void)socketManager:(OPSocketManagerBase *)socketManager didConnectToHost:(NSString *)host port:(uint16_t)port;

//断开连接
- (void)socketManager:(OPSocketManagerBase *)socketManager didDisconnectWithError:(NSError *)error;

@end

/**
 * socket管理基类
 */
@interface OPSocketManagerBase : NSObject<OPSocketTransceiverProtocol>

//超时时间，单位秒
@property (nonatomic) NSTimeInterval timeout;

//接收到的数据长度
@property (nonatomic, readonly) NSInteger receiveBytes;

//等待响应队列数据个数限制
@property (nonatomic) int maxWaitResponse;

//等待发送队列数据个数限制
@property (nonatomic) int maxWaitSend;

//socket连接成功
@property (nonatomic, copy) void(^connectedSuccess)(NSString *host, ushort port);

//socket连接失败
@property (nonatomic, copy) void(^connectedFailure)(NSString *host, ushort port, NSError *error);

//socket断开
@property (nonatomic, copy) void(^socketDisconnected)(NSError *error);

- (instancetype)initWithMaxWaitSend:(int)maxWaitSend
                    maxWaitResponse:(int)maxWaitResponse
                            timeout:(NSTimeInterval)timeout;

//连接的服务器地址
- (NSString *)connectedHost;

//连接的服务器端口
- (ushort)connectedPort;

//待发送队列长度
- (int)waitSendCount;

//待响应队列长度
- (int)waitResponseCount;

//连接指定服务器
- (void)connectToHost:(NSString *)host port:(ushort)port;

//关闭socket
- (void)disconnect;

//判断socket是否连接
- (BOOL)isConnected;

//发送请求包
- (void)sendRequestPackage:(id<OPRequestPackageProtocol>)requestPackage;

/**
 * 注册一个监控器
 * @param monitor 监控器
 */
- (void)registerMonitor:(id<OPSocketManagerMonitorProtocol>)monitor;

#pragma mark --------------需子类实现支持----------------

/**
 * 判断是否是推送数据
 * @param header 包头
 */
- (BOOL)isPushHeader:(id<OPPackageHeaderProtocol>)header;

//包头对应的具体实现类型，子类具体实现
- (Class<OPPackageHeaderProtocol>)headerClass;

@end

//请求包发送器，用来关联请求包与socket管理模块，一个socket模块对应一个发送器
@interface OPReuqestPackageSenderBase : NSObject<OPReuqestPackageSenderProtocol>

//注册socket管理模块
- (void)registerSocketManager:(OPSocketManagerBase *)socketManager;

//当前的socket管理模块
- (OPSocketManagerBase *)currentSocketManager;

@end
