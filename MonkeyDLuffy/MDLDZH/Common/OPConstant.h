//
//  OPConstant.h
//  OnePiece
//
//  Created by Duanwwu on 16/10/25.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import <Foundation/Foundation.h>

static const NSString * const KeyChainAccessGroup       = @"59B8QAXTFE.com.gw.dzhiphone622";
static const NSString * const DeviceIDKey               = @"DeviceID";
static const NSString * const ChannelNo                 = @"213";
static const NSString * const TerminalId                = @"iphone";
static const NSString * const PlatformId                = @"14";
static const NSTimeInterval SocketTimeout               = 7.;
static const NSTimeInterval HTTPTimeout                 = 7.;

static NSString *OPMarketConnectedNotification          = @"OPMarketConnectedNotification";//行情服务器连接成功通知
static NSString *OPMarketDisconnectNotification         = @"OPMarketDisconnectNotification";//行情服务器断开通知

@interface OPConstant : NSObject

+ (NSArray *)schedulingServerAddress;

+ (NSString *)deviceId;

+ (NSString *)versionNumber;

+ (NSMutableDictionary*)userPreferenceConfigDic;

@end
