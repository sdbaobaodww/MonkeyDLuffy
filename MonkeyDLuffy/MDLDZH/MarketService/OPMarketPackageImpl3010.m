//
//  OPMarketPackageImpl3010.m
//  OnePiece
//
//  Created by Duanwwu on 2016/11/13.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPMarketPackageImpl3010.h"
#import "NSMutableData+SerializeOperation.h"
#import "NSData+SerializeOperation.h"

#pragma mark --------------------成交价格分布 sub_type = 1000------------------

@implementation OPRequestPackage3010Sub1000

- (instancetype)initWithCode:(NSString *)code date:(int)date time:(short)time subAttr:(short)subAttr
{
    OPPackageHeader *header             = [[OPPackageHeader alloc] initWithType:3010];
    if (self = [super initWithHeader:header
                            response:[[OPResponsePackage3010Sub1000 alloc] init]])
    {
        header.subHeader                = [[OPPackageSubHeaderExtend alloc] initWithTag:OPResultTagRequestAsyncResponse type:1000 attrs:subAttr];
        
        self.reqTag                     = date;
        self.code                       = code;
        self.date                       = date;
        self.time                       = time;
    }
    return self;
}

- (NSData *)serializeBody
{
    NSMutableData *body                 = [[NSMutableData alloc] init];
    [body so_writeString:self.code];
    [body so_writeInt:self.date];
    [body so_writeShort:self.time];
    return body;
}

@end

@implementation OPMarketPriceDistributionItem

@end

@implementation OPResponsePackage3010Sub1000

- (void)deSerialize:(NSData *)body
{
    int pos                             = 0;
    short count                         = [body so_readUnsignedShort:&pos];
    if (count > 0)
    {
        NSMutableArray *arr             = [[NSMutableArray alloc] initWithCapacity:count];
        OPMarketPriceDistributionItem *item = nil;
        for (short i = 0; i < count; i++)
        {
            item                        = [[OPMarketPriceDistributionItem alloc] init];
            item.price                  = [body so_readInt:&pos];
            item.decimal                = [body so_readChar:&pos];
            item.volume                 = [body so_readInt:&pos];
            item.bigVolume              = [body so_readInt:&pos];
            [arr addObject:item];
        }
        self.resultArray                = arr;
    }
}

@end

#pragma mark --------------------成本分析 sub_type = 1001------------------

@implementation OPRequestPackage3010Sub1001

- (instancetype)initWithCode:(NSString *)code date:(int)date time:(short)time subAttr:(short)subAttr
{
    OPPackageHeader *header             = [[OPPackageHeader alloc] initWithType:3010];
    if (self = [super initWithHeader:header
                            response:[[OPResponsePackage3010Sub1001 alloc] init]])
    {
        header.subHeader                = [[OPPackageSubHeaderExtend alloc] initWithTag:OPResultTagRequestAsyncResponse type:1001 attrs:subAttr];
        
        self.reqTag                     = date;
        self.code                       = code;
        self.date                       = date;
        self.time                       = time;
    }
    return self;
}

- (NSData *)serializeBody
{
    NSMutableData *body                 = [[NSMutableData alloc] init];
    [body so_writeString:self.code];
    [body so_writeInt:self.date];
    [body so_writeShort:self.time];
    return body;
}

@end

@implementation OPResponsePackage3010Sub1001

- (void)deSerialize:(NSData *)body
{
    int pos                             = 0;
    short length                        = [body so_readShort:&pos];
    if (length > 0)
    {
        self.decimal                    = [body so_readChar:&pos];
        self.earnRatio                  = [body so_readChar:&pos];
        self.average                    = [body so_readInt:&pos];
        self.bigOrderAverage            = [body so_readInt:&pos];
        self.lowLimit70                 = [body so_readInt:&pos];
        self.highLimit70                = [body so_readInt:&pos];
        self.lowLimit90                 = [body so_readInt:&pos];
        self.highLimit90                = [body so_readInt:&pos];
    }
}

@end
