//
//  NSString+NumberFormat.m
//  OnePiece
//
//  Created by Duanwwu on 2016/12/8.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "NSString+NumberFormat.h"

@implementation NSString (NumberFormat)

+ (NSString *)nf_stringNoZeroWithPrice:(long long)value decimal:(short)decimal
{
    if (value == 0)
        return @"--";
    
    NSString *base                  = [NSString stringWithFormat:@"%%.%df",decimal];
    return [NSString stringWithFormat:base, value * powf(.1, decimal)];
}

+ (NSString *)nf_stringPercentageWithValue:(long long)value baseValue:(long long)baseValue decimal:(short)decimal
{
    if (value == 0)
        return @"--";
    else if (value == baseValue)
        return @"0.00%";
    else if (baseValue == 0)
        return @"--";
    else
    {
        NSString *base              = [NSString stringWithFormat:@"%%.%df%%%%",decimal];
        return [NSString stringWithFormat:base, (value - baseValue) * 100.f / baseValue];
    }
}

+ (NSString *)nf_stringNoZeroWithVolume:(long long)volume decimal:(short)decimal
{
    if (volume <= 0)
        return @"--";
    else if (volume < 10000)
        return [NSString stringWithFormat:@"%lli", volume];
    else if (volume < 100000000)
    {
        NSString *base              = [NSString stringWithFormat:@"%%.%df万",decimal];
        return [NSString stringWithFormat:base, volume * .0001f];
    }
    else
    {
        NSString *base              = [NSString stringWithFormat:@"%%.%df亿",decimal];
        return [NSString stringWithFormat:base, volume * .00000001f];
    }
}

@end
