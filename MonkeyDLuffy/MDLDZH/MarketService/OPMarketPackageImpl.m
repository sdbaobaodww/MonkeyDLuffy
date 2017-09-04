//
//  OPMarketPackageImpl.m
//  OnePiece
//
//  Created by Duanwwu on 16/10/25.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPMarketPackageImpl.h"
#import "OPConstant.h"
#import "NSMutableData+SerializeOperation.h"
#import "NSData+SerializeOperation.h"
#import "OPMarketDataModel.h"
#import "dzhbitstream.h"

#pragma mark ------------初始信息 type=1000 ---------------

@implementation OPRequestPackage1000

- (instancetype)initWithVersion:(NSString *)version deviceID:(NSString *)deviceId deviceType:(NSString *)deviceType
{
    //务必使1000请求的tag为'{'，否则使用HTTP协议往调度服务器发送1000请求会有问题
    if (self = [super initWithHeader:[[OPPackageHeader alloc] initWithTag:'{' type:1000 attrs:0] response:[[OPResponsePackage1000 alloc] init]])
    {
        self.version                    = version;
        self.deviceID                   = deviceId;
        self.deviceType                 = deviceType;
        self.paymentFlag                = 0;
        self.carrier                    = 0;
        self.serverList                 = @[@(1)];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithVersion:[OPConstant versionNumber] deviceID:[OPConstant deviceId] deviceType:TerminalId];
}

- (NSData *)serializeBody
{
    NSMutableData *body                 = [[NSMutableData alloc] init];
    [body so_writeString:self.version];
    [body so_writeString:self.deviceID];
    [body so_writeString:self.deviceType];
    
    [body so_writeChar:self.paymentFlag];
    [body so_writeChar:self.carrier];
    
    [body so_writeUnsignedShort:[self.serverList count]];
    for (NSNumber *number in self.serverList)
    {
        [body so_writeInt:[number intValue]];
    }
    return body;
}

@end

@implementation OPResponsePackage1000

- (void)deSerialize:(NSData *)body
{
    int pos                             = 0;
    self.hqServerAddresses              = [body so_readStringArray:&pos];
    self.wtServerAddresses              = [body so_readStringArray:&pos];
    self.noticeText                     = [body so_readString:&pos];
    self.recentVersionNum               = [body so_readString:&pos];
    self.downloadAddress                = [body so_readString:&pos];
    self.isAlertUpdate                  = [body so_readChar:&pos];
    self.isForceUpdate                  = [body so_readChar:&pos];
    self.isAlertLogin                   = [body so_readChar:&pos];
    self.carrierIP                      = [body so_readChar:&pos];
    self.uploadLogInterval              = [body so_readShort:&pos];
    self.updateNotice                   = [body so_readString:&pos];
    self.noticeCRC                      = [body so_readShort:&pos];
    self.noticeType                     = [body so_readChar:&pos];
    self.scheduleAddresses              = [body so_readStringArray:&pos];
    
    short count                         = [body so_readUnsignedShort:&pos];
    if (count > 0)
    {
        NSMutableDictionary *dic        = [[NSMutableDictionary alloc] initWithCapacity:count];
        int serviceId                   = 0;
        NSArray *serviceArray           = nil;
        for (short i = 0; i < count; i ++)
        {
            serviceId                   = [body so_readInt:&pos];
            serviceArray                = [body so_readStringArray:&pos];
            if ([serviceArray count] > 0)
                [dic setObject:serviceArray forKey:@(serviceId)];
        }
        self.serverDict                 = dic;
    }
}

@end

#pragma mark -----------连接会话心跳 type=2925-------------

@implementation OPRequestPackage2925

- (instancetype)initWithSessionId:(long long)sessionid
{
    if (self = [super initWithHeader:[[OPPackageHeader alloc] initWithType:2925] response:nil])
    {
        self.sessionid                  = sessionid;
        self.ignorResponse              = YES;
    }
    return self;
}

- (NSData *)serializeBody
{
    NSMutableData *body                 = [[NSMutableData alloc] init];
    [body so_writeInt64:self.sessionid];
    return body;
}

@end

#pragma mark -----------服务器当前时间，该接口客户端用来同步时间 type=2963-------------

@implementation OPRequestPackage2963

- (instancetype)init
{
    if (self = [super initWithHeader:[[OPPackageHeader alloc] initWithType:2963] response:[[OPResponsePackage2963 alloc] init]])
    {
        
    }
    return self;
}

@end

