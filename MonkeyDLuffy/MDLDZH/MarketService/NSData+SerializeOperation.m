//
//  NSData+SerializeOperation.m
//  OnePiece
//
//  Created by Duanwwu on 16/10/25.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "NSData+SerializeOperation.h"

@implementation NSData (SerializeOperation)

- (char)so_readChar:(int *)pos
{
    char tmp                    = 0;
    if (*pos + sizeof(tmp) <= [self length])
    {
        [self getBytes:&tmp range:NSMakeRange(*pos,sizeof(tmp))];
        *pos                    += sizeof(tmp);
    }
    return tmp;
}

- (short)so_readShort:(int *)pos
{
    short tmp                   = 0;
    if (*pos+sizeof(tmp) <= [self length])
    {
        [self getBytes:&tmp range:NSMakeRange(*pos,sizeof(tmp))];
        *pos                    += sizeof(tmp);
    }
    return tmp;
}

- (int)so_readInt:(int *)pos
{
    int tmp                     = 0;
    if (*pos+sizeof(tmp) <= [self length])
    {
        [self getBytes:&tmp range:NSMakeRange(*pos,sizeof(tmp))];
        *pos                    += sizeof(tmp);
    }
    return tmp;
}

- (int)so_readInt24:(int *)pos
{
    int tmp                     = 0;
    if (*pos+3 <= [self length])
    {
        [self getBytes:&tmp range:NSMakeRange(*pos,3)];
        *pos                    += 3;
        int n                   = 0x00800000;
        if ((tmp & n) == n)	//负值
            tmp                 = tmp | 0xFF000000;
    }
    return tmp;
}

- (long long)so_readInt64:(int *)pos
{
    long long tmp               = 0;
    if (*pos+sizeof(tmp) <= [self length])
    {
        [self getBytes:&tmp range:NSMakeRange(*pos,sizeof(tmp))];
        *pos                   += sizeof(tmp);
    }
    return tmp;
}

- (long long)so_readExpandInt:(int *)pos
{
    int v                       = [self so_readInt:pos];
    int v1                      = (v >> 30) & 0x03;
    if (v1 == 0)
    {
        return v;
    }
    else
    {
        long long v2            = v & 0x3FFFFFFF;
        v2                      = v2 << (v1 * 4);
        return v2;
    }
}

- (unsigned char)so_readUnsignedChar:(int *)pos
{
    unsigned char tmp           = 0;
    if (*pos + sizeof(tmp) <= [self length])
    {
        [self getBytes:&tmp range:NSMakeRange(*pos,sizeof(tmp))];
        *pos                    += sizeof(tmp);
    }
    return tmp;
}

- (unsigned short)so_readUnsignedShort:(int *)pos
{
    unsigned short tmp          = 0;
    if (*pos + sizeof(tmp) <= [self length])
    {
        [self getBytes:&tmp range:NSMakeRange(*pos,sizeof(tmp))];
        *pos                    += sizeof(tmp);
    }
    return tmp;
}

- (unsigned int)so_readUnsignedInt:(int *)pos
{
    unsigned int tmp            = 0;
    if (*pos + sizeof(tmp) <= [self length])
    {
        [self getBytes:&tmp range:NSMakeRange(*pos,sizeof(tmp))];
        *pos                    += sizeof(tmp);
    }
    return tmp;
}

- (NSString *)so_readString:(int *)pos
{
    NSString *result            = nil;
    if (*pos+2 <= [self length])
    {
        short len               = 0;
        [self getBytes:&len range:NSMakeRange(*pos,2)];
        *pos                    += 2;
        if (len > 0 && *pos + len <= [self length])
        {
            char * buffer       = calloc(len+1, 1);
            [self getBytes:buffer range:NSMakeRange(*pos,len)];
            *pos                += len;
            result              = [NSString stringWithUTF8String:buffer];
            if(!result)//针对非utf8编码字符串做特殊处理
            {
                result          = [NSString stringWithCString:buffer encoding:[NSString defaultCStringEncoding]];
            }
            free(buffer);
        }
    }
    return result ? result : @"";
}

- (NSData *)so_readData:(int *)pos
{
    int len                     = [self so_readUnsignedShort:pos];
    NSData *retData             = nil;
    if (*pos+len <= [self length])
    {
        retData                 = [self subdataWithRange:NSMakeRange(*pos, len)];
    }
    *pos                        += len;
    return retData;
}

- (NSArray *)so_readStringArray:(int *)pos
{
    short len                   = [self so_readUnsignedShort:pos];
    if (len > 0)
    {
        NSMutableArray *arr     = [[NSMutableArray alloc] initWithCapacity:len];
        for (short i = 0; i < len; i ++)
        {
            [arr addObject:[self so_readString:pos]];
        }
        return arr;
    }
    return nil;
}

- (NSArray *)so_readIntArray:(int *)pos
{
    short len                   = [self so_readUnsignedShort:pos];
    if (len > 0)
    {
        NSMutableArray *arr     = [[NSMutableArray alloc] initWithCapacity:len];
        for (short i = 0; i < len; i ++)
        {
            [arr addObject:[NSNumber numberWithInt:[self so_readInt:pos]]];
        }
        return arr;
    }
    return nil;
}

@end
