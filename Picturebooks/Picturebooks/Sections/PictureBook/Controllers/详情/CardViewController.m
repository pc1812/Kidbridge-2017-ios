//
//  CardViewController.m
//  PictureBook
//
//  Created by Yasin on 2017/7/8.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "CardViewController.h"
#import "MainCollectionViewCell.h"
#import "PictureModel.h"
#import "WebViewController.h"
#import "PicFreeDetailViewController.h"

static NSString * const reuseIdentifierCell = @"MainCollectionViewCell";
static NSString * const headIdentifierView = @"MainHeaderView";
static NSString * const footIdentifierView = @"MainfootView";

@interface CardViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,SDCycleScrollViewDelegate>

@property (nonatomic, strong)UICollectionView *collectionView;
@property (nonatomic, strong)UIImageView *noSearchImageView;

@property (nonatomic, strong)NSMutableArray *dataSource;
@property (nonatomic, assign)BOOL isMorePage;
@property (nonatomic, assign)NSInteger pageNum;//页数
@property (nonatomic, copy)NSString *imgIcon;
@property (nonatomic, copy)NSString *imgUrl;

@end

@implementation CardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
//    self.navigationItem.titleView = [UINavigationItem titleViewForTitle:self.titleStr];
    self.navigationItem.titleView = [UINavigationItem titleViiewWithTitle:self.titleStr];
    
    [self.view addSubview:self.collectionView];

    self.noSearchImageView = [[UIImageView alloc] initWithFrame : CGRectMake(0.0f, 0.0f, 200, 200)];
    self.noSearchImageView.backgroundColor = [UIColor clearColor];
    self.noSearchImageView.center = self.collectionView.center;
    [self.view addSubview:self.noSearchImageView];
    
    [self loadData];
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
    [parame setObject:PICTUREBOOK_DETAIL forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:@(self.bookId) forKey:@"id"];
    
    [[HttpManager sharedManager] POST:PICTUREBOOK_DETAIL parame:parame sucess:^(id success) {
        
        if ([success[@"event"] isEqualToString:@"SUCCESS"]) {
            
            NSMutableArray *boyarray= success[@"data"][@"bookList"];
            if (![boyarray isEqual:[NSNull null]]) {
                for (NSDictionary *dic in boyarray) {
                    PictureModel *carouselModel = [PictureModel modelWithDictionary:dic];
                    [self.dataSource addObject:carouselModel];
                }
            }
            self.imgIcon = success[@"data"][@"cover"][@"icon"];
            self.imgUrl = success[@"data"][@"cover"][@"link"];
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
        layout.sectionInset = UIEdgeInsetsMake(12, 11.5, 12, 11.5);
        layout.itemSize = CGSizeMake((SCREEN_WIDTH - 35) / 2, 55 + ((SCREEN_WIDTH - 35) / 2) * 3/4);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - PBNew64) collectionViewLayout:layout];
        _collectionView.backgroundColor = RGBHex(0xf0f0f0);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        
        [_collectionView registerClass:[MainCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifierCell];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headIdentifierView];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footIdentifierView];
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
    MainCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifierCell forIndexPath:indexPath];
    
    PictureModel *model = self.dataSource[indexPath.row];
    
    NSString * url = [NSString stringWithFormat:@"%@%@", Qiniu_host, model.icon[0]];
    [cell.picImage sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"con_placeholder"]];
    cell.nameLabel.text = model.name;
    
    // 判断标签数组为空
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
    
    //NSString *price = [NSString stringWithFormat:@"%.2f", model.price];
    if (model.lock == 1) {
        cell.lockImage.hidden = YES;
        cell.ageLabel.hidden = NO;
        cell.freeLabel.text = @"免费";
    }else{
        cell.freeLabel.text = ageStr;
        cell.ageLabel.hidden = YES;
        cell.lockImage.hidden = NO;
    }
    return cell;
}

//点击
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PictureModel *model = self.dataSource[indexPath.row];
    PicFreeDetailViewController *freeVC = [[PicFreeDetailViewController alloc] init];
    freeVC.picId = model.ID;
    freeVC.name = model.name;
    [self.navigationController pushViewController:freeVC animated:YES];
}

#pragma mark - 头脚高度
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return CGSizeMake(SCREEN_WIDTH , (SCREEN_WIDTH - 20) * 5/9);
    } else{
        return CGSizeMake(SCREEN_WIDTH, 0.001);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(SCREEN_WIDTH, 10);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headIdentifierView forIndexPath:indexPath];
        for (UIView *views in view.subviews) {
            [views removeFromSuperview];
        }
        
        SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, (SCREEN_WIDTH - 20) * 5/9) delegate:self placeholderImage:[UIImage imageNamed:@"litongOne"]];
        cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
        //         --- 模拟加载延迟
        cycleScrollView.currentPageDotColor = [Global convertHexToRGB:@"14d02f"];
        cycleScrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFit;
        NSMutableArray *mainArray = [NSMutableArray array];
        cycleScrollView.autoScroll = NO;

        NSString * url = [NSString stringWithFormat:@"%@%@", Qiniu_host, self.imgIcon];
       
        [mainArray addObject:url];
        cycleScrollView.imageURLStringsGroup = mainArray;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
        });
        [view addSubview:cycleScrollView];
        view.backgroundColor = RGBHex(0xf0f0f0);
        return view;
    }else{
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:footIdentifierView forIndexPath:indexPath];
        view.backgroundColor = RGBHex(0xf0f0f0);
        return view;
    }
}

#pragma mark - SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    WebViewController *webVC = [[WebViewController alloc] init];
    webVC.url = self.imgUrl;
    [self.navigationController pushViewController:webVC animated:YES];
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
