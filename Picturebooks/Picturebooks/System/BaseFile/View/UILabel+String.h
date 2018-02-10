//
//  UILabel+String.h
//  Teaism
//
//  Created by ike on 15/11/2.
//  Copyright © 2015年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (String)

- (CGSize)boundingRectWithSize:(CGSize)size;

/*
 根据给定的坐标原点、字符串、字体的大小计算Label的Frame
 
 @param origin 给定的坐标原点
 @param text 给定的字符串
 @param font 给定的字体大小
 */
- (void)setLabelFrameWithOrigin:(CGPoint)origin andText:(NSString *)text andFont:(UIFont *)font andMax:(CGSize)maxSize;


@end
