//
//  LLLMyTabBar.h
//  newsyrinx
//
//  Created by SPS on 2017/4/21.
//  Copyright © 2017年 希芸. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LLLMyTabBar;
@protocol LLLMyTabBarDelegate <NSObject>

-(void)tarBar:(LLLMyTabBar *)tabBar didSeletedButtonFrom:(int)from to:(int )to;

@end

@interface LLLMyTabBar : UIView

@property(nonatomic,weak)UIButton *nomarlButton;
@property(nonatomic,weak)UIButton *seletedButton;
@property(nonatomic,weak)id<LLLMyTabBarDelegate>delegate;

-(void)addTabBarButtonWithItem:(UITabBarItem *)item;

@end

