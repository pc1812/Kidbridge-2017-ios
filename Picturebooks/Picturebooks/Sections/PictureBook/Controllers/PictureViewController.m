//
//  PictureViewController.m
//  PictureBook
//
//  Created by Yasin on 2017/7/7.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "PictureViewController.h"
#import "MainCollectionViewCell.h"
#import "NewPagedFlowView.h"
#import "PGIndexBannerSubiew.h"
#import "PicSearchViewController.h"
#import "PicAgeViewController.h"
#import "CardViewController.h"
#import "CarouselModel.h"
#import "WebViewController.h"
#import "PictureModel.h"
#import "PicFreeDetailViewController.h"
#import "CardBookViewController.h"
#import "PicBookModel.h"

static NSString * const reuseIdentifierCell = @"MainCollectionViewCell";
static NSString * const headIdentifierView = @"MainHeaderView";
static NSString * const footIdentifierView = @"footView";

@interface PictureViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,NewPagedFlowViewDelegate, NewPagedFlowViewDataSource,UISearchBarDelegate>
{
    UILabel *_ageLabel;
    UIButton *_ageBtn;
    NSInteger ageIndex;
    NSInteger buttonTag;
}

@property (nonatomic, strong)UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *carouselArray;
@property (nonatomic, strong) NewPagedFlowView *pageFlowView;
@property (nonatomic, strong) NSMutableArray *ageArray;
@property (nonatomic, strong) NSMutableArray *todayArray;
@property (nonatomic, strong) NSMutableArray *hotArray;

@end

@implementation PictureViewController
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (IOS7) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

#pragma mark - Jxd-修改-添加 UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    // 跳转到搜索界面
    PicSearchViewController *shopSearch = [[PicSearchViewController alloc]init];
    [self.navigationController pushViewController:shopSearch animated:YES];
    return NO;
}

#pragma mark - Jxd-修改-添加搜索条
- (void)setUpSearchBarUI
{
    // 标题视图
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH * 0.75, XDHightRatio(33))];
    self.navigationItem.titleView = titleView;
    // 搜索条
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.frame = titleView.bounds;
    [titleView addSubview:searchBar];
    // 设置代理
    searchBar.delegate = self;
    // 修改placeholder字体的尺寸
    searchBar.placeholder = @"请输入绘本名称";
    UITextField * searchField = [searchBar valueForKey:@"_searchField"];
    searchField.leftView = [UIView new]; // 去掉左侧的🔍
    [searchField setValue:[UIFont systemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    // 设置圆角及背景色
    searchBar.backgroundColor = [UIColor whiteColor];
    searchBar.layer.cornerRadius = CGRectGetHeight(searchBar.frame) * 0.5;
    searchBar.layer.masksToBounds = YES;
    [searchBar.layer setBorderWidth:1.5];
    //设置边框的颜色
    [searchBar.layer setBorderColor:[UIColor whiteColor].CGColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
//    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_title"]];
    [self setUpSearchBarUI];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem leftBarButtonItemWithImage:[UIImage imageNamed:@"pic_search"] highlighted:[UIImage imageNamed:@"pic_search"] target:self selector:@selector(search)];
    
    ageIndex = 0;
    buttonTag = 200;
    
    _ageArray = [NSMutableArray array];
    _todayArray = [NSMutableArray array];
    _hotArray = [NSMutableArray array];
    
    [self.view addSubview:self.collectionView];
    // Do any additional setup after loading the view.
    //轮播数据
    [self carouselData];
    //今日打卡
    [self todayData];
    //年龄
    [self ageData];
    //热门书单
    [self hotData];
    
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self carouselData];
        [self todayData];
        [self ageData];
        [self hotData];
        [self.collectionView.mj_header endRefreshing];
    }];
    
}

