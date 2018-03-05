//
//  PicFreeDetailViewController.m
//  PictureBook
//
//  Created by Yasin on 2017/7/12.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "PicFreeDetailViewController.h"
#import "PicFreeViewCell.h"
#import "PicWithReadViewController.h"
#import "PicFreeWithViewController.h"
#import "PicDetailModel.h"
#import "CustomIOSAlertView.h"
#import "PicReadTopModel.h"
#import "MineShadowViewController.h"
#import "MineMoneysViewController.h"

@interface PicFreeDetailViewController ()<UITableViewDelegate, UITableViewDataSource, SDCycleScrollViewDelegate>

@property (nonatomic, strong)UIView *bottomView;    // 其他状态的底部视图
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)UIView *payBottomView; // 支付的底部视图

@property (nonatomic, strong)NSArray *nameArr;
@property (nonatomic, strong)NSArray *dataArr;
@property (nonatomic, strong)NSArray *carouselArr;
@property (nonatomic, strong)NSMutableArray *dataSource;
@property (nonatomic, copy)NSString *priceStr;
@property (nonatomic, copy)NSString *lockPrice;
@property (nonatomic, copy)NSString *price;
@property (nonatomic, copy)NSString *withReadStr; //我要跟读 还是免费跟读
@property (nonatomic, assign)NSInteger unlockState;
@property (nonatomic, assign)NSInteger pageNum;//页数
@property (nonatomic, assign)BOOL isMorePage;
@property (nonatomic, copy)NSString *rewardId;
@end

@implementation PicFreeDetailViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _pageNum=0;
    [self readData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //navigationBar标题
    //    self.navigationItem.title = self.name;
    self.navigationItem.titleView = [UINavigationItem titleViiewWithTitle:self.name];
    
    [self.view addSubview:self.tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickShare:) name:@"wechatShare" object:nil];
  
    [self loadData];
    
    self.tableView.mj_header=[MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _pageNum=0;
        [self readData];
        [self.tableView.mj_header endRefreshing];
    }];
    
    self.tableView.mj_footer=[MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (_isMorePage) {
            _pageNum++;
            [self readData];
        }
        [self.tableView.mj_footer endRefreshing];
    }];
    [self.tableView.mj_header beginRefreshing];
}

-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSource;
}

- (NSArray *)nameArr{
    if (!_nameArr) {
        _nameArr = @[@"故事梗概", @"绘本感悟", @"适龄", @"关键词"];
    }
    return _nameArr;
}

#pragma mark - 分享回调
//分享回调
- (void)clickShare:(NSNotification *)notification{
    
    switch ([notification.object integerValue]) {
        case 0:
            [Global showWithView:self.view withText:@"分享成功"];
            break;
        case -1:
            [Global showWithView:self.view withText:@"普通类型错误"];
            break;
        case -2:
            [Global showWithView:self.view withText:@"用户点击了取消"];
            break;
        case -3:
            [Global showWithView:self.view withText:@"发送取消"];
            break;
        case -4:
            [Global showWithView:self.view withText:@"发送失败"];
            break;
            
        default:
            [Global showWithView:self.view withText:@"微信不支持"];
            break;
    }
}

