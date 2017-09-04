//
//  SocketTransceiver.m
//  OnePiece
//
//  Created by Duanwwu on 16/10/25.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPSocketTransceiver.h"
#import "GCDAsyncSocket.h"

@implementation OPSocketTransceiver
{
    GCDAsyncSocket                      *_socket;
}

- (instancetype)initWithDelegateQueue:(dispatch_queue_t)queue delegate:(id<OPSocketTransceiverProtocol>)delegate
{
    if (self = [super init])
    {
        _socket                         = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:queue];
        self.delegate                   = delegate;
    }
    return self;
}

- (void)connectToHost:(NSString *)host port:(ushort)port timeout:(NSTimeInterval)timeout
{
    self.host                           = host;
    self.port                           = port;
    NSError *error                      = nil;
    [_socket connectToHost:host onPort:port withTimeout:timeout error:&error];
    if (error != nil)
    {
        if ([self.delegate respondsToSelector:@selector(connectFailureToHost:port:error:)])
            [self.delegate connectFailureToHost:host port:port error:error];
    }
}

- (void)disconnect
{
    [_socket disconnect];
}

- (BOOL)isConnected
{
    return _socket.isConnected;
}

- (void)sendData:(NSData *)data tag:(long)tag
{
    [_socket writeData:data withTimeout:-1 tag:tag];
}

#pragma mark -----GCDAsyncSocketDelegate--------

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [sock readDataWithTimeout:-1 tag:0];
    if ([self.delegate respondsToSelector:@selector(didConnectToHost:port:)])
        [self.delegate didConnectToHost:host port:port];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if ([self.delegate respondsToSelector:@selector(didWriteDataWithTag:)])
        [self.delegate didWriteDataWithTag:tag];
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
    return 0;
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [sock readDataWithTimeout:-1 tag:0];
    if ([self.delegate respondsToSelector:@selector(didReadData:withTag:)])
        [self.delegate didReadData:data withTag:tag];
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
    return 0;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if ([self.delegate respondsToSelector:@selector(didDisconnectHost:port:error:)])
        [self.delegate didDisconnectHost:self.host port:self.port error:err];
}

@end
