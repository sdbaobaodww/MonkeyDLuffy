//
//  NSString+FilePath.m
//  OnePiece
//
//  Created by Duanwwu on 2016/11/8.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "NSString+FilePath.h"

@implementation NSString (FilePath)

+ (NSString *)fp_documentFilePath:(NSString *)fileName
{
    return [NSString stringWithFormat:@"%@/%@", [self fp_documentFilePath], fileName];
}

+ (NSString *)fp_documentFilePath
{
    NSArray *paths                          = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString *)fp_libraryCachesFilePath:(NSString *)fileName
{
    return [NSString stringWithFormat:@"%@/%@", [self fp_libraryCachesFilePath], fileName];
}

+ (NSString *)fp_libraryCachesFilePath
{
    NSArray *paths                          = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
    return [paths objectAtIndex:0];
}

@end
