//
//  OPMarketDataUpdaterManager.h
//  OnePiece
//
//  Created by Duanwwu on 2016/12/13.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(uint64_t, OPTrendDataType)
{
    //静态数据部分
    OPTrendData2939,//静态数据
    OPTrendData2974,//个股完整财务数据
    OPTrendData2987,//个股期权行权日和行权价
    OPTrendData2958                         = 1 << 3,//k线除权数据
    
    //动态数据部分
    OPTrendData2940                         = 1 << 5,//动态数据
    OPTrendData2206                         = 1 << 6,//涨跌家数数据
    OPTrendData2955                         = 1 << 7,//个股财务数据
    OPTrendData2994                         = 1 << 8,//A、B或母基金扩展数据
    OPTrendData2997                         = 1 << 9,//港股熔断信息
    
    //分时
    OPTrendData2942                         = 1 << 15,//分时数据
    OPTrendData2965                         = 1 << 16,//涨跌家数走势
    OPTrendData2917                         = 1 << 17,//level2委托队列
    
    //分时买卖盘
    OPTrendData2204                         = 1 << 20,//分时买卖盘
    OPTrendData2915                         = 1 << 21,//level2扩展买卖盘数据
    
    //分时明
    OPTrendData2941                         = 1 << 22,//分时成交数据
    
    //分时level2
    OPTrendData2922                         = 1 << 25,//分时ddx
    OPTrendData2923                         = 1 << 26,//分时成交单差
    OPTrendData2924                         = 1 << 27,//分时总买总卖量
    
    //k线数据
    OPTrendData2944                         = 1 << 30,//K线数据
    OPTrendData2918                         = 1 << 31,//k线DDX数据
    OPTrendData2919                         = 1 << 32,//k线DDY数据
    OPTrendData2920                         = 1 << 33,//k线DDZ数据
    OPTrendData2928                         = 1 << 34,//k线主力资金线数据
    OPTrendData2933                         = 1 << 35,//k线BS点数据
    
    //k线历史分时
    OPTrendData2985                         = 1 << 40,//历史分钟走势数据
};

//typedef NS_OPTIONS(uint64_t, OPTrendDataType)
//{
//    //静态数据部分
//    OPTrendData2939                         = 0,//静态数据
//    OPTrendData2974                         = 1 << 1,//个股完整财务数据
//    OPTrendData2987                         = 1 << 2,//个股期权行权日和行权价
//    OPTrendData2958                         = 1 << 3,//k线除权数据
//    
//    //动态数据部分
//    OPTrendData2940                         = 1 << 5,//动态数据
//    OPTrendData2206                         = 1 << 6,//涨跌家数数据
//    OPTrendData2955                         = 1 << 7,//个股财务数据
//    OPTrendData2994                         = 1 << 8,//A、B或母基金扩展数据
//    OPTrendData2997                         = 1 << 9,//港股熔断信息
//    
//    //分时
//    OPTrendData2942                         = 1 << 15,//分时数据
//    OPTrendData2965                         = 1 << 16,//涨跌家数走势
//    OPTrendData2917                         = 1 << 17,//level2委托队列
//    
//    //分时买卖盘
//    OPTrendData2204                         = 1 << 20,//分时买卖盘
//    OPTrendData2915                         = 1 << 21,//level2扩展买卖盘数据
//    
//    //分时明
//    OPTrendData2941                         = 1 << 22,//分时成交数据
//    
//    //分时level2
//    OPTrendData2922                         = 1 << 25,//分时ddx
//    OPTrendData2923                         = 1 << 26,//分时成交单差
//    OPTrendData2924                         = 1 << 27,//分时总买总卖量
//    
//    //k线数据
//    OPTrendData2944                         = 1 << 30,//K线数据
//    OPTrendData2918                         = 1 << 31,//k线DDX数据
//    OPTrendData2919                         = 1 << 32,//k线DDY数据
//    OPTrendData2920                         = 1 << 33,//k线DDZ数据
//    OPTrendData2928                         = 1 << 34,//k线主力资金线数据
//    OPTrendData2933                         = 1 << 35,//k线BS点数据
//    
//    //k线历史分时
//    OPTrendData2985                         = 1 << 40,//历史分钟走势数据
//};
//
//typedef NS_ENUM(NSUInteger, OPMinuteRightType)
//{
//    OPMinuteRightNone                       = 0,
//    OPMinuteRightPan                        = 1,//盘
//    OPMinuteRightMing                       = 2,//明
//    OPMinuteRightXiang                      = 3,//详
//};
//
//typedef NS_ENUM(NSUInteger, OPMinuteLevel2Type)
//{
//    OPMinuteLevel2None                      = 0,
//    OPMinuteLevel2DDX                       = 1,//分时DDX
//    OPMinuteLevel2Differ                    = 2,//分时单差
//    OPMinuteLevel2Total                     = 3,//分时买卖总量
//};
//
//typedef NS_ENUM(NSUInteger, OPKlineLevel2Type)
//{
//    OPKlineLevel2None                       = 0,
//    OPKlineLevel2DDX                        = 1,//k线DDX
//    OPKlineLevel2DDY                        = 2,//k线DDY
//    OPKlineLevel2DDZ                        = 3,//k线DDZ
//    OPKlineLevel2BS                         = 4,//k线BS
//    OPKlineLevel2Mainmem                    = 5,//k线主力资金线
//};