@implementation OPResponsePackage2963

- (void)deSerialize:(NSData *)body
{
    int pos                             = 0;
    self.year                           = [body so_readShort:&pos];
    self.month                          = [body so_readChar:&pos];
    self.day                            = [body so_readChar:&pos];
    self.hour                           = [body so_readChar:&pos];
    self.minute                         = [body so_readChar:&pos];
    self.second                         = [body so_readChar:&pos];
}

@end

#pragma mark -----------请求服务器端特定信息 type=2986-------------

@implementation OPRequestPackage2986

- (instancetype)initWithMask:(int)mask
{
    if (self = [super initWithHeader:[[OPPackageHeader alloc] initWithType:2986] response:[[OPResponsePackage2986 alloc] init]])
    {
        self.mask                       = mask;
    }
    return self;
}

- (NSData *)serializeBody
{
    NSMutableData *body                 = [[NSMutableData alloc] init];
    [body so_writeInt:self.mask];
    return body;
}

@end

@implementation OPResponsePackage2986

- (void)deSerialize:(NSData *)body
{
    int pos                             = 0;
    self.mask                           = [body so_readInt:&pos];
    self.sessionid                      = [body so_readInt64:&pos];
}

@end

#pragma mark -----------设置证券推送证券信息 type=2978-------------

@implementation OPRequestPackage2978

- (instancetype)initWithProductPush:(short)productId
                             filed1:(int)fieldType1
                             field2:(int)fieldType2
                           sortType:(char)sortType
                          sortField:(char)sortField
                           beginPos:(short)beginPos
                             reqNum:(short)reqNum
{
    if (self = [super initWithHeader:[[OPPackageHeader alloc] initWithType:2978] response:[[OPResponsePackage2978 alloc] init]])
    {
        self.infoType                   = 1;
        self.fieldType1                 = fieldType1;
        self.fieldType2                 = fieldType2;
        self.sortType                   = sortType;
        self.sortField                  = sortField;
        self.beginPos                   = beginPos;
        self.reqNum                     = reqNum;
    }
    return self;
}

- (instancetype)initWithCodes:(NSArray *)codes
                       filed1:(int)fieldType1
                       field2:(int)fieldType2
{
    if (self = [super initWithHeader:[[OPPackageHeader alloc] initWithType:2978] response:[[OPResponsePackage2978 alloc] init]])
    {
        self.infoType                   = 2;
        self.fieldType1                 = fieldType1;
        self.fieldType2                 = fieldType2;
        self.codes                      = codes;
    }
    return self;
}

- (instancetype)init
{
    if (self = [super initWithHeader:[[OPPackageHeader alloc] initWithType:2978] response:[[OPResponsePackage2978 alloc] init]])
    {
        self.infoType                   = 0;
    }
    return self;
}

- (NSData *)serializeBody
{
    NSMutableData *body                 = [[NSMutableData alloc] init];
    if (self.infoType == 0)
    {
        [body so_writeChar:0];
    }
    else if (self.infoType == 1)
    {
        [body so_writeChar:1];
        [body so_writeInt:self.fieldType1];
        [body so_writeInt:self.fieldType2];
        
        [body so_writeShort:self.productId];
        [body so_writeChar:self.sortType];
        [body so_writeChar:self.sortField];
        [body so_writeShort:self.beginPos];
        [body so_writeShort:self.reqNum];
    }
    else if (self.infoType == 2)
    {
        [body so_writeChar:2];
        [body so_writeInt:self.fieldType1];
        [body so_writeInt:self.fieldType2];
        
        [body so_writeShort:[self.codes count]];
        for (NSString *code in self.codes)
        {
            [body so_writeString:code];
        }
    }
    return body;
}

@end

@implementation OPResponsePackage2978

