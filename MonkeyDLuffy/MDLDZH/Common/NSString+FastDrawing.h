//
//  NSString+FastDrawing.h
//  OnePiece
//
//  Created by Duanwwu on 2016/12/8.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (FastDrawing)

/**
 * @see sizeWithAttributes:
 */
- (CGSize)fd_sizeWithFont:(UIFont *)font;

/**
 * @see boundingRectWithSize:options:attributes:context:
 */
- (CGSize)fd_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

/**
 * @see boundingRectWithSize:options:attributes:context:
 */
- (CGSize)fd_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;

/**
 * @see drawAtPoint:withAttributes:
 */
- (void)fd_drawAtPoint:(CGPoint)point withFont:(UIFont *)font fontColor:(UIColor *)fontColor;

/**
 * @see drawInRect:withAttributes:
 */
- (void)fd_drawInRect:(CGRect)rect withFont:(UIFont *)font fontColor:(UIColor *)fontColor;

/**
 * @see drawInRect:withAttributes:
 */
- (void)fd_drawInRect:(CGRect)rect withFont:(UIFont *)font fontColor:(UIColor *)fontColor lineBreakMode:(NSLineBreakMode)lineBreakMode;

/**
 * @see drawInRect:withAttributes:
 */
- (void)fd_drawInRect:(CGRect)rect withFont:(UIFont *)font fontColor:(UIColor *)fontColor lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment;

/**
 * 垂直居中绘制
 */
- (CGSize)fd_drawCenterInRect:(CGRect)rect withFont:(UIFont *)font fontColor:(UIColor *)fontColor lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment;

/**
 * 垂直居中绘制 lineBreakMode取值NSLineBreakByClipping
 * @see fd_drawCenterInRect:withFont:fontColor:lineBreakMode:alignment:
 */
- (void)fd_drawCenterInRect:(CGRect)rect withFont:(UIFont *)font fontColor:(UIColor *)fontColor alignment:(NSTextAlignment)alignment;

@end
