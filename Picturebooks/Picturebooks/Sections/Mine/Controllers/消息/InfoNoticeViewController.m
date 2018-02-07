//
//  InfoNoticeViewController.m
//  PictureBook
//
//  Created by Yasin on 2017/7/15.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "InfoNoticeViewController.h"
#import "SegmentTapView.h"
#import "FlipTableView.h"
#import "InfoCommentViewController.h"
#import "InfoPushViewController.h"

@interface InfoNoticeViewController ()<SegmentTapViewDelegate,FlipTableViewDelegate>

@property(nonatomic,strong)FlipTableView *flipView;
@property(nonatomic,strong)SegmentTapView *segment;
@property(nonatomic,strong)NSMutableArray *controllsArray;

@end

@implementation InfoNoticeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView = [UINavigationItem titleViewForTitle:@"消息通知"];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setBool:NO forKey:@"info"];
    [userDefault synchronize];
    
    
    [self initSegment];
    [self initFlipTableView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

-(void)initSegment{
    if (IS_IPHONE5()) {
        self.segment = [[SegmentTapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44) withDataArray:[NSArray arrayWithObjects:@"评论消息",@"推送消息",nil] withFont:14];
        self.segment.delegate = self;
        self.segment.backgroundColor=[Global convertHexToRGB:@"f7f7f7"];
        [self.view addSubview:self.segment];
        
    }else{
        self.segment = [[SegmentTapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44) withDataArray:[NSArray arrayWithObjects:@"评论消息",@"推送消息",nil] withFont:16];
        self.segment.delegate = self;
        self.segment.backgroundColor=[Global convertHexToRGB:@"f7f7f7"];
        [self.view addSubview:self.segment];
    }
}

-(void)initFlipTableView{
    if (!self.controllsArray){
        self.controllsArray = [[NSMutableArray alloc] init];
    }
    //评论
    InfoCommentViewController *v1 = [[InfoCommentViewController alloc] init];
    [self addChildViewController:v1];
    //推送
    InfoPushViewController *v2 = [[InfoPushViewController alloc] init];
    [self addChildViewController:v2];
    
    [self.controllsArray addObject:v1];
    [self.controllsArray addObject:v2];
   
    self.flipView = [[FlipTableView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT-PBNew64-44) withArray:_controllsArray];
    self.flipView.delegate = self;
    [self.view addSubview:self.flipView];
}

#pragma mark -------- select Index
-(void)selectedIndex:(NSInteger)index{
    [self.flipView selectIndex:index];
}

-(void)scrollChangeToIndex:(NSInteger)index{
    [self.segment selectIndex:index];
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