- (NSMutableArray *)carouselArray{
    if (!_carouselArray) {
        _carouselArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _carouselArray;
}

//轮播数据请求
- (void)carouselData{
    [self.carouselArray removeAllObjects];
    //得到基本固定参数字典，加入调用接口所需参数
    
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:Pageflow_list forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    
    [[HttpManager sharedManager] POST:Pageflow_list parame:parame sucess:^(id success) {
        
        if ([success[@"event"] isEqualToString:@"SUCCESS"]) {
            NSMutableArray *boyarray= success[@"data"];
            if (![boyarray isEqual:[NSNull null]]) {
                for (NSDictionary *dic in boyarray) {
                    CarouselModel *carouselModel = [CarouselModel modelWithDictionary:dic];
                    [self.carouselArray addObject:carouselModel];
                }
            }
        }
       // [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        [self.collectionView reloadData];
    } failure:^(NSError *error) {
        [Global showWithView:self.view withText:@"网络错误"];
    }];
}

//年龄数据
- (void)ageData{
    [self.ageArray removeAllObjects];
    //得到基本固定参数字典，加入调用接口所需参数
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:Picturebook_list forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:@(0 * kOffset) forKey:@"offset"];
    [parame setObject:@(2) forKey:@"limit"];
    [parame setObject:@(ageIndex) forKey:@"fit"];
    
    [[HttpManager sharedManager] POST:Picturebook_list parame:parame sucess:^(id success) {
        [self.ageArray removeAllObjects];
        
        if ([success[@"event"] isEqualToString:@"SUCCESS"]) {
            NSMutableArray *boyarray= success[@"data"];
            if (![boyarray isEqual:[NSNull null]]) {
                for (NSDictionary *dic in boyarray) {
                    PictureModel *carouselModel = [PictureModel modelWithDictionary:dic];
                    [self.ageArray addObject:carouselModel];
                }
            }
           //[self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
             [self.collectionView reloadData];
        }
    } failure:^(NSError *error) {
        [Global showWithView:self.view withText:@"网络错误"];
    }];
}

//今日数据
- (void)todayData{
    [self.todayArray removeAllObjects];
    //得到基本固定参数字典，加入调用接口所需参数
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:PICTUREBOOK_TODAY forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:@(0 * kOffset) forKey:@"offset"];
    [parame setObject:@(2) forKey:@"limit"];
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.labelText = @"加载中...";
    HUD.backgroundColor = [UIColor clearColor];
    [[HttpManager sharedManager] POST:PICTUREBOOK_TODAY parame:parame sucess:^(id success) {
       
        if ([success[@"event"] isEqualToString:@"SUCCESS"]) {
            [HUD hide:YES];
            NSMutableArray *boyarray= success[@"data"];
            if (![boyarray isEqual:[NSNull null]]) {
                for (NSDictionary *dic in boyarray) {
                    PicBookModel *carouselModel = [PicBookModel modelWithDictionary:dic];
                    [self.todayArray addObject:carouselModel];
                }
            }
            //[self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
             [self.collectionView reloadData];
        }
    } failure:^(NSError *error) {
        [HUD hide:YES];
        [Global showWithView:self.view withText:@"网络错误"];
    }];
}

//热门数据
- (void)hotData{
    [self.hotArray removeAllObjects];
    //得到基本固定参数字典，加入调用接口所需参数
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:PICTUREBOOK_HOT forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:@(0 * kOffset) forKey:@"offset"];
    [parame setObject:@(4) forKey:@"limit"];
    
    [[HttpManager sharedManager] POST:PICTUREBOOK_HOT parame:parame sucess:^(id success) {
        
        if ([success[@"event"] isEqualToString:@"SUCCESS"]) {
            NSMutableArray *boyarray= success[@"data"];
            if (![boyarray isEqual:[NSNull null]]) {
                for (NSDictionary *dic in boyarray) {
                    PicBookModel *carouselModel = [PicBookModel modelWithDictionary:dic];
                    [self.hotArray addObject:carouselModel];
                }
            }
            //[self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:2]];
             [self.collectionView reloadData];
        }
    } failure:^(NSError *error) {
        [Global showWithView:self.view withText:@"网络错误"];
    }];
}

