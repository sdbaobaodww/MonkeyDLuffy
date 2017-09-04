//
//  NSData+SerializeOperation.h
//  OnePiece
//
//  Created by Duanwwu on 16/10/25.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (SerializeOperation)

- (char)so_readChar:(int *)pos;
- (short)so_readShort:(int *)pos;
- (int)so_readInt:(int *)pos;
- (int)so_readInt24:(int *)pos;
- (long long)so_readInt64:(int *)pos;
- (long long)so_readExpandInt:(int *)pos;

- (unsigned char)so_readUnsignedChar:(int *)pos;
- (unsigned short)so_readUnsignedShort:(int *)pos;
- (unsigned int)so_readUnsignedInt:(int *)pos;

- (NSString *)so_readString:(int *)pos;
- (NSData *)so_readData:(int *)pos;

- (NSArray *)so_readStringArray:(int *)pos;
- (NSArray *)so_readIntArray:(int *)pos;

@end
