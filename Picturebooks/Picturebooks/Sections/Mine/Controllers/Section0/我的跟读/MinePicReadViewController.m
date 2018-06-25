//
//  MinePicReadViewController.m
//  PictureBook
//
//  Created by Yasin on 2017/7/12.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "MinePicReadViewController.h"
#import "MineCollectionViewCell.h"
#import "PictureModel.h"
#import "MineReadModel.h"
#import "MineShadowViewController.h"

static NSString * const collectionIdentifier = @"collectionViewIdentifier";

@interface MinePicReadViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong)UICollectionView *collectionView;
@property (nonatomic, strong)UIView *footView;
@property (nonatomic, strong)NSIndexPath *indexPath;
@property (nonatomic, strong)UIButton *rightBtn;//右上角btn
@property (nonatomic, strong) UIButton *selBtn;
@property (nonatomic, strong) NSMutableIndexSet* selectedIndexSet;

@property (nonatomic, assign) NSInteger pageNum;//页数
@property (nonatomic, assign) BOOL isMorePage;
@property (nonatomic, strong)NSMutableArray *dataSource;
@property(nonatomic)UIImageView *noSearchImageView;
@property(nonatomic)UILabel *noLabel;
@end

@implementation MinePicReadViewController
{
    UIButton *_allSelectBtn;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(edit) name:@"edit" object:nil];
    _selBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
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
-(UILabel *)noLabel
{
    if (!_noLabel) {
        self.noLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-250)/2, (SCREEN_HEIGHT-100-44-250)/2, 250, 250)];
        self.noLabel.backgroundColor=[UIColor clearColor];
        self.noLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.noLabel];
        
    }
    return _noLabel;
}

//-(UIImageView *)noSearchImageView
//{
//    if (!_noSearchImageView) {
//        self.noSearchImageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-250)/2, (SCREEN_HEIGHT-100-44-250)/2, 250, 250)];
//        self.noSearchImageView.backgroundColor=[UIColor clearColor];
//        [self.view addSubview:self.noSearchImageView];
//        
//    }
//    return _noSearchImageView;
//}
//

-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSource;
}

- (void)loadData{
    _allSelectBtn.selected = NO;
    //得到基本固定参数字典，加入调用接口所需参数
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:USER_READ forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:@(_pageNum * kOffset) forKey:@"offset"];
    [parame setObject:@(kOffset) forKey:@"limit"];
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.labelText = @"加载中...";
    HUD.backgroundColor = [UIColor clearColor];
    
    [[HttpManager sharedManager] POST:USER_READ parame:parame sucess:^(id success) {
        
        if ([success[@"event"] isEqualToString:@"SUCCESS"]) {
            NSLog(@"%@", [success objectForKey:@"data"]);
            [HUD hide:YES];
            if (_pageNum == 0) {
                [self.dataSource removeAllObjects];
            }
            NSMutableArray *boyarray= success[@"data"];
            if (![boyarray isEqual:[NSNull null]]) {
                for (NSDictionary *dic in boyarray) {
                    MineReadModel *model = [MineReadModel modelWithDictionary:dic];
                    [self.dataSource addObject:model];
                }
            }
            
            if (self.dataSource.count) {
                self.noLabel.text = @"";
            }else{
                self.noLabel.text = @"暂无数据";

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
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - PBNew64 - 44) collectionViewLayout:layout];
        _collectionView.backgroundColor = RGBHex(0xf0f0f0);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[MineCollectionViewCell class] forCellWithReuseIdentifier:collectionIdentifier];
    }
    return _collectionView;
}

//编辑
- (void)edit{
    [self.view addSubview:self.footView];
    if (self.editMessageStaue) {
        self.footView.hidden = NO;
        _allSelectBtn.selected = NO;
        _collectionView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - PBNew64 - 44 - 40);
        _collectionView.allowsMultipleSelection = YES;
        [_collectionView reloadData];
    }else{
        self.footView.hidden = YES;
         _collectionView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - PBNew64 - 44);
        _collectionView.allowsMultipleSelection = NO;
        [_collectionView reloadData];
    }
}

- (UIView *)footView{
    if (!_footView) {
        _footView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - PBNew64 - 44 - 40, SCREEN_WIDTH, 40)];
        _footView.backgroundColor = [UIColor whiteColor];
        
        UIImage *image = [UIImage imageNamed:@"m_bounsel"];
        UILabel *allLab = [UILabel new];
        LabelSet(allLab, @"全选", [UIColor blackColor], 15, allDic, allSize);
        allLab.frame = FRAMEMAKE_F(_footView.frame.size.width / 2 - 30 - allSize.width, (CGRectGetHeight(_footView.frame) - allSize.height) / 2 , allSize.width, allSize.height);
        //添加全选图片按钮
        _allSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _allSelectBtn.frame = CGRectMake(_footView.frame.size.width / 2 - 40 - image.size.width -  allSize.width, (CGRectGetHeight(_footView.frame) - image.size.height) / 2, image.size.width + allSize.width + 10, image.size.height);
        [_allSelectBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_allSelectBtn setImage:image forState:UIControlStateNormal];
        [_allSelectBtn setImage:[UIImage imageNamed:@"m_bosel"] forState:UIControlStateSelected];
        [_allSelectBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_footView addSubview:allLab];
        [_footView addSubview:_allSelectBtn];
        
        UIImage *image1 = [UIImage imageNamed:@"m_del"];
        UILabel *delLab = [UILabel new];
        LabelSet(delLab, @"删除", [UIColor blackColor], 15, delDic, delSize);
        delLab.frame = FRAMEMAKE_F(_footView.frame.size.width / 2 + 40 + image1.size.width, (CGRectGetHeight(_footView.frame) - delSize.height) / 2 , delSize.width, delSize.height);
        //添加全选图片按钮
        UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        delBtn.frame = CGRectMake(_footView.frame.size.width / 2 + 30 , (CGRectGetHeight(_footView.frame) - image1.size.height) / 2, image1.size.width + delSize.width + 10, image1.size.height);
        [delBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [delBtn setImage:image1 forState:UIControlStateNormal];
        [delBtn addTarget:self action:@selector(delBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_footView addSubview:delLab];
        [_footView addSubview:delBtn];
    }
    return _footView;
}

