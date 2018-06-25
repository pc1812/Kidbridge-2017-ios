//
//  MineReadViewController.m
//  PictureBook
//
//  Created by Yasin on 2017/7/11.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "MineReadViewController.h"
#import "MinePicReadViewController.h"
#import "MineCoReadViewController.h"
#import "SegmentTapView.h"
#import "FlipTableView.h"

@interface MineReadViewController ()<SegmentTapViewDelegate,FlipTableViewDelegate>

@property(nonatomic,strong)FlipTableView *flipView;
@property(nonatomic,strong)SegmentTapView *segment;
@property(nonatomic,strong)NSMutableArray *controllsArray;
@property(nonatomic)UIButton *rightBtn;//右上角btn
@property(nonatomic,strong)MinePicReadViewController *v1;

@end

@implementation MineReadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView = [UINavigationItem titleViewForTitle:@"我的跟读"];

    self.rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightBtn.frame=CGRectMake(0, 0, 40, 40);
    [self.rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [self.rightBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [self.rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.rightBtn addTarget:self  action:@selector(editMessage:) forControlEvents:UIControlEventTouchUpInside];
    //self.rightBtn=button;
    UIView *containView = [[UIView alloc] initWithFrame: self.rightBtn.bounds];
    [containView addSubview: self.rightBtn];
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:containView];
    
    [self initSegment];
    [self initFlipTableView];
}

- (void)editMessage:(UIButton *)button{
    button.selected = !button.selected;
    if (button.selected) {
        [self.rightBtn setTitle:@"取消" forState:UIControlStateNormal];
        self.v1.editMessageStaue = YES;
    }else{
        [self.rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
        self.v1.editMessageStaue = NO;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"edit" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

-(void)initSegment{
    if (IS_IPHONE5()) {
        self.segment = [[SegmentTapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44) withDataArray:[NSArray arrayWithObjects:@"绘本跟读",@"课程跟读",nil] withFont:14];
        self.segment.delegate = self;
        self.segment.backgroundColor=[Global convertHexToRGB:@"f7f7f7"];
        [self.view addSubview:self.segment];
        
    }else{
        self.segment = [[SegmentTapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44) withDataArray:[NSArray arrayWithObjects:@"绘本跟读",@"课程跟读",nil] withFont:16];
        self.segment.delegate = self;
        self.segment.backgroundColor=[Global convertHexToRGB:@"f7f7f7"];
        [self.view addSubview:self.segment];
    }
}

-(void)initFlipTableView{
    if (!self.controllsArray){
        self.controllsArray = [[NSMutableArray alloc] init];
    }
    
    self.v1 = [[MinePicReadViewController alloc] init];
    [self addChildViewController:  self.v1];
    
    MineCoReadViewController *v2 = [[MineCoReadViewController alloc] init];
    [self addChildViewController:v2];

    [self.controllsArray addObject:  self.v1];
    [self.controllsArray addObject:v2];

    self.flipView = [[FlipTableView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT-PBNew64-44) withArray:_controllsArray];
    self.flipView.delegate = self;
    [self.view addSubview:self.flipView];
}

#pragma mark -------- select Index
-(void)selectedIndex:(NSInteger)index{
    [self.flipView selectIndex:index];
    if (index == 0) {
        [self.rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
        self.rightBtn.hidden = NO;
    }else{
       self.rightBtn.hidden = YES;
    }
}

-(void)scrollChangeToIndex:(NSInteger)index{
    [self.segment selectIndex:index];
    NSLog(@"-----%ld", index);
    if (index == 1) {
        [self.rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
        self.rightBtn.hidden = NO;
    }else{
        self.rightBtn.hidden = YES;
        
    }

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
