//
//  SocketTransceiver.h
//  OnePiece
//
//  Created by Duanwwu on 16/10/25.
//  Copyright © 2016年 DZH. All rights reserved.
//

//socket数据收发器delegate，socket状态变更时触发
@protocol OPSocketTransceiverProtocol <NSObject>

//连接成功
- (void)didConnectToHost:(NSString *)host port:(uint16_t)port;

//连接失败
- (void)connectFailureToHost:(NSString *)host port:(uint16_t)port error:(NSError *)error;

//断开连接
- (void)didDisconnectHost:(NSString *)host port:(uint16_t)port error:(NSError *)error;

//写入数据成功
- (void)didWriteDataWithTag:(long)tag;

//读取数据成功
- (void)didReadData:(NSData *)data withTag:(long)tag;

@end

//socket数据收发器
@interface OPSocketTransceiver : NSObject

@property (nonatomic) id<OPSocketTransceiverProtocol> delegate;

//连接的地址，只有连接上服务器的时候才会设置
@property (nonatomic, strong) NSString *host;

//连接的端口，只有连接上服务器的时候才会设置
@property (nonatomic) ushort port;

//创建对象方法，queue指定socket状态变更时回调执行的线程
- (instancetype)initWithDelegateQueue:(dispatch_queue_t)queue delegate:(id<OPSocketTransceiverProtocol>)delegate;

//连接指定服务器
- (void)connectToHost:(NSString *)host port:(ushort)port timeout:(NSTimeInterval)timeout;

//关闭socket
- (void)disconnect;

//判断socket是否连接
- (BOOL)isConnected;

//发送数据包，tag为该包的标志
- (void)sendData:(NSData *)data tag:(long)tag;

@end
