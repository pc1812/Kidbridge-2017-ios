//
//  MineAboutViewController.m
//  PictureBook
//
//  Created by Yasin on 2017/7/10.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "MineAboutViewController.h"

@interface MineAboutViewController ()

@end

@implementation MineAboutViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView=[UINavigationItem titleViewForTitle:@"关于我们"];
    
    UIImageView *logoImg = [UIImageView new];
    [self.view addSubview:logoImg];
    logoImg.image = [UIImage imageNamed:@"login_headimage"];
    logoImg.frame = FRAMEMAKE_F((SCREEN_WIDTH - 80) / 2, PBNew64, 80, 80);
    logoImg.aliCornerRadius = 40;
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    UILabel *desLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(logoImg.frame) + 50, SCREEN_WIDTH, 15)];
    desLabel.textColor=[UIColor blackColor];
    desLabel.font=[UIFont systemFontOfSize:15];
    desLabel.textAlignment=NSTextAlignmentCenter;
    desLabel.text=[NSString stringWithFormat:@"本软件版本为V%@", appVersion];
    [self fuwenbenLabel:desLabel FontNumber:[UIFont systemFontOfSize:15] AndRange:NSMakeRange(6, appVersion.length + 1) AndColor:[Global convertHexToRGB:@"14d02f"]];
    [self.view addSubview:desLabel];
    
    UILabel *proLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(desLabel.frame) + 20, SCREEN_WIDTH, 15)];
    proLabel.textColor=[UIColor blackColor];
    proLabel.font=[UIFont systemFontOfSize:15];
    proLabel.textAlignment=NSTextAlignmentCenter;
    proLabel.text= @"本产品的最终解释权归属藤桥教育科技(上海)有限公司";
    [self.view addSubview:proLabel];

    UILabel *proLabel1=[[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(proLabel.frame) + 20, SCREEN_WIDTH, 15)];
    proLabel1.textColor=[UIColor blackColor];
    proLabel1.font=[UIFont systemFontOfSize:15];
    proLabel1.textAlignment=NSTextAlignmentCenter;
    proLabel1.text= @"使用协议版本声明";
    [self.view addSubview:proLabel1];
}

//设置不同字体颜色
-(void)fuwenbenLabel:(UILabel *)labell FontNumber:(id)font AndRange:(NSRange)range AndColor:(UIColor *)vaColor{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:labell.text];
    //设置字号
    [str addAttribute:NSFontAttributeName value:font range:range];
    //设置文字颜色
    [str addAttribute:NSForegroundColorAttributeName value:vaColor range:range];
    labell.attributedText = str;
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
