//
//  PunchInViewController.m
//  Picturebooks
//
//  Created by 尹凯 on 2017/8/23.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "PunchInViewController.h"
#import "PicFreeDetailViewController.h"
#import "PicFreeWithViewController.h"
#import "YKCalendarView.h"
#import "PunchInTableViewCell.h"
#import "SignModel.h"
#import "CourseDetailModel.h"
#import "PicWithReadViewController.h"
#import "CoDiscussViewController.h"
#import "CalenderView.h"
#import "MineShadowViewController.h"

//static NSInteger limit = 5;
@interface PunchInViewController ()<UITableViewDelegate, UITableViewDataSource, YKCalendarViewDelegate>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)UIView *downView;
@property (nonatomic, strong)UIScrollView *topScrollview;
@property (nonatomic, strong)YKCalendarView *calendarView;

@property (nonatomic, strong)NSMutableArray *courseDetailList;
@property (nonatomic, strong)NSMutableArray *signTodayList;
@property (nonatomic, assign)BOOL isMorePage;
@property (nonatomic, assign)NSInteger pageNum;
@property (nonatomic, assign)NSInteger userCourseId;
@property (nonatomic, strong)CourseDetailModel *currentModel;

@property (nonatomic, assign)NSInteger startTime;//开始时间
@property (nonatomic, assign)NSInteger totalCycle;//结束时间
@property (nonatomic, strong) CalenderView  *caView;

#pragma mark - Jxd-添加的属性
/** 记录当天的日期 */
@property (nonatomic,strong) NSString *todayDateString;
@end

@implementation PunchInViewController

#pragma mark - 懒加载
//懒加载UItableView
- (UITableView *)tableView{
    if (!_tableView) {
        if (!_hideBottom) {
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - PBNew64 - 44) style:UITableViewStyleGrouped];
            
        }else{
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - PBNew64) style:UITableViewStyleGrouped];
        }
        
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        //分割线设置
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [self.tableView registerClass:[PunchInTableViewCell class] forCellReuseIdentifier:@"punchInList"];
        
        // Jxd-start------------------------------
#pragma mark -Jxd 修改--添加上拉刷新功能
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            if (_isMorePage) {
                _pageNum++;
                [self getCourseSignTodayList:self.todayDateString];
                [self.tableView.mj_footer endRefreshing];
            } else {
                self.tableView.mj_footer.state = MJRefreshStateNoMoreData;
            }
        }];
        // Jxd-end------------------------------
        
    }
    return _tableView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = RGBHex(0xf0f0f0);
    self.navigationController.navigationBar.translucent = NO;
    //禁止scrollview内容自动设置
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //navigationBar背景颜色
    self.navigationController.navigationBar.barTintColor = RGBHex(0x14d02f);
    //navigationBar标题
    self.navigationItem.title = self.name;
    //navigationBar标题字体、颜色
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickShare:) name:@"wechatShare" object:nil];
    
    //左上角返回按钮
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 30)];
    [button setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    button.adjustsImageWhenHighlighted = NO;
    [button sizeToFit];
    UIView *containView = [[UIView alloc] initWithFrame:button.bounds];
    [containView addSubview:button];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:containView];
    self.navigationItem.leftBarButtonItem = barButton;
    
    self.courseDetailList = [[NSMutableArray alloc] init];
    self.signTodayList = [[NSMutableArray alloc] init];
    self.isMorePage = YES;
    
    if (!_hideBottom) {
        [self createDownView];
    }
    
    [self getCourseSign];
    [self getCourseSignTodayList:@""];
    
