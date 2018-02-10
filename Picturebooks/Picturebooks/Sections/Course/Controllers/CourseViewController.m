//
//  CourseViewController.m
//  PictureBook
//
//  Created by Yasin on 2017/7/7.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "CourseViewController.h"
#import "CourseCollectionViewCell.h"
#import "NewPagedFlowView.h"
#import "PGIndexBannerSubiew.h"
#import "CoAgeViewController.h"
#import "CoMineViewController.h"
#import "COHotViewController.h"
#import "CourseDetailViewController.h"
#import "CarouselModel.h"
#import "WebViewController.h"
#import "CourseModel.h"

static NSString * const reuseIdentifierCell = @"MainCollectionView";
static NSString * const headIdentifierView = @"MainHeader";
static NSString * const footIdentifierView = @"foot";

@interface CourseViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,NewPagedFlowViewDelegate, NewPagedFlowViewDataSource>
{
    UIButton *_ageBtn;
    NSInteger ageIndex;
    NSInteger buttonTag;
}

@property (nonatomic, strong)UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *imageArray;       //图片数组
@property (nonatomic, strong) NSMutableArray *carouselArray;
@property (nonatomic, strong) NSMutableArray *myCourseArray;
@property (nonatomic, strong) NSMutableArray *ageArray;
@property (nonatomic, strong) NSMutableArray *hotArray;
@property (nonatomic, strong) NewPagedFlowView *pageFlowView;
@property (nonatomic, assign) NSInteger full;

@end

@implementation CourseViewController

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (IOS7) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView = [UINavigationItem titleViewForTitle:@"课程馆"];
    
    ageIndex = 0;
    buttonTag = 200;

    NSArray *array = @[@"ceshi.jpg", @"ceshi1.jpg"];
    [self.imageArray addObjectsFromArray:array];
    
    [self.view addSubview:self.collectionView];
    
    self.myCourseArray = [NSMutableArray array];
    self.ageArray = [NSMutableArray array];
    self.hotArray = [NSMutableArray array];
    //轮播
    [self carouselData];
    //我的课程
    [self myCourseDate];
    //年龄
    [self ageData];
    //热门
    [self hotData];
    
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self carouselData];
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
        //[self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        [self.collectionView reloadData];
    } failure:^(NSError *error) {
        [Global showWithView:self.view withText:@"网络错误"];
    }];
}

//我的课程数据
- (void)myCourseDate{
     [self.myCourseArray removeAllObjects];
    //得到基本固定参数字典，加入调用接口所需参数
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:MINE_COURSE forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:@(0 * kOffset) forKey:@"offset"];
    [parame setObject:@(2) forKey:@"limit"];
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.labelText = @"加载中...";
    HUD.backgroundColor = [UIColor clearColor];
    
    [[HttpManager sharedManager] POST:MINE_COURSE parame:parame sucess:^(id success) {
        
        if ([success[@"event"] isEqualToString:@"SUCCESS"]) {
            [HUD hide:YES];
        
            NSMutableArray *boyarray= success[@"data"];
            if (![boyarray isEqual:[NSNull null]]) {
                for (NSDictionary *dic in boyarray) {
                    CourseModel *courseModel = [CourseModel modelWithDictionary:dic];
                    [self.myCourseArray addObject:courseModel];
                }
            }
            //[self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            [self.collectionView reloadData];
        }
    } failure:^(NSError *error) {
        [HUD hide:YES ];
        [Global showWithView:self.view withText:@"网络错误"];
    }];
}

//年龄数据
- (void)ageData{
     [self.ageArray removeAllObjects];
    //得到基本固定参数字典，加入调用接口所需参数
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:COURSE_LIST forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:@(0 * kOffset) forKey:@"offset"];
    [parame setObject:@(2) forKey:@"limit"];
    [parame setObject:@(ageIndex) forKey:@"fit"];
    
    [[HttpManager sharedManager] POST:COURSE_LIST parame:parame sucess:^(id success) {
        [self.ageArray removeAllObjects];
        
        if ([success[@"event"] isEqualToString:@"SUCCESS"]) {
           
            NSMutableArray *boyarray= success[@"data"];
            if (![boyarray isEqual:[NSNull null]]) {
                for (NSDictionary *dic in boyarray) {
                    CourseModel *courseModel = [CourseModel modelWithDictionary:dic];
                    [self.ageArray addObject:courseModel];
                }
            }
            //[self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
            [self.collectionView reloadData];
        }
    } failure:^(NSError *error) {
        [Global showWithView:self.view withText:@"网络错误"];
    }];
}

