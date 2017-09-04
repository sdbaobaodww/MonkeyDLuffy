//
//  NSArray+Random.m
//  OnePiece
//
//  Created by Duanwwu on 2016/11/8.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "NSArray+Random.h"

@implementation NSArray (Random)

- (id)rd_randomObject {
    if ([self count] <= 0) {
        return nil;
    } else {
        int index = arc4random() % [self count];
        return [self objectAtIndex:index];
    }
}

@end
