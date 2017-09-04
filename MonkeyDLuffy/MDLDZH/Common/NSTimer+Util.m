//
//  NSTimer+Util.m
//  OnePiece
//
//  Created by Duanwwu on 2016/12/15.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "NSTimer+Util.h"

@implementation NSTimer (Util)

- (void)util_suspend {
    [self setFireDate:[NSDate distantFuture]];
}

- (void)util_resume {
    [self setFireDate:[NSDate distantPast]];
}

- (void)util_nextFire {
    [self setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.timeInterval]];
}

@end