#pragma mark - 点击📅中某一天的事件处理
    __weak PunchInViewController *selfWeak = self;
    self.caView.clickedDate = ^(NSDateComponents *date) {
       
        NSString *monthStr;
        NSString *dayStr;
        if ([selfWeak nsinterLength:date.month] == 1) {
            monthStr = [NSString stringWithFormat:@"0%ld", (long)date.month];
        }else{
            monthStr = [NSString stringWithFormat:@"%ld", (long)date.month];
        }
        if ([selfWeak nsinterLength:date.day] == 1) {
            dayStr = [NSString stringWithFormat:@"0%ld", (long)date.day];
        }else{
             dayStr = [NSString stringWithFormat:@"%ld", (long)date.day];
        }
       
        // Jxd-start---------------------------------
#pragma mark -Jxd修改->出现问题:添加self.pageNum = 0
        selfWeak.pageNum = 0;
        selfWeak.todayDateString = [NSString stringWithFormat:@"%ld%@%@", (long)date.year, monthStr,dayStr];
        // Jxd-end---------------------------------
        
        [selfWeak getCourseSignTodayList:[NSString stringWithFormat:@"%ld%@%@", (long)date.year, monthStr,dayStr]];
      
    };

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

- (NSInteger)nsinterLength:(NSInteger)x {
    NSInteger sum=0,j=1;
    while( x >= 1 ) {
        //NSLog(@"%zd位数是 : %zd\n",j,x%10);
        x=x/10;
        sum++;
        j=j*10;
    }
    //NSLog(@"你输入的是一个%zd位数\n",sum);
    return sum;
}
#pragma mark - 网络请求
//获取课程-用户今日打卡记录
- (void)getCourseSignTodayList:(NSString *)dateStr{
    //得到基本固定参数字典，加入调用接口所需参数
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:Today_list forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:@(self.courseId) forKey:@"id"];
    
    [parame setObject:@(self.pageNum * kOffset) forKey:@"offset"];
    [parame setObject:@(kOffset) forKey:@"limit"];
    if (![dateStr isEqualToString:@""]) {
         [parame setObject:dateStr forKey:@"date"];
    }
    
    [[HttpManager sharedManager] POST:Today_list parame:parame sucess:^(id success) {
        
        if (_pageNum == 0) {
            [self.signTodayList removeAllObjects];
        }
        
        if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
            
            NSMutableArray *tempArray = [[success objectForKey:@"data"] objectForKey:@"sign"];
            for (NSMutableDictionary *dic in tempArray) {
                SignModel *signmodel = [SignModel modelWithDictionary:dic];
                [self.signTodayList addObject:signmodel];
            }
            
            // Jxd-start---------------------------------
#pragma mark - Jxd-添加->上拉刷新功能 MJRefreshStateWillRefresh
            NSInteger total = 0;
            total = self.signTodayList.count;
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
            // Jxd-end---------------------------------
            
            if (self.tableView) {
                NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:0];
                [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
        }else{
            NSLog(@"event = %@, describe = %@", [success objectForKey:@"event"], [success objectForKey:@"describe"]);
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

//获取课程打卡信息
- (void)getCourseSign{
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:Course_sign forKey:@"uri"];
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:@(self.courseId) forKey:@"id"];
    
    [[HttpManager sharedManager] POST:Course_sign parame:parame sucess:^(id success) {
//        NSLog(@"dake------%@", success);
        
        if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
            NSMutableArray *tempArray = [[success objectForKey:@"data"] objectForKey:@"courseDetailList"];
            for (NSMutableDictionary *dic in tempArray) {
                CourseDetailModel *courseDetail = [CourseDetailModel modelWithDictionary:dic];
                [self.courseDetailList addObject:courseDetail];
            }
            [self.view addSubview:self.tableView];
            
            self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                if (_isMorePage) {
                    _pageNum++;
                }
                [self.tableView.mj_footer endRefreshing];
            }];
            
            if (!_isMorePage) {
                self.tableView.mj_footer.state = MJRefreshStateNoMoreData;
            }
            
        }else{
            [Global showWithView:self.view withText:[success objectForKey:@"describe"]];
        }
    } failure:^(NSError *error) {
        [Global showWithView:self.view withText:@"网络异常～"];
    }];
}

