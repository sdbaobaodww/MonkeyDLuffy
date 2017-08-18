//
//  NSMethodSignature+MDLBlock.h
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/11.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 获取block对象的方法签名
 */
@interface NSMethodSignature (MDLBlock)

+ (instancetype)mdlblock_methodSignatureWithBlock:(id)block;

@end
