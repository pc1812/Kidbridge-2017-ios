//
//  CourseDetailViewController.m
//  Picturebooks
//
//  Created by Yasin on 2017/7/20.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "CourseDetailViewController.h"
#import "CustomIOSAlertView.h"
#import "PicFreeViewCell.h"
#import "CourseDetailViewCell.h"
#import "CourseModel.h"
#import "PunchInViewController.h"
#import "MineMoneysViewController.h"

@interface CourseDetailViewController ()<UITableViewDelegate, UITableViewDataSource, SDCycleScrollViewDelegate,UIWebViewDelegate>

@property (nonatomic, strong)UIView *bottomView;
@property (nonatomic, strong)UIView *payView;
@property (nonatomic, strong)UIView *endView;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSArray *nameArr;
@property (nonatomic, strong)NSArray *dataArr;
@property (nonatomic, strong)NSArray *carouselArr;
@property (nonatomic, copy)NSString *detailStr;
@property (nonatomic, copy)NSString *priceStr;
@property (nonatomic, copy)NSString *endStr;
@property (nonatomic, copy)NSString *lockPrice;
@property (nonatomic, assign)NSInteger unlockState;
@property (nonatomic, copy)NSString *price;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;

/** 课程详情标题 */
@property (nonatomic,strong)  UIView *courseTitleView;

@end

@implementation CourseDetailViewController

#pragma mark - 懒加载
/** 懒加载--课程标题 */
- (UIView *)courseTitleView {
    if (!_courseTitleView) {
        _courseTitleView = [[UIView alloc] init];
        // 竖线
        UILabel *greeLab = [UILabel new];
        greeLab.frame = FRAMEMAKE_F(10, 10, 2, 20);
        greeLab.backgroundColor = RGBHex(0X13D02F);
        [_courseTitleView addSubview:greeLab];
        
        // 课程详情
        UILabel *nameLab = [UILabel new];
        nameLab.text = @"课程详情";
        nameLab.textColor = [UIColor blackColor];
        nameLab.font = [UIFont systemFontOfSize:16 weight:1];
        NSDictionary *conDic = StringFont_DicK(nameLab.font);
        CGSize conSize = [nameLab.text sizeWithAttributes:conDic];
        nameLab.frame = FRAMEMAKE_F(CGRectGetMaxX(greeLab.frame) + 13, CGRectGetMinY(greeLab.frame), conSize.width, conSize.height);
        [_courseTitleView addSubview:nameLab];
    }
    return _courseTitleView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
//    self.navigationItem.title = self.name;
    self.navigationItem.titleView = [UINavigationItem titleViiewWithTitle:self.name];
    
    [self.view addSubview:self.tableView];
    
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    _webView.delegate = self;
    _webView.scrollView.scrollEnabled = NO;
    
    //[_webView loadHTMLString:_pictext baseURL:[NSURL fileURLWithPath: [[NSBundle mainBundle]  bundlePath]]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/course/richtext/%ld", URL_api, _courseId]]]];
    
    NSLog(@"--------%@", [NSString stringWithFormat:@"%@/course/richtext/%ld", URL_api, _courseId]);
    [self loadData];
}

- (NSArray *)nameArr{
    if (!_nameArr) {
        _nameArr = @[ @"适龄", @"关键词", @"周期"];
    }
    return _nameArr;
}

- (void)loadData{
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:COURSE_DETAIL forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:@(_courseId) forKey:@"id"];
    
