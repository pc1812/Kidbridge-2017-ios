//
//  RootViewController.m
//  PictureBook
//
//  Created by Yasin on 2017/7/7.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "RootViewController.h"
#import "PictureViewController.h"
#import "CourseViewController.h"
#import "MineViewController.h"
#import "LLLMyTabBar.h"
#import "PBNavViewController.h"

@interface RootViewController ()<LLLMyTabBarDelegate, UITabBarControllerDelegate>

@property(nonatomic,weak)LLLMyTabBar *customTabBar2;//自定义tabbar

@end

@implementation RootViewController

- (void)dealloc{
    NSLog(@"根视图控制器没有内存泄漏");
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

  
}


- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
   
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self creatTarBar];
    [self childAllChildViewControllers];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

#pragma mark ------初始化tabbar
-(void)creatTarBar
{
    LLLMyTabBar *customTabBar = [[LLLMyTabBar alloc]init];
    customTabBar.frame = self.tabBar.bounds;
    customTabBar.delegate = self;
    //[self.tabBar addSubview:customTabBar];
   [self.tabBar bringSubviewToFront:customTabBar];
    self.customTabBar2 = customTabBar;
}

-(void)fromPosition:(NSNotification *)noti{
    NSDictionary *dic=noti.userInfo;
    self.customTabBar2.seletedButton.selected = NO;
    self.customTabBar2.nomarlButton = (UIButton *) [self.customTabBar2 viewWithTag:[dic[@"selectTabbar"] integerValue]];
    self.customTabBar2.nomarlButton.selected = YES;
    self.customTabBar2.seletedButton = self.customTabBar2.nomarlButton;
    self.selectedIndex = [dic[@"selectTabbar"] integerValue];
}

-(void)tarBar:(LLLMyTabBar *)tabBar didSeletedButtonFrom:(int)from to:(int)to
{
    self.selectedIndex=to;
}

#pragma mark ------初始化所有的子控制器
-(void)childAllChildViewControllers{
    
    PictureViewController *picture = [[PictureViewController alloc]init];
    [self setupChildViewController:picture title:@"绘本馆" imageName:@"tab_pic" seletedImageName:@"tab_picselect"];
    
    CourseViewController *course = [[CourseViewController alloc]init];
    [self setupChildViewController:course title:@"课程馆" imageName:@"tab_course" seletedImageName:@"tab_courseselect"];
    
    MineViewController *mine=[[MineViewController alloc]init];
    [self setupChildViewController:mine title:@"我的" imageName:@"tab_mine" seletedImageName:@"tab_mineselect"];
}

-(void)setupChildViewController:(UIViewController *)childVC title:(NSString *)title imageName:(NSString *)imageName seletedImageName:(NSString *)seletedIamge
{
    childVC.tabBarItem.title=title;
    childVC.tabBarItem.image=[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childVC.tabBarItem.selectedImage=[[UIImage imageNamed:seletedIamge]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];//告诉模拟器不要渲染，总是显示原来的图片
   self.tabBar.tintColor = [UIColor blackColor];
   self.tabBar.barTintColor = [UIColor whiteColor];
    PBNavViewController *nav=[[PBNavViewController alloc]initWithRootViewController:childVC];
    
    [self addChildViewController:nav];
    //添加tabbar内部的按钮
    [self.customTabBar2 addTabBarButtonWithItem:childVC.tabBarItem];
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
