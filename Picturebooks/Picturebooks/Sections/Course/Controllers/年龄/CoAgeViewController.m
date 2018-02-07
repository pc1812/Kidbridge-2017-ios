//
//  CoAgeViewController.m
//  PictureBook
//
//  Created by Yasin on 2017/7/8.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "CoAgeViewController.h"
#import "SegmentTapView.h"
#import "FlipTableView.h"
#import "COThreeViewController.h"
#import "COSixViewController.h"
#import "CONineViewController.h"

@interface CoAgeViewController ()<SegmentTapViewDelegate,FlipTableViewDelegate, UIScrollViewDelegate>

@property(nonatomic,strong)FlipTableView *flipView;
@property(nonatomic,strong)SegmentTapView *segment;
@property(nonatomic,strong)NSMutableArray *controllsArray;
@property(nonatomic,strong)UIScrollView *scrollView;
@end

@implementation CoAgeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView = [UINavigationItem titleViewForTitle:@"适合年龄"];
    
    [self initSegment];
    [self initFlipTableView];
    if ([self.index integerValue] == 1 ) {
        [self.segment selectIndex:1];
         self.scrollView.contentOffset = CGPointMake(SCREEN_WIDTH * 0, 0);
    }else if ([self.index integerValue] == 2 ) {
        [self.segment selectIndex:2];
        self.scrollView.contentOffset = CGPointMake(SCREEN_WIDTH * 1, 0);
    }else if ([self.index integerValue] == 3 ) {
        [self.segment selectIndex:3];
       self.scrollView.contentOffset = CGPointMake(SCREEN_WIDTH * 2, 0);
    }
    
}

-(void)initSegment{
    if (IS_IPHONE5()) {
        self.segment = [[SegmentTapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44) withDataArray:[NSArray arrayWithObjects:@"3-5岁",@"6-8岁",@"9-12岁",nil] withFont:14];
        self.segment.delegate = self;
        self.segment.backgroundColor=[Global convertHexToRGB:@"f7f7f7"];
        [self.view addSubview:self.segment];
    }else{
        self.segment = [[SegmentTapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44) withDataArray:[NSArray arrayWithObjects:@"3-5岁",@"6-8岁",@"9-12岁",nil] withFont:16];
        self.segment.delegate = self;
        self.segment.backgroundColor=[Global convertHexToRGB:@"f7f7f7"];
        [self.view addSubview:self.segment];
    }
}

-(void)initFlipTableView{
    if (!self.controllsArray){
        self.controllsArray = [[NSMutableArray alloc] init];
    }
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT-PBNew64-44)];
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 3, 0);
    COThreeViewController *v1 = [[COThreeViewController alloc] init];
    [self addChildViewController:v1];
    [self.scrollView addSubview:v1.view];
    v1.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-PBNew64-44);
    
    COSixViewController *v2 = [[COSixViewController alloc] init];
    [self addChildViewController:v2];
    [self.scrollView addSubview:v2.view];
    v2.view.frame = CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT-PBNew64-44);
    
    
    CONineViewController *v3 = [[CONineViewController alloc] init];
    [self addChildViewController:v3];
    [self.scrollView addSubview:v3.view];
    v3.view.frame = CGRectMake(SCREEN_WIDTH * 2, 0, SCREEN_WIDTH, SCREEN_HEIGHT-PBNew64-44);
    
    [self.controllsArray addObject:v1];
    [self.controllsArray addObject:v2];
    [self.controllsArray addObject:v3];
    
   
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int index = scrollView.contentOffset.x / SCREEN_WIDTH;
    NSLog(@"---index%d", index);
    [self.segment selectIndex:index + 1];
}

#pragma mark -------- select Index
-(void)selectedIndex:(NSInteger)index{
    self.scrollView.contentOffset = CGPointMake(SCREEN_WIDTH * index, 0);
    //[self.flipView selectIndex:index];
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
