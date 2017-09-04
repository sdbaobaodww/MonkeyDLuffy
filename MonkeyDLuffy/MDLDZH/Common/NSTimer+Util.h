//
//  NSTimer+Util.h
//  OnePiece
//
//  Created by Duanwwu on 2016/12/15.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Util)

/**
 * 暂停
 */
- (void)util_suspend;

/**
 * 唤醒
 */
- (void)util_resume;

/**
 * 手动延迟一个周期触发
 */
- (void)util_nextFire;

@end