//绘本 +详情数据
- (void)loadData{
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:Picturebook_detail forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:@(_picId) forKey:@"id"];
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.labelText = @"加载中...";
    HUD.backgroundColor = [UIColor clearColor];
    
    [[HttpManager sharedManager] POST:Picturebook_detail parame:parame sucess:^(id success) {
        if ([success[@"event"] isEqualToString:@"SUCCESS"]) {
            [HUD hide:YES];
            NSDictionary *dic= success[@"data"][@"book"];
            PicDetailModel *model = [PicDetailModel modelWithDictionary:dic];
            self.navigationItem.title = model.name;
            self.rewardId = model.rewardStr;
            NSString *ageStr;
            if (model.fit == 0) {
                ageStr = @"3-5岁";
            }else if (model.fit == 1){
                ageStr = @"6-8岁";
            }else{
                ageStr = @"9-12岁";
            }
            NSString *keyStr = [model.tag componentsJoinedByString:@","];
            self.dataArr = @[model.outline, model.feeling, ageStr, keyStr];
            self.carouselArr = model.icon;
            self.priceStr = [NSString stringWithFormat:@"%.2f元解锁绘本", model.price];
            self.lockPrice = [NSString stringWithFormat:@"是否支付%.2f元解锁绘本?", model.price];
            
             self.price = [NSString stringWithFormat:@"%.2f", model.price];
            //-1 未解锁 >1已解锁 绘本或课程的ID值
            self.unlockState = [success[@"data"][@"belong"] integerValue];
            if ([success[@"data"][@"belong"] integerValue] == -1) {
                if ([self.price isEqualToString:@"0.00"]) {
                    self.withReadStr = @"免费跟读";
                    [self.view addSubview:self.bottomView];
                }else{
                    [self.view addSubview:self.payBottomView];
                }
            }else{
                self.withReadStr = @"我要跟读";
                [self.view addSubview:self.bottomView];
            }
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [HUD hide:YES];
        [Global showWithView:self.view withText:@"网络错误"];
    }];
}

//跟读榜数据
- (void)readData{
    //得到基本固定参数字典，加入调用接口所需参数
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:PICTUREBOOK_READTOP forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:@(self.picId) forKey:@"id"];
    [parame setObject:@(_pageNum * kOffset) forKey:@"offset"];
    [parame setObject:@(kOffset) forKey:@"limit"];

    [[HttpManager sharedManager] POST:PICTUREBOOK_READTOP parame:parame sucess:^(id success) {
        if ([success[@"event"] isEqualToString:@"SUCCESS"]) {
            if (_pageNum == 0) {
                [self.dataSource removeAllObjects];
            }
            NSMutableArray *boyarray= success[@"data"][@"rank"];
            if (![boyarray isEqual:[NSNull null]]) {
                for (NSDictionary *dic in boyarray) {
                    PicReadTopModel *carouselModel = [PicReadTopModel modelWithDictionary:dic];
                    [self.dataSource addObject:carouselModel];
                }
            }
            NSInteger total = 0;
            total = self.dataSource.count;
            NSInteger totalPages = total / kOffset;
            
            if (self.pageNum >= totalPages) {
                _isMorePage = NO;
                if (total > 0) {
                    self.tableView.mj_footer.state = MJRefreshStateNoMoreData;
                }else{
                    self.tableView.mj_footer.state = MJRefreshStateWillRefresh;
                }
            }else{
                self.tableView.mj_footer.state = MJRefreshStateIdle;
                _isMorePage = YES;
            }
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        [Global showWithView:self.view withText:@"网络错误"];
    }];
}

- (UIView *)payBottomView{
    if (!_payBottomView) {
        _payBottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - PBNew64 - 44, SCREEN_WIDTH, 44)];
        _payBottomView.backgroundColor = [UIColor whiteColor];
        UIButton *freeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        freeBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:2];
        [freeBtn setTitle:self.priceStr forState:UIControlStateNormal];
        [freeBtn addTarget:self action:@selector(unlockClick:) forControlEvents:UIControlEventTouchUpInside];
        freeBtn.backgroundColor = [Global convertHexToRGB:@"14d02f"];
        [_payBottomView addSubview:freeBtn];
        [freeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_payBottomView.mas_top);
            make.right.mas_equalTo(_payBottomView.mas_right);
            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 44));
        }];
    }
    return _payBottomView;
}

