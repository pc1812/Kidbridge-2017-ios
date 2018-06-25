//
//  UILabel+String.m
//  Teaism
//
//  Created by ike on 15/11/2.
//  Copyright © 2015年 Apple. All rights reserved.
//

#import "UILabel+String.h"

@implementation UILabel (String)

- (CGSize)boundingRectWithSize:(CGSize)size
{
    NSDictionary *attribute = @{NSFontAttributeName: self.font};
    CGSize retSize = [self.text boundingRectWithSize:size
                                             options:\
                      NSStringDrawingTruncatesLastVisibleLine |
                      NSStringDrawingUsesLineFragmentOrigin |
                      NSStringDrawingUsesFontLeading
                                          attributes:attribute
                                             context:nil].size;
    return retSize;
}

/*
根据给定的坐标原点、字符串、字体的大小计算Label的Frame

@param origin 给定的坐标原点
@param text 给定的字符串
@param font 给定的字体大小
*/
- (void)setLabelFrameWithOrigin:(CGPoint)origin andText:(NSString *)text andFont:(UIFont *)font andMax:(CGSize)maxSize
{
    // 设置label的字体
    self.font = font;
    self.numberOfLines = 1;
    // 字体的属性
    NSDictionary *dictAttribute = @{NSFontAttributeName : font};
    // 计算字体所占的总size
    CGSize size = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dictAttribute context:nil].size;
    self.frame = CGRectMake(origin.x, origin.y, size.width + 10, size.height);
}

@end
