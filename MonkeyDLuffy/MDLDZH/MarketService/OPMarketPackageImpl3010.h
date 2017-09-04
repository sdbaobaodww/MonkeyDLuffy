//
//  OPMarketPackageImpl3010.h
//  OnePiece
//
//  Created by Duanwwu on 2016/11/13.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPMarketNetBase.h"

#pragma mark --------------------成交价格分布 sub_type = 1000------------------

@interface OPRequestPackage3010Sub1000 : OPMarketRequestPackage

@property (nonatomic, copy) NSString *code;//股票代码
@property (nonatomic) int date;//日期 YYYYMMDD格式 (请求当天的成本， 日期=0)
@property (nonatomic) short time;//时间 HHMM格式

- (instancetype)initWithCode:(NSString *)code date:(int)date time:(short)time subAttr:(short)subAttr;

@end

//成交价格分布数据项
@interface OPMarketPriceDistributionItem : NSObject

@property (nonatomic, assign) int price;//成交价
@property (nonatomic, assign) char decimal;//价格小数位数
@property (nonatomic, assign) int volume;//成交量  注：成交量的单位是手
@property (nonatomic, assign) int bigVolume;//大单成交量

@end

@interface OPResponsePackage3010Sub1000 : OPResponsePackage

@property (nonatomic, strong) NSArray *resultArray;

@end

#pragma mark --------------------成本分析 sub_type = 1001------------------

@interface OPRequestPackage3010Sub1001 : OPMarketRequestPackage

@property (nonatomic, copy) NSString *code;//股票代码
@property (nonatomic) int date;//日期 YYYYMMDD格式 (请求当天的成本， 日期=0)
@property (nonatomic) short time;//时间 HHMM格式

- (instancetype)initWithCode:(NSString *)code date:(int)date time:(short)time subAttr:(short)subAttr;

@end

@interface OPResponsePackage3010Sub1001 : OPResponsePackage

@property (nonatomic, assign) char decimal;//价格小数位数
@property (nonatomic, assign) char earnRatio;//获利比例
@property (nonatomic, assign) int average;//平均成本
@property (nonatomic, assign) int bigOrderAverage;//大单平均成本
@property (nonatomic, assign) int lowLimit70 ;//70%成本下限
@property (nonatomic, assign) int highLimit70 ;//70%成本上限
@property (nonatomic, assign) int lowLimit90 ;//90%成本下限
@property (nonatomic, assign) int highLimit90 ;//90%成本上限

@end
