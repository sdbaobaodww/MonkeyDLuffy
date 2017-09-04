//
//  OPMarketNetManager.m
//  OnePiece
//
//  Created by Duanwwu on 2016/11/8.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPMarketNetManager.h"
#import "NSString+FilePath.h"
#import "OPMarketPackageImpl.h"
#import "NSArray+Random.h"
#import "OPMarketMonitor.h"
#import "OPConstant.h"

NSString *OPSocketConnectSuccessNotification        = @"OPSocketConnectSuccessNotification";
NSString *OPSocketDisconnectNotification            = @"OPSocketDisconnectNotification";

@interface OPMarketAddressManager ()

//本地保存的服务器下发调度地址
@property (nonatomic, strong) NSArray *dispatchAddress;

//保存的行情服务器地址
@property (nonatomic, strong) NSArray *savedMarketAddress;

//行情连接成功的回调
@property (nonatomic, copy) void(^completion)(NSString *host, ushort port);

@end

@implementation OPMarketAddressManager
{
    OPSocketManagerMarket                   *_socketManager;
    dispatch_queue_t                        _operateQueue;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.timeout                        = 7.;
        self.dispatchAddress                = [NSArray arrayWithContentsOfFile:[NSString fp_libraryCachesFilePath:@"DispatchAddress.plist"]];
        self.savedMarketAddress             = [NSArray arrayWithContentsOfFile:[NSString fp_libraryCachesFilePath:@"MarketAddress.plist"]];
        _socketManager                      = [[OPSocketManagerMarket alloc] init];
        _operateQueue                       = dispatch_queue_create("OPMarketAddressManager", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    }
    return self;
}

- (void)getMarketAddress:(void(^)(NSString *host, ushort port))completion
{
    if (!completion)
        return;
    
    _socketManager.timeout                  = self.timeout;
    if ([self.savedMarketAddress count] > 0)//本地有保存的行情地址
    {
        NSString *address                   = [self.savedMarketAddress rd_randomObject];
        NSArray *sep                        = [address componentsSeparatedByString:@":"];
        
        if ([sep count] == 2)
        {
            completion([sep firstObject], [[sep objectAtIndex:1] intValue]);
            self.completion                 = nil;
            [self _requestMarketAddress:nil];//请求下一组行情地址
        }
        else
        {
            OPLOG_ERROR(OPLogModuleNetService, @"保存的行情地址有误!!!!");
            NSMutableArray *arr             = [NSMutableArray arrayWithArray:self.savedMarketAddress];
            [arr removeObject:address];
            self.savedMarketAddress         = arr;
            [self getMarketAddress:completion];
        }
    }
    else
    {
        self.completion                     = completion;
        [self _requestMarketAddress:completion];//无行情地址，先进行行情地址请求
    }
}

- (void)_requestMarketAddress:(void(^)(NSString *host, ushort port))completion
{
    NSArray *sep                            = [[self _marketAddress] componentsSeparatedByString:@":"];
    NSString *host                          = [sep firstObject];
    ushort port                             = [[sep objectAtIndex:1] intValue];
    
    __weak typeof(self) wself               = self;
    _socketManager.connectedSuccess         = ^(NSString *host, ushort port){
      
        [wself _request1000];
    };
    _socketManager.connectedFailure         = ^(NSString *host, ushort port, NSError *error){
        
        [wself _reRequestMarketAddress];
    };
    
    OPLOG_DEBUG(OPLogModuleNetService, @"请求的调度地址 %@:%d",host, port);
    [_socketManager connectToHost:host port:port];
}

- (void)_reRequestMarketAddress
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1. * NSEC_PER_SEC)), _operateQueue, ^{
        
        [self _requestMarketAddress:self.completion];
    });
}