- (void)deSerialize:(NSData *)body
{
    int pos                             = 0;
    int fields                          = [body so_readInt:&pos];//推送返回的字段
    self.pushProperty                   = fields;
    self.total                          = [body so_readShort:&pos]; // 该分类证券总数
    short count                         = [body so_readShort:&pos];//对个股列表推送返回的是设置的个数；对商品列表返回的是该id分类总数目
    NSMutableArray *arr                 = [[NSMutableArray alloc] initWithCapacity:count];
    OPMarketListItem *item              = nil;
    for (int i = 0; i < count; i ++)
    {
        item                            = [[OPMarketListItem alloc] init];
        item.code                       = [body so_readString:&pos];
        if ((fields & 0x0001) == 1)
            item.name                   = [body so_readString:&pos]; // 名称
        
        if (((fields >> 1) & 0x0001) == 1)
        {
            item.marketType             = [body so_readChar:&pos]; // 类型
            item.decimal                = [body so_readChar:&pos]; // 价格位数
        }
        if (((fields >> 2) & 0x0001) == 1)
            item.volumeUnit             = [body so_readShort:&pos]; // 成交量单位
        if (((fields >> 3) & 0x0001) == 1)
            item.circulationEquity      = [body so_readInt:&pos]; // 流通股本
        if (((fields >> 4) & 0x0001) == 1)
            item.totalEquity            = [body so_readInt:&pos]; // 总股本
        if (((fields >> 5) & 0x0001) == 1)
            item.lastClose              = [body so_readInt:&pos]; // 昨收
        if (((fields >> 6) & 0x0001) == 1)
        {
            item.limitup                = [body so_readInt:&pos]; // 涨停价
            item.limitdown              = [body so_readInt:&pos]; // 跌停价
        }
        if (((fields >> 7) & 0x0001) == 1)
            item.lastSettlement         = [body so_readInt:&pos]; // 昨日结算价
        if (((fields >> 8) & 0x0001) == 1)
            item.lastPosition           = [body so_readInt:&pos]; // 昨日持仓量
        if (((fields >> 9) & 0x0001) == 1)
            item.updateTime             = [body so_readInt:&pos]; // 动态数据时间
        if (((fields >> 10) & 0x0001) == 1)
            item.open                   = [body so_readInt:&pos]; // 开盘
        if (((fields >> 11) & 0x0001) == 1)
        {
            item.high                   = [body so_readInt:&pos]; // 最高
            item.low                    = [body so_readInt:&pos]; // 最低
        }
        if (((fields >> 12) & 0x0001) == 1)
            item.price                  = [body so_readInt:&pos]; // 最新价
        if (((fields >> 13) & 0x0001) == 1)
            item.average                = [body so_readInt:&pos]; // 均价
        if (((fields >> 14) & 0x0001) == 1)
            item.volume                 = [body so_readExpandInt:&pos]; // 成交量
        if (((fields >> 15) & 0x0001) == 1)
            item.curVolume              = [body so_readInt:&pos]; // 现手
        if (((fields >> 16) & 0x0001) == 1)
            item.turnover               = [body so_readInt:&pos]; // 成交额
        if (((fields >> 17) & 0x0001) == 1)
            item.sellVolume             = [body so_readInt:&pos]; // 内盘
        if (((fields >> 18) & 0x0001) == 1)
            item.holdVolume             = [body so_readInt:&pos]; // 持仓量
        if (((fields >> 19) & 0x0001) == 1)
            item.settlement             = [body so_readInt:&pos]; // 结算价
        
        int position                    = 20;
        NSMutableArray *asks            = [[NSMutableArray alloc] init];
        NSMutableArray *bids            = [[NSMutableArray alloc] init];
        OPMarketAskBidInfoModel *bid    = nil;
        OPMarketAskBidInfoModel *ask    = nil;
        while ((((fields >> position) & 0x0001) == 1) && position < 30)
        {
            bid                         = [[OPMarketAskBidInfoModel alloc] init];
            ask                         = [[OPMarketAskBidInfoModel alloc] init];
            
            ask.price                   = [body so_readInt:&pos];  // 卖价
            bid.price                   = [body so_readInt:&pos];  // 买价
            position++;
            
            if (((fields >> position) & 0x0001) == 1)
            {
                ask.volume              = [body so_readInt:&pos];  // 卖量
                bid.volume              = [body so_readInt:&pos];  // 买量
            }
            position++;
            
            [asks addObject:ask];
            [bids addObject:bid];
        }
        
        if ([asks count] > 0)
            item.askData                = asks;
        if ([bids count] > 0)
            item.bidData                = bids;
        
        if (((fields >> 30) & 0x0001) == 1)
        {
            char lending                = [body so_readChar:&pos]; // 融资融券标记
            if (lending == 1)
            {
                item.securityFlag       = DZHSecurityFlagRong;
            }
        }
        if (((fields >> 31) & 0x0001) == 1)
            item.mineTime               = [body so_readInt:&pos];   // 信息地雷时间
        
        [arr addObject:item];
    }
    self.resultArray                    = arr;
}

@end

#pragma mark ---------证券分钟走势数据 type=2942--------------

@implementation OPRequestPackage2942

