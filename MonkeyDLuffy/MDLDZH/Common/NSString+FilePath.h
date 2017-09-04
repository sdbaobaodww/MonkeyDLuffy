//
//  NSString+FilePath.h
//  OnePiece
//
//  Created by Duanwwu on 2016/11/8.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FilePath)

+ (NSString *)fp_documentFilePath:(NSString *)fileName;

+ (NSString *)fp_documentFilePath;

+ (NSString *)fp_libraryCachesFilePath:(NSString *)fileName;

+ (NSString *)fp_libraryCachesFilePath;

@end
