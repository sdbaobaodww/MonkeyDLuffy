//
//  OPMarketPackageImpl.h
//  OnePiece
//
//  Created by Duanwwu on 16/10/25.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPMarketNetBase.h"
#import "OPMarketDataModel.h"

#pragma mark ------------初始信息 type=1000 ---------------

@interface OPRequestPackage1000 : OPMarketRequestPackage

@property (nonatomic, strong) NSString *version;//版本
@property (nonatomic, strong) NSString *deviceID;//终端编号
@property (nonatomic, strong) NSString *deviceType;//终端类型
@property (nonatomic) char paymentFlag;//收费用户标记
@property (nonatomic) char carrier;//运营商标记
@property (nonatomic, strong) NSArray *serverList;//请求不同服务地址列表

- (instancetype)initWithVersion:(NSString *)version deviceID:(NSString *)deviceId deviceType:(NSString *)deviceType;

@end

@interface OPResponsePackage1000 : OPResponsePackage

@property (nonatomic, strong) NSArray *hqServerAddresses; // 行情服务器地址数组
@property (nonatomic, strong) NSArray *wtServerAddresses; // 委托服务器地址数组
@property (nonatomic, strong) NSString *noticeText; // 公告信息
@property (nonatomic, strong) NSString *recentVersionNum; // 新版本号
@property (nonatomic, strong) NSString *downloadAddress; // 下载地址
@property (nonatomic) BOOL isAlertUpdate; // 是否提醒升级
@property (nonatomic) BOOL isForceUpdate; // 是否强制升级
@property (nonatomic) BOOL isAlertLogin; // 是否提示登录
@property (nonatomic) char carrierIP; // 用户运营商ip   0表示未知；非0表示有效，
@property (nonatomic) short uploadLogInterval; // 统计信息时间间隔  单位秒,如果为0表示不统计信息
@property (nonatomic, strong) NSString *updateNotice; // 升级提示文字
@property (nonatomic) short noticeCRC; // 公告crc
@property (nonatomic) char noticeType; // 公告提示类型
@property (nonatomic, strong) NSArray *scheduleAddresses; // 调度地址
@property (nonatomic, strong) NSDictionary * serverDict; // 不同服务器地址列表

@end

#pragma mark -----------连接会话心跳 type=2925-------------

@interface OPRequestPackage2925 : OPMarketRequestPackage

@property (nonatomic) long long sessionid;//会话id

- (instancetype)initWithSessionId:(long long)sessionid;

@end

#pragma mark -----------服务器当前时间，该接口客户端用来同步时间 type=2963-------------

@interface OPRequestPackage2963 : OPMarketRequestPackage

@end

@interface OPResponsePackage2963 : OPResponsePackage

@property (nonatomic) short year;//年
@property (nonatomic) short month;//月
@property (nonatomic) short day;//日
@property (nonatomic) short hour;//时
@property (nonatomic) short minute;//分
@property (nonatomic) short second;//秒

@end

#pragma mark -----------请求服务器端特定信息 type=2986-------------

@interface OPRequestPackage2986 : OPMarketRequestPackage

@property (nonatomic) int mask;//信息掩码 1位：       会话id    //该接口需在2972接口之后

- (instancetype)initWithMask:(int)mask;

@end

@interface OPResponsePackage2986 : OPResponsePackage

@property (nonatomic) int mask;//信息掩码
@property (nonatomic) long long sessionid;//会话id

@end

#pragma mark -----------设置证券推送证券信息 type=2978-------------

@interface OPRequestPackage2978 : OPPushableMarketRequestPackage

@property (nonatomic) char infoType;//信息类型1表示设置商品id列表推送，只支持商品类的推送；2表示设置个股列表推送；0表示取消已有的推送
@property (nonatomic) int fieldType1;//首次设置时服务器推送返回的字段
@property (nonatomic) int fieldType2;//后续推送返回的字段，如果该字段为0，只返回一次字段属性1内容
@property (nonatomic) short productId;//分类id 商品列表id
@property (nonatomic) char sortType;//排序方式 0降序 1升序
@property (nonatomic) char sortField;//排序字段
@property (nonatomic) short beginPos;//起始序号
@property (nonatomic) short reqNum;//请求条数
@property (nonatomic, strong) NSArray *codes;//个股推送 股票代码

