//
//  PicSearchViewController.m
//  PictureBook
//
//  Created by Yasin on 2017/7/7.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "PicSearchViewController.h"
#import "MainCollectionViewCell.h"
#import "PictureModel.h"
#import "PicFreeDetailViewController.h"

#define SEARCHHISTORY @"searchHistory"

static NSString * const reuseIdentifierCell = @"MainCollectionViewCell";

@interface PicSearchViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong)UISearchBar *searchBar;//搜索框
@property (nonatomic, strong)UICollectionView *collectionView;
@property (nonatomic, strong)UIView *backView;
@property (nonatomic, strong)UILabel *notFound;

@property (nonatomic, strong)NSMutableArray *searchArray;
@property (nonatomic, strong)NSMutableArray *dataSource;
@property (nonatomic, assign)NSInteger pageNum;//页数
@property (nonatomic, assign)BOOL isMorePage;

@end

@implementation PicSearchViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.searchBar resignFirstResponder];
    [self.searchBar becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear: animated];
    [self.searchBar resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView = [UINavigationItem titleViewForTitle:@"绘本馆"];
    self.dataSource = [[NSMutableArray alloc] init];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:tap];
    
    UIView *backGroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 57)];
    [self.view addSubview:backGroundView];
    backGroundView.backgroundColor = RGBHex(0xf0f0f0);
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(backGroundView.frame) - 80, 40)];
    [backGroundView addSubview:self.searchBar];
    self.searchBar.center = backGroundView.center;
    self.searchBar.delegate = self;
    _searchBar.layer.masksToBounds = YES;
    _searchBar.layer.cornerRadius = 20;
    _searchBar.clipsToBounds = YES;
    [self.searchBar setContentMode:UIViewContentModeLeft];
    self.searchBar.placeholder = @"请输入绘本名称或书单名称";
    self.searchBar.barStyle = UIBarStyleDefault;
    self.searchBar.backgroundImage = [Global imageWithColor:[UIColor clearColor] size:self.searchBar.bounds.size];
    
    for (UIView* subview in [[_searchBar.subviews lastObject] subviews]) {
        
        if ([subview isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField*)subview;
            textField.textColor = [Global convertHexToRGB:@"999999"];//修改输入字体的颜色
            textField.font = [UIFont systemFontOfSize:14];
            [textField setValue:RGBHex(0x999999) forKeyPath:@"_placeholderLabel.textColor"];//修改placeholder的颜色
            [textField setValue:[UIFont boldSystemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
        } else if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]){
            [subview removeFromSuperview];
        }
    }

    [self.view addSubview:self.collectionView];
    [self creatSearchList];
    
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _pageNum=0;
        
        // Jxd-start-------------------------
#pragma mark - Jxd-修改:首先清空数组
        [self.dataSource removeAllObjects];
        // Jxd-start-------------------------
        
        [self getsearchList];
        [self.collectionView.mj_header endRefreshing];
    }];
    
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (_isMorePage) {
            _pageNum++;
            [self getsearchList];
        }
        else{
            [self.collectionView.mj_footer endRefreshing];
        }
    }];
    
    if (_searchString!=nil){
        // 马上进入刷新状态
        [self.collectionView.mj_header beginRefreshing];
    }
    self.collectionView.mj_footer.state = MJRefreshStatePulling;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        self.dataSource = [NSMutableArray arrayWithCapacity:1];
    }
    return _dataSource;
}