typedef NS_ENUM(NSUInteger, OPDataUpdateType)
{
    OPDataUpdate,//更新
    OPDataResetUpdate,//重置并更新
    OPDataLoadMore,//加载更多
};

@class OPUpdaterManagerContext;
@class OPMarketSecurityModel;

@protocol OPUpdaterManagerContextDelegate <NSObject>

/**
 * 一组DataUpdater更新数据完成后的回调
 */
- (void)updateCompletedWithContext:(OPUpdaterManagerContext *)context;

@end

/**
 * 数据集合更新上下文
 */
@interface OPUpdaterManagerContext : NSObject

@property (nonatomic, assign) id<OPUpdaterManagerContextDelegate> delegate;

@property (nonatomic, strong) id userInfo;

/**
 * 准备完毕，子类实现，用于发送网络请求
 */
- (void)allReady;

@end

@class OPDataUpdaterBase;

#define kUpdaterDefaultTag      -1

/**
 * 数据更新基类
 */
@interface OPDataUpdaterBase : NSObject

@property (nonatomic) int tag;//对象的tag标记，默认-1

@property (nonatomic, copy) void(^updateCompleted)(id updater);//数据更新完成后回调

@property (nonatomic, strong) OPMarketSecurityModel *securityModel;//证券数据模型

- (instancetype)initWithSecurityModel:(OPMarketSecurityModel *)securityModel;

/**
 * 更新数据，子类实现
 * @param updateType 数据更新类型
 * @param context 数据管理上下文
 */
- (void)updateDataWithType:(OPDataUpdateType)updateType context:(OPUpdaterManagerContext *)context;

/**
 * 数据更新完成以后调用，会进行一些处理，并执行updateCompleted block
 * @param updater 数据集合更新对象
 */
- (void)onReceiveDataComplete:(OPDataUpdaterBase *)updater;

@end

@class OPDataUpdaterManager;

/**
 * 数据更新对象管理类delegate
 */
@protocol OPDataUpdaterManagerDelegate <NSObject>

/**
 * 所有数据更新完成后的回调
 */
- (void)updateCompleted:(OPDataUpdaterManager *)updaterManager context:(OPUpdaterManagerContext *)context;

@end

/**
 * 数据更新对象管理类，对OPDataUpdaterBase对象进行统一管理
 */
@interface OPDataUpdaterManager : NSObject<OPUpdaterManagerContextDelegate>

@property (nonatomic, assign) id<OPDataUpdaterManagerDelegate> delegate;

/**
 * 创建数据管理上下文，每次请求数据的时候会调用此方法创建一个上下文，子类可重载，如：数据使用http，可返回一个管理http请求上下文；数据使用socket，可返回一个socket请求上下文
 * @returns 数据管理上下文
 */
- (OPUpdaterManagerContext *)buildContext;

/**
 * 增加一个数据集合更新对象
 * @param updater 数据集合更新对象
 */
- (void)addDateUpdater:(OPDataUpdaterBase *)updater;

/**
 * 批量增加一个数据集合更新对象
 * @param updaters 数据集合更新对象数组
 */
- (void)addDateUpdaters:(NSArray *)updaters;

/**
 * 移除一个数据集合更新对象
 * @param updater 数据集合更新对象
 */
- (void)removeDateUpdater:(OPDataUpdaterBase *)updater;

/**
 * 批量移除一个数据集合更新对象
 * @param updaters 数据集合更新对象数组
 */
- (void)removeDateUpdaters:(NSArray *)updaters;

/**
 * 根据tag标记移除数据集合更新对象
 * @param tag 标记
 * @returns 是否移除成功
 */
- (BOOL)removeDateUpdaterWithTag:(int)tag;

/**
 * 更新数据
 * @param updateType 数据更新类型
 */
- (void)updateDataWithType:(OPDataUpdateType)updateType;

/**
 * 指定数据集合更新对象更新数据
 * @param updateType 数据更新类型
 * @param updater 数据集合更新对象
 */
- (void)updateDataWithType:(OPDataUpdateType)updateType updater:(OPDataUpdaterBase *)updater;

/**
 * 批量数据集合更新对象更新数据
 * @param updateType 数据更新类型
 * @param updaters 数据集合更新对象数组
 */
- (void)updateDataWithType:(OPDataUpdateType)updateType updaters:(NSArray *)updaters;

@end
