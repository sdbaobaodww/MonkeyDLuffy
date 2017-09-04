//
//  OPMarketNetManager.h
//  OnePiece
//
//  Created by Duanwwu on 2016/11/8.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 行情地址管理
 */
@interface OPMarketAddressManager : NSObject

@property (nonatomic) NSTimeInterval timeout;//超时时间，单位秒

/**
 * 获取行情地址，分两种情况：
 * 1，程序第一次启动，本地不存在保存的行情地址，此时去调度地址请求行情地址，如果请求异常则每隔一段时间继续请求，直到返回地址；
 * 2，非第一次启动，本地存在保存的行情地址。
 * @param completion 回调返回行情地址和端口
 */
- (void)getMarketAddress:(void(^)(NSString *host, ushort port))completion;

@end

/**
 * 行情网络管理
 */
@interface OPMarketNetManager : NSObject

+ (instancetype)instance;

/**
 * 创建行情连接
 */
- (void)buildNetwork;

@end