#pragma mark -----创建搜索历史列表
-(void)creatSearchList{
    
    [(UIView *)[self.view viewWithTag:5000] removeFromSuperview];
    
    self.backView = [[UIView alloc]initWithFrame:CGRectMake(0, 57, SCREEN_WIDTH, SCREEN_HEIGHT - PBNew64 - 40)];
    self.backView.backgroundColor = [Global convertHexToRGB:@"333333"];
    
    self.backView.tag = 5000;
    if (_searchString.length>0) {
        self.backView.hidden = YES;
    }else{
        self.backView.hidden = NO;
    }
    [self.view addSubview:self.backView];

    UIView *backGoundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - PBNew64 - 57)];
    backGoundView.backgroundColor = [Global convertHexToRGB:@"f3f5f7"];
    [self.backView addSubview:backGoundView];

    UILabel *desLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, 20)];
    desLabel.text = @"搜索记录";
    desLabel.font = [UIFont systemFontOfSize:13];
    desLabel.textColor = [Global convertHexToRGB:@"9b9b9c"];
    [backGoundView addSubview:desLabel];
    
    NSString *searchStr = [[NSUserDefaults standardUserDefaults]objectForKey:SEARCHHISTORY];
    self.searchArray  = [NSMutableArray arrayWithCapacity:1];
    if (searchStr.length>0) {
        self.searchArray = (NSMutableArray *)[searchStr componentsSeparatedByString:@"  "];
    }
    
    UIView *whiteView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, (self.searchArray.count+1) * 40)];
    whiteView.backgroundColor =[UIColor whiteColor];
    [backGoundView addSubview:whiteView];
    
    for (NSInteger i=0; i < self.searchArray.count ; i++) {
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 39 * i, SCREEN_WIDTH - 20, 39)];
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.textColor = [Global convertHexToRGB:@"4a4a4a"];
        titleLabel.text = self.searchArray[i];
        titleLabel.userInteractionEnabled = YES;
        titleLabel.tag = 10000+i;
        [whiteView addSubview:titleLabel];
        [titleLabel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(titleLabelClick:)]];
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 40 * (i + 1), SCREEN_WIDTH, 1)];
        lineView.backgroundColor = [Global convertHexToRGB:@"f0f2f2"];
        [whiteView addSubview:lineView];
    }
    
    UIButton *cleanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cleanBtn.frame = CGRectMake(0, CGRectGetMaxY(whiteView.frame) - 60, SCREEN_WIDTH, 40);
    cleanBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [cleanBtn setTitle:@"清除历史记录" forState:UIControlStateNormal];
    [cleanBtn addTarget:self action:@selector(cleanBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [cleanBtn setTitleColor:[Global convertHexToRGB:@"a7a7a7"] forState:UIControlStateNormal];
    [cleanBtn setTitleColor:[Global convertHexToRGB:@"a7a7a7"] forState:UIControlStateHighlighted];
    [cleanBtn setTitleColor:[Global convertHexToRGB:@"a7a7a7"] forState:UIControlStateSelected];
    [whiteView addSubview:cleanBtn];
}

-(void)titleLabelClick:(UITapGestureRecognizer *)sender{
    
    // Jxd-start-------------------------
#pragma mark - Jxd-修改:首先清空数组
    [self.dataSource removeAllObjects];
    // Jxd-start-------------------------
    
    self.searchBar.text = self.searchArray[sender.view.tag - 10000];
    _searchString=self.searchBar.text;
    [self getsearchList];
}

#pragma mark -----开始搜索
-(void)getsearchList{
    if (_searchString.length > 0) {
        self.backView.hidden = YES;
        
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.labelText = @"加载中...";
        HUD.backgroundColor = [UIColor clearColor];
        
//        [self.dataSource removeAllObjects];
        [self.notFound removeFromSuperview];
        
        //得到基本固定参数字典，加入调用接口所需参数
        NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
        [parame setObject:Picturebook_search forKey:@"uri"];
        //得到加盐MD5加密后的sign，并添加到参数字典
        [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
        [parame setObject:@(_pageNum * kOffset) forKey:@"offset"];
        [parame setObject:@(kOffset) forKey:@"limit"];
        [parame setObject:self.searchString forKey:@"keyword"];
        
        [[HttpManager sharedManager] POST:Picturebook_search parame:parame sucess:^(id success) {
            
            if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
                [HUD hide:YES];
        
                NSMutableArray *tmpArray = [success objectForKey:@"data"];
                if (tmpArray.count == 0) {
                    [self.view addSubview:self.notFound];
                }
                for (NSDictionary *dic in tmpArray) {
                    PictureModel *model = [PictureModel modelWithDictionary:dic];
                    [self.dataSource addObject:model];
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
            }else{
                NSLog(@"event = %@, describe = %@", [success objectForKey:@"event"], [success objectForKey:@"describe"]);
            }
        } failure:^(NSError *error) {
            [HUD hide:YES];
            [Global showWithView:self.view withText:@"网络错误"];
        }];
    }else{
        self.backView.hidden = NO;
        [self.dataSource removeAllObjects];
        [self.collectionView reloadData];
    }
}

- (UILabel *)notFound{
    if (!_notFound) {
        _notFound = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT / 2 - PBNew64, SCREEN_WIDTH, 15)];
        _notFound.textAlignment = 1;
        _notFound.textColor = RGBHex(0x9b9b9c);
        _notFound.font = [UIFont systemFontOfSize:13];
    }
    _notFound.text = [NSString stringWithFormat:@"没有找到与\"%@\"相关的内容", _searchString];
    return _notFound;
}