//获取用户课程打卡记录
- (void)getUserCourseScheduleListWithDate:(NSString *)date userCourseId:(NSInteger)userCourseid{
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:Schedule_list forKey:@"uri"];
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:@(userCourseid) forKey:@"id"];
    [parame setObject:date forKey:@"date"];
    
    [[HttpManager sharedManager] POST:Schedule_list parame:parame sucess:^(id success) {
       
        if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
            NSLog(@"%@", [success objectForKey:@"data"]);
            NSMutableArray *tempArray = success[@"data"][@"schedule"];
            NSMutableArray *haveDone = [[NSMutableArray alloc] init];
            for (NSMutableDictionary *dic in tempArray) {
                 //[haveDone addObject:[dic objectForKey:@"createTime"]];
//                if ([[[dic objectForKey:@"book"] objectForKey:@"id"] integerValue] == self.currentModel.bookmodel.bookId) {
//                    [haveDone addObject:[dic objectForKey:@"createTime"]];
//                }
                
                NSString *time = [AppTools timestampToTime:[dic objectForKey:@"createTime"] format:@"yyyyMMdd" ];
                //        NSString *str1 = [time substringToIndex:4];//不包含4
                //        NSString *str2 = [time substringWithRange:NSMakeRange(4, 2)];//包含4
                //        NSString *str3 = [time substringFromIndex:6];//包含6
                [haveDone addObject:[_caView dateDicWithYear:[[time substringToIndex:4] integerValue] month:[[time substringWithRange:NSMakeRange(4, 2)] integerValue] day:[[time substringFromIndex:6]  integerValue]]];
            }
            
            
            _caView.hadDoneArray = haveDone;
            [_caView reloadData];
            
//            self.calendarView.haveDone = haveDone;
//            NSMutableDictionary *startDateAndCycle = [[NSMutableDictionary alloc] init];
//
//            [startDateAndCycle setObject:[NSString stringWithFormat:@"%ld", self.startTime] forKey:@"startDate"];
//            [startDateAndCycle setObject:@(self.totalCycle) forKey:@"cycle"];
//            
//            
//            self.calendarView.startDateAndCycle = startDateAndCycle;
//            self.calendarView.date = [NSDate date];
        }else{
            [Global showWithView:self.view withText:[success objectForKey:@"describe"]];
        }
    } failure:^(NSError *error) {
        [Global showWithView:self.view withText:@"网络异常～"];
    }];
}



#pragma mark - UITableView代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.signTodayList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"punchInList";
    PunchInTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    SignModel *signmodel = [self.signTodayList objectAtIndex:indexPath.row];
    cell.signmodel = signmodel;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 460;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    [view addSubview:self.topScrollview];
    
    UIView *greeenView = [[UIView alloc] init];
    [view addSubview:greeenView];
    greeenView.backgroundColor = RGBHex(0x14d02f);
    
    [greeenView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.mas_equalTo(155);
        make.width.mas_equalTo(3);
        make.height.mas_equalTo(20);
    }];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [view addSubview:titleLabel];
    titleLabel.font = [UIFont boldSystemFontOfSize:15];

    titleLabel.text = @"课程进度";
    [titleLabel sizeToFit];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(greeenView.mas_right).offset(10);
        make.centerY.mas_equalTo(greeenView.mas_centerY);
    }];
    
    [view addSubview:self.caView];
    
    UIView *greeenView_ = [[UIView alloc] init];
    [view addSubview:greeenView_];
    greeenView_.backgroundColor = RGBHex(0x14d02f);
    
    [greeenView_ mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.mas_equalTo(430);
        make.width.mas_equalTo(3);
        make.height.mas_equalTo(20);
    }];
    
    UILabel *titleLabel_ = [[UILabel alloc] init];
    [view addSubview:titleLabel_];
    titleLabel_.font = [UIFont boldSystemFontOfSize:15];
    
    titleLabel_.text = @"今日打卡记录";
    [titleLabel_ sizeToFit];
    [titleLabel_ mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(greeenView_.mas_right).offset(10);
        make.centerY.mas_equalTo(greeenView_.mas_centerY);
    }];
    return view;
}

