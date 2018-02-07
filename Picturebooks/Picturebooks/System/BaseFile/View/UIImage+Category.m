//
//  UIImage+Category.m
//  Picturebooks
//
//  Created by 吉晓东 on 2018/1/18.
//  Copyright © 2018年 ZhiyuanNetwork. All rights reserved.
//

#import "UIImage+Category.h"

@implementation UIImage (Category)

#pragma mark - 通过自定义的颜色创建图片
+ (instancetype)imageWithColor:(UIColor *)color
{
    /** 描述矩形 */
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    
    /** 开启位图上下文 */
    UIGraphicsBeginImageContext(rect.size);
    // 获取位图上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 使用color演示填充上下文
    CGContextSetFillColorWithColor(context, [color CGColor]);
    // 渲染上下文
    CGContextFillRect(context, rect);
    // 从上下文中获取图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    // 结束上下文
    UIGraphicsEndImageContext();
    
    return image;
}

@end
