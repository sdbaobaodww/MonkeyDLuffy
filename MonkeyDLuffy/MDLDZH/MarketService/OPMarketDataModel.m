//
//  OPMarketDataModel.m
//  OnePiece
//
//  Created by Duanwwu on 2016/11/7.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPMarketDataModel.h"

@implementation OPMarketSecurityModel

- (instancetype)init
{
    if (self = [super init])
    {
        self.securityType           = OPSecurityUNKNOWN;
        self.marketType             = OPSecurityMarketUNKNOWN;
    }
    return self;
}

- (void)setCode:(NSString *)code
{
    if (code != _code)
    {
        _code                       = [code copy];
        
        if ([code length] > 2)
        {
            self.briefCode          = [code substringFromIndex:2];
            self.marketType         = marketTypeFromCodePrefix([[code substringToIndex:2] UTF8String]);
        }
    }
}

@end

@implementation OPMarketListItem

@end

@implementation OPSecurityTimeModel

- (BOOL)isEqual:(OPSecurityTimeModel *)other
{
    if (self == other)
        return YES;
    else if (![other isKindOfClass:[self class]])
        return NO;
    else
        return self.time == other.time;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"时间:%d 开:%d 高:%d 低:%d 收:%d", self.time, self.openPrice, self.highPrice, self.lowPrice, self.closePrice];
}

@end

@implementation OPMarketAskBidInfoModel

@end

@implementation OPSecurityDDXModel

@end

@implementation OPSecurityTotalAskBidModel

@end
