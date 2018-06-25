//
//  LLLUibutton.m
//  newsyrinx
//
//  Created by SPS on 2017/4/21.
//  Copyright © 2017年 希芸. All rights reserved.
//

#import "LLLUibutton.h"

//图表的比例
#define LLLUibuttonRatio 0.7;
@implementation LLLUibutton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView.contentMode=UIViewContentModeCenter;
        self.titleLabel.textAlignment=NSTextAlignmentCenter;
        self.titleLabel.font=[UIFont systemFontOfSize:11];
    }
    return self;
}

-(void)setHighlighted:(BOOL)highlighted{
    
}

-(CGRect)imageRectForContentRect:(CGRect)contentRect{
    CGFloat imageW=contentRect.size.width;
    CGFloat imageH=contentRect.size.height*LLLUibuttonRatio;
    return CGRectMake(0, 0, imageW, imageH);
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect{
    CGFloat titleY=contentRect.size.height*LLLUibuttonRatio;
    CGFloat titleW=contentRect.size.width;
    CGFloat titleH=contentRect.size.height-titleY;
    return CGRectMake(0, titleY, titleW, titleH);
}

@end