- (void)unlockClick:(UIButton *)button{
    
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    //添加子视图
    alertView.backgroundColor = [UIColor whiteColor];
    [alertView setSubView:[self addSubView]];
    //添加按钮标题数组
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"取消", @"解锁", nil]];
    //添加按钮点击方法
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        
        if (buttonIndex == 1) {
            //得到基本固定参数字典，加入调用接口所需参数
            NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
            [parame setObject:PICTURE_UNLOCK forKey:@"uri"];
            //得到加盐MD5加密后的sign，并添加到参数字典
            [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
            [parame setObject:@(_picId) forKey:@"id"];
            
            MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD.labelText = @"解锁中...";
            HUD.backgroundColor = [UIColor clearColor];
            
            [[HttpManager sharedManager] POST:PICTURE_UNLOCK parame:parame sucess:^(id success) {
                [HUD hide:YES];
                if ([success[@"event"] isEqualToString:@"SUCCESS"]){
                    [Global showWithView:self.view withText:@"解锁成功"];
                    if (_callback) {
                        _callback(@"1");
                    }

                    [self.payBottomView removeFromSuperview];
                    self.withReadStr = @"我要跟读";
                    [self.view addSubview:self.bottomView];
                    [self loadData];
                }else if ([success[@"event"] isEqualToString:@"INSUFFICIENT_BALANCE"]){
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您的余额不足，是否需要充值？" preferredStyle:UIAlertControllerStyleAlert];
                    
                    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                    }]];
                    [alertController addAction:[UIAlertAction actionWithTitle:@"去充值" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        MineMoneysViewController *moneyVC = [[MineMoneysViewController alloc] init];
                        [self.navigationController pushViewController:moneyVC animated:YES];
                    }]];
                    [self presentViewController:alertController animated:YES completion:nil];
                }
                else{
                    [Global showWithView:self.view withText:[success objectForKey:@"describe"]];

                }
            } failure:^(NSError *error) {
                [HUD hide:YES];
                [Global showWithView:self.view withText:@"网络错误"];
            }];
        }else{
            
        }
        //关闭
        [alertView close];
    }];
    //显示
    [alertView show];
}

//自定义的子视图
- (UIView *)addSubView{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 230, 50)];
    view.font = [UIFont systemFontOfSize:15 weight:2];
    view.textColor = [UIColor blackColor];
    //view.text = @"是否支付1元解锁绘本?";
    view.text = self.lockPrice;
    view.textAlignment = NSTextAlignmentCenter;
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - PBNew64 - 44) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.dataArr.count;
    }else{
        if (self.unlockState > 1) {
            return self.dataSource.count;
//            if ([self.price isEqualToString:@"0.00"]) {
//            }else{
//                return 0;
//            }
        }else{
            return 0;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.unlockState > 1) {
        return 2;
//        if ([self.price isEqualToString:@"0.00"]) {
//        }else{
//            return 1;
//        }
    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return [self detailCellEithTableView:tableView cellForRowAtIndexPath:indexPath];
    }else{
        return [self readCellEithTableView:tableView cellForRowAtIndexPath:indexPath ];
    }
}

- (UITableViewCell *)detailCellEithTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellId =[NSString stringWithFormat:@"cellTwo%ld%ld",(long)[indexPath section],(long)[indexPath row]];
    PicFreeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[PicFreeViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    [cell setName:self.nameArr[indexPath.row] detail:self.dataArr[indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (UITableViewCell *)readCellEithTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellId = [NSString stringWithFormat:@"cellTwo%ld%ld", (long)[indexPath section], (long)[indexPath row]];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }else{//当页面拉动的时候 当cell存在并且最后一个存在 把它进行删除就出来一个独特的cell我们在进行数据配置即可避免
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
        }
    }
    
    PicReadTopModel *model = self.dataSource[indexPath.row];
    UIImageView *photoImg = [UIImageView new];
    [cell.contentView addSubview:photoImg];
    
    NSString * url = [NSString stringWithFormat:@"%@%@", Qiniu_host, model.userModel.head];
    
    [photoImg sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"defaultPhoto"]];
    photoImg.frame = FRAMEMAKE_F(10, 14, 45, 45);
    photoImg.aliCornerRadius = 45 / 2;
    
    
    UILabel *nameLab = [[UILabel alloc] init];
    [cell.contentView addSubview:nameLab];
    nameLab.textColor = [UIColor blackColor];
    nameLab.font = [UIFont systemFontOfSize:15 weight:2];
    
    // nameLab.text = model.userModel.nickname;
