//
//  MineRecordViewController.m
//  Picturebooks
//
//  Created by Yasin on 2017/9/7.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "MineRecordViewController.h"
#import "MainCollectionViewCell.h"
#import "MineCoPicModel.h"
#import "MineShadowViewController.h"
#import "WXZCustomPickView.h"
#import "MineCoDateModel.h"
static NSString * const collectionIdentifier = @"collectionViewIdentifier";
@interface MineRecordViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, CustomPickViewDelegate>
@property (nonatomic, strong)UICollectionView *collectionView;
@property (nonatomic, strong)NSMutableArray *dataSource;
@property (nonatomic, strong)NSMutableArray *repeatArr;
@property (nonatomic, assign)BOOL isMorePage;
@property (nonatomic, assign)NSInteger pageNum;//页数
@property (nonatomic, copy)NSString *picName;
@end

@implementation MineRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView = [UINavigationItem titleViewForTitle:@"跟读记录"];
    [self.view addSubview:self.collectionView];
    
    self.repeatArr = [NSMutableArray array];
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
    
    
    // Do any additional setup after loading the view.
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
    [parame setObject:MINE_COURSE_Record forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:@(self.readId) forKey:@"id"];
    [parame setObject:@(_pageNum * kOffset) forKey:@"offset"];
    [parame setObject:@(kOffset) forKey:@"limit"];
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.labelText = @"加载中...";
    HUD.backgroundColor = [UIColor clearColor];
    
    [[HttpManager sharedManager] POST:MINE_COURSE_Record parame:parame sucess:^(id success) {
        
        if ([success[@"event"] isEqualToString:@"SUCCESS"]) {
            [HUD hide:YES];
            if (_pageNum == 0) {
                [self.dataSource removeAllObjects];
            }
            NSMutableArray *boyarray= success[@"data"];
            if (![boyarray isEqual:[NSNull null]]) {
                for (NSDictionary *dic in boyarray) {
                    MineCoPicModel *carouselModel = [MineCoPicModel modelWithDictionary:dic];
                    [self.dataSource addObject:carouselModel];
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
        layout.sectionInset = UIEdgeInsetsMake(12, 11.5, 12, 11.5);
        layout.itemSize = CGSizeMake((SCREEN_WIDTH - 35) / 2, 55 + ((SCREEN_WIDTH - 35) / 2) * 3/4);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - PBNew64) collectionViewLayout:layout];
        _collectionView.backgroundColor = RGBHex(0xf0f0f0);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        
        [_collectionView registerClass:[MainCollectionViewCell class] forCellWithReuseIdentifier:collectionIdentifier];
      
    }
    return _collectionView;
}

#pragma mark - collectionView代理方法实现
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
   
    MainCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionIdentifier forIndexPath:indexPath];
    MineCoPicModel *model = self.dataSource[indexPath.row];
    NSString * url = [NSString stringWithFormat:@"%@%@", Qiniu_host, model.icon[0]];
    [cell.picImage sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"con_placeholder"]];
    cell.nameLabel.text = model.name;
    
    if (model.tag.count) {
        cell.tagLabel.text = model.tag[0];
    } else {
        cell.tagLabel.text = @"";
    }
    
    cell.lockImage.hidden = YES;
    cell.ageLabel.hidden = YES;
    cell.freeLabel.text = model.age;
    
    return cell;
}

//点击
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    MineCoPicModel *model = self.dataSource[indexPath.row];
    self.picName = model.name;
//    MineShadowViewController *mineReadVC = [[MineShadowViewController alloc] init];
//    mineReadVC.readId = model.dateModel.dateId;
//    mineReadVC.nameStr = model.name;
//    mineReadVC.urlStr = MINE_COURSE_Detail;
//    mineReadVC.commentUrl = MINE_COURSE_Comment;
//    mineReadVC.picRepeatType =  CoRepeatAppreciation;
//    mineReadVC.publishTime = model.dateModel.time;
//    mineReadVC.likeUrl = USERCO_LIKE;
//    mineReadVC.rewardUrl =  COURSE_RepeatReward;
//    [self.navigationController pushViewController:mineReadVC animated:YES];
    NSMutableArray *dateArr = [NSMutableArray array];
    for (MineCoDateModel *dateModel in model.dateArr) {
        [dateArr addObject:dateModel.time];
        [self.repeatArr addObject:[NSString stringWithFormat:@"%ld", dateModel.dateId]];
    }
    
   
    //NSMutableArray *arrayData = [NSMutableArray arrayWithObjects:@"2k以下",@"2k-5k",@"5k-10k",@"10k-15k",@"15k-25k",@"25k-50k",@"50k以上", nil];
    
    WXZCustomPickView *pickerSingle = [[WXZCustomPickView alloc]init];
    
    [pickerSingle setDataArray:dateArr];
    [pickerSingle setDefalutSelectRowStr:dateArr[0]];
    
    
    [pickerSingle setDelegate:self];
    
    [pickerSingle show];
    [self.view endEditing:YES];
}
-(void)customPickView:(WXZCustomPickView *)customPickView selectedTitle:(NSString *)selectedTitle index:(NSInteger)index{
    NSLog(@"选择%@%ld",selectedTitle, index);
    MineShadowViewController *mineReadVC = [[MineShadowViewController alloc] init];
    mineReadVC.readId = [self.repeatArr[index] integerValue];
    mineReadVC.nameStr = self.picName;
    mineReadVC.urlStr = MINE_COURSE_Detail;
    mineReadVC.commentUrl = MINE_COURSE_Comment;
    mineReadVC.picRepeatType =  CoRepeatAppreciation;
    //mineReadVC.publishTime = model.dateModel.time;
    mineReadVC.likeUrl = USERCO_LIKE;
    mineReadVC.rewardUrl =  COURSE_RepeatReward;
    mineReadVC.picPushShow = YES;
    [self.navigationController pushViewController:mineReadVC animated:YES];
}

#pragma mark - 头脚高度
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(SCREEN_WIDTH, 0.001);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(SCREEN_WIDTH, 0.001);
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