//商品列表推送
- (instancetype)initWithProductPush:(short)productId
                             filed1:(int)fieldType1
                             field2:(int)fieldType2
                           sortType:(char)sortType
                          sortField:(char)sortField
                           beginPos:(short)beginPos
                             reqNum:(short)reqNum;

//指定股票列表推送
- (instancetype)initWithCodes:(NSArray *)codes
                       filed1:(int)fieldType1
                       field2:(int)fieldType2;

//取消推送，使用默认初始化
- (instancetype)init;

@end

@interface OPResponsePackage2978 : OPResponsePackage

@property (nonatomic) int pushProperty;         // 服务器返回的本次数据注册参数
@property (nonatomic) int total;                // 该分类证券总数
@property (nonatomic, strong) NSArray *resultArray;

@end

#pragma mark ---------证券分钟走势数据 type=2942--------------

@interface OPRequestPackage2942 : OPMarketRequestPackage

@property (nonatomic, copy) NSString *code;//代码
@property (nonatomic) short beginPos;//数据位置

- (instancetype)initWithCode:(NSString *)code beginPos:(short)beginPos;

@end

@interface OPResponsePackage2942 : OPResponsePackage

@property (nonatomic) BOOL holdTag;//持仓标记
@property (nonatomic) unsigned short totalNum;//一天总的分时数目
@property (nonatomic) short mineCount;//信息地雷数
@property (nonatomic) short starVal;//五星评级
@property (nonatomic) short pos;//数据位置
@property (nonatomic, strong) NSArray *marketTimes;//市场交易时间
@property (nonatomic, strong) NSArray *minutes;//分时记录

@end

@interface OPMarketTimes : NSObject

@property (nonatomic) short openTime;//开盘时间
@property (nonatomic) short endTime;//休盘时间

@end

#pragma mark ---------K线数据 type=2944--------------

@interface OPRequestPackage2944 : OPMarketRequestPackage

@property (nonatomic, copy) NSString *code;//代码
@property (nonatomic) OPSecurityKlineType klineType;//K线类型
@property (nonatomic) int endDate;//截至日期
@property (nonatomic) unsigned short reqNum;//请求根数
@property (nonatomic) OPEXRightsType exRights;//除权标记，1表示后除权，2表示前除权，0或者无该字段表示不除权

- (instancetype)initWithCode:(NSString *)code
                   klineType:(OPSecurityKlineType)klineType
                     endDate:(int)endDate
                      reqNum:(unsigned short)reqNum
                    exRights:(OPEXRightsType)exRights;

@end

@interface OPResponsePackage2944 : OPResponsePackage

@property (nonatomic) BOOL holdTag;//持仓标记
@property (nonatomic, strong) NSArray *klines;//k线记录

@end

#pragma mark ---------定制证券分钟走势数据 type=2985--------------

@interface OPRequestPackage2985 : OPMarketRequestPackage

@property (nonatomic, copy) NSString *code;//代码
@property (nonatomic) char offset;//第几交易日走势 0表示当天的数据， 1表示前1交易日数据，2表示前2一日数据....；
@property (nonatomic) char stride;//数据间隔 表示多少分钟一个走势数据；0表示取服务端默认数值
@property (nonatomic) char mask;//走势数据掩码 0位表示时间，1位表示成交量，2位表示均价，3位表示持仓量；
@property (nonatomic) short pos;//数据位置
@property (nonatomic) short reqNum;//数据数目 0表示请求指定交易日所有数据

- (instancetype)initWithCode:(NSString *)code
                      offset:(char)offset
                      stride:(int)stride
                        mask:(char)mask
                         pos:(short)pos
                      reqNum:(short)reqNum;

@end

@interface OPResponsePackage2985 : OPResponsePackage

@property (nonatomic) unsigned short totalNum;//一天总的分时数目
@property (nonatomic, strong) NSArray *marketTimes;//市场交易时间
@property (nonatomic) char stride;//数据间隔
@property (nonatomic) char mask;//走势数据掩码
@property (nonatomic) short pos;//数据位置
@property (nonatomic, strong) NSArray *minutes;//分时记录

@end

#pragma mark ---------证券静态数据 type=2939--------------

//该接口如果存在多个代码会以2943接口返回；如果只有一个证券返回静态，不存在就返回长度为0的响应
@interface OPRequestPackage2939 : OPMarketRequestPackage

@property (nonatomic, copy) NSString *code;//代码

- (instancetype)initWithCode:(NSString *)code;

@end

