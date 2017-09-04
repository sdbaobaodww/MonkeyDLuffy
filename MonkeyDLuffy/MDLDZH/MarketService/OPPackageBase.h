//
//  OPPackageBase.h
//  OnePiece
//
//  Created by Duanwwu on 16/10/25.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPPackageProtocol.h"

//数据请求包基类
@interface OPRequestPackage : NSObject<OPRequestPackageProtocol>

//发送器
@property (nonatomic, strong) id<OPReuqestPackageSenderProtocol>sender;

//包头
@property (nonatomic, strong) id<OPPackageHeaderProtocol> header;

//请求包状态
@property (nonatomic) OPRequestStatus status;

//响应状态
@property (nonatomic) OPResponseStatus responseStatus;

//请求包状态变更block
@property (nonatomic, copy) OPRequestBlock stautsNotify;

//响应回调block
@property (nonatomic, copy) OPResponseBlock responseCompletion;

//响应成功block
@property (nonatomic, copy) OPResponseBlock responseSuccess;

//响应失败block
@property (nonatomic, copy) OPResponseBlock responseFailure;

//是否忽略掉响应
@property (nonatomic) BOOL ignorResponse;

//数据响应包
@property (nonatomic, strong) id<OPResponsePackageProtocol> response;

- (instancetype)initWithHeader:(id<OPPackageHeaderProtocol>)header
                      response:(id<OPResponsePackageProtocol>)response
                        sender:(id<OPReuqestPackageSenderProtocol>)sender;

#pragma mark -----------------子类需选择重载的方法--------------------------

//如果responseParser未初始化，会调用此方法进行初始化，子类可以重载，特别是有些请求对应多个不同类型的响应时，如2939会返回2939数据或者2943数据
- (void)generateResponsePackage:(id<OPPackageHeaderProtocol>)responseHeader;

//序列化包内容，子类重载实现具体的数据写入
- (NSData *)serializeBody;

@end

//数据响应包基类，主要用来对原始数据进行解析
@interface OPResponsePackage : NSObject<OPResponsePackageProtocol>

//包头
@property (nonatomic, strong) id<OPPackageHeaderProtocol> header;

@end