#pragma mark - jxd-修改
    if ([Global isNullOrEmpty:model.userModel.nickname]) {
        nameLab.text = @"匿名用户";
    } else {
        nameLab.text = model.userModel.nickname;
    }
    
    NSDictionary *nameDic = StringFont_DicK(nameLab.font );
    CGSize nameSize = [nameLab.text sizeWithAttributes:nameDic];
//    nameLab.frame = FRAMEMAKE_F(CGRectGetMaxX(photoImg.frame) + 12, CGRectGetMinY(photoImg.frame), nameSize.width, nameSize.height);
    nameLab.frame = FRAMEMAKE_F(CGRectGetMaxX(photoImg.frame) + 12, CGRectGetMinY(photoImg.frame), SCREEN_WIDTH * 0.6, nameSize.height);
    
    UILabel *dateLab = [[UILabel alloc] init];
    [cell.contentView addSubview:dateLab];
    
    NSString *year = [model.time substringToIndex:10];
    NSString *time = [model.time substringFromIndex:10];
    
    LabelSet(dateLab, year, RGBHex(0x999999), 12, dateDic, dateSize);
    dateLab.frame = FRAMEMAKE_F(CGRectGetMinX(nameLab.frame ), CGRectGetMaxY(nameLab.frame) + 14, dateSize.width, dateSize.height);
    
    UILabel *timeLab = [[UILabel alloc] init];
    [cell.contentView addSubview:timeLab];
    
    LabelSet(timeLab, time, RGBHex(0x999999), 12, timeDic, timeSize);
    timeLab.frame = FRAMEMAKE_F(CGRectGetMaxX(dateLab.frame ) + 38, CGRectGetMinY(dateLab.frame), timeSize.width, timeSize.height);
    UIImage *image = [UIImage imageNamed:@"pic_unlike"];
    UILabel *likeLab = [UILabel new];
    NSString *like = [NSString stringWithFormat:@"%ld", (long)model.like];
    LabelSet(likeLab, like, RGBHex(0x999999), 13, allDic, allSize);
    likeLab.frame = FRAMEMAKE_F(SCREEN_WIDTH - 10 - allSize.width, CGRectGetMinY(nameLab.frame) , allSize.width, allSize.height);
    
    //添加全选图片按钮
    UIButton *likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    likeBtn.frame = CGRectMake(SCREEN_WIDTH - 20 - image.size.width -  allSize.width, CGRectGetMinY(nameLab.frame) + 2 , image.size.width + allSize.width + 20, image.size.height);
    [likeBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [likeBtn setImage:[UIImage imageNamed:@"pic_like"] forState:UIControlStateNormal];
    likeBtn.tag = 120;
    [cell.contentView addSubview:likeLab];
    [cell.contentView addSubview:likeBtn];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//点赞
- (void)likeBtnClick:(UIButton *)button{
    button.selected = !button.selected;
}

//设置区头高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return SCREEN_WIDTH * 3/4;
    }else{
        return 65;
    }
}

//设置区尾高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 20;
    }else{
        return 0.001;
    }
}

- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - PBNew64 - 44, SCREEN_WIDTH, 44)];
        _bottomView.backgroundColor = [UIColor whiteColor];
        UIButton *freeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        freeBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:2];
        [freeBtn setTitle:self.withReadStr forState:UIControlStateNormal];
        [freeBtn addTarget:self action:@selector(freeClick:) forControlEvents:UIControlEventTouchUpInside];
        freeBtn.backgroundColor = [Global convertHexToRGB:@"14d02f"];
        [_bottomView addSubview:freeBtn];
        [freeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_bottomView.mas_top);
            make.right.mas_equalTo(_bottomView.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH / 2, 44));
        }];
        
        UIButton *enjoyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        enjoyBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:2];
        [enjoyBtn setTitle:@"赏析区" forState:UIControlStateNormal];
        [enjoyBtn addTarget:self action:@selector(enjoyClick:) forControlEvents:UIControlEventTouchUpInside];
        enjoyBtn.backgroundColor = [Global convertHexToRGB:@"fe6b76"];
        [_bottomView addSubview:enjoyBtn];
        [enjoyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_bottomView.mas_top);
            make.left.mas_equalTo(_bottomView.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH / 2, 44));
        }];
    }
    return _bottomView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak PicFreeDetailViewController *preferSelf = self;
    if (indexPath.section == 0) {
        PicFreeViewCell *sortCell = (PicFreeViewCell *)[preferSelf tableView:_tableView cellForRowAtIndexPath:indexPath];
        return sortCell.frame.size.height;
    }else{
        return 60;
    }
}