- (CalenderView *)caView{
    if (!_caView) {
        _caView = [[CalenderView alloc] initWithMinY:180];
        if (_hideBottom) {
            _caView.red = YES;
        }
    }
    return _caView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     SignModel *signmodel = [self.signTodayList objectAtIndex:indexPath.row];
    if (signmodel.repeatID == -1) {
        return;
    }else{
        MineShadowViewController *mineReadVC = [[MineShadowViewController alloc] init];
        mineReadVC.readId = signmodel.repeatID;
        mineReadVC.nameStr = signmodel.nickname;
        mineReadVC.urlStr = MINE_COURSE_Detail;
        mineReadVC.commentUrl = MINE_COURSE_Comment;
        mineReadVC.picRepeatType =  CoRepeatAppreciation;
        //mineReadVC.publishTime = model.dateModel.time;
        mineReadVC.likeUrl = USERCO_LIKE;
        mineReadVC.isFromPublish = YES;
        
        // Jxd-增加类型判断
        mineReadVC.picPushShow = YES;
        mineReadVC.bottomTitle = @"Comments to student";
        
        mineReadVC.rewardUrl =  COURSE_RepeatReward;
        
        [self.navigationController pushViewController:mineReadVC animated:YES];
    }
}

//- (YKCalendarView *)calendarView{
//    if (!_calendarView) {
//        _calendarView = [[YKCalendarView alloc] init];
//        _calendarView.frame = CGRectMake(10, 180, SCREEN_WIDTH - 20, 170);
//        _calendarView.delegate = self;
//    }
//    return _calendarView;
//}

#pragma mark - YKCalendarViewDelegate
- (void)lastOrNextMonth:(NSString *)dateYYYYMM{
    if (self.currentModel != nil) {
        //[self getUserCourseScheduleListWithDate:dateYYYYMM userCourseId:self.userCourseId];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001f;
}

//懒加载顶部scrollView
- (UIScrollView *)topScrollview{
    if (!_topScrollview) {
        _topScrollview = [[UIScrollView alloc] init];
        _topScrollview.backgroundColor = RGBHex(0xf0f0f0);
        _topScrollview.showsHorizontalScrollIndicator = NO;
        _topScrollview.bounces = YES;
        _topScrollview.contentSize = CGSizeMake(11.5 + 85 * self.courseDetailList.count + 4 * (self.courseDetailList.count - 1) + 11.5, 0);
        _topScrollview.frame = CGRectMake(0, 0, SCREEN_WIDTH, 140);
        [self createPictureImageView];
    }
    return _topScrollview;
}

- (void)createPictureImageView{
    UIView *view = [[UIView alloc] init];
    [self.topScrollview addSubview:view];
    view.frame = CGRectMake(0, 0, 11.5 + 85 * self.courseDetailList.count + 4 * (self.courseDetailList.count - 1) + 11.5, 140);
    
    NSMutableArray *cycleArr = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < self.courseDetailList.count; i++) {
        CourseDetailModel *courseDetail = self.courseDetailList[i];
        
        NSString *time = [AppTools timestampToTime:courseDetail.startTime format:@"yyyyMMdd" ];
//        NSString *str1 = [time substringToIndex:4];//不包含4
//        NSString *str2 = [time substringWithRange:NSMakeRange(4, 2)];//包含4
//        NSString *str3 = [time substringFromIndex:6];//包含6
        [cycleArr addObject:[self.caView beginYear:[[time substringToIndex:4] integerValue] month:[[time substringWithRange:NSMakeRange(4, 2)] integerValue] day:[[time substringFromIndex:6]  integerValue] cycle:courseDetail.cycleDay]];
        
        UIButton *whiteView = [UIButton buttonWithType:UIButtonTypeCustom];
        [view addSubview:whiteView];
        whiteView.backgroundColor = [UIColor whiteColor];
        whiteView.layer.masksToBounds = YES;
        whiteView.layer.cornerRadius = 3;
        whiteView.tag = 1000 + i;
        [whiteView addTarget:self action:@selector(pushPictureDetail:) forControlEvents:UIControlEventTouchUpInside];
        [whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(9);
            make.bottom.mas_equalTo(-9);
            make.width.mas_equalTo(85);
            make.left.mas_equalTo(11.5 + i * (85 + 4));
        }];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [whiteView addSubview:imageView];
        NSURL *url = [NSURL URLWithString:[Qiniu_host stringByAppendingString:[courseDetail.bookmodel.icon firstObject]]];
        [imageView sd_setImageWithURL:url];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 3;
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(1);
            make.bottom.mas_equalTo(-1);
            make.left.mas_equalTo(1);
            make.right.mas_equalTo(-1);
        }];

