//
//  OPPackageProtocol.h
//  OnePiece
//
//  Created by Duanwwu on 16/10/26.
//  Copyright © 2016年 DZH. All rights reserved.
//

@class OPSocketManagerBase;
@protocol OPRequestPackageProtocol;
@protocol OPResponsePackageProtocol;
@protocol OPReuqestPackageSenderProtocol;

typedef NS_ENUM(NSUInteger, OPRequestStatus)
{
    OPRequestStatusNone,        //无
    OPRequestStatusEnqueue,     //已入发送队列
    OPRequestStatusSerialized,  //已序列化
    OPRequestStatusSended,      //已发送
    OPRequestStatusReceived,    //已收到数据
    OPRequestStatusDeSerialized //已反序列化
};

typedef NS_ENUM(NSUInteger, OPResponseStatus)
{
    OPResponseStatusNone,        //无
    OPResponseStatusSucess,      //响应成功
    OPResponseStatusTimeout,     //超时
    OPResponseStatusSocketClose, //socket关闭
    OPResponseStatusError,       //其它错误
};

typedef void(^OPResponseBlock)(OPResponseStatus status, id<OPRequestPackageProtocol> package);
typedef void(^OPRequestBlock)(OPRequestStatus status, id<OPRequestPackageProtocol> package);

//包头序列化、反序列化协议
@protocol OPHeaderSerializableProtocol <NSObject>

//将包头序列化生成data
- (NSMutableData *)serializeWithBodySize:(unsigned int)bodysize;

//将包头数据反序列化，并返回包内容的长度
- (int)deserialize:(NSData *)data pos:(int *)pos;

@end

//数据包头协议
@protocol OPPackageHeaderProtocol <OPHeaderSerializableProtocol>

//包头最少占用的长度，用于判断数据是否为一个有效包
+ (int)validHeaderMinSize;

//包序号
- (long)packageId;

//包类型号
- (unsigned short)type;

//包内容大小
- (unsigned int)bodySize;

@end

//请求包协议，请求包是由包头和包内容组成
@protocol OPRequestPackageProtocol <NSObject>

//设置请求包发送器
- (void)setSender:(id<OPReuqestPackageSenderProtocol>)sender;

//获取请求包发送器
- (id<OPReuqestPackageSenderProtocol>)sender;

//设置请求包头
- (void)setHeader:(id<OPPackageHeaderProtocol>)header;

//获取请求包头
- (id<OPPackageHeaderProtocol>)header;

//设置请求包状态
- (void)setStatus:(OPRequestStatus)status;

//获取请求包状态
- (OPRequestStatus)status;

//响应数据
- (id<OPResponsePackageProtocol>)response;

//响应状态
- (void)setResponseStatus:(OPResponseStatus)status;

//是否需要服务端响应
- (BOOL)ignorResponse;

//响应回调block
- (OPResponseBlock)responseCompletion;

//响应成功block
- (OPResponseBlock)responseSuccess;

//响应失败block
- (OPResponseBlock)responseFailure;

//通过响应包头判断该响应是否是有效响应
- (BOOL)responseMatch:(id<OPPackageHeaderProtocol>)responseHeader;

//发送请求
- (void)sendRequest:(OPResponseBlock)completion success:(OPResponseBlock)success failure:(OPResponseBlock)failure;

//发送请求
- (void)sendRequest;

//对数据进行序列化，生成二进制数据，分为序列化内容和包头两部
- (NSData *)serialize;

//收到数据处理，responseMatch匹配成功后会掉用此方法，data为nil时代表收到的为空数据包
- (void)receiveBodyData:(NSData *)body responseHeader:(id<OPPackageHeaderProtocol>)responseHeader;

//是否处理完成
- (BOOL)isFinished;

@end

//推送包协议
@protocol OPPushablePackageProtocol <OPRequestPackageProtocol>

//是否是取消推送的请求
- (BOOL)isUnRegisterPushPackage;

//注册推送
- (void)registerPush:(OPResponseBlock)pushBlock;

//取消注册推送
- (void)unRegisterPush:(OPResponseBlock)pushBlock;

@end

//响应包协议，响应包是由包头和包内容组成
@protocol OPResponsePackageProtocol <NSObject>

//设置响应包头
- (void)setHeader:(id<OPPackageHeaderProtocol>)header;

//获取响应包头
- (id<OPPackageHeaderProtocol>)header;

//反序列化数据，子类重载实现具体的数据反序列化
- (void)deSerialize:(NSData *)body;

//是否是空数据包
- (BOOL)isEmptyResponse;

@end

//请求包发送器，用来关联请求包与socket管理模块，一个socket模块对应一个发送器
@protocol OPReuqestPackageSenderProtocol <NSObject>

//将package请求包加入socket管理模块进行发送
- (void)sendPackage:(id<OPRequestPackageProtocol>)package;

@end