//cell点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        PicReadTopModel *model = self.dataSource[indexPath.row];
        MineShadowViewController *mineReadVC = [[MineShadowViewController alloc] init];

        mineReadVC.readId = model.readId;
        mineReadVC.nameStr = model.userModel.nickname;
        mineReadVC.urlStr = USER_READDETAIL;
        mineReadVC.commentUrl = USER_COMMENT;
        mineReadVC.picRepeatType = PicRepeatAppreciation;
        mineReadVC.likeUrl = USER_LIKE;
        mineReadVC.rewardUrl =  PIC_RepeatReward;
        [self.navigationController pushViewController:mineReadVC animated:YES];

    }
}

//区头
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    __strong UIView *view = [UIView new];
    if (section == 0) {
        view.backgroundColor = [UIColor whiteColor];
        
        SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 3/4) delegate:self placeholderImage:[UIImage imageNamed:@"litongOne"]];
        cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
        cycleScrollView.backgroundColor = [UIColor whiteColor];
        cycleScrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFit;
        //         --- 模拟加载延迟
        cycleScrollView.currentPageDotColor = [Global convertHexToRGB:@"14d02f"];
        NSMutableArray *mainArray = [NSMutableArray array];

        cycleScrollView.autoScroll = NO;
        for (NSString *string in self.carouselArr) {
            NSString * url = [NSString stringWithFormat:@"%@%@", Qiniu_host, string];
            [mainArray addObject:url];
        }
        cycleScrollView.imageURLStringsGroup = mainArray;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        });
        [view addSubview:cycleScrollView];
    }else{
        view.backgroundColor = [UIColor whiteColor];
        UILabel *_greeLab = [UILabel new];
        _greeLab.frame = FRAMEMAKE_F(10, 30, 2, 20);
        _greeLab.backgroundColor = RGBHex(0X13D02F);
        
        UILabel *_nameLab = [UILabel new];
        _nameLab.text = @"跟读榜";
        _nameLab.textColor = [UIColor blackColor];
        _nameLab.font = [UIFont systemFontOfSize:16 weight:2];
        NSDictionary *conDic = StringFont_DicK(_nameLab.font);
        CGSize conSize = [_nameLab.text sizeWithAttributes:conDic];
        _nameLab.frame = FRAMEMAKE_F(CGRectGetMaxX(_greeLab.frame) + 13, CGRectGetMinY(_greeLab.frame), conSize.width, conSize.height);
        [view addSubview:_greeLab];
        [view addSubview:_nameLab];
    }
    return view;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    __strong UIView *view = [UIView new];
    UIView *white = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
    white.backgroundColor = [UIColor whiteColor];
    [view addSubview:white];
    view.backgroundColor = RGBHex(0xf0f0f0);
    return view;
}