#pragma mark - Jxd-修改->判断条件
        /**
         修改之前的判断条件
         if ([courseDetail.startTime integerValue] > [[AppTools getTimestamp13] integerValue] || [courseDetail.startTime integerValue] + courseDetail.cycleDay * 3600 * 24 * 1000 < [[AppTools getTimestamp13] integerValue])
         */
        if ([courseDetail.startTime integerValue] > [[AppTools getTimestamp13] integerValue]) {
            whiteView.userInteractionEnabled = NO;
            
            UIView *blackDown = [[UIView alloc] init];
            [imageView addSubview:blackDown];
            blackDown.backgroundColor = [UIColor colorWithRed:0.02 green:0.02 blue:0.02 alpha:0.75];
            [blackDown mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.and.left.and.bottom.and.right.mas_equalTo(0);
            }];
        }else{
            
            self.currentModel = courseDetail;
            
#pragma mark - Jxd-修改->增加topScrollview的偏移量
            CGFloat currentX = 11.5 + i * (85 + 4);
            CGFloat offsetX = currentX + (85 * 0.5) - (SCREEN_WIDTH * 0.5);
            self.topScrollview.contentOffset = CGPointMake(offsetX, 0);

//            //当前时间
//            NSDate *dateNow = [NSDate date];
//            //----------设置你想要的格式，hh与HH的区别：分别表示12小时制，24小时制
//            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//            [formatter setDateFormat:@"YYYYMM"];
//            //----------将NSDate按formatter格式转成NSString
//            NSString *currentTimeString = [formatter stringFromDate:dateNow];
//            
            self.userCourseId = self.currentModel.courseDetailId;
//            //self.userCourseId = 38;
//            [self getUserCourseScheduleListWithDate:currentTimeString userCourseId:self.belong];
        }
    }
    
      _caView.beginAndCycleArray = cycleArr;
    

    if (!_hideBottom) {
        //当前时间
        NSDate *dateNow = [NSDate date];
        //----------设置你想要的格式，hh与HH的区别：分别表示12小时制，24小时制
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYYMM"];
        //----------将NSDate按formatter格式转成NSString
        NSString *currentTimeString = [formatter stringFromDate:dateNow];
        
        //self.userCourseId = self.currentModel.courseDetailId;
        //self.userCourseId = 38;
        [self getUserCourseScheduleListWithDate:currentTimeString userCourseId:self.belong];
        //    if (self.currentModel == nil) {
        //        self.calendarView.date = [NSDate date];
        //    }
        
    }
}

- (void)pushPictureDetail:(UIButton *)btn{
    CourseDetailModel *courseDetail = [self.courseDetailList objectAtIndex:btn.tag - 1000];
    
    PicWithReadViewController *readVC = [[PicWithReadViewController alloc] init];
    readVC.name = self.name;
    readVC.picId = courseDetail.bookmodel.bookId;
    readVC.belong = self.belong;
    readVC.rewardId = self.rewardStr;
    readVC.rewardUrl = PIC_Reward;
    readVC.isFromPublish = YES;
    readVC.isFromCalendar = YES;
    [self.navigationController pushViewController:readVC animated:YES];
}