- (instancetype)initWithCode:(NSString *)code beginPos:(short)beginPos
{
    if (self = [super initWithHeader:[[OPPackageHeader alloc] initWithType:2942 attrs:2] response:[[OPResponsePackage2942 alloc] init]])
    {
        self.code                       = code;
        self.beginPos                   = beginPos;
    }
    return self;
}

- (NSData *)serializeBody
{
    NSMutableData *body                 = [[NSMutableData alloc] init];
    [body so_writeString:self.code];
    [body so_writeShort:self.beginPos];
    return body;
}

@end

@implementation OPResponsePackage2942

- (void)deSerialize:(NSData *)body
{
    int pos                             = 0;
    unsigned short attrs                = [(OPPackageHeader *)self.header attrs];
    NSData *tempData                    = body;
    if (attrs & 0x0002)//压缩数据
    {
        NSMutableArray *marketTimes     = [NSMutableArray array];
        tempData                        = [self decompressionData:body marketTimes:marketTimes totalNum:&_totalNum];
        self.marketTimes                = marketTimes;
    }
    BOOL holdTag                        = [tempData so_readChar:&pos];//持仓标记
    self.holdTag                        = holdTag;
    self.mineCount                      = [tempData so_readChar:&pos];
    self.starVal                        = [tempData so_readChar:&pos];
    self.pos                            = [tempData so_readShort:&pos];
    short count                         = [tempData so_readUnsignedShort:&pos];
    NSMutableArray *arr                 = [[NSMutableArray alloc] initWithCapacity:count];
    OPSecurityTimeModel *item           = nil;
    for (int i = 0; i < count; i++)
    {
        item                            = [[OPSecurityTimeModel alloc] init];
        item.time                       = [tempData so_readInt:&pos];
        item.closePrice                 = [tempData so_readInt:&pos];
        item.totalVolume                = [tempData so_readInt:&pos];
        item.average                    = [tempData so_readInt:&pos];
        if (holdTag)
            item.holdVol                = [tempData so_readInt:&pos];
        [arr addObject:item];
    }
    self.minutes                        = arr;
}

- (NSData *)decompressionData:(NSData *)data marketTimes:(NSMutableArray *)marketTimes totalNum:(unsigned short *)totalNum
{
    char *pbody                         = (char *)[data bytes];
    unsigned short exlen                = 1024 * 10;
    char *presult                       = (char *)calloc(exlen, 1);
    
    MARKETTIME* pMarketTimes            = NULL;
    decompressMinData(pbody, [data length], presult, &exlen, totalNum, &pMarketTimes);
    
    if (exlen == 0)
    {
        free(presult);
        return nil;
    }
    
    if (pMarketTimes && (pMarketTimes->m_nNum > 0))
    {
        for (int i = 0; i < pMarketTimes->m_nNum && i < 8; i++)
        {
            OPMarketTimes *times        = [[OPMarketTimes alloc] init];
            times.openTime              = pMarketTimes->m_TradeTime[i].m_wOpen;
            times.endTime               = pMarketTimes->m_TradeTime[i].m_wEnd;
            [marketTimes addObject:times];
        }
    }
    NSData *tempData                    = [[NSData alloc] initWithBytes:presult length:exlen];
    free(presult);
    presult                             = NULL;
    return tempData;
}

@end

@implementation OPMarketTimes

- (NSString *)description
{
    return [NSString stringWithFormat:@"开盘:%d 休盘:%d", self.openTime, self.endTime];
}

@end

#pragma mark ---------K线数据 type=2944--------------

@implementation OPRequestPackage2944

- (instancetype)initWithCode:(NSString *)code
                   klineType:(OPSecurityKlineType)klineType
                     endDate:(int)endDate
                      reqNum:(unsigned short)reqNum
                    exRights:(OPEXRightsType)exRights
{
    if (self = [super initWithHeader:[[OPPackageHeader alloc] initWithType:2944 attrs:2] response:[[OPResponsePackage2944 alloc] init]])
    {
        self.code                       = code;
        self.klineType                  = klineType;
        self.endDate                    = endDate;
        self.reqNum                     = reqNum;
        self.exRights                   = exRights;
    }
    return self;
}

- (NSData *)serializeBody
{
    NSMutableData *body                  = [[NSMutableData alloc] init];
    [body so_writeString:self.code];
    [body so_writeChar:self.klineType];
    [body so_writeInt:self.endDate];
    [body so_writeShort:self.reqNum];
    [body so_writeChar:self.exRights];
    return body;
}