//    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    HUD.labelText = @"加载中...";
//    HUD.backgroundColor = [UIColor clearColor];
    
    [[HttpManager sharedManager] POST:COURSE_DETAIL parame:parame sucess:^(id success) {
        
//        NSLog(@"success: %@",success);
//        NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithDictionary:success];
//        [dictM writeToFile:@"/Users/yasin/Desktop/textplist/abc.plist" atomically:YES];
        
        if ([success[@"event"] isEqualToString:@"SUCCESS"]) {
           // [HUD hide:YES];
            NSDictionary *dic= success[@"data"][@"course"];
            CourseModel *model = [CourseModel modelWithDictionary:dic];
            self.rewardStr = model.rewardStr;
           
            NSString *keyStr = [model.tag componentsJoinedByString:@","];
            NSString *cycleStr = [NSString stringWithFormat:@"%ld", (long)model.cycle];
            self.dataArr = @[model.age, keyStr, cycleStr];
            self.carouselArr = model.icon;
            self.detailStr = model.outline;
          
            self.lockPrice = [NSString stringWithFormat:@"是否支付%.0f H币解锁课程?", model.price];
            
            self.price = [NSString stringWithFormat:@"%.2f", model.price];
            //-1 未解锁 >-1已解锁 用户绘本和课程的ID值
            self.unlockState = [success[@"data"][@"belong"] integerValue];
            //1 2 不能解锁
            
//            if ([success[@"data"][@"belong"] integerValue] != -1) {
////                self.priceStr = @"去打卡";
////                [self.view addSubview:self.bottomView];
//                //0未开课 1正在开课 2已结束
//             if (self.status == 1 ||self.status == 2 || self.full == 1) {
//                //self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - PBNew64);
//                if (self.status == 1) {
//                    self.endStr = @"正在开课";
//                }else if (self.status == 2){
//                     self.endStr = @"已结束";
//                }else{
//                     self.endStr = @"报名人数已满";
//                }
//                [self.view addSubview:self.endView];
//             }
//            }else if ([success[@"data"][@"belong"] integerValue] == -1) {
//                self.priceStr = [NSString stringWithFormat:@"%.2f元解锁课程", model.price];
//                [self.view addSubview:self.payView];
//            }else{
//                self.priceStr = @"去打卡";
//                [self.view addSubview:self.bottomView];
//            }
#warning jxd -- 修改逻辑判断
            NSInteger belongState = [success[@"data"][@"belong"] integerValue];
            if (belongState != -1) {
                
                if (self.status == 0) {
                    // 未开课
                    self.endStr = @"未开课";
                    [self.view addSubview:self.endView];
                    
                } else if (self.status == 1) {
                    // 去打卡
                    self.priceStr = @"去打卡";
                    [self.view addSubview:self.bottomView];
                    
                } else if (self.status == 2) {
                    // 已结束
                    self.endStr = @"已结束";
                    [self.view addSubview:self.endView];
                }
                
            } else if (belongState == -1) {
                
                if (self.status == 0 ) {
                    // 解锁:报名人数已满,不能解锁
                    if (self.full == 1) {
                        // 报名人数已满,不能解锁
                        self.endStr = @"报名人数已满";
                        [self.view addSubview:self.endView];
                    } else {
                        // 可以解锁
                        self.priceStr = [NSString stringWithFormat:@"%.0f H币解锁课程", model.price];
                        [self.view addSubview:self.payView];
                    }
                    
                } else if (self.status == 1) {
                    // 开课中
                    self.endStr = @"正在开课";
                    [self.view addSubview:self.endView];
                    
                } else if (self.status == 2) {
                    // 已结束
                    self.endStr = @"已结束";
                    [self.view addSubview:self.endView];
                }
                
            } else {
                
                if (self.status == 2) {
                    // 已结束
                    self.endStr = @"已结束";
                    [self.view addSubview:self.endView];
                }
            }
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        //[HUD hide:YES];
        [Global showWithView:self.view withText:@"网络错误"];
    }];
    
    
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - PBNew64 - 44) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    if (section == 0) {
//        return 1;
//    }
//    return self.dataArr.count;
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (indexPath.section == 0) {
//        return [self detailCellEithTableView:tableView cellForRowAtIndexPath:indexPath];
//    }else{
//        return [self ageCellEithTableView:tableView cellForRowAtIndexPath:indexPath ];
//    }
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellId = [NSString stringWithFormat:@"cellTwo%ld%ld",(long)[indexPath section],(long)[indexPath row]];
//    CourseDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
//    if (!cell) {
//        cell = [[CourseDetailViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
//    }
//    cell.photoImg.image = [UIImage imageNamed:@"ceshi1.jpg"];
//    [cell setName:@"课程详情" detail:[NSString stringWithFormat:@"%@/course/richtext/%ld", URL_api, _courseId]];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    [cell.contentView addSubview:_webView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)ageCellEithTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellId =[NSString stringWithFormat:@"cellTwo%ld%ld",(long)[indexPath section],(long)[indexPath row]];
    PicFreeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[PicFreeViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    [cell setName:self.nameArr[indexPath.row] detail:self.dataArr[indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//设置区头高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    if (section == 0) {
//        return 192;
//    }else{
//        return 0.001;
//    }
//    return SCREEN_WIDTH * 5 / 9;
    
#pragma mark - jxd修改--区头的高度
      return SCREEN_WIDTH * 5 / 9 + 40;
}

//设置区尾高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    if (section == 1) {
//        return 20;
//    }else{
//        return 0.001;
//    }
     return 0.001;
}

- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - PBNew64 - 44, SCREEN_WIDTH, 44)];
        _bottomView.backgroundColor = [UIColor whiteColor];
        UIButton *freeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        freeBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:2];
        [freeBtn setTitle:self.priceStr forState:UIControlStateNormal];
        [freeBtn addTarget:self action:@selector(unlockClick:) forControlEvents:UIControlEventTouchUpInside];
        freeBtn.backgroundColor = [Global convertHexToRGB:@"14d02f"];
        [_bottomView addSubview:freeBtn];
        [freeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_bottomView.mas_top);
            make.right.mas_equalTo(_bottomView.mas_right);
            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 44));
        }];
    }
    return _bottomView;
}

