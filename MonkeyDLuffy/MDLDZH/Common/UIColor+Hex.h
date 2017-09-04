//
//  UIColor+Hex.h
//  OnePiece
//
//  Created by Duanwwu on 2016/12/8.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

/**
 * 通过rgb值创建颜色
 * @param rgbValue 颜色rgb值
 * @returns UIColor
 */
+ (instancetype)hex_colorFromRGB:(int)rgbValue;

/**
 * 通过argbValue值创建颜色
 * @param argbValue 颜色rgb值
 * @returns UIColor
 */
+ (instancetype)hex_colorFromARGB:(int)argbValue;

/**
 * 通过argb或者rgb字符串创建颜色
 * @param hexStr argb或者rgb字符串
 * @returns UIColor
 */
+ (instancetype)hex_colorFromString:(NSString *)hexStr;

@end
