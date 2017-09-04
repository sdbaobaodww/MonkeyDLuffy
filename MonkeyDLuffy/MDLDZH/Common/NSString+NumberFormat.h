//
//  NSString+NumberFormat.h
//  OnePiece
//
//  Created by Duanwwu on 2016/12/8.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NumberFormat)

/**
 * 生成格式化后的字符串，value为0则返回"--"
 * @param value 浮点值
 * @param decimal 小数位数
 * @returns 字符串
 */
+ (NSString *)nf_stringNoZeroWithPrice:(long long)value decimal:(short)decimal;

/**
 * 通过值和基准值获取格式化后的涨幅字符串，涨幅>0 不加正号，但涨幅<0会有负号
 * @param value 值
 * @param baseValue 基准值
 * @param decimal 小数位
 * @returns 字符串
 */
+ (NSString *)nf_stringPercentageWithValue:(long long)value baseValue:(long long)baseValue decimal:(short)decimal;

/**
 * 格式化成交量数据
 * 小于等于0，返回"--"
 * 大于0，小于1万，直接返回
 * 大于1万，小于1亿，格式化为以万做单位
 * 大于1亿，格式化为以亿做单位
 * @param volume 成交量
 * @Param decimal 突破万后面显示的小数点个数，如100000，precision为2时显示10.00万
 * @returns 字符串
 */
+ (NSString *)nf_stringNoZeroWithVolume:(long long)volume decimal:(short)decimal;

@end