#pragma mark - 搜索
//搜索
- (void)search{
#pragma mark - Jxd- 修改:注释掉跳转搜索界面
//    PicSearchViewController *shopSearch = [[PicSearchViewController alloc]init];
//    [self.navigationController pushViewController:shopSearch animated:YES];
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumInteritemSpacing = 12;
        layout.minimumLineSpacing = 12;
        layout.sectionInset = UIEdgeInsetsMake(12, 11.5, 12, 11.5);
        layout.itemSize = CGSizeMake((SCREEN_WIDTH - 35) / 2, 55 + ((SCREEN_WIDTH - 35) / 2) * 3/4); //115
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT -  TabbarHeight - NAVIGATION_HEIGHT) collectionViewLayout:layout];
        
        self.collectionView.backgroundColor = RGBHex(0xf0f0f0);
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.showsVerticalScrollIndicator = NO;
        [self.collectionView registerClass:[MainCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifierCell];
      
        [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headIdentifierView];
        [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footIdentifierView];
    }
    return _collectionView;
}

#pragma mark - collectionView代理方法实现
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section == 0) {
        return self.todayArray.count;
    }else if (section == 1) {
        return self.ageArray.count;
    }else {
        return self.hotArray.count;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return  [self firstCollectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    }else if (indexPath.section == 1){
         return [self secondCollectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    }else{
        return [self thirdCollectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    }
}

- (UICollectionViewCell *)firstCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MainCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifierCell forIndexPath:indexPath];
    PicBookModel *model = self.todayArray[indexPath.row];
    NSString * url = [NSString stringWithFormat:@"%@%@", Qiniu_host, model.icon];
    [cell.picImage sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"con_placeholder"]];
    cell.nameLabel.text = model.name;
    
    // 标签数组为空进行处理
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

- (UICollectionViewCell *)secondCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MainCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifierCell forIndexPath:indexPath];
    PictureModel *model = self.ageArray[indexPath.row];
    NSString * url = [NSString stringWithFormat:@"%@%@", Qiniu_host, model.icon[0]];
    [cell.picImage sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"con_placeholder"]];
    cell.nameLabel.text = model.name;
    
    // 标签数组为空的处理
    if (model.tag.count) {
        cell.tagLabel.text = model.tag[0];
    } else {
        cell.tagLabel.text = @"";
    }
    
    NSString *ageStr;
    if (model.fit == 0) {
        ageStr = @"3-5岁";
    }else if (model.fit == 1){
          ageStr = @"6-8岁";
    }else{
        ageStr = @"9-12岁";
    }
    cell.ageLabel.text = ageStr;
   // NSString *price = [NSString stringWithFormat:@"%.2f", model.price];
    if (model.lock == 1) {
        cell.lockImage.hidden = YES;
        cell.freeLabel.text = @"免费";
        cell.ageLabel.hidden = NO;
    }else{
        cell.freeLabel.text = ageStr;
        cell.ageLabel.hidden = YES;
        cell.lockImage.hidden = NO;
    }
    return cell;
}

- (UICollectionViewCell *)thirdCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MainCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifierCell forIndexPath:indexPath];
    PicBookModel *model = self.hotArray[indexPath.row];
    NSString * url = [NSString stringWithFormat:@"%@%@", Qiniu_host, model.icon];
    [cell.picImage sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"con_placeholder"]];
    cell.nameLabel.text = model.name;
    
    // 标签数组为空的处理
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
    
    if (indexPath.section == 0) {
        PicBookModel *model = self.todayArray[indexPath.row];
        
        CardViewController *cardVC = [[CardViewController alloc] init];
        cardVC.titleStr = model.name;
        cardVC.bookId = model.ID;
        [self.navigationController pushViewController:cardVC animated:YES];
    }else if (indexPath.section == 1) {
        PictureModel *model = self.ageArray[indexPath.row];
        
        PicFreeDetailViewController *freeVC = [[PicFreeDetailViewController alloc] init];
        freeVC.picId = model.ID;
        freeVC.name = model.name;
        [self.navigationController pushViewController:freeVC animated:YES];
    }else{
        PicBookModel *model = self.hotArray[indexPath.row];
        
        CardViewController *cardVC = [[CardViewController alloc] init];
        cardVC.titleStr = model.name;
        cardVC.bookId = model.ID;
        [self.navigationController pushViewController:cardVC animated:YES];
    }
}

