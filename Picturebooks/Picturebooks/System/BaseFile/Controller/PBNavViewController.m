 //
//  PBNavViewController.m
//  PictureBook
//
//  Created by Yasin on 2017/7/7.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "PBNavViewController.h"

@interface PBNavViewController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate>


@end

@implementation PBNavViewController
{
    UIScreenEdgePanGestureRecognizer *screenEdgePanGesture;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak PBNavViewController *weakSelf = self;
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.interactivePopGestureRecognizer.delegate = weakSelf;
        self.delegate = weakSelf;
    }
}





- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // 删除系统自带的tabBarButton
//    for (UIView *tabBar in self.tabBarController.tabBar.subviews) {
//        if ([tabBar isKindOfClass:[UIControl class]]) {
//            [tabBar removeFromSuperview];
//        }
//    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    // 删除系统自带的tabBarButton
    //[tabBar isKindOfClass:NSClassFromString(@"UITabBarButton")]
//    for (UIView *tabBar in self.tabBarController.tabBar.subviews) {
//        if ([tabBar isKindOfClass:[UIControl class]]) {
//            [tabBar removeFromSuperview];
//        }
//    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        self.interactivePopGestureRecognizer.enabled = NO;
    }
   
    
    [super pushViewController:viewController animated:animated];
    // 修改tabBra的frame
    CGRect frame = self.tabBarController.tabBar.frame;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height;
    self.tabBarController.tabBar.frame = frame;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
