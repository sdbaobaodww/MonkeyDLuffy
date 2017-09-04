//
//  NSString+FastDrawing.m
//  OnePiece
//
//  Created by Duanwwu on 2016/12/8.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "NSString+FastDrawing.h"

@implementation NSString (FastDrawing)

- (CGSize)fd_sizeWithFont:(UIFont *)font {
    return [self sizeWithAttributes: @{NSFontAttributeName : font}];
}

- (CGSize)fd_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size {
    return [self boundingRectWithSize:size
                              options:NSStringDrawingUsesFontLeading
                           attributes:@{NSFontAttributeName : font}
                              context:nil].size;
}

- (CGSize)fd_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode {
    NSMutableParagraphStyle *style      = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineBreakMode                 = lineBreakMode;
    
    NSDictionary *attributes            = @{NSFontAttributeName : font,NSParagraphStyleAttributeName : style};
    
    return [self boundingRectWithSize:size
                              options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:attributes
                              context:nil].size;
}

- (void)fd_drawAtPoint:(CGPoint)point withFont:(UIFont *)font fontColor:(UIColor *)fontColor {
    [self drawAtPoint:point withAttributes:@{NSFontAttributeName : font,NSForegroundColorAttributeName : fontColor}];
}

- (void)fd_drawInRect:(CGRect)rect withFont:(UIFont *)font fontColor:(UIColor *)fontColor {
    [self drawInRect:rect withAttributes:@{NSFontAttributeName : font,NSForegroundColorAttributeName : fontColor}];
}

- (void)fd_drawInRect:(CGRect)rect withFont:(UIFont *)font fontColor:(UIColor *)fontColor lineBreakMode:(NSLineBreakMode)lineBreakMode {
    NSMutableParagraphStyle *style      = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineBreakMode                 = lineBreakMode;
    
    [self drawInRect:rect withAttributes:@{NSFontAttributeName : font, NSForegroundColorAttributeName : fontColor,NSParagraphStyleAttributeName : style }];
}

- (void)fd_drawInRect:(CGRect)rect withFont:(UIFont *)font fontColor:(UIColor *)fontColor lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment {
    NSMutableParagraphStyle *style      = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineBreakMode                 = lineBreakMode;
    style.alignment                     = alignment;
    
    [self drawInRect:rect withAttributes:@{NSFontAttributeName : font, NSForegroundColorAttributeName : fontColor,NSParagraphStyleAttributeName : style }];
}

- (CGSize)fd_drawCenterInRect:(CGRect)rect withFont:(UIFont *)font fontColor:(UIColor *)fontColor lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment {
    CGSize size                         = [self fd_sizeWithFont:font constrainedToSize:rect.size lineBreakMode:lineBreakMode];
    CGRect textRect                     = rect;
    textRect.origin.y                   += (rect.size.height - size.height) * .5;
    textRect.size.height                = size.height;
    
    [self fd_drawInRect:textRect withFont:font fontColor:fontColor lineBreakMode:lineBreakMode alignment:alignment];
    return size;
}

- (void)fd_drawCenterInRect:(CGRect)rect withFont:(UIFont *)font fontColor:(UIColor *)fontColor alignment:(NSTextAlignment)alignment {
    [self fd_drawCenterInRect:rect withFont:font fontColor:fontColor lineBreakMode:NSLineBreakByClipping alignment:alignment];
}

@end
