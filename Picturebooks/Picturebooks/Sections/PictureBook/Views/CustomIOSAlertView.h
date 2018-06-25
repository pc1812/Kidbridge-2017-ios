//
//  CustomIOSAlertView.h
//  CustomIOSAlertView
//
//  Created by Richard on 20/09/2013.
//  Copyright (c) 2013-2015 Wimagguc.
//
//  Lincesed under The MIT License (MIT)
//  http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

@interface CustomIOSAlertView : UIView

//提示视图
@property (nonatomic, strong) UIView *dialogView;
//提示视图的子视图（自定义）
@property (nonatomic, strong) UIView *containerView;
//按钮标题数组
@property (nonatomic, strong) NSArray *buttonTitles;

//按钮点击事件
@property (copy) void (^onButtonTouchUpInside)(CustomIOSAlertView *alertView, int buttonIndex) ;
//初始化
- (id)init;
//显示
- (void)show;
//关闭
- (void)close;
//设置子视图
- (void)setSubView: (UIView *)subView;
//设置按钮点击事件
- (void)setOnButtonTouchUpInside:(void (^)(CustomIOSAlertView *alertView, int buttonIndex))onButtonTouchUpInside;
//设备旋转，横向/竖向改变
- (void)deviceOrientationDidChange: (NSNotification *)notification;

- (void)dealloc;

@end