- (void)_request1000
{
    __weak typeof(self) wself               = self;
    OPRequestPackage1000 *package           = [[OPRequestPackage1000 alloc] init];
    package.responseSuccess                 = ^(OPResponseStatus status, id<OPRequestPackageProtocol> package){
        
        OPResponsePackage1000 *response     = package.response;
        
        NSArray *hqAddress                  = [response hqServerAddresses];//String[]   地址格式为 ip:port
        self.savedMarketAddress             = hqAddress;
        [hqAddress writeToFile:[NSString fp_libraryCachesFilePath:@"MarketAddress.plist"] atomically:YES];//保存行情服务器
        
        NSArray *scheduleAddresses          = [response scheduleAddresses];//String[]   服务器地址格式：ip:port:id
        NSMutableArray *dispatch            = [NSMutableArray array];
        for (NSString *address in scheduleAddresses)
        {
            NSArray *arr                    = [address componentsSeparatedByString:@":"];
            if ([arr count] >= 2)
            {
                [dispatch addObject:[NSString stringWithFormat:@"%@:%@",[arr objectAtIndex:0], [arr objectAtIndex:1]]];
            }
        }
        self.dispatchAddress                = dispatch;
        [dispatch writeToFile:[NSString fp_libraryCachesFilePath:@"DispatchAddress.plist"] atomically:YES];//保存下发的调度地址
        
        OPLOG_DEBUG(OPLogModuleNetService, @"获取的行情地址：%@", hqAddress);
        
        NSString *str                       = [hqAddress rd_randomObject];
        NSArray *sep                        = [str componentsSeparatedByString:@":"];
        if ([sep count] == 2)
        {
            if (self.completion)
                self.completion([sep firstObject], [[sep objectAtIndex:1] intValue]);
          
            [_socketManager disconnect];//请求成功以后关闭socket
            OPLOG_DEBUG(OPLogModuleNetService, @"关闭调度连接");
        }
        else
        {
            OPLOG_ERROR(OPLogModuleNetService, @"获取的行情地址有误!!!!");
            [wself _reRequest1000];
        }
    };
    
    package.responseFailure                 = ^(OPResponseStatus status, id<OPRequestPackageProtocol> package){
        
        [wself _reRequest1000];
    };
    
    OPLOG_DEBUG(OPLogModuleNetService, @"请求行情地址");
    [_socketManager sendRequestPackage:package];
}

- (void)_reRequest1000
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.0 * NSEC_PER_SEC)), _operateQueue, ^{
        
        [self _request1000];
    });
}

- (NSString *)_marketAddress
{
    NSArray *address                        = nil;
    BOOL mock                               = NO;
    if (mock)
    {
        address                             = @[@"10.15.107.11:12346"];
    }
    else if ([self.dispatchAddress count] > 0)
    {
        address                             = self.dispatchAddress;
    }
    else
    {
        address                             = @[@"222.73.34.8:12346",@"222.73.103.42:12346",@"61.151.252.4:12346",@"61.151.252.14:12346"];
    }
    if ([address count] > 0)
    {
        return [address rd_randomObject];
    }
    return nil;
}

@end

@implementation OPMarketNetManager
{
    OPSocketManagerMarket                   *_market;
    OPMarketAddressManager                  *_addressManager;
}

+ (instancetype)instance
{
    static dispatch_once_t onceToken;
    static OPMarketNetManager *instance     = nil;
    dispatch_once(&onceToken, ^{
        instance                            = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _addressManager                     = [[OPMarketAddressManager alloc] init];
        _market                             = [[OPSocketManagerMarket alloc] init];
        _market.connectedSuccess            = ^(NSString *host, ushort port){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:OPMarketConnectedNotification object:nil];
        };
        _market.socketDisconnected          = ^(NSError *error){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:OPMarketDisconnectNotification object:nil];
        };
        
        [[OPReuqestPackageSenderMarket instance] registerSocketManager:_market];//全局行情包发送器注册socket管理器
        [_market registerMonitor:[[OPSocketMonitorTimeout alloc] init]];//超时监控器
        [_market registerMonitor:[[OPSocketMonitorNetLog alloc] init]];//网络日志上传
        [_market registerMonitor:[[OPSocketMonitorHeartBeat alloc] init]];//心跳包发送
    }
    return self;
}

- (void)buildNetwork
{
    [_addressManager getMarketAddress:^(NSString *host, ushort port) {
        
        OPLOG_DEBUG(OPLogModuleNetService, @"连接的行情地址 %@:%d",host, port);
        [_market connectToHost:host port:port];
    }];
}

@end
