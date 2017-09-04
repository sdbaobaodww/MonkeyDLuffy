//
//  OPMarketNetBase.h
//  OnePiece
//
//  Created by Duanwwu on 2016/11/11.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPPackageBase.h"
#import "OPSocketManager.h"

//请求包resultTag类型
typedef NS_ENUM(NSUInteger, OPResultTagRequest)
{
    OPResultTagRequestNoResponse    = 0,    //表示不需要给用户任何的返回
    OPResultTagRequestReceipt       = 1,    //行情服务器给予是否发送成功的返回
    OPResultTagRequestWaitResponse  = 2,    //该请求需要等服务器应答的返回
    OPResultTagRequestAsyncResponse = 3,    //该响应服务端可异步返回
};

//响应包resultTag类型
typedef NS_ENUM(NSUInteger, OPResultTagResponse)
{
    OPResultTagResponseSuccess      = 0,    //行情服务器返回的成功标记
    OPResultTagResponseFailure      = 1,    //行情服务器返回的失败标记
    OPResultTagResponseData         = 2,    //通用服务器返回的数据
    OPResultTagResponsePush         = 3,    //通用服务器主动推送的数据,推送数据的分隔符都是0
};

//子包头
@interface OPPackageSubHeader : NSObject<OPHeaderSerializableProtocol>

/**
 * 请求时表示是否等待服务器返回结果:
    0 表示不需要给用户任何的返回,
    1 行情服务器给予是否发送成功的返回
    2 该请求需要等服务器应答的返回.
    3 该响应服务端可异步返回
 
   响应时表示服务器返回结果:
    0:行情服务器返回的成功标记
    1:行情服务器返回的失败标记
    2:通用服务器返回的数据
    3:通用服务器主动推送的数据,推送数据的分隔符都是0
 *
 */
@property (nonatomic) char resultTag;

@property (nonatomic) unsigned short subType;

@property (nonatomic) unsigned short subAttrs;

@property (nonatomic) unsigned short subLength;

- (instancetype)initWithTag:(OPResultTagRequest)resultTag type:(unsigned short)subType attrs:(unsigned short)subAttrs;

- (instancetype)initWithTag:(OPResultTagRequest)resultTag type:(unsigned short)subType;

@end

//3001推送接口子包头；3010成本分布接口子包头
@interface OPPackageSubHeaderExtend : OPPackageSubHeader

@property (nonatomic) unsigned int subExtend;

- (instancetype)initWithTag:(OPResultTagRequest)resultTag type:(unsigned short)subType attrs:(unsigned short)subAttrs extend:(unsigned int)subExtend;

@end

//行情数据包头
@interface OPPackageHeader : NSObject<OPPackageHeaderProtocol>

@property (nonatomic) unsigned char tag;//起始标记
@property (nonatomic) unsigned short type;//包类型
@property (nonatomic) unsigned short attrs;//属性
@property (nonatomic) unsigned int length;//正文长度
@property (nonatomic, retain) OPPackageSubHeader * subHeader;//子包头

- (instancetype)initWithTag:(unsigned char)tag type:(unsigned short)type attrs:(unsigned short)attrs;

- (instancetype)initWithType:(unsigned short)type attrs:(unsigned short)attrs;

- (instancetype)initWithType:(unsigned short)type;

@end

//行情请求
@interface OPMarketRequestPackage : OPRequestPackage

@property (nonatomic) int reqTag;//自定义标记，可在业务层用于标记请求，不会写入网络通信数据中

- (instancetype)initWithHeader:(id<OPPackageHeaderProtocol>)header
                      response:(id<OPResponsePackageProtocol>)response;

@end

//行情推送请求
@interface OPPushableMarketRequestPackage : OPMarketRequestPackage<OPPushablePackageProtocol>

@property (nonatomic) BOOL isUnRegisterPushPackage;

@end

/**
 * 行情组包请求，可添加子组包
 */
@interface OPMarketRequestPackageGroup : OPRequestPackage

/**
 * 添加请求包
 */
- (void)addPackage:(OPRequestPackage *)package;

/**
 * 通过行情包类型查找该组包下的请求包，只找到第一个匹配的，找不到返回nil
 * @param type 行情包类型
 * @returns 请求包
 */
- (OPRequestPackage *)findSinglePackageWithType:(short)type;

/**
 * 通过行情包类型查找该组包下的请求包，查找所有匹配的请求包，找不到返回nil
 * @param type 行情包类型
 * @returns 请求包数组
 */
- (NSArray *)findPackagesWithType:(short)type;

@end

/**
 * 行情功能的socket管理类
 */
@interface OPSocketManagerMarket : OPSocketManagerBase

@end

//行情包发送器
@interface OPReuqestPackageSenderMarket : OPReuqestPackageSenderBase

+ (instancetype)instance;

@end

typedef void(^OPHttpBlock)(id data, NSError *error);

@interface OPHttpManager : NSObject

//通过http发送行情数据包
+ (void)httpSendPackage:(id<OPRequestPackageProtocol>)requestPackage toURL:(NSString *)urlStr timeout:(NSTimeInterval)timeout;

//发送http请求
+ (void)httpSendRequest:(NSURLRequest *)request completion:(OPHttpBlock)completion;

//获取json数据
+ (void)httpSendJsonRequest:(NSURLRequest *)request completion:(OPHttpBlock)completion;

@end