//全选
- (void)selectBtnClick:(UIButton *)button{
    button.selected = !button.selected;
    if (button.selected) {
        // 多选时
        for (int i = 0; i< self.dataSource.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:
                                                         i inSection:0];
             [_collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        }
    }else{
        NSArray *indexs = _collectionView.indexPathsForSelectedItems;
        for (NSIndexPath *ind in indexs) {
            [_collectionView deselectItemAtIndexPath:ind animated:true];
        }
    }
}

//删除
- (void)delBtnClick:(UIButton *)button{
    NSArray *indexs = _collectionView.indexPathsForSelectedItems;
    NSMutableArray *mArr = [NSMutableArray array];
    
    for (NSIndexPath *ind in indexs) {
        [mArr addObject:[NSString stringWithFormat:@"%ld", (long)ind.row]];
    }
    NSMutableArray *deleteArr = [NSMutableArray arrayWithCapacity:0];
    for (NSString *str in mArr) {
        MineReadModel *model = self.dataSource[[str integerValue]];
        //[self deleteMessage:model.readId];
        [deleteArr addObject:@(model.readId)];
    }
    
    [self deleteMessage:deleteArr];
}

//删除之后重新刷新数据就OK了
-(void)deleteMessage:(NSArray *)messageArr{
    NSLog(@"-----数字%@", messageArr);
    if (messageArr.count == 0 ) {
        [Global showWithView:self.view withText:@"请选择要删除的绘本"];
        return;
    }
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.backgroundColor = [UIColor clearColor];
    
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:USER_PICTUREDEL forKey:@"uri"];
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
   
    [parame setObject:messageArr forKey:@"id"];
    
    [[HttpManager sharedManager]POST:USER_PICTUREDEL parame:parame sucess:^(id success) {
        [HUD hide:YES];
        if ([success[@"event"] isEqualToString:@"SUCCESS"]){
            [Global showWithView:self.view withText:@"删除成功！"];
          
            // 马上进入刷新状态
            [self.collectionView.mj_header beginRefreshing];
            
        }else{
             [Global showWithView:self.view withText:[success objectForKey:@"describe"]];
        }
    } failure:^(NSError *error) {
        
        
        [HUD hide:YES];
        [Global showWithView:self.view withText:@"网络错误"];
        
    }];

}

#pragma mark - collectionView代理方法实现
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MineCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionIdentifier forIndexPath:indexPath];

    if (_editMessageStaue) {
        cell.selbtn.hidden = NO;
        [cell.selbtn addTarget:self action:@selector(selectClick:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        cell.selbtn.hidden = YES;
    }
  
    MineReadModel *model = self.dataSource[indexPath.row];

    NSString * url = [NSString stringWithFormat:@"%@%@", Qiniu_host, model.picModel.icon[0]];
    [cell.picImage sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"con_placeholder"]];
    cell.nameLabel.text = model.picModel.name;
    
    // 判断标签数组为空
    if (model.picModel.tag.count) {
        cell.tagLabel.text = model.picModel.tag[0];
    } else {
        cell.tagLabel.text = @"";
    }
    
    NSString *ageStr;
    if (model.picModel.fit == 0) {
        ageStr = @"3-5岁";
    }else if (model.picModel.fit == 1){
        ageStr = @"6-8岁";
    }else if (model.picModel.fit == 3){
        ageStr = @"4-7岁";
    }else if (model.picModel.fit == 4){
        ageStr = @"8-10岁";
    }else{
        ageStr = @"9-12岁";
    }
    cell.ageLabel.hidden = YES;
    cell.freeLabel.text = ageStr;

    return cell;
}

- (void)selectClick:(UIButton *)button{
    
}

//点击
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (_editMessageStaue){
    
    }else{
        MineShadowViewController *mineReadVC = [[MineShadowViewController alloc] init];
        MineReadModel *model = self.dataSource[indexPath.row];
        mineReadVC.readId = model.readId;
        mineReadVC.nameStr = model.picModel.name;
        mineReadVC.urlStr = USER_READDETAIL;
        mineReadVC.commentUrl = USER_COMMENT;
        mineReadVC.picRepeatType = PicRepeatAppreciation;
        mineReadVC.likeUrl = USER_LIKE;
        mineReadVC.rewardUrl =  PIC_RepeatReward;
        mineReadVC.bottomTitle = @"评价";
        [self.navigationController pushViewController:mineReadVC animated:YES];
    }
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