- (UIView *)payView{
    if (!_payView) {
        _payView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - PBNew64 - 44, SCREEN_WIDTH, 44)];
        _payView.backgroundColor = [UIColor whiteColor];
        UIButton *freeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        freeBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:2];
        [freeBtn setTitle:self.priceStr forState:UIControlStateNormal];
        [freeBtn addTarget:self action:@selector(unlockClick:) forControlEvents:UIControlEventTouchUpInside];
        freeBtn.backgroundColor = [Global convertHexToRGB:@"14d02f"];
        [_payView addSubview:freeBtn];
        [freeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_payView.mas_top);
            make.right.mas_equalTo(_payView.mas_right);
            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 44));
        }];
    }
    return _payView;
}


- (UIView *)endView{
    if (!_endView) {
        _endView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - PBNew64 - 44, SCREEN_WIDTH, 44)];
        _endView.backgroundColor = [UIColor whiteColor];
        UIButton *freeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        freeBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:2];
        [freeBtn setTitle:self.endStr forState:UIControlStateNormal];
        //[freeBtn addTarget:self action:@selector(unlockClick:) forControlEvents:UIControlEventTouchUpInside];
        freeBtn.backgroundColor = [UIColor grayColor];
        //[freeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_endView addSubview:freeBtn];
        freeBtn.userInteractionEnabled = NO;
        [freeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_endView.mas_top);
            make.right.mas_equalTo(_endView.mas_right);
            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 44));
        }];
    }
    return _endView;
}