@interface OPResponsePackage2939 : OPResponsePackage

@property (nonatomic, strong) NSString *code;//代码
@property (nonatomic, strong) NSString *name;//名称
@property (nonatomic) OPSecurityType securityType;//类型
@property (nonatomic) short decimal;//价格位数
@property (nonatomic) short volumeUnit;//成交量单位
@property (nonatomic) int lastClose;//昨收
@property (nonatomic) int limitup;//涨停
@property (nonatomic) int limitdown;//跌停
@property (nonatomic) long long circulationEquity;//流通盘
@property (nonatomic) long long totalEquity;//总股本
@property (nonatomic) char margin;//融资融券标记 1是融资融券标的，0不是
@property (nonatomic) int tradeUnit;//这个主要用于港股的委托使用的交易量，对其它市场该数值和成交量单位相同
@property (nonatomic) char extend;//证券扩展分类 0无效，1基础三板，2创新三板
@property (nonatomic) short optionFlag;//证券标记 共16位，用来表示证券只有2个状态的各个标记
@property (nonatomic) int lastPosition;//对期货或期指是昨日持仓，单位是手
@property (nonatomic) int lastSettlement;//对商品是昨结算价

@end

#pragma mark ---------查询证券 type=2943--------------

@interface OPRequestPackage2943 : OPMarketRequestPackage

@property (nonatomic, copy) NSString *keyword;//关键词

- (instancetype)initWithKeyWord:(NSString *)keyword;

@end

@interface OPResponsePackage2943 : OPResponsePackage

//搜索出来的证券数据   [OPMarketSecurityModel]
@property (nonatomic, strong) NSArray *resultArray;

@end

#pragma mark ---------证券动态数据 type=2940--------------

@interface OPRequestPackage2940 : OPMarketRequestPackage

@property (nonatomic, copy) NSString *code;//代码

- (instancetype)initWithCode:(NSString *)code;

@end

@interface OPResponsePackage2940 : OPResponsePackage

@property (nonatomic) int price;            //最新
@property (nonatomic) int open;             //今开
@property (nonatomic) int high;             //最高
@property (nonatomic) int low;              //最低
@property (nonatomic) int volume;           //成交量
@property (nonatomic) int turnover;         //成交额
@property (nonatomic) int sellVolume;       //内盘
@property (nonatomic) int curVolume;        //现手
@property (nonatomic) int average;          //均价
@property (nonatomic) int settlement;       //结算价
@property (nonatomic) int holdVolume;       //持仓
@property (nonatomic) int increment;        //增仓
@property (nonatomic) int volumeRatio;      //量比
@property (nonatomic, strong) NSArray *bidData; //买盘记录
@property (nonatomic, strong) NSArray *askData; //卖盘记录

@end

@interface OPMarketSecurityModel (Initialize)

- (instancetype)initWithStaticData:(OPResponsePackage2939 *)staticData dynamicData:(OPResponsePackage2940 *)dynamicData;

- (void)updateWithStaticData:(OPResponsePackage2939 *)staticData;

- (void)updateWithDynamicData:(OPResponsePackage2940 *)dynamicData;

@end

#pragma mark ---------level2的分时ddx--------------

@interface OPResponsePackageMinuteLevel2 : OPResponsePackage

@property (nonatomic, strong) NSArray *resultArray;

@end

//level2的分时ddx
@interface OPRequestPackage2922 : OPMarketRequestPackage

@property (nonatomic, copy) NSString *code;//代码
@property (nonatomic) int pos;//数据位置

- (instancetype)initWithCode:(NSString *)code pos:(int)pos;

@end

@interface OPResponsePackage2922 : OPResponsePackageMinuteLevel2

@end

//level2的分时成交单数差
@interface OPRequestPackage2923 : OPMarketRequestPackage

@property (nonatomic, copy) NSString *code;//代码
@property (nonatomic) int pos;//数据位置

- (instancetype)initWithCode:(NSString *)code pos:(int)pos;

@end

@interface OPResponsePackage2923 : OPResponsePackageMinuteLevel2

@end

//level2的分时总买总卖量
@interface OPRequestPackage2924 : OPMarketRequestPackage

@property (nonatomic, copy) NSString *code;//代码
@property (nonatomic) int pos;//数据位置

- (instancetype)initWithCode:(NSString *)code pos:(int)pos;

@end

@interface OPResponsePackage2924 : OPResponsePackageMinuteLevel2

@end
