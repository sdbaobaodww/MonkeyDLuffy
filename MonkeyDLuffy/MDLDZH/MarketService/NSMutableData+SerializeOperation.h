//
//  NSMutableData+SerializeOperation.h
//  OnePiece
//
//  Created by Duanwwu on 16/10/25.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableData (SerializeOperation)

- (void)so_writeChar:(char)num;
- (void)so_writeShort:(short)num;
- (void)so_writeInt:(int)num;
- (void)so_writeInt64:(long long)num;

- (void)so_writeUnsignedChar:(unsigned char)num;
- (void)so_writeUnsignedShort:(unsigned short)num;
- (void)so_writeUnsignedInt:(unsigned int)num;

- (void)so_writeString:(NSString *)str;
- (void)so_writeData:(NSData *)data;

@end
