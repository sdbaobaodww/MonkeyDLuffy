//
//  NSDictionary+Description.m
//  OnePiece
//
//  Created by Duanwwu on 2016/11/17.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "NSDictionary+Description.h"

@implementation NSDictionary (Description)

- (NSString *)descriptionWithLocale:(id)locale {
    NSMutableString *string = [NSMutableString string];
    
    // 开头有个{
    [string appendString:@"{\n"];
    
    // 遍历所有的键值对
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [string appendFormat:@"%@ : %@,\n", key, obj];
    }];
    
    // 结尾有个}
    [string appendString:@"}"];
    
    // 查找最后一个逗号
    NSRange range = [string rangeOfString:@"," options:NSBackwardsSearch];
    if (range.location != NSNotFound)
        [string deleteCharactersInRange:range];
    
    return string;
}

@end