#pragma mark - 底部视图
//创建下方按钮
- (void)createDownView{
    self.downView = [[UIView alloc] init];
    [self.view addSubview:self.downView];
    [self.downView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(44);
    }];
    
    UIButton *comment = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.downView addSubview:comment];
    comment.backgroundColor = RGBHex(0x14d02f);
#pragma mark - Jxd 修改--之前:讨论区,后:去评价
    [comment setTitle:@"集中纠错 To class" forState:UIControlStateNormal];
    comment.titleLabel.textColor = [UIColor whiteColor];
    comment.titleLabel.font = [UIFont systemFontOfSize:15 weight:2];
    [comment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH / 2);
        make.height.mas_equalTo(44);
    }];
    [comment addTarget:self action:@selector(commentBtnAct:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *punchIn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.downView addSubview:punchIn];
    punchIn.backgroundColor =RGBHex(0xfe6b76);
    [punchIn setTitle:@"去打卡" forState:UIControlStateNormal];
    punchIn.titleLabel.textColor = [UIColor whiteColor];
    punchIn.titleLabel.font = [UIFont systemFontOfSize:15 weight:2];
    [punchIn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(comment.mas_right).offset(0);
        make.top.equalTo(comment.mas_top).offset(0);
        make.width.mas_equalTo(SCREEN_WIDTH / 2);
        make.height.mas_equalTo(44);
    }];
    [punchIn addTarget:self action:@selector(punchInBtnAct:) forControlEvents:UIControlEventTouchUpInside];
}

//讨论区按钮触发方法
- (void)commentBtnAct:(UIButton *)btn{
    CoDiscussViewController *discussVC = [[CoDiscussViewController alloc] init];
    discussVC.picId = self.courseId;
    [self.navigationController pushViewController:discussVC animated:YES];
}

//去打卡按钮触发方法
- (void)punchInBtnAct:(UIButton *)btn{
    
    
    
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:Course_repeat_token forKey:@"uri"];
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:@(self.belong) forKey:@"course"];
    [parame setObject:@(self.currentModel.bookmodel.bookId) forKey:@"book"];
    
    // Jxd-start-----------------------------
#pragma mark - Jxd-添加 显示数据加载提示框
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // Jxd-end-----------------------------
    
    [[HttpManager sharedManager] POST:Course_repeat_token parame:parame sucess:^(id success) {
        if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
            PicFreeWithViewController *picFreeVC = [[PicFreeWithViewController alloc] init];
            picFreeVC.pictureId = self.currentModel.bookmodel.bookId;
//            picFreeVC.userCourseId = self.userCourseId;
            // Jxd-start-------------------------
#pragma mark - Jxd-修改- picFreeVC.userCourseId
            picFreeVC.userCourseId = self.belong;
            // Jxd-end--------------------------
            
            NSLog(@"userCourseId:%zd",self.userCourseId);
            
            picFreeVC.token = [[success objectForKey:@"data"] objectForKey:@"token"];
            picFreeVC.name = self.name;
            
            [self.navigationController pushViewController:picFreeVC animated:YES];
            
            // Jxd-start-----------------------------
#pragma mark - Jxd-添加 隐藏数据加载提示框
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            // Jxd-end-----------------------------
            
        }else{
            
            // Jxd-start-----------------------------
#pragma mark - Jxd-添加 隐藏数据加载提示框
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            // Jxd-end-----------------------------
            
            [Global showWithView:self.view withText:[success objectForKey:@"describe"]];
        }
    } failure:^(NSError *error) {
        [Global showWithView:self.view withText:@"网络错误"];
    }];
}

#pragma mark - 其他方法
//返回按钮方法
- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
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
