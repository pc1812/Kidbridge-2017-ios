//
//  COThreeViewController.m
//  PictureBook
//
//  Created by Yasin on 2017/7/8.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "COThreeViewController.h"
#import "CourseCollectionViewCell.h"
#import "CourseModel.h"
#import "CourseDetailViewController.h"

static NSString * const collectionIdentifier = @"collectionIdentifier";

@interface COThreeViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong)UICollectionView *collectionView;
@property (nonatomic) NSInteger pageNum;//页数
@property (nonatomic) BOOL isMorePage;
@property (nonatomic, strong)NSMutableArray *dataSource;
@property (nonatomic) NSInteger full;

@end

@implementation COThreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    
    self.collectionView.mj_header=[MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _pageNum=0;
        [self loadData];
        [self.collectionView.mj_header endRefreshing];
    }];
    self.collectionView.mj_footer=[MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (_isMorePage) {
            _pageNum++;
            [self loadData];
        }
        [self.collectionView.mj_footer endRefreshing];
    }];
    // 马上进入刷新状态
    [self.collectionView.mj_header beginRefreshing];
    
}

-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        self.dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSource;
}

- (void)loadData{
    //得到基本固定参数字典，加入调用接口所需参数
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:COURSE_LIST forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:@(_pageNum * kOffset) forKey:@"offset"];
    [parame setObject:@(kOffset) forKey:@"limit"];
    [parame setObject:@(0) forKey:@"fit"];
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.labelText = @"加载中...";
    HUD.backgroundColor = [UIColor clearColor];
    
    [[HttpManager sharedManager] POST:COURSE_LIST parame:parame sucess:^(id success) {
        
        if ([success[@"event"] isEqualToString:@"SUCCESS"]) {
            [HUD hide:YES];
            
            if (_pageNum == 0) {
                [self.dataSource removeAllObjects];
            }
            NSMutableArray *boyarray= success[@"data"];
            if (![boyarray isEqual:[NSNull null]]) {
                for (NSDictionary *dic in boyarray) {
                    CourseModel *courseModel = [CourseModel modelWithDictionary:dic];
                    [self.dataSource addObject:courseModel];
                }
            }
            NSInteger total = 0;
            total = self.dataSource.count;
            NSInteger totalPages = total / kOffset;
            
            if (self.pageNum >= totalPages) {
                _isMorePage = NO;
                if (total > 0) {
                    self.collectionView.mj_footer.state = MJRefreshStateNoMoreData;
                }else{
                    self.collectionView.mj_footer.state = MJRefreshStateWillRefresh;
                }
            }else{
                self.collectionView.mj_footer.state = MJRefreshStateIdle;
                _isMorePage = YES;
            }
            [self.collectionView reloadData];
        }
    } failure:^(NSError *error) {
        [HUD hide:YES ];
        [Global showWithView:self.view withText:@"网络错误"];
    }];
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumInteritemSpacing = 12;
        layout.minimumLineSpacing = 12;
        layout.sectionInset = UIEdgeInsetsMake(12, 12, 12, 12);
        layout.itemSize = CGSizeMake(SCREEN_WIDTH - 36, 50 + (SCREEN_WIDTH - 36) *5/9);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - PBNew64 - 44) collectionViewLayout:layout];
        _collectionView.backgroundColor = RGBHex(0xf0f0f0);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[CourseCollectionViewCell class] forCellWithReuseIdentifier:collectionIdentifier];
      
        
    }
    return _collectionView;
}

#pragma mark - collectionView代理方法实现
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CourseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionIdentifier forIndexPath:indexPath];
    CourseModel *model = self.dataSource[indexPath.row];
    NSString * url = [NSString stringWithFormat:@"%@%@", Qiniu_host, model.icon[0]];
    [cell.photoImg sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"head_placeholder"]];
    if (model.lock == 1) {
        cell.lockImage.hidden = YES;
    }else{
        cell.lockImage.hidden = NO;
    }

    NSString *courseStr;
    if (model.status == 0) {
        courseStr = [NSString stringWithFormat:@"%ld/%ld", (long)model.enter, (long)model.limit];
    }else if (model.status == 1){
        courseStr = @"正在开课";
    }else{
        courseStr = @"已结束";
    }
    [cell setName:model.name age:model.age course:courseStr day:[NSString stringWithFormat:@"%ld", (long)model.cycle] price:[NSString stringWithFormat:@"¥%.2f", model.price] water:@"" array:model.tag];
    
    return cell;
}

//点击
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    CourseModel *courseModel = self.dataSource[indexPath.row];
  
    if (courseModel.enter == courseModel.limit) {
        self.full = 1;
    }
    CourseDetailViewController *courseVC = [[CourseDetailViewController alloc] init];
    courseVC.name = courseModel.name;
    courseVC.courseId = courseModel.ID;
    courseVC.status = courseModel.status;
    courseVC.full = self.full;
    
    courseVC.callback = ^(NSString *value) {
        if (value.length == 0) {
            return ;
        }
        courseModel.lock = 1;
        [self.dataSource replaceObjectAtIndex:indexPath.row withObject:courseModel];
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    
    };
    
    [self.navigationController pushViewController:courseVC animated:YES];
}

//设置每个分区页眉的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    return CGSizeMake(SCREEN_WIDTH, 0.01f);
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