//热门数据
- (void)hotData{
    [self.hotArray removeAllObjects];
    //得到基本固定参数字典，加入调用接口所需参数
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:COURSE_HOT forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:@(0 * kOffset) forKey:@"offset"];
    [parame setObject:@(4) forKey:@"limit"];
    
    [[HttpManager sharedManager] POST:COURSE_HOT parame:parame sucess:^(id success) {
    
        if ([success[@"event"] isEqualToString:@"SUCCESS"]) {
            NSMutableArray *boyarray= success[@"data"];
            if (![boyarray isEqual:[NSNull null]]) {
                for (NSDictionary *dic in boyarray) {
                    CourseModel *courseModel = [CourseModel modelWithDictionary:dic];
                    [self.hotArray addObject:courseModel];
                }
            }
            //[self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:2]];
            [self.collectionView reloadData];
        }
    } failure:^(NSError *error) {
        [Global showWithView:self.view withText:@"网络错误"];
    }];
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumInteritemSpacing = 12;
        layout.minimumLineSpacing = 12;
        layout.sectionInset = UIEdgeInsetsMake(12, 12, 12, 12);
        layout.itemSize = CGSizeMake(SCREEN_WIDTH - 36, 50 + (SCREEN_WIDTH - 36) *5/9);//156
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT- TabbarHeight - PBNew64) collectionViewLayout:layout];
        _collectionView.backgroundColor = RGBHex(0xf0f0f0);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[CourseCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifierCell];
        
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headIdentifierView];
        [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footIdentifierView];
    }
    return _collectionView;
}

#pragma mark - collectionView代理方法实现
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0 ) {
        return self.myCourseArray.count;
    } else if (section == 1) {
        return self.ageArray.count;
    } else{
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
    CourseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifierCell forIndexPath:indexPath];
   
    CourseModel *model = self.myCourseArray[indexPath.row];
    NSString * url = [NSString stringWithFormat:@"%@%@", Qiniu_host, model.icon[0]];
    [cell.photoImg sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"head_placeholder"]];
    cell.lockImage.hidden = YES;
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

- (UICollectionViewCell *)secondCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CourseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifierCell forIndexPath:indexPath];
    CourseModel *model = self.ageArray[indexPath.row];
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