@end

@implementation OPResponsePackage2944

- (void)deSerialize:(NSData *)body
{
    int pos                             = 0;
    unsigned short attrs                = [(OPPackageHeader *)self.header attrs];
    NSData *tempData                    = body;
    if (attrs & 0x0002)//压缩数据
    {
        tempData                        = [self decompressionData:body];
    }
    
    BOOL holdTag                        = [tempData so_readChar:&pos];//持仓标记
    self.holdTag                        = holdTag;
    short count                         = [tempData so_readUnsignedShort:&pos];
    NSMutableArray *arr                 = [[NSMutableArray alloc] initWithCapacity:count];
    OPSecurityTimeModel *item           = nil;
    for (int i = 0; i < count; i++)
    {
        item                            = [[OPSecurityTimeModel alloc] init];
        item.time                       = [tempData so_readInt:&pos];
        item.openPrice                  = [tempData so_readInt:&pos];
        item.highPrice                  = [tempData so_readInt:&pos];
        item.lowPrice                   = [tempData so_readInt:&pos];
        item.closePrice                 = [tempData so_readInt:&pos];
        item.volume                     = [tempData so_readInt:&pos];
        item.turnover                   = [tempData so_readInt:&pos];
        if (holdTag)
            item.holdVol                = [tempData so_readInt:&pos];
        [arr addObject:item];
    }
    self.klines                         = arr;
}

- (NSData *)decompressionData:(NSData *)data
{
    char *pbody                         = (char *)[data bytes];
    unsigned short exlen                = 1024 * 10;
    char *presult                       = (char *)calloc(exlen, 1);
    
    decompressKlineData(pbody, [data length], presult, &exlen);
    
    if (exlen == 0)
    {
        free(presult);
        return nil;
    }
    
    NSData *tempData                    = [[NSData alloc] initWithBytes:presult length:exlen];
    free(presult);
    presult                             = NULL;
    return tempData;
}

@end

@implementation OPRequestPackage2985

- (instancetype)initWithCode:(NSString *)code
                      offset:(char)offset
                      stride:(int)stride
                        mask:(char)mask
                         pos:(short)pos
                      reqNum:(short)reqNum
{
    if (self = [super initWithHeader:[[OPPackageHeader alloc] initWithType:2985 attrs:2] response:[[OPResponsePackage2985 alloc] init]])
    {
        self.code                       = code;
        self.offset                     = offset;
        self.stride                     = stride;
        self.mask                       = mask;
        self.pos                        = pos;
        self.reqNum                     = reqNum;
    }
    return self;
}

- (NSData *)serializeBody
{
    NSMutableData *body                  = [[NSMutableData alloc] init];
    [body so_writeString:self.code];
    [body so_writeChar:self.offset];
    [body so_writeChar:self.stride];
    [body so_writeChar:self.mask];
    [body so_writeShort:self.pos];
    [body so_writeShort:self.reqNum];
    return body;
}

@end

@implementation OPResponsePackage2985

- (void)deSerialize:(NSData *)body
{
    int pos                             = 0;
    unsigned short attrs                = [(OPPackageHeader *)self.header attrs];
    NSData *tempData                    = body;
    if (attrs & 0x0002)//压缩数据
    {
        NSMutableArray *marketTimes     = [NSMutableArray array];
        tempData                        = [self decompressionData:body marketTimes:marketTimes totalNum:&_totalNum];
        self.marketTimes                = marketTimes;
    }
    
    self.stride                         = [tempData so_readChar:&pos];//数据间隔
    char mask                           = [tempData so_readChar:&pos];//走势数据掩码
    self.mask                           = mask;
    self.pos                            = [tempData so_readShort:&pos];//数据位置
    short count                         = [tempData so_readUnsignedShort:&pos];
    
    NSMutableArray *arr                 = [[NSMutableArray alloc] initWithCapacity:count];
    OPSecurityTimeModel *item           = nil;
    for (int i = 0; i < count; i++)
    {
        item                            = [[OPSecurityTimeModel alloc] init];
        if (mask & 0x01)
            item.time                   = [tempData so_readInt:&pos];
        item.closePrice                 = [tempData so_readInt:&pos];
        if (mask & 0x02)
            item.volume                 = [tempData so_readInt:&pos];
        if (mask & 0x04)
            item.average                = [tempData so_readInt:&pos];
        if (mask & 0x08)
            item.holdVol                = [tempData so_readInt:&pos];
        [arr addObject:item];
    }
    self.minutes                        = arr;
}

