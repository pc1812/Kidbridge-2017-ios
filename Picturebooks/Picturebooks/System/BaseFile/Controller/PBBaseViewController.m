//
//  PBBaseViewController.m
//  PictureBook
//
//  Created by Yasin on 2017/7/7.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "PBBaseViewController.h"
#import "RootViewController.h"

@interface PBBaseViewController ()<UIGestureRecognizerDelegate>

@property(nullable, nonatomic, weak) id<UINavigationControllerDelegate> delegate;
@property(nullable, nonatomic, readonly) UIGestureRecognizer *interactivePopGestureRecognizer NS_AVAILABLE_IOS(7_0) __TVOS_PROHIBITED;

@end

@implementation PBBaseViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (IOS7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;      // 手势有效设置为YES  无效为NO
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
    if (@available(iOS 11, *)) {
        [UIScrollView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever; //iOS11 解决SafeArea的问题，同时能解决pop时上级页面scrollView抖动的问题
    }
    
    self.navigationController.navigationBar.barTintColor = RGBHex(0x14d02f);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18 weight:2], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.view.backgroundColor = RGBHex(0xefeff4);
    
    if (self.navigationController.childViewControllers.count > 1) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25 + 20, 40)];
        [button setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        // 内容水平左对齐
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        
        [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        button.adjustsImageWhenHighlighted = NO;
//        [button sizeToFit];
        UIView *containView = [[UIView alloc] initWithFrame:button.bounds];
        [containView addSubview:button];
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:containView];
        self.navigationItem.leftBarButtonItem = barButton;
        
    }
    
}

#pragma mark ---- 返回方法
- (void)back {
    [self back:YES];
}

- (void)back:(BOOL)animated {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)requestSystemTime{
    
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