- (void)unlockClick:(UIButton *)button{
    //付完钱之后进入去打卡
    if ([self.priceStr isEqualToString:@"去打卡"]) {
        PunchInViewController *punchInVC = [[PunchInViewController alloc] init];
        punchInVC.courseId = self.courseId;
        punchInVC.belong = self.unlockState;
        punchInVC.status = self.status;
        punchInVC.name = self.name;
        punchInVC.rewardStr = self.rewardStr;
        [self.navigationController pushViewController:punchInVC animated:YES];
        
    }else{
        CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
        //添加子视图
        alertView.backgroundColor = [UIColor whiteColor];
        [alertView setSubView:[self addSubView]];
        //添加按钮标题数组
        [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"取消", @"解锁", nil]];
        //添加按钮点击方法
        [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
            NSLog(@"----%d", buttonIndex);
            
            if (buttonIndex == 1) {
                //得到基本固定参数字典，加入调用接口所需参数
                NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
                [parame setObject:COURSE_UNLOCK forKey:@"uri"];
                //得到加盐MD5加密后的sign，并添加到参数字典
                [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
                [parame setObject:@(self.courseId) forKey:@"id"];
                
                MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                HUD.labelText = @"解锁中...";
                HUD.backgroundColor = [UIColor clearColor];
                
                [[HttpManager sharedManager] POST:COURSE_UNLOCK parame:parame sucess:^(id success) {
                    [HUD hide:YES];
                    if ([success[@"event"] isEqualToString:@"SUCCESS"]){
                        if (_callback) {
                            _callback(@"1");
                        }
                        [Global showWithView:self.view withText:@"解锁成功"];
                        [self loadData];
                        [self.payView removeFromSuperview];
                        self.priceStr = @"去打卡";
                        [self.view addSubview:self.bottomView];
                      //H币不足去充值
                    }else if([success[@"event"] isEqualToString:@"INSUFFICIENT_BALANCE"]){
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您的H币不足，是否需要充值？" preferredStyle:UIAlertControllerStyleAlert];
                        
                        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            
                        }]];
                        [alertController addAction:[UIAlertAction actionWithTitle:@"去充值" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            MineMoneysViewController *moneyVC = [[MineMoneysViewController alloc] init];
                            [self.navigationController pushViewController:moneyVC animated:YES];
                        }]];
                        [self presentViewController:alertController animated:YES completion:nil];
                    }else{
                        [Global showWithView:self.view withText:[success objectForKey:@"decribe"]];
                    }
                } failure:^(NSError *error) {
                    [HUD hide:YES];
                    [Global showWithView:self.view withText:@"网络错误"];
                }];
            }
            //关闭
            [alertView close];
        }];
        //显示
        [alertView show];
    }
}

//自定义的子视图
- (UIView *)addSubView{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 230, 50)];
    view.font = [UIFont systemFontOfSize:15 weight:2];
    view.textColor = [UIColor blackColor];
    view.text = self.lockPrice;
    view.textAlignment = NSTextAlignmentCenter;
    view.backgroundColor = [UIColor whiteColor];
    return view;
}
#pragma mark - UIWebView Delegate Methods
-(void)webViewDidFinishLoad:(UIWebView *)webView{
       [self.progressHUD hide:YES];
     CGFloat height  = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
    self.webView.frame = CGRectMake(self.webView.frame.origin.x,self.webView.frame.origin.y, SCREEN_WIDTH, height + 10);
    [self.tableView reloadData];
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.progressHUD .labelText = @"加载中...";
    self.progressHUD .backgroundColor = [UIColor clearColor];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.progressHUD hide:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //__weak CourseDetailViewController *preferSelf = self;
     return _webView.frame.size.height;
//    if (indexPath.section == 0) {
//        PicFreeViewCell *sortCell = (PicFreeViewCell *)[preferSelf tableView:_tableView cellForRowAtIndexPath:indexPath];
//        return sortCell.frame.size.height;
//    }else{
//        CourseDetailViewCell *sortCell = (CourseDetailViewCell *)[preferSelf tableView:_tableView cellForRowAtIndexPath:indexPath];
//        return sortCell.frame.size.height;
//    }
}

//区头
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    __strong UIView *view = [UIView new];
    if (section == 0) {
        view.backgroundColor = [UIColor whiteColor];
        
        SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 5 / 9) delegate:self placeholderImage:[UIImage imageNamed:@"litongOne"]];
        cycleScrollView.autoScroll = NO;
        cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
        //         --- 模拟加载延迟
        cycleScrollView.currentPageDotColor = [Global convertHexToRGB:@"14d02f"];
       // cycleScrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFit;
        
        NSMutableArray *mainArray = [NSMutableArray array];
        for (NSString *string in self.carouselArr) {
            NSString * url = [NSString stringWithFormat:@"%@%@", Qiniu_host, string];
            [mainArray addObject:url];
        }

        cycleScrollView.imageURLStringsGroup = mainArray;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        });
        
        [view addSubview:cycleScrollView];
        
#pragma mark - jxd修改--添加课程详情提示标题
        self.courseTitleView.frame = CGRectMake(0, CGRectGetMaxY(cycleScrollView.frame), SCREEN_WIDTH, 20);
        [view addSubview:self.courseTitleView];
        
    }else{
        view.backgroundColor = [UIColor whiteColor];
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