- (UICollectionViewCell *)thirdCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CourseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifierCell forIndexPath:indexPath];
    CourseModel *model = self.hotArray[indexPath.row];
    NSString * url = [NSString stringWithFormat:@"%@%@", Qiniu_host, model.icon[0]];
    [cell.photoImg sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"head_placeholder"]];
     cell.lockImage.hidden = YES;
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
    CourseModel *courseModel = [[CourseModel alloc] init];
   
    if (indexPath.section == 0) {
        courseModel = self.myCourseArray[indexPath.row];
    }else if(indexPath.section == 1){
        courseModel = self.ageArray[indexPath.row];
    }else{
        courseModel = self.hotArray[indexPath.row];
    }
    
    if (courseModel.enter == courseModel.limit) {
        self.full = 1;
    }
    CourseDetailViewController *courseVC = [[CourseDetailViewController alloc] init];
    courseVC.courseId = courseModel.ID;
    courseVC.status = courseModel.status;
    courseVC.name = courseModel.name;
    courseVC.full = self.full;
  
    [self.navigationController pushViewController:courseVC animated:YES];
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
            titleImg.image = [UIImage imageNamed:@"course_car"];
            titleImg.frame = CGRectMake(12, SCREEN_WIDTH / 2 + 10 + (30 - titleImg.image.size.height) / 2, titleImg.image.size.width, titleImg.image.size.height);
            
            UILabel *_titleLabel = [UILabel new];
            LabelSet(_titleLabel, @"我的课程", [UIColor blackColor], 16, titleDic, titleSize);
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
                _ageBtn.frame = FRAMEMAKE_F(30 + (corSize.width + 20) *i, (30 -corSize.height ) / 2, corSize.width, corSize.height);
                
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
            _titleLabel1.frame = FRAMEMAKE_F(SCREEN_WIDTH - titleSize1.width - 12 - CGRectGetWidth(moreImage.frame), ( 30-titleSize1.height) / 2, titleSize1.width, titleSize1.height);
            
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
            LabelSet(_titleLabel, @"热门课程", [UIColor blackColor], 16, titleDic, titleSize);
            _titleLabel.frame = FRAMEMAKE_F(CGRectGetMaxX(titleImg.frame) + 10, (30 - titleSize.height) / 2, titleSize.width, titleSize.height);
            
            UIImageView *moreImage = [UIImageView new];
            moreImage.image = [UIImage imageNamed:@"pic_more"];
            moreImage.frame = FRAMEMAKE_F(SCREEN_WIDTH - 12 - moreImage.image.size.width, (30 - moreImage.image.size.height) / 2,  moreImage.image.size.width,  moreImage.image.size.height);
            
            UILabel *_titleLabel1 = [UILabel new];
            LabelSet(_titleLabel1, @"更多", [UIColor blackColor], 15, titleDic1, titleSize1);
            _titleLabel1.frame = FRAMEMAKE_F(SCREEN_WIDTH - titleSize1.width - 12 - CGRectGetWidth(moreImage.frame), ( 30-titleSize1.height) / 2, titleSize1.width, titleSize1.height);
            
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
        self.pageFlowView = [[NewPagedFlowView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH / 2)];
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
    CoAgeViewController *picVC = [[CoAgeViewController alloc] init];
    picVC.index = [NSString stringWithFormat:@"%ld", (long)(buttonTag - 199)];
    [self.navigationController pushViewController:picVC animated:YES];
}

//我的课程
- (void)cardClick:(UIButton *)button{
    CoMineViewController *cardVC = [[CoMineViewController alloc ] init];
    [self.navigationController pushViewController:cardVC animated:YES];
}

//热门课程
- (void)hotClick:(UIButton *)button{
    COHotViewController *hotVC = [[COHotViewController alloc ] init];
    [self.navigationController pushViewController:hotVC animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark NewPagedFlowView Delegate
- (CGSize)sizeForPageInFlowView:(NewPagedFlowView *)flowView {
//    return CGSizeMake(SCREEN_WIDTH - 80, (SCREEN_WIDTH - 80) * 9 / 16);
    return CGSizeMake(SCREEN_WIDTH - 80, (SCREEN_WIDTH - 80) * 5 / 9);
}

- (void)didSelectCell:(UIView *)subView withSubViewIndex:(NSInteger)subIndex {
    
    CarouselModel *model = self.carouselArray[subIndex];
    
    WebViewController *webVC = [[WebViewController alloc] init];
    webVC.url = model.link;
    [self.navigationController pushViewController:webVC animated:YES];
}

#pragma mark NewPagedFlowView Datasource
- (NSInteger)numberOfPagesInFlowView:(NewPagedFlowView *)flowView {
    
     return self.carouselArray.count;
}

- (UIView *)flowView:(NewPagedFlowView *)flowView cellForPageAtIndex:(NSInteger)index{
    PGIndexBannerSubiew *bannerView = (PGIndexBannerSubiew *)[flowView dequeueReusableCell];
    if (!bannerView) {
//        bannerView = [[PGIndexBannerSubiew alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 9 / 16)];
        bannerView = [[PGIndexBannerSubiew alloc] initWithFrame:CGRectMake(0, 0, (SCREEN_WIDTH - 80), (SCREEN_WIDTH - 80) * 5 / 9)];
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

- (void)didScrollToPage:(NSInteger)pageNumber inFlowView:(NewPagedFlowView *)flowView {

}

- (void)dealloc {
    NSLog(@"“课程馆”界面没有内存泄漏");
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