#pragma mark ---------  清除历史记录
-(void)cleanBtnClick{
    NSString *searchStr = [[NSUserDefaults standardUserDefaults]objectForKey:SEARCHHISTORY];
    if (searchStr.length>0) {
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:SEARCHHISTORY];
        [[NSUserDefaults standardUserDefaults]synchronize];
        _searchString = nil;
        [self.searchBar resignFirstResponder];
        [self creatSearchList];
    }
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 12;
        layout.minimumLineSpacing = 12;
        layout.sectionInset = UIEdgeInsetsMake(12, 11.5, 12, 11.5);
        layout.itemSize = CGSizeMake((SCREEN_WIDTH - 35) / 2, 55 + ((SCREEN_WIDTH - 35) / 2) * 3/4);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 57, SCREEN_WIDTH, SCREEN_HEIGHT - PBNew64 - 57) collectionViewLayout:layout];
        _collectionView.backgroundColor = RGBHex(0xf0f0f0);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        
        [_collectionView registerClass:[MainCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifierCell];
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
    MainCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifierCell forIndexPath:indexPath];
    
    PictureModel *model = self.dataSource[indexPath.row];
    NSString * url = [NSString stringWithFormat:@"%@%@", Qiniu_host, model.icon[0]];
    [cell.picImage sd_setImageWithURL:[NSURL URLWithString:url]];
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
    }else if (model.fit == 3){
        ageStr = @"4-7岁";
    }else if (model.fit == 4){
        ageStr = @"8-10岁";
    }else{
        ageStr = @"9-12岁";
    }
    cell.ageLabel.text = ageStr;
    NSString *price = [NSString stringWithFormat:@"%.2f", model.price];
    if ([price isEqualToString:@"0.00"]) {
        cell.lockImage.hidden = YES;
        cell.freeLabel.text = @"免费";
        cell.ageLabel.hidden = NO;
    }else{
        cell.freeLabel.text = ageStr;
        cell.ageLabel.hidden = YES;
        cell.lockImage.hidden = NO;
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cellDicSelected:)];
    [cell.contentView addGestureRecognizer:tap];

    return cell;
}

-(void)cellDicSelected:(UITapGestureRecognizer *)tap{
    [self.searchBar resignFirstResponder];
    
    CGPoint point = [tap locationInView:self.collectionView];
    NSIndexPath * indexPath = [self.collectionView indexPathForItemAtPoint:point];
    
    PictureModel *model = self.dataSource[indexPath.row];
    PicFreeDetailViewController *freeVC = [[PicFreeDetailViewController alloc] init];
    freeVC.picId = model.ID;
    freeVC.name = model.name;
    [self.navigationController pushViewController:freeVC animated:YES];
}

//点击
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
 
    PictureModel *model = self.dataSource[indexPath.row];
    PicFreeDetailViewController *freeVC = [[PicFreeDetailViewController alloc] init];
    freeVC.picId = model.ID;
    freeVC.name = model.name;
    [self.navigationController pushViewController:freeVC animated:YES];
}

//设置每个分区页眉的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {

    return CGSizeMake(SCREEN_WIDTH, 0.01f);
}

#pragma mark -  UISearchBarDelegate Method
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    if (searchText.length>0) {
        self.backView.hidden = YES;
        self.searchString = searchText;
    }else{
        self.backView.hidden = NO;
        [self.dataSource removeAllObjects];
        [self.collectionView reloadData];
        [self.notFound removeFromSuperview];
    }
}

#pragma mark -----  搜索点击事件  存储此次搜索的东西
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self.searchBar resignFirstResponder];
    _pageNum=0;
    _searchString=searchBar.text;
    
    // Jxd-start-------------------------
#pragma mark - Jxd-修改:首先清空数组
    [self.dataSource removeAllObjects];
    // Jxd-start-------------------------
    
    [self getsearchList];
    
    //存储搜索文字
    NSString *searchStr = [[NSUserDefaults standardUserDefaults]objectForKey:SEARCHHISTORY];
    if (searchStr.length==0) {
        [[NSUserDefaults standardUserDefaults]setObject:_searchString forKey:SEARCHHISTORY];
    }else{
        BOOL existBool = NO;
        for (NSString *searchStr2 in [searchStr componentsSeparatedByString:@"  "]) {
            if ([searchStr2 isEqualToString:_searchString]) {
                existBool = YES;
            }
        }
        if (!existBool) {
            NSMutableArray *searchArray = (NSMutableArray *)[[NSString stringWithFormat:@"%@  %@",_searchString,searchStr] componentsSeparatedByString:@"  "];
            if (searchArray.count>5) {//超过5个数字 自动删除
                [searchArray removeObjectAtIndex:5];
                [[NSUserDefaults standardUserDefaults] setObject:[searchArray componentsJoinedByString:@"  "] forKey:SEARCHHISTORY];
            }else{
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@  %@",_searchString,searchStr] forKey:SEARCHHISTORY];
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self creatSearchList];
}

- (void)tapAction:(UITapGestureRecognizer *)tap{
    [self.searchBar resignFirstResponder];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
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