#pragma mark - 头脚高度
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return CGSizeMake(SCREEN_WIDTH , SCREEN_WIDTH / 2 + 40);
    } else{
        return CGSizeMake(SCREEN_WIDTH, 30);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeMake(SCREEN_WIDTH, 0.001);
}

#pragma mark - collectionView头视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headIdentifierView forIndexPath:indexPath];
        for (UIView *views in view.subviews) {
            [views removeFromSuperview];
        }
        view.backgroundColor = RGBHex(0xf0f0f0);
        if (indexPath.section == 0) {
            
            [view addSubview:self.pageFlowView];
            [self.pageFlowView reloadData];
            
            UIImageView *titleImg = [[UIImageView alloc] init];
            titleImg.image = [UIImage imageNamed:@"pic_card"];
            titleImg.frame = CGRectMake(12, SCREEN_WIDTH / 2 + 10 + (30 - titleImg.image.size.height) / 2, titleImg.image.size.width, titleImg.image.size.height);
            
            UILabel *_titleLabel = [UILabel new];
            LabelSet(_titleLabel, @"今日打卡", [UIColor blackColor], 16, titleDic, titleSize);
            _titleLabel.frame = FRAMEMAKE_F(CGRectGetMaxX(titleImg.frame) + 10, SCREEN_WIDTH / 2 + 10 +(30 - titleSize.height) / 2, titleSize.width, titleSize.height);
            
            UIImageView *moreImage = [UIImageView new];
            moreImage.image = [UIImage imageNamed:@"pic_more"];
            moreImage.frame = FRAMEMAKE_F(SCREEN_WIDTH - 12 - moreImage.image.size.width,SCREEN_WIDTH / 2 + 10 + (30 - moreImage.image.size.height) / 2,  moreImage.image.size.width,  moreImage.image.size.height);
            
            UILabel *_titleLabel1 = [UILabel new];
            LabelSet(_titleLabel1, @"更多", [UIColor blackColor], 15, titleDic1, titleSize1);
            _titleLabel1.frame = FRAMEMAKE_F(SCREEN_WIDTH - titleSize1.width - 12 - CGRectGetWidth(moreImage.frame), SCREEN_WIDTH / 2 + 10 +( 30-titleSize1.height) / 2, titleSize1.width, titleSize1.height);
            
            UIButton *_moreButton = [UIButton new];
            [_moreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
            _moreButton.frame = FRAMEMAKE_F(SCREEN_WIDTH - 18 - titleSize1.width - CGRectGetWidth(moreImage.frame) , _titleLabel1.frame.origin.y, titleSize1.width + CGRectGetWidth(moreImage.frame) + 5, titleSize1.height);
            [_moreButton addTarget:self action:@selector(cardClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [view addSubview:_titleLabel];
            [view addSubview:titleImg];
            [view addSubview:_titleLabel1];
            [view addSubview:moreImage];
            [view addSubview:_moreButton];
        }else if(indexPath.section == 1){
            
            UIImageView *titleImg = [[UIImageView alloc] init];
            titleImg.image = [UIImage imageNamed:@"pic_age"];
            titleImg.frame = CGRectMake(12, (30 - titleImg.image.size.height) / 2, titleImg.image.size.width, titleImg.image.size.height);
            
            NSArray *arr = @[@"3-5岁", @"6-8岁", @"9-12岁"];
            for (int i = 0; i < arr.count; i++) {
                
                _ageBtn = [UIButton new];
                [_ageBtn setTitle:arr[i] forState:UIControlStateNormal];
                [_ageBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [_ageBtn setTitleColor:RGBHex(0x8fe69c) forState:UIControlStateSelected];
                _ageBtn.titleLabel.font = [UIFont systemFontOfSize:15];
                NSDictionary *cordDic = StringFont_DicK(_ageBtn.titleLabel.font);
                CGSize corSize = [_ageBtn.titleLabel.text sizeWithAttributes:cordDic];
                _ageBtn.frame = FRAMEMAKE_F(30 + (corSize.width + 20) * i, (30 -corSize.height ) / 2, corSize.width, corSize.height);

                _ageBtn.tag = 200 + i;
                if (buttonTag == _ageBtn.tag) {
                    _ageBtn.selected = YES;
                }
                [_ageBtn addTarget:self action:@selector(ageTap:) forControlEvents:UIControlEventTouchUpInside];
                [view addSubview:_ageBtn];
            }
            
            UIImageView *moreImage = [UIImageView new];
            moreImage.image = [UIImage imageNamed:@"pic_more"];
            moreImage.frame = FRAMEMAKE_F(SCREEN_WIDTH - 12 - moreImage.image.size.width, (30 - moreImage.image.size.height) / 2,  moreImage.image.size.width,  moreImage.image.size.height);
            
            UILabel *_titleLabel1 = [UILabel new];
            LabelSet(_titleLabel1, @"更多", [UIColor blackColor], 15, titleDic1, titleSize1);
            _titleLabel1.frame = FRAMEMAKE_F(SCREEN_WIDTH - titleSize1.width - 12 - CGRectGetWidth(moreImage.frame), (30 - titleSize1.height) / 2, titleSize1.width, titleSize1.height);
            
            UIButton *_moreButton = [UIButton new];
            [_moreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
            _moreButton.frame = FRAMEMAKE_F(SCREEN_WIDTH - 18 - titleSize1.width - CGRectGetWidth(moreImage.frame) , _titleLabel1.frame.origin.y, titleSize1.width + CGRectGetWidth(moreImage.frame) + 5, titleSize1.height);
            [_moreButton addTarget:self action:@selector(ageClick:) forControlEvents:UIControlEventTouchUpInside];
          
            [view addSubview:titleImg];
            [view addSubview:_titleLabel1];
            [view addSubview:moreImage];
            [view addSubview:_moreButton];
        }else{
            UIImageView *titleImg = [[UIImageView alloc] init];
            titleImg.image = [UIImage imageNamed:@"pic_book"];
            titleImg.frame = CGRectMake(12, (30 - titleImg.image.size.height) / 2, titleImg.image.size.width, titleImg.image.size.height);
            
            UILabel *_titleLabel = [UILabel new];
            LabelSet(_titleLabel, @"热门书单", [UIColor blackColor], 16, titleDic, titleSize);
            _titleLabel.frame = FRAMEMAKE_F(CGRectGetMaxX(titleImg.frame) + 10, (30 - titleSize.height) / 2, titleSize.width, titleSize.height);
            
            UIImageView *moreImage = [UIImageView new];
            moreImage.image = [UIImage imageNamed:@"pic_more"];
            moreImage.frame = FRAMEMAKE_F(SCREEN_WIDTH - 12 - moreImage.image.size.width, (30 - moreImage.image.size.height) / 2,  moreImage.image.size.width,  moreImage.image.size.height);
            
            UILabel *_titleLabel1 = [UILabel new];
            LabelSet(_titleLabel1, @"更多", [UIColor blackColor], 15, titleDic1, titleSize1);
            _titleLabel1.frame = FRAMEMAKE_F(SCREEN_WIDTH - titleSize1.width - 12 - CGRectGetWidth(moreImage.frame), (30 - titleSize1.height) / 2, titleSize1.width, titleSize1.height);
            
            UIButton *_moreButton = [UIButton new];
            [_moreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
            _moreButton.frame = FRAMEMAKE_F(SCREEN_WIDTH - 18 - titleSize1.width - CGRectGetWidth(moreImage.frame) , _titleLabel1.frame.origin.y, titleSize1.width + CGRectGetWidth(moreImage.frame) + 5, titleSize1.height);
            [_moreButton addTarget:self action:@selector(hotClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [view addSubview:_titleLabel];
            [view addSubview:titleImg];
            [view addSubview:_titleLabel1];
            [view addSubview:moreImage];
            [view addSubview:_moreButton];
        }
        return view;
    }else {
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:footIdentifierView forIndexPath:indexPath];
        
        if (indexPath.section == 1 || indexPath.section == 2){
            view.backgroundColor = RGBHex(0xf0f0f0);
        }else{
            view.backgroundColor = RGBHex(0xf0f0f0);
        }
        return view;
    }
}

- (NewPagedFlowView *)pageFlowView{
    if (!_pageFlowView) {
        self.pageFlowView = [[NewPagedFlowView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH / 2) ];
        //添加阴影效果
        self.pageFlowView.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
        self.pageFlowView.layer.shadowOffset = CGSizeMake(4,4);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
        self.pageFlowView.layer.shadowOpacity = 0.4;//阴影透明度，默认0
        self.pageFlowView.layer.shadowRadius = 5;//阴影半径，默认3
        
        self.pageFlowView.delegate = self;
        self.pageFlowView.dataSource = self;
        self.pageFlowView.minimumPageAlpha = 0.1;
        self.pageFlowView.isCarousel = YES;
        self.pageFlowView.orientation = NewPagedFlowViewOrientationHorizontal;
        self.pageFlowView.isOpenAutoScroll = YES;
    }
    return _pageFlowView;
}

//年龄点击
- (void)ageTap:(UIButton *)button{
    if (button.tag == 200) {
        ageIndex = 0;
        [self ageData];
    }else if(button.tag == 201){
        ageIndex = 1;
        [self ageData];
    }else{
        ageIndex = 2;
        [self ageData];
    }
    buttonTag = button.tag;
}

//年龄
- (void)ageClick:(UIButton *)button{
    PicAgeViewController *picVC = [[PicAgeViewController alloc] init];
    picVC.index = [NSString stringWithFormat:@"%ld", (long)buttonTag - 199];
    [self.navigationController pushViewController:picVC animated:YES];
}

//今日打卡
- (void)cardClick:(UIButton *)button{
    CardBookViewController *cardVC = [[CardBookViewController alloc] init];
    cardVC.titleStr = @"今日打卡";
    cardVC.url =  PICTUREBOOK_TODAY;
    [self.navigationController pushViewController:cardVC animated:YES];
}

//热门菜单
- (void)hotClick:(UIButton *)button{
    CardBookViewController *cardVC = [[CardBookViewController alloc] init];
    cardVC.titleStr = @"热门书单";
    cardVC.url =  PICTUREBOOK_HOT;
    [self.navigationController pushViewController:cardVC animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - NewPagedFlowView Delegate  
- (CGSize)sizeForPageInFlowView:(NewPagedFlowView *)flowView {
    return CGSizeMake(SCREEN_WIDTH - 80, (SCREEN_WIDTH - 80) * 5 / 9);
}

- (void)didSelectCell:(UIView *)subView withSubViewIndex:(NSInteger)subIndex {
    CarouselModel *model = self.carouselArray[subIndex];
    
    WebViewController *webVC = [[WebViewController alloc] init];
    webVC.url = model.link;
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)didScrollToPage:(NSInteger)pageNumber inFlowView:(NewPagedFlowView *)flowView {
    
}

#pragma mark - NewPagedFlowView Datasource
- (NSInteger)numberOfPagesInFlowView:(NewPagedFlowView *)flowView {
    return self.carouselArray.count;
}

- (UIView *)flowView:(NewPagedFlowView *)flowView cellForPageAtIndex:(NSInteger)index{
    PGIndexBannerSubiew *bannerView = (PGIndexBannerSubiew *)[flowView dequeueReusableCell];
    if (!bannerView) {
//        bannerView = [[PGIndexBannerSubiew alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 9 / 16)]; //9/16
        bannerView = [[PGIndexBannerSubiew alloc] initWithFrame:CGRectMake(0, 0, (SCREEN_WIDTH - 80), (SCREEN_WIDTH - 80) * 5 / 9)]; //9/16
        bannerView.tag = index;
        bannerView.layer.cornerRadius = 4;
        bannerView.layer.masksToBounds = YES;
    }
    CarouselModel *model = self.carouselArray[index];
    NSString * url = [NSString stringWithFormat:@"%@%@", Qiniu_host, model.icon];
    
    //在这里下载网络图片
    [bannerView.mainImageView sd_setImageWithURL:[NSURL URLWithString:url]];
    
    return bannerView;
}

#pragma mark - 其他方法
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)dealloc{
    NSLog(@"“绘本馆”界面没有内存泄漏");
    [self.pageFlowView stopTimer];
    self.pageFlowView = nil;
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
