//
//  OPMarketDataModel.h
//  OnePiece
//
//  Created by Duanwwu on 2016/11/7.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import <Foundation/Foundation.h>

//K线类型
typedef NS_ENUM(NSUInteger, OPSecurityKlineType)
{
    OPSecurityKlineNone              = 0x00,
    OPSecurityKlineMin1              = 0x01,
    OPSecurityKlineMin5              = 0x02,
    OPSecurityKlineMin15             = 0x03,
    OPSecurityKlineMin30             = 0x04,
    OPSecurityKline60                = 0x05,
    OPSecurityKline240               = 0x06,
    OPSecurityKlineDay               = 0x07,
    OPSecurityKlineWeek              = 0x08,
    OPSecurityKlineMonth             = 0x09,
    OPSecurityKlineSeason            = 0x0A,
    OPSecurityKlineHalfYear          = 0x0B,
    OPSecurityKlineYear              = 0x0C,
};

//品种类型
typedef NS_ENUM(NSUInteger, OPSecurityType)
{
    OPSecurityINDEX                 = 0,//指数
    OPSecuritySTOCK                 = 1,//股票
    OPSecurityFUND                  = 2,//基金
    OPSecurityBOND                  = 3,//债券
    OPSecurityOTHERSTOCK            = 4,//其它股票
    OPSecurityOPTION                = 5,//选择权
    OPSecurityEXCHANGE              = 6,//外汇
    OPSecurityFUTURE                = 7,//期货
    OPSecurityFTRIDX                = 8,//期指
    OPSecurityRGZ                   = 9,//认购证
    OPSecurityETF                   = 10,//ETF
    OPSecurityLOF                   = 11,//LOF
    OPSecurityCOVBOND               = 12,//可转债
    OPSecurityTRUST                 = 13,//信托
    OPSecurityWARRANT               = 14,//权证
    OPSecurityREPO                  = 15,//回购
    OPSecuritySTOCKB                = 16,//B股
    OPSecurityCOMM                  = 17,//商品现货
    OPSecurityENTRY                 = 18,//入库
    OPSecurityGFUNDA                = 27,//分级A基金
    OPSecurityGFUNDB                = 28,//分级B基金
    OPSecurityGFUND                 = 29,//分级母基金
    OPSecurityUNKNOWN               = -1,//不清楚类型时使用
};

//市场类型
typedef NS_ENUM(NSUInteger, OPSecurityMarketType)
{
    OPSecurityMarketUNKNOWN         = 0,//未知市场
    OPSecurityMarketSH              = 1,//上海
    OPSecurityMarketSZ              = 2,//深圳
    OPSecurityMarketHK              = 3,//香港
    OPSecurityMarketIX              = 4,//全球指数
    OPSecurityMarketCK              = 5,//全球期货
    OPSecurityMarketFE              = 6,//外汇
    OPSecurityMarketOF              = 7,//开放基金
    OPSecurityMarketBI              = 8,//板块指数
    OPSecurityMarketSF              = 9,//上海金融期货（股指期货）
    OPSecurityMarketSC              = 10,//上海期货
    OPSecurityMarketZC              = 11,//郑州期货
    OPSecurityMarketDC              = 12,//大连期货
    OPSecurityMarketSG              = 13,//上海黄金
    OPSecurityMarketSO              = 14,//三板市场
    OPSecurityMarketZH              = 15,//B转H股
    OPSecurityMarketOP              = 16,//期权市场
    OPSecurityMarketHKT             = 17,//港股通
    OPSecurityMarketUS              = 18,//美股
};

//除权标记
typedef NS_ENUM(NSUInteger, OPEXRightsType)
{
    OPEXRightsER                = 0,//除权
    OPEXRightsAfter             = 1,//后复权
    OPEXRightsBefore            = 2,//前复权
};

//分时level2指标类型
typedef NS_ENUM(NSUInteger, OPMinuteLevel2Type)
{
    OPMinuteLevel2DDX,//分时ddx
    OPMinuteLevel2TotalAskBid,//分时总买总卖量
    OPMinuteLevel2OrderDiffer,//分时成交单数差
};

//证券标记
typedef NS_ENUM(NSUInteger, DZHSecurityFlag)
{
    DZHSecurityFlagNone,
    DZHSecurityFlagRong,                //融资融券
    DZHSecurityFlagXGMBond,             //小公募债券
    DZHSecurityFlagXSBBasic,            //新三板基础
    DZHSecurityFlagXSBInnovate,         //新三板创新
    DZHSecurityFlagFusing,              //熔断标记
    DZHSecurityFlagSHHKConnect,         //沪港通
    DZHSecurityFlagSZHKConnect,         //深港通
};

/**
 * 通过股票代码前缀获取市场类型
 * @returns 市场类型
 */
