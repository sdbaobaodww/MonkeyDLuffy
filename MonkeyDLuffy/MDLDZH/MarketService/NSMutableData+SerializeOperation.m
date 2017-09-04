//
//  NSMutableData+SerializeOperation.m
//  OnePiece
//
//  Created by Duanwwu on 16/10/25.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "NSMutableData+SerializeOperation.h"

@implementation NSMutableData (SerializeOperation)

- (void)so_writeChar:(char)num
{
    [self appendBytes:&num length:sizeof(num)];
}

- (void)so_writeShort:(short)num
{
    [self appendBytes:&num length:sizeof(num)];
}

- (void)so_writeInt:(int)num
{
    [self appendBytes:&num length:sizeof(num)];
}

- (void)so_writeInt64:(long long)num
{
    [self appendBytes:&num length:sizeof(num)];
}

- (void)so_writeUnsignedChar:(unsigned char)num
{
    [self appendBytes:&num length:sizeof(num)];
}

- (void)so_writeUnsignedShort:(unsigned short)num
{
    [self appendBytes:&num length:sizeof(num)];
}

- (void)so_writeUnsignedInt:(unsigned int)num
{
    [self appendBytes:&num length:sizeof(num)];
}

- (void)so_writeString:(NSString *)str
{
    unsigned short len          = [str lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    [self appendBytes:&len length:sizeof(len)];
    [self appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)so_writeData:(NSData *)data
{
    unsigned short len          = [data length];
    [self appendBytes:&len length:sizeof(len)];
    [self appendData:data];
}

@end
