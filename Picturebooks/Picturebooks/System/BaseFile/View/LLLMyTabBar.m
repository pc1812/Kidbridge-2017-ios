//
//  LLLMyTabBar.m
//  newsyrinx
//
//  Created by SPS on 2017/4/21.
//  Copyright © 2017年 希芸. All rights reserved.
//

#import "LLLMyTabBar.h"

#import "LLLUibutton.h"

@implementation LLLMyTabBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)addTabBarButtonWithItem:(UITabBarItem *)item
{
    //创建按钮
    LLLUibutton *button=[LLLUibutton buttonWithType:UIButtonTypeCustom];
    [self addSubview:button];
    //设置数据
    
//    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [button setTitle:item.title forState:UIControlStateNormal];
    [button setImage:item.image forState:UIControlStateNormal];
    [button setImage:item.selectedImage forState:UIControlStateSelected];
    //button.backgroundColor=[UIColor whiteColor];
    //监听按钮点击
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
    
    //默认选中第0个按钮
    if (self.subviews.count==1) {
        [self buttonClick:button];
    }
}

//监听按钮点击
-(void)buttonClick:(LLLUibutton *)sender
{
    //通知代理
    if ([self.delegate respondsToSelector:@selector(tarBar:didSeletedButtonFrom:to:)]) {
        [self.delegate tarBar:self didSeletedButtonFrom:(int)self.seletedButton.tag to:(int)sender.tag];
    }
    self.seletedButton.selected=NO;
    sender.selected=YES;
    self.seletedButton=sender;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    for (NSInteger index=0; index<self.subviews.count; index++) {
        LLLUibutton *button=self.subviews[index];
        button.frame=CGRectMake(index*(SCREEN_WIDTH/self.subviews.count), 0, self.frame.size.width/self.subviews.count, self.frame.size.height);
        button.tag=index;
    }
}

@end
