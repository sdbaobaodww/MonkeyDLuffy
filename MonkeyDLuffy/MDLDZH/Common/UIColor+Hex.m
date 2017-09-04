//
//  UIColor+Hex.m
//  OnePiece
//
//  Created by Duanwwu on 2016/12/8.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (instancetype)hex_colorFromRGB:(int)rgbValue {
    return [UIColor colorWithRed:((rgbValue >> 16) & 0xFF)/255.0 green:((rgbValue >> 8) & 0xFF)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (instancetype)hex_colorFromARGB:(int)argbValue {
    return [UIColor colorWithRed:((argbValue >> 16) & 0xFF)/255.0 green:((argbValue >> 8) & 0xFF)/255.0 blue:(argbValue & 0xFF)/255.0 alpha:((argbValue >> 24) & 0xFF)/255.0];
}

+ (instancetype)hex_colorFromString:(NSString *)hexStr {
    if(hexStr.length < 6)
        return nil;
    
    if([hexStr hasPrefix:@"#"])
        hexStr                      = [hexStr substringFromIndex:1];
    
    if(hexStr.length<6)
        return nil;
    
    NSRange range                   = NSMakeRange(0, 2);
    NSString *aString               = nil;
    if ([hexStr length] == 8) {//argb
        aString                     = [hexStr substringWithRange:range];
        range.location              = 2;
    }
    NSString *rString               =[hexStr substringWithRange:range];
    range.location                  += 2;
    NSString *gString               =[hexStr substringWithRange:range];
    range.location                  += 2;
    NSString *bString               =[hexStr substringWithRange:range];
    
    unsigned int a,r,g,b;
    if (aString)
        [[NSScanner scannerWithString:aString] scanHexInt:&a];
    else
        a                           = 255;
    
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a/255.];
}

@end
