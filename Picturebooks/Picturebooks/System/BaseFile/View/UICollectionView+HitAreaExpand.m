//
//  UICollectionView+HitAreaExpand.m
//  Picturebooks
//
//  Created by 吉晓东 on 2018/1/10.
//  Copyright © 2018年 ZhiyuanNetwork. All rights reserved.
//

#import "UICollectionView+HitAreaExpand.h"
#import <objc/runtime.h>

@implementation UICollectionView (HitAreaExpand)

- (CGFloat)minHitTestWidth
{
    // 获取关联对象的值
    NSNumber *width = objc_getAssociatedObject(self, @selector(minHitTestWidth));
    return [width floatValue];
}

- (void)setMinHitTestWidth:(CGFloat)minHitTestWidth
{
    objc_setAssociatedObject(self, @selector(minHitTestWidth), [NSNumber numberWithFloat:minHitTestWidth], OBJC_ASSOCIATION_RETAIN);
}

- (CGFloat)minHitTestHeight
{
    NSNumber *height = objc_getAssociatedObject(self, @selector(minHitTestHeight));
    return [height floatValue];
}

- (void)setMinHitTestHeight:(CGFloat)minHitTestHeight
{
    objc_setAssociatedObject(self, @selector(minHitTestHeight), [NSNumber numberWithFloat:minHitTestHeight], OBJC_ASSOCIATION_RETAIN);
}

// 判断是否是可点击的区域
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return CGRectContainsPoint(HitTestingBounds(self.bounds, self.minHitTestWidth, self.minHitTestHeight), point);
}


// 设置超出自身区域点击范围
CGRect HitTestingBounds(CGRect bounds, CGFloat minimumHitTestWidth, CGFloat minimumHitTestHeight)
{
    CGRect hitTestingBounds = bounds;
    if (minimumHitTestWidth > bounds.size.width) {
        hitTestingBounds.size.width = minimumHitTestWidth;
        hitTestingBounds.origin.x -= (hitTestingBounds.size.width - bounds.size.width) / 2;
    }
    
    if (minimumHitTestHeight > bounds.size.height) {
        hitTestingBounds.size.height = minimumHitTestHeight;
        hitTestingBounds.origin.y -= (hitTestingBounds.size.height - bounds.size.height) / 2;
    }
    
    return hitTestingBounds;
}


@end