- (NSData *)decompressionData:(NSData *)data marketTimes:(NSMutableArray *)marketTimes totalNum:(unsigned short *)totalNum
{
    char *pbody                         = (char *)[data bytes];
    unsigned short exlen                = 1024 * 10;
    char *presult                       = (char *)calloc(exlen, 1);
    
    MARKETTIME* pMarketTimes            = NULL;
    decompressKlineHisMinData(pbody, [data length], presult, &exlen, totalNum, &pMarketTimes);
    
    if (exlen == 0)
    {
        free(presult);
        return nil;
    }
    
    if (pMarketTimes && (pMarketTimes->m_nNum > 0))
    {
        for (int i = 0; i < pMarketTimes->m_nNum && i < 8; i++)
        {
            OPMarketTimes *times        = [[OPMarketTimes alloc] init];
            times.openTime              = pMarketTimes->m_TradeTime[i].m_wOpen;
            times.endTime               = pMarketTimes->m_TradeTime[i].m_wEnd;
            [marketTimes addObject:times];
        }
    }
    NSData *tempData                    = [[NSData alloc] initWithBytes:presult length:exlen];
    free(presult);
    presult                             = NULL;
    return tempData;
}

@end

#pragma mark ---------证券静态数据 type=2939--------------

@implementation OPRequestPackage2939

- (instancetype)initWithCode:(NSString *)code
{
    if (self = [super initWithHeader:[[OPPackageHeader alloc] initWithType:2939] response:nil])
    {
        self.code                       = code;
    }
    return self;
}

- (BOOL)responseMatch:(OPPackageHeader *)responseHeader
{
    return self.header.packageId == responseHeader.packageId ||
    (responseHeader.type == 2943 && ((OPPackageHeader *)self.header).tag == responseHeader.tag);
}

- (void)generateResponsePackage:(OPPackageHeader *)responseHeader
{
    self.response                       = responseHeader.type == 2939 ? [[OPResponsePackage2939 alloc] init] : [[OPResponsePackage2943 alloc] init];
}

- (NSData *)serializeBody
{
    NSMutableData *body                  = [[NSMutableData alloc] init];
    [body so_writeString:self.code];
    return body;
}

@end

@implementation OPResponsePackage2939

- (void)deSerialize:(NSData *)body
{
    int pos                             = 0;
    self.code                           = [body so_readString:&pos];
    self.name                           = [body so_readString:&pos];
    OPSecurityType securityType         = [body so_readChar:&pos];
    self.securityType                   = securityType;
    self.decimal                        = [body so_readChar:&pos];
    self.volumeUnit                     = [body so_readShort:&pos];
    self.lastClose                      = [body so_readInt:&pos];
    self.limitup                        = [body so_readInt:&pos];
    self.limitdown                      = [body so_readInt:&pos];
    
    if (securityType == OPSecurityFUTURE || securityType == OPSecurityFTRIDX)//对期货或期指是昨日持仓，其它为流通盘
        self.lastPosition               = [body so_readInt:&pos];
    else
        self.circulationEquity          = [body so_readExpandInt:&pos];
    
    if (securityType == OPSecurityCOMM || securityType == OPSecurityFUTURE || securityType == OPSecurityFTRIDX || securityType == OPSecurityOPTION)//对商品、期货是昨结算价，其它是总股本
        self.lastSettlement             = [body so_readInt:&pos];
    else
        self.totalEquity                = [body so_readExpandInt:&pos];
    
    self.margin                         = [body so_readChar:&pos];
    self.tradeUnit                      = [body so_readInt:&pos];
    self.extend                         = [body so_readChar:&pos];
    self.optionFlag                     = [body so_readShort:&pos];
}

@end

#pragma mark ---------查询证券 type=2943--------------

@implementation OPRequestPackage2943

- (instancetype)initWithKeyWord:(NSString *)keyword
{
    if (self = [super initWithHeader:[[OPPackageHeader alloc] initWithType:2943] response:[[OPResponsePackage2943 alloc] init]])
    {
        self.keyword                    = keyword;
    }
    return self;
}

- (NSData *)serializeBody
{
    NSMutableData *body                  = [[NSMutableData alloc] init];
    [body so_writeString:self.keyword];
    return body;
}

@end

@implementation OPResponsePackage2943