//免费
- (void)freeClick:(UIButton *)button{
    if ([self.withReadStr isEqualToString:@"免费跟读"]) {
        //得到基本固定参数字典，加入调用接口所需参数
        NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
        [parame setObject:PICTURE_UNLOCK forKey:@"uri"];
        //得到加盐MD5加密后的sign，并添加到参数字典
        [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
        [parame setObject:@(self.picId) forKey:@"id"];
        
        // Jxd-start-----------------------------
#pragma mark - Jxd-添加 显示数据加载提示框
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        // Jxd-end-----------------------------
        
        [[HttpManager sharedManager] POST:PICTURE_UNLOCK parame:parame sucess:^(id success) {
            
            if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
                
                NSMutableDictionary *parame_ = [HttpManager necessaryParameterDictionary];
                [parame_ setObject:Repeat_token forKey:@"uri"];
                [parame_ setObject:[HttpManager getAddSaltMD5Sign:parame_] forKey:@"sign"];
                [parame_ setObject:@(self.unlockState) forKey:@"id"];
                
                [[HttpManager sharedManager] POST:Repeat_token parame:parame_ sucess:^(id success) {
                    if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
                        self.token = [[success objectForKey:@"data"] objectForKey:@"token"];
                        
                        PicFreeWithViewController *freeVC = [[PicFreeWithViewController alloc] init];
                        freeVC.unlockState = self.unlockState;
                        freeVC.name = self.navigationItem.title;
                        freeVC.token = self.token;
                        [self.navigationController pushViewController:freeVC animated:YES];
                        
                    }else{
                        NSLog(@"event = %@, describe = %@", [success objectForKey:@"event"], [success objectForKey:@"describe"]);
                    }
                    
                    // Jxd-start-----------------------------
#pragma mark - Jxd-添加 隐藏数据加载提示框
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    // Jxd-end-----------------------------
                    
                } failure:^(NSError *error) {
                    
                    // Jxd-start-----------------------------
#pragma mark - Jxd-添加 隐藏数据加载提示框
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    // Jxd-end-----------------------------
                    
                    [Global showWithView:self.view withText:@"网络错误"];
                }];
            }else{
                NSLog(@"event = %@, describe = %@", [success objectForKey:@"event"], [success objectForKey:@"describe"]);
            }
        } failure:^(NSError *error) {
            [Global showWithView:self.view withText:@"网络错误"];
        }];
    }
    else{
        
        // 绘本课堂中的跟读界面
        NSMutableDictionary *parame_ = [HttpManager necessaryParameterDictionary];
        [parame_ setObject:Repeat_token forKey:@"uri"];
        [parame_ setObject:[HttpManager getAddSaltMD5Sign:parame_] forKey:@"sign"];
        [parame_ setObject:@(self.unlockState) forKey:@"id"];
        
        // Jxd-start-----------------------------
#pragma mark - Jxd-添加 显示数据加载提示框
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        // Jxd-end-----------------------------
        
        [[HttpManager sharedManager] POST:Repeat_token parame:parame_ sucess:^(id success) {
            if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
                self.token = [[success objectForKey:@"data"] objectForKey:@"token"];
                
                PicFreeWithViewController *freeVC = [[PicFreeWithViewController alloc] init];
                freeVC.unlockState = self.unlockState;
                
#pragma mark - Jxd-temp
                NSLog(@"%zd",self.unlockState);
                
                freeVC.name = self.navigationItem.title;
                freeVC.token = self.token;
                
                [self.navigationController pushViewController:freeVC animated:YES];
                
                
            }else{
                NSLog(@"event = %@, describe = %@", [success objectForKey:@"event"], [success objectForKey:@"describe"]);
            }
            
            // Jxd-start-----------------------------
#pragma mark - Jxd-添加 隐藏数据加载提示框
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            // Jxd-end-----------------------------
        } failure:^(NSError *error) {
            
            // Jxd-start-----------------------------
#pragma mark - Jxd-添加 隐藏数据加载提示框
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            // Jxd-end-----------------------------
            [Global showWithView:self.view withText:@"网络错误"];
        }];
    }
}

//欣赏区
- (void)enjoyClick:(UIButton *)button{
   

    PicWithReadViewController *readVC = [[PicWithReadViewController alloc] init];
    readVC.name = self.name;
    readVC.picId = self.picId;
    readVC.belong = self.unlockState;
    readVC.rewardId = self.rewardId;
    readVC.rewardUrl = PIC_Reward;
    [self.navigationController pushViewController:readVC animated:YES];
}

#pragma mark - SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    
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
