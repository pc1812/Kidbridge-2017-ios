//
//  MyAchievementViewController.m
//  Picturebooks
//
//  Created by 吉晓东 on 2018/3/13.
//  Copyright © 2018年 ZhiyuanNetwork. All rights reserved.
//

#import "MyAchievementViewController.h"
#import "Medal.h"
#import "MedalCollectionViewCell.h"

@interface MyAchievementViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
/** UICollection */
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger bonus;
/** 头部视图 */
@property (nonatomic,strong) UIView *headerView;

@end

/** 重用标识符--头部视图 */
static NSString *const HeaderView_identifier = @"HeaderView_identifier";

@implementation MyAchievementViewController

#pragma mark - 懒加载
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        
        //设置每个item(cell)的大小
        flowLayout.itemSize = CGSizeMake(85 * PROPORTION, 128 * PROPORTION);
        //设置最小行间距
        flowLayout.minimumLineSpacing = 27 * PROPORTION;
        //设置最小列间距
        flowLayout.minimumInteritemSpacing = 40 * PROPORTION;
        //设置item与四周边界的距离  上左下右
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 27 * PROPORTION, 25 * PROPORTION, 27 * PROPORTION);
        //设置滚动方向
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        //设置头部区域大小
        //flowLayout.headerReferenceSize = CGSizeMake(375, 150);
        
//        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 63 * PROPORTION, SCREEN_WIDTH, 300 * PROPORTION) collectionViewLayout:flowLayout];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_collectionView];
        
//        _collectionView.scrollEnabled = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        
        [_collectionView registerClass:[MedalCollectionViewCell class] forCellWithReuseIdentifier:@"collectionFirstViewCell"];
        // 注册--头部视图
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HeaderView_identifier];
        
    }
    return _collectionView;
}

/** 懒加载--头部视图 */
- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, XDHightRatio(270))];
        _headerView.backgroundColor = RGBHex(0xf0f0f0);
        // 创建子控件
        [self createHeaderSubView:_headerView];
    }
    return _headerView;
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = RGBHex(0xf0f0f0);
    self.navigationItem.title = @"勋章墙";
    self.navigationController.navigationBar.barTintColor = RGBHex(0x14d02f);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18 weight:2], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 30)];
    [button setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    button.adjustsImageWhenHighlighted = NO;
    UIView *containView = [[UIView alloc] initWithFrame:button.bounds];
    [containView addSubview:button];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:containView];
    self.navigationItem.leftBarButtonItem = barButton;
    
    self.dataArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:User_medal forKey:@"uri"];
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    
    [[HttpManager sharedManager] POST:User_medal parame:parame sucess:^(id success) {
        
        if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
            
            NSMutableDictionary *tmpDic = [success objectForKey:@"data"];
            self.bonus = [[tmpDic objectForKey:@"bonus"] integerValue];
            NSMutableArray *tmpArray = [tmpDic objectForKey:@"medalList"];
            for (NSMutableDictionary *dic in tmpArray) {
                Medal *medal = [Medal modelWithDictionary:dic];
                [self.dataArray addObject:medal];
            }
//            [self createView];
            [self.collectionView reloadData];
        }else{
            NSLog(@"event = %@, describe = %@", [success objectForKey:@"event"], [success objectForKey:@"describe"]);
        }
    } failure:^(NSError *error) {
        [Global showWithView:self.view withText:@"网络错误"];
    }];
    
}

- (void)createHeaderSubView:(UIView *)view{
    
    UIView *headView = [[UIView alloc] init];
    [view addSubview:headView];
    headView.backgroundColor = [UIColor whiteColor];
    [headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(XDHightRatio(220)); // 140 * PROPORTION
    }];
    
    [self setUpHeaderSubView:headView];
    
    UIView *backgroundView = [[UIView alloc] init];
    [view addSubview:backgroundView];
    backgroundView.backgroundColor = [UIColor whiteColor];
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(XDHightRatio(230)); // 230 * PROPORTION
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(XDHightRatio(50));
    }];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"我的勋章墙";
    titleLabel.font = [UIFont boldSystemFontOfSize:18 * PROPORTION];
    [titleLabel sizeToFit];
    [backgroundView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12 * PROPORTION);
        make.centerY.mas_equalTo(backgroundView);
    }];
    
    UILabel *remarkLabel = [[UILabel alloc] init];
    [backgroundView addSubview:remarkLabel];
    remarkLabel.text = @"（注：水滴兑换H币后不影响勋章等级）";
    remarkLabel.font = [UIFont systemFontOfSize:14 * PROPORTION];
    remarkLabel.textColor = [UIColor grayColor];
    [remarkLabel sizeToFit];
    [remarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel.mas_right).offset(3 * PROPORTION);
        make.centerY.mas_equalTo(titleLabel.mas_centerY);
    }];
    
}

/** 头部视图的子控件 */
- (void)setUpHeaderSubView:(UIView *)view
{
    /** 1.水滴图标 */
    UIImageView *imageView = [UIImageView new];
    [view addSubview:imageView];
    imageView.image = [UIImage imageNamed:@"m_water"];
    imageView.frame = FRAMEMAKE_F((SCREEN_WIDTH - imageView.image.size.width) / 2, XDHightRatio(20), imageView.image.size.width, imageView.image.size.height);
    
    /** 2.水滴个数标题 */
    UILabel *waterLab = [UILabel new];
    [view addSubview:waterLab];
    waterLab.textColor = [Global convertHexToRGB:@"585552"];
    LabelSet(waterLab, @"水滴个数", [UIColor blackColor], 15, waterDic, waterSize);
    waterLab.frame = FRAMEMAKE_F((SCREEN_WIDTH - waterSize.width) / 2, CGRectGetMaxY(imageView.frame) + XDHightRatio(10), waterSize.width, waterSize.height);
    
    /** 3.水滴个数 */
    UILabel *numLab = [UILabel new];
    [view addSubview:numLab];
    numLab.textColor = [Global convertHexToRGB:@"15CF30"];
    numLab.font = [UIFont systemFontOfSize:32 weight:2];
    numLab.text = [NSString stringWithFormat:@"%zd",self.bonus];
    
    NSDictionary *numDic = StringFont_DicK(numLab.font);
    CGSize numSize = [numLab.text sizeWithAttributes:numDic];
    numLab.frame = FRAMEMAKE_F((SCREEN_WIDTH - numSize.width) / 2, CGRectGetMaxY(waterLab.frame) + XDHightRatio(10), numSize.width, numSize.height)
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MedalCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionFirstViewCell" forIndexPath:indexPath];
    Medal *medal = [self.dataArray objectAtIndex:indexPath.row];

    if (self.bonus >= medal.BONUS) {
        cell.active = YES;
    }else{
        cell.active = NO;
    }
    cell.medal = medal;
    return cell;
}

// 和UITableView类似，UICollectionView也可设置段头段尾
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    // 设置头部视图
    if([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        if (indexPath.section == 0) {
            UICollectionReusableView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:HeaderView_identifier forIndexPath:indexPath];
            [headView addSubview:self.headerView];
            return headView;
        }
    }
    return nil;
}

/** 返回头尾视图的高度 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    // 返回头部视图的高度
    if (section == 0) {
        return CGSizeMake(SCREEN_WIDTH , XDHightRatio(280));
    }
    return CGSizeZero;
}

- (void)dealloc{
    NSLog(@"-----没有泄漏哦-----");
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

