static inline OPSecurityMarketType marketTypeFromCodePrefix(const char *market)
{
    if (market == NULL) return OPSecurityMarketUNKNOWN;
    else if (strcmp(market, "SH") == 0)     // 沪市
        return OPSecurityMarketSH;
    else if (strcmp(market, "SZ") == 0)     // 深市
        return OPSecurityMarketSZ;
    else if (strcmp(market, "HK") == 0)     // 港股
        return OPSecurityMarketHK;
    else if (strcmp(market, "IX") == 0)     // 全球指数
        return OPSecurityMarketIX;
    else if (strcmp(market, "CK") == 0)     // 全球期货
        return OPSecurityMarketCK;
    else if (strcmp(market, "FE") == 0 || strcmp(market, "IB") == 0 )     // 外汇   -- IB*** 人民币中间价
        return OPSecurityMarketFE;
    else if (strcmp(market, "OF") == 0)     // 开放基金
        return OPSecurityMarketOF;
    else if (strcmp(market, "BI") == 0)     // 板块
        return OPSecurityMarketBI;
    else if (strcmp(market, "SF") == 0)		// 股指期货
        return OPSecurityMarketSF;
    else if (strcmp(market, "SC") == 0)		// 上海期货
        return OPSecurityMarketSC;
    else if (strcmp(market, "ZC") == 0)		// 郑州期货
        return OPSecurityMarketZC;
    else if (strcmp(market, "DC") == 0)		// 大连期货
        return OPSecurityMarketDC;
    else if (strcmp(market, "SG") == 0)		// 上海黄金
        return OPSecurityMarketSG;
    else if (strcmp(market, "SO") == 0)		// 三板市场
        return OPSecurityMarketSO;
    else if (strcmp(market, "ZH") == 0)		// B转H股
        return OPSecurityMarketZH;
    else if (strcmp(market, "HH") == 0)		// 港股通
        return OPSecurityMarketHKT;
    else if (strcmp(market, "NS") == 0||strcmp(market, "NY") == 0)		// 美股
        return OPSecurityMarketUS;
    else
        return OPSecurityMarketUNKNOWN;
}

//证券数据模型
@interface OPMarketSecurityModel : NSObject

/**基础数据*/
@property (nonatomic, copy) NSString *code;         //代码
@property (nonatomic, strong) NSString *briefCode;  //简略代码，去掉市场前缀
@property (nonatomic, strong) NSString *name;       //名称
@property (nonatomic) short decimal;                //价格位数
@property (nonatomic) int lastClose;                //昨收
@property (nonatomic) int price;                    //最新价
@property (nonatomic) OPSecurityType securityType;  //股票类型
@property (nonatomic) OPSecurityMarketType marketType;//市场类型
@property (nonatomic) DZHSecurityFlag securityFlag; //证券标记

/**静态数据*/
@property (nonatomic) short volumeUnit;//成交量单位，即每手股数
@property (nonatomic) float limitup;//涨停
@property (nonatomic) float limitdown;//跌停
@property (nonatomic) long long circulationEquity;//流通盘
@property (nonatomic) long long totalEquity;//总股本
@property (nonatomic) int tradeUnit;//交易量单位，主要用于港股的委托使用的交易量，对其它市场该数值和成交量单位相同

/**动态数据*/
@property (nonatomic) float open;//今开
@property (nonatomic) int high;//最高
@property (nonatomic) int low;//最低
@property (nonatomic) long long volume;//成交量 也叫总手
@property (nonatomic) int turnover;//成交金额(总额)
@property (nonatomic) int sellVolume;//内盘
@property (nonatomic) int buyVolume;//外盘
@property (nonatomic) int curVolume;//现手
@property (nonatomic) float average;//均价
@property (nonatomic) float volumeRatio;//量比
@property (nonatomic) long long circulation;//流通值
@property (nonatomic) long long total;//总市值

/**财务数据*/
@property (nonatomic) float PERatio;//市盈率
@property (nonatomic) float PBRatio;//市净率
@property (nonatomic) float weibi;//委比

/**涨跌家数数据*/
@property (nonatomic) float weightedAverage;/**加权均价*/
@property (nonatomic) int riseCount;/**上涨家数*/
@property (nonatomic) int flatCount;/**平盘家数*/
@property (nonatomic) int fallCount;/**下跌家数*/

/**分级基金数据*/
@property (nonatomic) float premium;//整体溢价
@property (nonatomic) float baseNet;//母基实时净值
@property (nonatomic) float discount;//上折母基需涨
@property (nonatomic) float foldDown;//下折母基需跌
@property (nonatomic) float impliedIncome;//隐含收益
@property (nonatomic) float priceLever;//价格杠杆