- (void)deSerialize:(NSData *)body
{
    int pos                             = 0;
    short count                         = [body so_readShort:&pos];
    NSMutableArray *arr                 = [[NSMutableArray alloc] initWithCapacity:count];
    OPMarketSecurityModel *model        = nil;
    for (short i = 0; i < count; i++)
    {
        model                           = [[OPMarketSecurityModel alloc] init];
        model.code                      = [body so_readString:&pos];
        model.name                      = [body so_readString:&pos];
        model.securityType              = [body so_readChar:&pos];
        [arr addObject:model];
    }
    self.resultArray                    = arr;
}

@end

#pragma mark ---------证券动态数据 type=2940--------------

@implementation OPRequestPackage2940 : OPMarketRequestPackage

- (instancetype)initWithCode:(NSString *)code
{
    if (self = [super initWithHeader:[[OPPackageHeader alloc] initWithType:2940] response:[[OPResponsePackage2940 alloc] init]])
    {
        self.code                       = code;
    }
    return self;
}

- (NSData *)serializeBody
{
    NSMutableData *body                 = [[NSMutableData alloc] init];
    [body so_writeString:self.code];
    return body;
}

@end

@implementation OPResponsePackage2940

- (void)deSerialize:(NSData *)body
{
    int pos                             = 0;
    char tag                            = [body so_readChar:&pos];
    self.price                          = [body so_readInt:&pos];
    self.open                           = [body so_readInt:&pos];
    self.high                           = [body so_readInt:&pos];
    self.low                            = [body so_readInt:&pos];
    self.volume                         = [body so_readInt:&pos];
    self.turnover                       = [body so_readInt:&pos];
    self.sellVolume                     = [body so_readInt:&pos];
    self.curVolume                      = [body so_readInt:&pos];
    self.average                        = [body so_readInt:&pos];
    if (tag == 1)
    {
        self.settlement                 = [body so_readInt:&pos];
        self.holdVolume                 = [body so_readInt:&pos];
        self.increment                  = [body so_readInt:&pos];
    }
    self.volumeRatio                    = [body so_readShort:&pos];
    short count                         = [body so_readShort:&pos];
    int bsIndex                         = count / 2;    // 先卖盘后买盘
    NSMutableArray *bids                = [NSMutableArray arrayWithCapacity:bsIndex];
    NSMutableArray *asks                = [NSMutableArray arrayWithCapacity:bsIndex];
    OPMarketAskBidInfoModel *item       = nil;
    for (int i = 0; i < count; i++)
    {
        item                            = [[OPMarketAskBidInfoModel alloc] init];
        item.price                      = [body so_readInt:&pos];
        item.volume                     = [body so_readInt:&pos];
        
        if (i < bsIndex)
            [asks addObject:item];
        else
            [bids addObject:item];
    }
    self.bidData                        = bids;
    self.askData                        = asks;
}

@end

@implementation OPMarketSecurityModel (Initialize)

- (instancetype)initWithStaticData:(OPResponsePackage2939 *)staticData dynamicData:(OPResponsePackage2940 *)dynamicData
{
    OPMarketSecurityModel *model        = [[OPMarketSecurityModel alloc] init];
    model.code                          = staticData.code;
    [model updateWithStaticData:staticData];
    [model updateWithDynamicData:dynamicData];
    return model;
}

- (void)updateWithStaticData:(OPResponsePackage2939 *)staticData
{
    self.name                           = staticData.name;
    self.decimal                        = staticData.decimal;
    self.lastClose                      = staticData.lastClose;
    self.securityType                   = staticData.securityType;
    if (staticData.margin == 1)//融资融券
    {
        self.securityFlag               = DZHSecurityFlagRong;
    }
    else if (staticData.extend == 1)//1基础三板
    {
        self.securityFlag               = DZHSecurityFlagXSBBasic;
    }
    else if (staticData.extend == 2)//2创新三板
    {
        self.securityFlag               = DZHSecurityFlagXSBInnovate;
    }
    else if ((staticData.optionFlag >> 14) & 0x1)//熔断标记
    {
        self.securityFlag               = DZHSecurityFlagFusing;
    }
    else if ((staticData.optionFlag >> 4) & 0x1)//沪港通标记
    {
        self.securityFlag               = DZHSecurityFlagSHHKConnect;
    }
    else if ((staticData.optionFlag >> 5) & 0x1)//深港通标记
    {
        self.securityFlag               = DZHSecurityFlagSZHKConnect;
    }
    
    self.volumeUnit                     = staticData.volumeUnit;
    self.limitup                        = staticData.limitup;
    self.limitdown                      = staticData.limitdown;
    self.circulationEquity              = staticData.circulationEquity;
    self.totalEquity                    = staticData.totalEquity;
    self.tradeUnit                      = staticData.tradeUnit;
}

