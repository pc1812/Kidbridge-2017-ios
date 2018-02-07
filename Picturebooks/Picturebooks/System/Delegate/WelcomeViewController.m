//
//  WelcomeViewController.m
//  Picturebooks
//
//  Created by 尹凯 on 2017/8/12.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController ()<UIScrollViewDelegate>

@property (nonatomic, retain) UIScrollView *scrollView;

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen]bounds]];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];

    NSMutableArray *imageArray = [NSMutableArray arrayWithObjects:@"first",@"second",@"third", nil];
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * imageArray.count, 0);
    
    for (int i =0; i < imageArray.count; i++) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH * i, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        imageView.image = [UIImage imageNamed:[imageArray objectAtIndex:i]];
        [self.scrollView addSubview:imageView];
        
        if (i == 2) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
            imageView.userInteractionEnabled = YES;
            [imageView addGestureRecognizer:tap];
        }
    }
    
    //设置按页滑动
    self.scrollView.pagingEnabled = YES;
    //取消边界反弹效果(默认是开启)
    self.scrollView.bounces = NO;
    //是否显示水平滑动条
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.directionalLockEnabled = YES;
    self.scrollView.contentOffset = CGPointMake(0, 0);
    self.scrollView.delegate = self;
}

-(void)tapAction:(UITapGestureRecognizer *)tap{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeRootViewController" object:@"fromWelcome"];
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