/**期货数据*/
@property (nonatomic) float bidPrice;//卖出价
@property (nonatomic) int bidVolume;//卖出量
@property (nonatomic) float askPrice;//买入价
@property (nonatomic) int askVolume;//买入量
@property (nonatomic) int holdVolume;//持仓
@property (nonatomic) int increment;//增仓
@property (nonatomic) int dayIncrement;//日增
@property (nonatomic) float settlement;//结算
@property (nonatomic) float lastSettlement;//昨结算价
@property (nonatomic) float lastPosition;//昨日持仓
@property (nonatomic) int executeDay;//行权日
@property (nonatomic) float executePrice;//行权价

@property (nonatomic, strong) NSArray *bidData; //买盘记录
@property (nonatomic, strong) NSArray *askData; //卖盘记录

@end

//行情列表数据项
@interface OPMarketListItem : OPMarketSecurityModel

@property (nonatomic) short boardID;            //请求板块指数成分股的id
@property (nonatomic) int updateTime;           //动态数据时间
@property (nonatomic) short turnoverRate;       //换手率
@property (nonatomic) int mineTime;             //信息地雷时间
@property (nonatomic) short speedUp;            //涨速           short×10000

@property (nonatomic) char noteCount;           //公告数目       byte 0表示无

@property (nonatomic) int syRatio;              //市盈率	  int×100  有正负号
@property (nonatomic) int sjRatio;              //市净率	  int×100  有正负号

@property (nonatomic) int sellOne;              //卖一		  int
@property (nonatomic) int buyOne;               //买一		  int

@property (nonatomic) int riseRate7;            //7日涨幅	  int×10000  有正负号
@property (nonatomic) int turnoverRate7;        //7日换手	  int×10000
@property (nonatomic) int riseRate30;           //30日涨幅	  int×10000  有正负号
@property (nonatomic) int turnoverRate30;       //30日换手	  int×10000

@property (nonatomic) short ddx;                //当日ddx	  short×1000  有正负号
@property (nonatomic) short ddy;                //当日ddy	  short×1000  有正负号
@property (nonatomic) int ddz;                  //当日ddz	  int×1000  有正负号
@property (nonatomic) int ddx60Days;            //60日ddx	  int×1000  有正负号
@property (nonatomic) int ddy60Days;            //60日ddy	  int×1000  有正负号
@property (nonatomic) char ddx10DaysRiseNum;    //10日ddx红色的天数 char
@property (nonatomic) char ddx10DaysConitunedNum; //10日ddx连续红色数 char

@property (nonatomic) int fundIn;               //当日资金流入
@property (nonatomic) int fundOut;              //当日资金流出
@property (nonatomic) int fundIn5;              //5日资金流入
@property (nonatomic) int fundOut5;             //5日资金流出
@property (nonatomic) int fundAmount5;          //5日资金成交额
@property (nonatomic) int fundIn30;             //30日资金流入
@property (nonatomic) int fundOut30;            //30日资金流出
@property (nonatomic) int fundAmount30;         //30日资金成交额

@property (nonatomic) unsigned short mainBuyOrder;  // 机构买单数       short  //无符号
@property (nonatomic) unsigned short mainSellOrder; // 机构卖单数       short  //无符号
@property (nonatomic) unsigned short mainBuyDeal;   // 机构吃货数       short  //无符号
@property (nonatomic) unsigned short mainSellDeal;  // 机构吐货数       short  //无符号
@property (nonatomic) int mainBuyAmount;            // 机构吃货量       int
@property (nonatomic) int mainSellAmount;           // 机构吐货量       int

@end

//证券时间分割数据模型，如分时、k线，一个时间周期对应一个OPSecurityTimeModel数据集合
@interface OPSecurityTimeModel : NSObject

@property (nonatomic) int time;//日期
@property (nonatomic) int openPrice;//开盘价
@property (nonatomic) int highPrice;//最高价
@property (nonatomic) int lowPrice;//最低价
@property (nonatomic) int closePrice;//收盘价
@property (nonatomic) int average;//均价
@property (nonatomic) int volume;//成交量
@property (nonatomic) long long totalVolume;//截止当前时间总的成交量
@property (nonatomic) int turnover;//成交额
@property (nonatomic) int holdVol;//持仓量

@end

//量价信息
@interface OPMarketAskBidInfoModel : NSObject

@property (nonatomic) int time;             // 买卖时间
@property (nonatomic) int price;            // 买卖价
@property (nonatomic) int volume;           // 买卖量

@end

//DDX
@interface OPSecurityDDXModel : NSObject

@property (nonatomic) int ddxSum;
@property (nonatomic) int ddx;

@end

//分时买卖总量
@interface OPSecurityTotalAskBidModel : NSObject

@property (nonatomic) int totalBid;//总买
@property (nonatomic) int totalAsk;//总卖

@end