- (void)updateWithDynamicData:(OPResponsePackage2940 *)dynamicData
{
    self.price                          = dynamicData.price;
    self.open                           = dynamicData.open;
    self.high                           = dynamicData.high;
    self.low                            = dynamicData.low;
    self.volume                         = dynamicData.volume;
    self.turnover                       = dynamicData.turnover;
    self.sellVolume                     = dynamicData.sellVolume;
    self.curVolume                      = dynamicData.curVolume;
    self.average                        = dynamicData.average;
    self.settlement                     = dynamicData.settlement;
    self.holdVolume                     = dynamicData.holdVolume;
    self.increment                      = dynamicData.increment;
    self.volumeRatio                    = dynamicData.volumeRatio;
}

@end

#pragma mark ---------level2的分时ddx--------------

@implementation OPResponsePackageMinuteLevel2

@end

@implementation OPRequestPackage2922

- (instancetype)initWithCode:(NSString *)code pos:(int)pos
{
    if (self = [super initWithHeader:[[OPPackageHeader alloc] initWithType:2922] response:[[OPResponsePackage2922 alloc] init]])
    {
        self.code                       = code;
        self.pos                        = pos;
    }
    return self;
}

- (NSData *)serializeBody
{
    NSMutableData *body                 = [[NSMutableData alloc] init];
    [body so_writeString:self.code];
    [body so_writeInt:self.pos];
    return body;
}

@end

@implementation OPResponsePackage2922

- (void)deSerialize:(NSData *)body
{
    int pos                             = 0;
    short count                         = [body so_readUnsignedShort:&pos];
    NSMutableArray *arr                 = [NSMutableArray arrayWithCapacity:count];
    OPSecurityDDXModel *item            = nil;
    for (short i = 0; i < count; i++)
    {
        item                            = [[OPSecurityDDXModel alloc] init];
        item.ddxSum                     = [body so_readShort:&pos];
        [arr addObject:item];
    }
    self.resultArray                    = arr;
}

@end

@implementation OPRequestPackage2923

- (instancetype)initWithCode:(NSString *)code pos:(int)pos
{
    if (self = [super initWithHeader:[[OPPackageHeader alloc] initWithType:2923] response:[[OPResponsePackage2923 alloc] init]])
    {
        self.code                       = code;
        self.pos                        = pos;
    }
    return self;
}

- (NSData *)serializeBody
{
    NSMutableData *body                 = [[NSMutableData alloc] init];
    [body so_writeString:self.code];
    [body so_writeInt:self.pos];
    return body;
}

@end

@implementation OPResponsePackage2923

- (void)deSerialize:(NSData *)body
{
    int pos                             = 0;
    short count                         = [body so_readUnsignedShort:&pos];
    NSMutableArray *arr                 = [NSMutableArray arrayWithCapacity:count];
    for (short i = 0; i < count; i++)
    {
        [arr addObject:[NSNumber numberWithInt:[body so_readInt24:&pos]]];
    }
    self.resultArray                    = arr;
}

@end

@implementation OPRequestPackage2924

- (instancetype)initWithCode:(NSString *)code pos:(int)pos
{
    if (self = [super initWithHeader:[[OPPackageHeader alloc] initWithType:2924] response:[[OPResponsePackage2924 alloc] init]])
    {
        self.code                       = code;
        self.pos                        = pos;
    }
    return self;
}

- (NSData *)serializeBody
{
    NSMutableData *body                 = [[NSMutableData alloc] init];
    [body so_writeString:self.code];
    [body so_writeInt:self.pos];
    return body;
}

@end

@implementation OPResponsePackage2924

- (void)deSerialize:(NSData *)body
{
    int pos                             = 0;
    short count                         = [body so_readUnsignedShort:&pos];
    NSMutableArray *arr                 = [NSMutableArray arrayWithCapacity:count];
    OPSecurityTotalAskBidModel *item    = nil;
    for (short i = 0; i < count; i++)
    {
        item                            = [[OPSecurityTotalAskBidModel alloc] init];
        item.totalBid                   = [body so_readInt:&pos];
        item.totalAsk                   = [body so_readInt:&pos];
        [arr addObject:item];
    }
    self.resultArray                    = arr;
}

@end
