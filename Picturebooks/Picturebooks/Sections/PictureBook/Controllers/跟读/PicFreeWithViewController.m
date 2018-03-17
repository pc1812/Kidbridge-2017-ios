//
//  FollowViewController.m
//  FirstPage
//
//  Created by 尹凯 on 2017/7/14.
//  Copyright © 2017年 尹凯. All rights reserved.
//

#import "PicFreeWithViewController.h"
#import "PreviewViewController.h"
#import "PicFreeDetailViewController.h"
#import "MineShadowViewController.h"
#import "PunchInViewController.h"
#import "FollowCollectionViewCell.h"
#import "CustomIOSAlertView.h"
#import "Segment.h"
#import "HMAudioComposition.h"
#import "SRActionSheet.h"

// 底部录音创建的草稿视图的高度
#define DraftScrollView_H  XDHightRatio(75)
// 顶部->切换图片的视图
#define HeadView_H (SCREEN_WIDTH * 5/ 9)

@interface PicFreeWithViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, LGAudioPlayerDelegate, FollowCollectionViewCellDelegate, SRActionSheetDelegate>

@property (nonatomic, strong)UIView *headView;
@property (nonatomic, strong)UIImageView *headImg;
@property (nonatomic, strong)UILabel *pageLabel;
@property (nonatomic, strong)UICollectionView *myCollectionView;
@property (nonatomic, strong)UILabel *timeLable;
@property (nonatomic, strong)UIScrollView *draftScrollView;
@property (nonatomic, strong)MBProgressHUD *publishHud;//加载小菊花

//创建定时器（因为下面两个方法都使用，所以定时器设置为一个属性）
@property (nonatomic, strong)NSTimer *countDownTimer;
@property (nonatomic, assign)NSInteger secondCountDown;
@property (nonatomic, assign)NSInteger repeatActive;
@property (nonatomic, assign)NSInteger type;
@property (nonatomic, strong)NSMutableArray *imageArray;
@property (nonatomic, strong)NSMutableArray *messageArray;
@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, copy)NSString *getTokenUrl;
@property (nonatomic, assign)NSInteger repeatId;
@property (nonatomic, assign)NSInteger repeatPicId;
@property (nonatomic, copy)NSString *repeatName;
@property (nonatomic, assign)NSInteger  totalTime;//总时长


#pragma mark - Jxd-添加属性
/** 保存完成按钮的可变数组 */
@property (nonatomic,strong)  NSMutableArray *btnArrayM;

@end

@implementation PicFreeWithViewController

#pragma mark - 懒加载
/** 懒加载--完成按钮的数组 */
- (NSMutableArray *)btnArrayM {
    if (!_btnArrayM) {
        _btnArrayM = [NSMutableArray array];
    }
    return _btnArrayM;
}

- (void)dealloc{
    NSLog(@"没有内存泄漏");
    [LameTools clearSoundFile];
    [LameTools clearUploadFile];
    // 移除定时器
    [self killNSTimer];
    //移除所有通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = RGBHex(0xf0f0f0);
    self.navigationController.navigationBar.translucent = NO;
    //修改状态栏颜色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    //navigationBar背景颜色
    self.navigationController.navigationBar.barTintColor = RGBHex(0x14d02f);
    //navigationBar标题
    self.navigationItem.titleView = [UINavigationItem titleViiewWithTitle:self.name];

    //navigationBar标题字体、颜色
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
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
    
    [LameTools clearSoundFile];
    [LameTools clearUploadFile];
    [self createView];
    self.messageArray = [[NSMutableArray alloc] init];
    self.dataArray = [[NSMutableArray array] init];
    
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickShare:) name:@"wechatShare" object:nil];
    
    //音频播放代理协议
    [LGAudioPlayer sharePlayer].delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(killNSTimer) name:@"killNSTimer" object:nil];
    
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:@"/book/segment" forKey:@"uri"];
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:self.token forKey:@"repeat"];
    
    [[HttpManager sharedManager] POST:@"/book/segment" parame:parame sucess:^(id success) {
        
//        NSLog(@"--------------------------");
//        NSLog(@"%@",success);
//        NSLog(@"--------------------------");
        
        if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
            NSMutableDictionary *dic = [success objectForKey:@"data"];
            NSMutableArray *array = [dic objectForKey:@"bookSegmentList"];
            self.repeatActive = [[dic objectForKey:@"repeatActiveTime"] integerValue];
            self.imageArray = [[NSMutableArray array] init];
            
            // Jxd-start---------------------------------
#pragma mark - Jxd-修改 当前绘本限时打卡时间10分钟
            NSString *str_minute = [NSString stringWithFormat:@"当前绘本限时打卡%02ld分钟", (long)self.repeatActive/60];//分
            NSString *str_second = [NSString stringWithFormat:@"%02ld秒", (long)self.repeatActive%60];//秒
            if ([str_second isEqualToString:@"00秒"]) {
                str_second = @"";
            }
            
            [Global showWithView:self.view withText:[NSString stringWithFormat:@"%@%@", str_minute, str_second]];
            // Jxd-end---------------------------------
            
            for (NSMutableDictionary *dic in array) {
                Segment *model = [[Segment alloc] init];
                [model setValuesForKeysWithDictionary:dic];
                [self.imageArray addObject:model.icon];
                [self.dataArray addObject:model];
            }
            [self createImageView:self.imageArray];
            [self createCountDownView];
            [self createDraftScrollView];
            [self.myCollectionView reloadData];
        }else{
            [Global showWithView:self.view withText:[success objectForKey:@"describe"]];
        }
    } failure:^(NSError *error) {
        
        [Global showWithView:self.view withText:@"网络异常～"];
    }];
    
    self.publishHud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.publishHud];
    if (self.unlockState > 0) {
        self.type = 0;
        self.getTokenUrl = Repeat_token;
    }
    if (self.userCourseId > 0) {
        self.type = 3;
        self.getTokenUrl = Course_repeat_token;
    }
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
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        for (UIViewController *tempVC in self.navigationController.viewControllers) {
//            if ([tempVC isKindOfClass:[PicFreeDetailViewController class]] || [tempVC isKindOfClass:[PunchInViewController class]]) {
//                [self.navigationController popToViewController:tempVC animated:YES];
//            }
//        }
//
//    });
    
#pragma mark - Jxd-修改

    
}

//创建定时器视图
- (void)createCountDownView{
    self.secondCountDown = self.repeatActive;
    //设置定时器
    _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDownAction) userInfo:nil repeats:YES];
    
    
    //设置倒计时显示的时间
    NSString *str_minute = [NSString stringWithFormat:@"%02ld", (long)_secondCountDown/60];//分
    NSString *str_second = [NSString stringWithFormat:@"%02ld", (long)_secondCountDown%60];//秒
    NSString *format_time = [NSString stringWithFormat:@"%@:%@", str_minute, str_second];
    
    self.timeLable = [[UILabel alloc] init];
    [self.view addSubview:self.timeLable];
    self.timeLable.text = [NSString stringWithFormat:@"倒计时 %@", format_time];
    self.timeLable.textColor = [UIColor whiteColor];
    self.timeLable.font = [UIFont systemFontOfSize:14];
    self.timeLable.textAlignment = NSTextAlignmentCenter;
    self.timeLable.layer.masksToBounds = YES;
    self.timeLable.layer.cornerRadius = 12.5;
    self.timeLable.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.4];
    [self.timeLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(6);
        make.left.mas_equalTo((SCREEN_WIDTH - 120) / 2);
        make.height.mas_equalTo(25);
        make.width.mas_equalTo(120);
    }];
}

#pragma mark - 定时器执行方法
- (void)countDownAction{
    //倒计时-1
    _secondCountDown --;
    
    //重新计算
    NSString *str_minute = [NSString stringWithFormat:@"%02ld", (long)_secondCountDown/60];//分
    NSString *str_second = [NSString stringWithFormat:@"%02ld", (long)_secondCountDown%60];//秒
    NSString *format_time = [NSString stringWithFormat:@"%@:%@", str_minute, str_second];
    
    //修改倒计时标签及显示内容
    self.timeLable.text = [NSString stringWithFormat:@"倒计时 %@", format_time];
    
    //当倒计时到0时左需要的操作,比如验证码过期不能提交
    if (_secondCountDown == 0) {
        //计时器暂停，询问用户操作
        [self.countDownTimer setFireDate:[NSDate distantFuture]];
        
        CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
        //添加子视图
        alertView.backgroundColor = [UIColor whiteColor];
        [alertView setSubView:[self addSubViewWithTitle:@"已超时，打卡失败！\n是否重新打卡？"]];
        //添加按钮标题数组
        [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"重新打卡", @"退出打卡", nil]];
        //添加按钮点击方法
        [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
            if (buttonIndex == 0) {
                //关闭
                [alertView close];
                
                
                // Jxd-start--------------------------
#pragma mark - Jxd-修改:判断当前所在的控制器
                for (UIViewController *tempVC in self.navigationController.viewControllers) {
                    if ([tempVC isKindOfClass:[PreviewViewController class]]) {
                        [tempVC.navigationController popViewControllerAnimated:YES];
                    }
                }
                // Jxd-end-----------------------------
                
                
                //定时器启动
                [self.countDownTimer setFireDate:[NSDate distantPast]];
                
                self.secondCountDown = self.repeatActive;
                //重新计算
                NSString *str_minute = [NSString stringWithFormat:@"%02ld", (long)_secondCountDown/60];//分
                NSString *str_second = [NSString stringWithFormat:@"%02ld", (long)_secondCountDown%60];//秒
                NSString *format_time = [NSString stringWithFormat:@"%@:%@", str_minute, str_second];
                
                //修改倒计时标签及显示内容
                self.timeLable.text = [NSString stringWithFormat:@"倒计时 %@", format_time];
                
                //移除视图，清空数组
                [[self.view viewWithTag:12301] removeFromSuperview];
                for (UIView *view in self.draftScrollView.subviews) {
                    [view removeFromSuperview];
                }
                [self.messageArray removeAllObjects];
                
                [LameTools clearSoundFile];
                
                // Jxd-start----------------------
#pragma mark - Jxd-修改:将 CollectionViewCell 滚动到第一个
//                 [self.myCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
                self.myCollectionView.contentOffset=CGPointMake(0, 0);
                // Jxd-end------------------------
            
                NSMutableDictionary *parame_ = [HttpManager necessaryParameterDictionary];
                [parame_ setObject:self.getTokenUrl forKey:@"uri"];
                [parame_ setObject:[HttpManager getAddSaltMD5Sign:parame_] forKey:@"sign"];
                if (self.unlockState > 0) {
                    [parame_ setObject:@(self.unlockState) forKey:@"id"];
                }
                if (self.userCourseId > 0) {
                    [parame_ setObject:@(self.userCourseId) forKey:@"course"];
                    [parame_ setObject:@(self.pictureId) forKey:@"book"];
                }
                
                [[HttpManager sharedManager] POST:self.getTokenUrl parame:parame_ sucess:^(id success) {
                    if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
                        self.token = [[success objectForKey:@"data"] objectForKey:@"token"];
                    }else{
                        [Global showWithView:self.view withText:[success objectForKey:@"describe"]];
                    }
                } failure:^(NSError *error) {
                    [Global showWithView:self.view withText:@"网络错误"];
                }];
                
            }else{
                
                [self killNSTimer];
                [alertView close];
                
                for (UIViewController *tempVC in self.navigationController.viewControllers) {
                    if ([tempVC isKindOfClass:[PicFreeDetailViewController class]]) {
                        [self.navigationController popToViewController:tempVC animated:YES];
                    }
                }
                
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
        //显示
        [alertView show];
    }
}

//创建上方展示图片
- (void)createImageView:(NSMutableArray *)imageArray{
//    if (IS_IPHONE4) {
//         self.headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 110)];
//    }else if (IS_IPHONE5()) {
//        self.headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 150)];
//
//    }else{
//         self.headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 190)];
//    }
    
    self.headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, HeadView_H)];
    [self.view addSubview:self.headView];
    
//    for (int i = 0; i < imageArray.count; i++) {
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.headView.bounds];
//        NSURL *url = [NSURL URLWithString:[Qiniu_host stringByAppendingPathComponent:imageArray[imageArray.count - 1 - i]]];
//        [imageView sd_setImageWithURL:url];
//        imageView.tag = 1000 + imageArray.count - 1 - i;
//        [self.headView addSubview:imageView];
//    }
    
    self.headImg = [[UIImageView alloc] initWithFrame:self.headView.bounds];
    NSURL *url = [NSURL URLWithString:[Qiniu_host stringByAppendingPathComponent:imageArray[0]]];
    [self.headImg sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"head_placeholder"]];
    self.headImg.contentMode = UIViewContentModeScaleAspectFit;
    [self.headView addSubview:self.headImg];
    
    self.pageLabel = [[UILabel alloc] init];
    self.pageLabel.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.4];
    self.pageLabel.textAlignment = NSTextAlignmentCenter;
    self.pageLabel.text = [NSString stringWithFormat:@"1/%ld", (long)self.dataArray.count];
    [self.pageLabel sizeToFit];
    self.pageLabel.textColor = [UIColor whiteColor];
    self.pageLabel.layer.masksToBounds = YES;
    self.pageLabel.layer.cornerRadius = 10;
    [self.headView addSubview:self.pageLabel];
    
    [self.pageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.bottom.mas_equalTo(-4);
        make.size.mas_equalTo(CGSizeMake(50, 20));
    }];
}

#pragma mark - 创建视图
- (void)createView{
    [self createCollectionView];
}

//创建collectionView
- (void)createCollectionView{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    CGFloat margin = 12;
    CGFloat myCollectionView_H = SCREEN_HEIGHT - HeadView_H - DraftScrollView_H - PBNew64 - margin;
    CGFloat item_H = myCollectionView_H - margin;
    
    if (IS_IPHONE4) {
        flowLayout.itemSize = CGSizeMake(250, item_H);
    }else if (IS_IPHONE5()) {
        flowLayout.itemSize = CGSizeMake(280, item_H);
    }else{
        flowLayout.itemSize = CGSizeMake(319, item_H);
    }
    
    //设置最小行间距
    flowLayout.minimumLineSpacing = 0;
    //设置最小列间距
    flowLayout.minimumInteritemSpacing = 0;
    //设置item与四周边界的距离  上左下右
    flowLayout.sectionInset = UIEdgeInsetsMake(margin, 0, 0, 0);
    //设置滚动方向
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    
    if (IS_IPHONE4) {
        self.myCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH * 5/ 9, 250.001, myCollectionView_H) collectionViewLayout:flowLayout];
    }else if (IS_IPHONE5()) {
        self.myCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH * 5/ 9, 280.001, myCollectionView_H) collectionViewLayout:flowLayout];
    }else{
        self.myCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH * 5/ 9, 319.001, myCollectionView_H) collectionViewLayout:flowLayout];
    }
    
    // 设置超出区域的可点击范围
    self.myCollectionView.minHitTestWidth = SCREEN_WIDTH * 2;
    
    [self.view addSubview:self.myCollectionView];
    
    self.myCollectionView.delegate = self;
    self.myCollectionView.dataSource = self;
    self.myCollectionView.showsHorizontalScrollIndicator = NO;
    self.myCollectionView.backgroundColor = [UIColor clearColor];
    self.myCollectionView.pagingEnabled = YES;
    self.myCollectionView.clipsToBounds = NO;
    
    [self.myCollectionView registerClass:[FollowCollectionViewCell class] forCellWithReuseIdentifier:@"collectionFirstViewCell"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createDraft:) name:@"endRecordVoice" object:nil];
}

#pragma mark - collectionView代理方法
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.dataArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FollowCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionFirstViewCell" forIndexPath:indexPath];
    cell.totalPage = self.dataArray.count;
    cell.pageNum = indexPath.row;
    cell.segment = [self.dataArray objectAtIndex:indexPath.row];
    cell.delegate = self;
    cell.name = self.name;
    if ([LGAudioPlayer sharePlayer].index - 10 == cell.pageNum) {
        cell.playButton.selected = YES;
    }else{
        cell.playButton.selected = NO;
    }
    return cell;
}

#pragma mark - cell代理方法
//播放按钮触发代理方法
- (void)playAudioWithURLString:(NSString *)URLString index:(NSUInteger)index{
    if ([HttpManager isSavedFileToLocalWithFileName:[NSString stringWithFormat:@"%@.mp3", URLString]]) {
        [[LGAudioPlayer sharePlayer] playAudioWithURLString:[SoundFilesCaches stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", URLString]] atIndex:index];
    }else{
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.removeFromSuperViewOnHide = YES;
        HUD.labelText = @"缓存中...";
        HUD.backgroundColor = [UIColor clearColor];
        
        [[HttpManager sharedManager] downLoad:URLString success:^(id success) {
            [HUD hide:YES];
            [[LGAudioPlayer sharePlayer] playAudioWithURLString:[NSString stringWithFormat:@"%@", success] atIndex:index];
        } failure:^(NSError *error) {
            [Global showWithView:self.view withText:@"文件请求异常~"];
        }];
    }
}

//录音按钮触发代理方法
- (void)recordStatus:(NSInteger)status{
    if (status) {
        self.myCollectionView.scrollEnabled = NO;
        [Global showWithView:self.view withText:@"跟读录制开始～"];
    }else{
        self.myCollectionView.scrollEnabled = YES;
        [Global showWithView:self.view withText:@"跟读录制结束～"];
    }
}


#pragma mark - 创建草稿视图
- (void)createDraft:(NSNotification *)notification{
    
    NSInteger thisTag = [[notification.userInfo objectForKey:@"pageNum"] integerValue];
    if (self.messageArray.count != 0) {
        
        NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
        int i = 0;
        for (NSMutableDictionary *dic in self.messageArray) {
            if ([[dic objectForKey:@"pageNum"] integerValue] == thisTag) {

                NSString *filePath = [dic objectForKey:@"soundPath"];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                if ([fileManager fileExistsAtPath:filePath]) {
                    [fileManager removeItemAtPath:filePath error:nil];
                }
                tmpDic = dic;
                i++;
                [[self.draftScrollView viewWithTag:(1000 + thisTag)] removeFromSuperview];
            }
        }
        if (i == 1) {
            [self.messageArray removeObject:tmpDic];
        }
    }
    [self.messageArray addObject:notification.userInfo];
    
    UIView *draftView = [[UIView alloc]init];
    [self.draftScrollView addSubview:draftView];
    draftView.backgroundColor = [UIColor whiteColor];
    
    draftView.tag = 1000 + thisTag;
    [draftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(self.draftScrollView);
        make.left.mas_equalTo(SCREEN_WIDTH * thisTag);
    }];
    
    //阴影视图
    UIView *tempView = [[UIView alloc] init];
    [draftView addSubview:tempView];
    tempView.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    tempView.layer.shadowOpacity = 0.3;//阴影透明度，默认0
    tempView.layer.shadowRadius = 2;//阴影半径，默认3
    tempView.layer.shadowOffset = CGSizeMake(0,2);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
    [tempView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(14);
//        make.top.mas_equalTo(12);
//        make.width.and.height.mas_equalTo(47);
        
        make.left.mas_equalTo(XDWidthRatio(62));
        make.centerY.mas_equalTo(draftView);
        make.width.height.mas_equalTo(XDWidthRatio(47));
    }];
    
    UIImageView *headImageView = [[UIImageView alloc] init];
    [tempView addSubview:headImageView];
    headImageView.backgroundColor = [UIColor greenColor];
    headImageView.layer.masksToBounds = YES;
//    headImageView.layer.cornerRadius = 23.5;
    headImageView.layer.cornerRadius = XDWidthRatio(47) * 0.5;
    //头像图片选取判断
    NSString *headImage = [[NSUserDefaults standardUserDefaults] objectForKey:@"User_headimage"];
    if ([Global isNullOrEmpty:headImage]) {
        headImageView.image = [UIImage imageNamed:@"m_noheadimage"];
    }else{
        NSURL *imageUrl = [NSURL URLWithString:headImage];
        [headImageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"m_noheadimage"]];
    }
    [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(0);
//        make.left.mas_equalTo(0);
//        make.height.and.width.mas_equalTo(47);
        make.top.left.bottom.right.mas_equalTo(0);
    }];
    
//    UIView *soundView = [[UIView alloc] init];
//    [draftView addSubview:soundView];
//    soundView.backgroundColor = RGBHex(0x14d02f);
//
//#warning Jxd-mark
//    soundView.backgroundColor = [UIColor blackColor];
//
//    soundView.layer.masksToBounds = YES;
//    soundView.layer.cornerRadius = 10;
//    [soundView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(20);
//        make.width.mas_equalTo(182);
//        make.left.equalTo(headImageView.mas_right).offset(12);
//        make.top.mas_equalTo(55 / 2);
//    }];
//
//    UILabel *draftLabel = [[UILabel alloc] init];
//    [soundView addSubview:draftLabel];
//    draftLabel.text = @"音频草稿";
//    draftLabel.font = [UIFont systemFontOfSize:11];
//    draftLabel.textColor = [UIColor whiteColor];
//    [draftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(10);
//        make.top.mas_equalTo(3);
//    }];
//
//    UILabel *timeLabel = [[UILabel alloc] init];
//    [soundView addSubview:timeLabel];
//    timeLabel.text = [NSString stringWithFormat:@"%@", [AppTools secondsToMinutesAndSeconds:[notification.userInfo objectForKey:@"soundSeconds"]]];
//    timeLabel.font = [UIFont systemFontOfSize:11];
//    timeLabel.textColor = [UIColor whiteColor];
//    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(-10);
//        make.top.mas_equalTo(3);
//    }];
 
    // Jxd-start-------------------------------
#pragma mark - Jxd-添加->音频播放按钮
    /** 音频播放按钮 */
    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [draftView addSubview:playBtn];
    playBtn.tag = 10000 + thisTag;
    playBtn.backgroundColor = RGBHex(0x14d02f);
    
    // 设置图片
    [playBtn setImage:[UIImage imageNamed:@"followRead_play"] forState:UIControlStateNormal];
    [playBtn setImage:[UIImage imageNamed:@"followRead_pause"] forState:UIControlStateSelected];
    // 设置文字
    NSString *timeString = [NSString stringWithFormat:@"%@", [AppTools secondsToMinutesAndSeconds:[notification.userInfo objectForKey:@"soundSeconds"]]];
    [playBtn setTitle:timeString forState:UIControlStateNormal];
    playBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    // 设置图片与文件的间距
    [playBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [playBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -15)];
    
    playBtn.layer.masksToBounds = YES;
    playBtn.layer.cornerRadius = XDHightRatio(30) * 0.5;
    
    [playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(draftView.center);
        make.height.mas_equalTo(XDHightRatio(30));
        make.width.mas_equalTo(XDWidthRatio(90));
    }];
    [playBtn addTarget:self action:@selector(playAndStop:) forControlEvents:UIControlEventTouchUpInside];

    
    /** 完成按钮 */
    UIButton *completeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [draftView addSubview:completeButton];
    
    // 保存完成按钮
    [self.btnArrayM addObject:completeButton];
    
//    completeButton.backgroundColor = RGBHex(0x14d02f);
    [completeButton setBackgroundImage:[UIImage imageWithColor:RGBHex(0x14d02f)] forState:UIControlStateSelected];
    [completeButton setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
    // 设置相关属性
    [completeButton setTitle:@"完成" forState:UIControlStateNormal];
    completeButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    completeButton.layer.cornerRadius = XDWidthRatio(47) * 0.5;
    completeButton.layer.masksToBounds = YES;
    
    // 按钮的状态
    completeButton.selected = NO;
    
    // 添加点击事件
    [completeButton addTarget:self action:@selector(completeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    // 设置约束
    [completeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(draftView.mas_trailing).offset(-XDWidthRatio(62));
        make.centerY.mas_equalTo(draftView);
        make.height.width.mas_equalTo(XDWidthRatio(47));
    }];
    
    if (self.messageArray.count == self.dataArray.count) {
        completeButton.selected = YES;
        
        for (UIButton *btn in self.btnArrayM) {
            btn.selected = YES;
        }
        
//        [self completeBtn];
    }
    
    // Jxd-end-------------------------------
    
    
//    // 播放按钮
//    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [draftView addSubview:playBtn];
//    playBtn.tag = 10000 + thisTag;
//    [playBtn setImage:[UIImage imageNamed:@"repeat_play"] forState:UIControlStateNormal];
//    [playBtn setImage:[UIImage imageNamed:@"repeat_pause"] forState:UIControlStateSelected];
//    playBtn.layer.masksToBounds = YES;
//    playBtn.layer.cornerRadius = 12.5;
//    [playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(soundView.mas_right).offset(22);
//        make.top.mas_equalTo(25);
//        make.height.and.width.mas_equalTo(25);
//    }];
//    [playBtn addTarget:self action:@selector(playAndStop:) forControlEvents:UIControlEventTouchUpInside];
//
//    if (self.messageArray.count == self.dataArray.count) {
//        [self completeBtn];
//    }
}

#pragma mark - 完成按钮的点击事件
- (void)completeButtonClick:(UIButton *)sender
{
    if (sender.selected) {
        // 暂停计时器
        [self killNSTimer];
//        NSLog(@"完成,开始发布");
        [self pushPreviewViewController];
    }
    
}

#pragma mark - 创建音频草稿 ScrollView
//创建音频草稿scrollView
- (void)createDraftScrollView{
    self.draftScrollView = [[UIScrollView alloc] init];
    
    [self.view addSubview:self.draftScrollView];
    self.draftScrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 5, 0);
    self.draftScrollView.userInteractionEnabled = YES;
    //是否显示水平滑动条
    self.draftScrollView.showsHorizontalScrollIndicator = NO;
    self.draftScrollView.directionalLockEnabled = YES;
    self.draftScrollView.scrollEnabled = NO;
    self.draftScrollView.contentOffset = CGPointMake(0, 0);
    
    [self.draftScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
//        make.top.equalTo(self.myCollectionView.mas_bottom).offset(0);
//        make.height.mas_equalTo(75);
        make.height.mas_equalTo(DraftScrollView_H);
        make.bottom.mas_equalTo(0);
    }];
}

//播放按钮点击方法
- (void)playAndStop:(UIButton *)button{
    button.selected = !button.selected;
    for (NSMutableDictionary *dic in self.messageArray) {
        if ([[dic objectForKey:@"pageNum"] integerValue] == button.tag - 10000) {
            [[LGAudioPlayer sharePlayer] playAudioWithURLString:[dic objectForKey:@"soundPath"] atIndex:(button.tag - 10000)];
        }
    }
}

//LGAudioPlayer代理方法  当播放器状态改变时执行
- (void)audioPlayerStateDidChanged:(LGAudioPlayerState)audioPlayerState forIndex:(NSUInteger)index {
    
    NSInteger tmpTag = [[NSString stringWithFormat:@"%lu", (long)index] integerValue];
    
    if (audioPlayerState == 2) {
        
    }else if (audioPlayerState == 0){
        ((UIButton *)[[self.draftScrollView viewWithTag:1000 + tmpTag] viewWithTag:10000 + tmpTag]).selected = NO;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pageButtonChange" object:@(tmpTag)];
    }else{
        if (tmpTag != -1) {
            ((UIButton *)[[self.draftScrollView viewWithTag:1000 + tmpTag] viewWithTag:10000 + tmpTag]).selected = NO;
            
             [[NSNotificationCenter defaultCenter] postNotificationName:@"pageButtonChange" object:@(tmpTag)];
        }
    }
    
    
//
//    if (tmpTag < 10) {
//        if (audioPlayerState == 2) {
//            
//        }else if (audioPlayerState == 0){
//            ((UIButton *)[[self.draftScrollView viewWithTag:1000 + tmpTag] viewWithTag:10000 + tmpTag]).selected = NO;
//        }else{
//            if (tmpTag != -1) {
//                ((UIButton *)[[self.draftScrollView viewWithTag:1000 + tmpTag] viewWithTag:10000 + tmpTag]).selected = NO;
//            }
//        }
//    }else if(tmpTag >= 10 && tmpTag < 20){
//        if (audioPlayerState == 2) {
//            
//        }else if (audioPlayerState == 0){
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"pageButtonChange" object:@(tmpTag)];
//        }else{
//            if (tmpTag != -1) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"pageButtonChange" object:@(tmpTag)];
//            }
//        }
//    }
}

//创建完成按钮
- (void)completeBtn{
    [[self.view viewWithTag:12301] removeFromSuperview];
    UIButton *completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:completeBtn];
    completeBtn.backgroundColor = RGBHex(0x14d02f);
    completeBtn.tag = 12301;
    [completeBtn setTitle:@"完成跟读" forState:UIControlStateNormal];
    completeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [completeBtn addTarget:self action:@selector(pushPreviewViewController) forControlEvents:UIControlEventTouchUpInside];
    [completeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_offset(0);
        make.width.mas_offset(SCREEN_WIDTH);
        make.height.mas_offset(44);
    }];
}


#pragma mark - 跟读完成按钮触发方法
//用户可选择直接在该页面发布，或者跳转到预览页面，预览后再发布
- (void)pushPreviewViewController{
    [[LGAudioPlayer sharePlayer] stopAudioPlayer];
    
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    //添加子视图
    alertView.backgroundColor = [UIColor whiteColor];
//    [alertView setSubView:[self addSubViewWithTitle:@"跟读完成！您想直接发布或者\n预览后发布，请选择"]];
    [alertView setSubView:[self addSubViewWithTitle:@"绘本跟读完成!"]];
    //添加按钮标题数组
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"预览", @"发布", nil]];
    //添加按钮点击方法
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        if (buttonIndex == 0) {
            //关闭
            [alertView close];
            
            PreviewViewController *previewController = [[PreviewViewController alloc] init];
            previewController.imageArray = self.imageArray;
            previewController.messageArray = self.messageArray;
            previewController.dataArray = self.dataArray;
            previewController.token = self.token;
            previewController.name = self.name;
            previewController.type = self.type;
            
            // 计时器
//            previewController.currentTimer = self.countDownTimer;
            
#pragma mark - Jxd-temp
            NSLog(@"messageArray:%@",self.messageArray);
            
            [self.navigationController pushViewController:previewController animated:YES];
        }else{
            [alertView close];
            self.navigationItem.leftBarButtonItem.customView.userInteractionEnabled = NO;
            
            // Jxd-start--------------------------------------
#pragma mark - Jxd-修改:暂停计时器
//            [self killNSTimer];
            // Jxd-end--------------------------------------
            
            //显示的文字
            self.publishHud.labelText = @"发布中，请稍后！";
            //是否有遮罩
            self.publishHud.dimBackground = NO;
            self.publishHud.backgroundColor = [UIColor clearColor];
            //提示框的样式
            self.publishHud.mode = MBProgressHUDModeIndeterminate;
            [self.publishHud show:YES];
            
            NSMutableArray *tempMessageArray = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < self.dataArray.count; i++) {
                Segment *model = [self.dataArray objectAtIndex:i];
                for (NSMutableDictionary *dic in self.messageArray) {
                    if ([[dic objectForKey:@"pageNum"] integerValue] == i) {
                        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(model.ID), @"Id", [dic objectForKey:@"soundPath"], @"soundPath", nil];
                        [tempMessageArray addObject:tmpDic];
                    }
                }
            }
            
            NSString *filePath = [DocumentDirectory stringByAppendingPathComponent:@"UploadFile"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                NSError *error = nil;
                [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:&error];
                if (error) {
                    NSLog(@"%@", error);
                }
            }
            
            //创建多线程队列  对录制好的caf音频文件进行转码压缩，转成MP3后执行上传的一系列操作
            dispatch_queue_t queue = dispatch_queue_create("cafToMP3.queue", DISPATCH_QUEUE_CONCURRENT);
            
            NSMutableArray *newMessageArray = [[NSMutableArray alloc] init];
            for (NSMutableDictionary *dic in tempMessageArray) {
                dispatch_async(queue, ^{
                    [LameTools cafTransToMP3WithCafFilePath:[dic objectForKey:@"soundPath"] mp3FilePath:[DocumentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"UploadFile/%ld.mp3", (long)[[dic objectForKey:@"Id"] integerValue]]]];
                
                    NSInteger singleTime = [self singleTime:[DocumentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"UploadFile/%ld.mp3", (long)[[dic objectForKey:@"Id"] integerValue]]]];
                    
                    [newMessageArray addObject:@{@"Id" : @([[dic objectForKey:@"Id"] integerValue]), @"soundPath" : [DocumentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"UploadFile/%ld.mp3", (long)[[dic objectForKey:@"Id"] integerValue]]], @"time" : @(singleTime)}];
                    if (newMessageArray.count == tempMessageArray.count) {
                         [LameTools clearSoundFile];
                         [self getQiniuToken:newMessageArray];
                    }
                 
                });
            }
            //栅栏
//            dispatch_barrier_async(queue, ^{
//                [LameTools clearSoundFile];
//                [self getQiniuToken:newMessageArray];
//            });
        }
    }];
    //显示
    [alertView show];
}

#pragma mark - 音频转码压缩后的上传操作
//从后台请求到上传文件到七牛的token
- (void)getQiniuToken:(NSMutableArray *)newMessageArray{
    //得到基本固定参数字典，加入调用接口所需参数
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:Upload_token forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];

    [[HttpManager sharedManager] POST:Upload_token parame:parame sucess:^(id success) {
        
        if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
//            for (int i = 0; i < newMessageArray.count - 1; i++) {
//                for (int j = i + 1; j < newMessageArray.count; j++) {
//                    if ([newMessageArray[i][@"Id"] integerValue] > [newMessageArray[j][@"Id"] integerValue]) {
//                        //交换
//                        [newMessageArray exchangeObjectAtIndex:i withObjectAtIndex:j];
//                    }
//                }
//            }
            
//            NSMutableData *sounds = [NSMutableData alloc];
//
//            for (NSMutableDictionary *dic in newMessageArray) {
//                //音频文件路径
//                NSString *mp3Path = [dic objectForKey:@"soundPath"];
//                //音频数据
//                NSData *soundData = [[NSData alloc] initWithContentsOfFile: mp3Path];
//                //合并音频
//                [sounds appendData:soundData];
//            }
//            //保存音频
//            NSString *wholePath = [DocumentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"UploadFile/%@whole.mp3", [AppTools getTimestamp]]];
//            [sounds writeToFile:wholePath atomically:YES];
//            AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:wholePath]];
//            NSTimeInterval durationTime = asset.duration.value / asset.duration.timescale * 1000.0f;
            
//            AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:wholePath] options:nil];
//            
//            CMTime audioDuration = audioAsset.duration;
//            
//            float audioDurationSeconds =CMTimeGetSeconds(audioDuration) * 1000.0f;
//            self.totalTime = [[NSString stringWithFormat:@"%f",audioDurationSeconds] integerValue];
        
            [self uploadAudioToQiniu:[[success objectForKey:@"data"] objectForKey:@"token"] array:newMessageArray];
        }else{
            [Global showWithView:self.view withText:[success objectForKey:@"describe"]];
        }
    } failure:^(NSError *error) {
        [Global showWithView:self.view withText:@"网络异常~"];
    }];
}

//获取音频的时间

- (NSInteger)singleTime:(NSString *)filePath{
    AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:filePath] options:nil];
    
    CMTime audioDuration = audioAsset.duration;
    
    float audioDurationSeconds =CMTimeGetSeconds(audioDuration) * 1000.0f;

   return [[NSString stringWithFormat:@"%f",audioDurationSeconds] integerValue];
}

//得到token后，将文件上传七牛，并得到返回的文件名（文件名和id整理成键值对的形式，和后台传来的数据要对应上）
- (void)uploadAudioToQiniu:(NSString *)uplaod_token array:(NSMutableArray *)array{
    
  
    __weak PicFreeWithViewController *selfWeak = self;
    //创建多线程队列
    dispatch_queue_t queue = dispatch_queue_create("uploadToQiniu.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSMutableArray *postArray = [[NSMutableArray alloc] init];
        for (NSMutableDictionary *dic in array) {
            QNUploadManager *upManager = [[QNUploadManager alloc] init];
            NSData *data = [NSData dataWithContentsOfFile:[dic objectForKey:@"soundPath"]];
            [upManager putData:data key:nil token:uplaod_token
                      complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                          NSLog(@"%@", resp);
                          NSDictionary *dicAudio = @{@"source" : [resp objectForKey:@"key"], @"time": @([[dic objectForKey:@"time"] integerValue])};
                          
                          NSMutableDictionary *temDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([[dic objectForKey:@"Id"] integerValue]), @"id", dicAudio, @"audio", nil];
                          [postArray addObject:temDic];
                          if (postArray.count == array.count) {
                               [LameTools clearUploadFile];
                              [self postRepeatMessage:postArray];
//                              QNUploadManager *upManager_ = [[QNUploadManager alloc] init];
//                              NSData *data_ = [NSData dataWithContentsOfFile:wholePath];
//                              [upManager_ putData:data_ key:nil token:uplaod_token
//                                         complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
//                                           
//                                             //NSMutableDictionary *wholeDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[resp objectForKey:@"key"], @"audio",(self.totalTime), @"time", nil];
//                                             NSMutableDictionary *wholeDic = [[NSMutableDictionary alloc] init];
//                                             [wholeDic setObject:[resp objectForKey:@"key"] forKey:@"audio"];
//                                             [wholeDic setObject:@(totalTime) forKey:@"time"];
//                                           
//                                             NSLog(@"------%123@", wholeDic);
//                                             [LameTools clearUploadFile];
//                                             [self postRepeatMessage:postArray whole:wholeDic];
//                                         } option:nil];
                          }
                      } option:nil];
            
            
        }
    });
}

//将包含文件名和id字典的数组依照id逆行排序后，反给后台
- (void)postRepeatMessage:(NSMutableArray *)array{
    
    for (int i = 0; i < array.count - 1; i++) {
        for (int j = i + 1; j < array.count; j++) {
            if ([array[i][@"id"] integerValue] > [array[j][@"id"] integerValue]) {
                //交换
                [array exchangeObjectAtIndex:i withObjectAtIndex:j];
            }
        }
    }
    
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:Book_repeat forKey:@"uri"];
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    //提交跟读信息接口参数
//    NSMutableDictionary *segment = [[NSMutableDictionary alloc] init];
//    [segment setObject:array forKey:@"segmentation"];
//    [segment setObject:whole forKey:@"whole"];
//    [parame setObject:@{@"segment" : segment, @"token" : self.token} forKey:@"repeat"];
   
    [parame setObject:@{@"segment" : array, @"token" : self.token} forKey:@"repeat"];

    
    NSLog(@"%@", parame);
    
    [[HttpManager sharedManager] POST:Book_repeat parame:parame sucess:^(id success) {
        [self.publishHud hide:YES];
        if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
            
            self.repeatId = [success[@"data"][@"repeat"] integerValue];
            self.repeatPicId = [success[@"data"][@"type"] integerValue];
            
            CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
            // 添加子视图
            alertView.backgroundColor = [UIColor whiteColor];
            [alertView setSubView:[self addSubViewWithTitle:@"是否分享？"]];
            // 添加按钮标题数组
            [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"分享", @"不分享", nil]];
            // 添加按钮点击方法
            [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
                [self killNSTimer];
                if (buttonIndex == 0) {
                    //关闭
                    [alertView close];
                    self.navigationItem.leftBarButtonItem.customView.userInteractionEnabled = YES;
//                    for (UIViewController *tempVC in self.navigationController.viewControllers) {
//                        if ([tempVC isKindOfClass:[PicFreeDetailViewController class]] || [tempVC isKindOfClass:[PunchInViewController class]]) {
//                            [self.navigationController popToViewController:tempVC animated:YES];
//                        }
//                    }
                    
                    SRActionSheet *actionSheet = [SRActionSheet sr_actionSheetViewWithTitle:nil
                                                                                cancelTitle:@"取消"
                                                                           destructiveTitle:nil
                                                                                otherTitles:@[@"分享给微信好友", @"分享到朋友圈(+1滴水)"]
                                                                                otherImages:@[[UIImage imageNamed:@"pic_wechat"],
                                                                                              [UIImage imageNamed:@"pic_friend"]
                                                                                              ]
                                                                                   delegate:self];
                    actionSheet.cover.userInteractionEnabled = NO;
                    
                    actionSheet.otherActionItemAlignment = SROtherActionItemAlignmentCenter;
                    [actionSheet show];

                }else{
                    [alertView close];
                    //绘本跟读
                    if ([success[@"data"][@"type"] integerValue] == 0) {
                        MineShadowViewController *mineReadVC = [[MineShadowViewController alloc] init];
                        mineReadVC.readId = [success[@"data"][@"repeat"] integerValue];
                        mineReadVC.nameStr = self.name;
                        mineReadVC.urlStr = USER_READDETAIL;
                        mineReadVC.commentUrl = USER_COMMENT;
                        mineReadVC.picRepeatType = PicRepeatAppreciation;
                        mineReadVC.likeUrl = USER_LIKE;
                        mineReadVC.isFromPublish = YES;
                        mineReadVC.rewardUrl =  PIC_RepeatReward;
                        [self.navigationController pushViewController:mineReadVC animated:YES];

                    //课程跟读
                    }else{
                        
                        MineShadowViewController *mineReadVC = [[MineShadowViewController alloc] init];
                        mineReadVC.readId = [success[@"data"][@"repeat"] integerValue];
                        mineReadVC.nameStr = self.name;
                        mineReadVC.urlStr = MINE_COURSE_Detail;
                        mineReadVC.commentUrl = MINE_COURSE_Comment;
                        mineReadVC.picRepeatType =  CoRepeatAppreciation;
                        //mineReadVC.publishTime = model.dateModel.time;
                        mineReadVC.likeUrl = USERCO_LIKE;
                        mineReadVC.isFromPublish = YES;
                        // Jxd-增加类型判断
                        mineReadVC.picPushShow = YES;
                        
                        mineReadVC.rewardUrl =  COURSE_RepeatReward;
                        [self.navigationController pushViewController:mineReadVC animated:YES];

                    }
//                    self.navigationItem.leftBarButtonItem.customView.userInteractionEnabled = YES;
//                    MineShadowViewController *mineShadowVC = [[MineShadowViewController alloc] init];
//                    mineShadowVC.isFromPublish = YES;
//                    [self.navigationController pushViewController:mineShadowVC animated:YES];
                }
            }];
            //显示
            [alertView show];
        }
        else{
            [Global showWithView:self.view withText:[success objectForKey:@"describe"]];
        }
    } failure:^(NSError *error) {
        [self.publishHud hide:YES];
        [Global showWithView:self.view withText:@"网络异常~"];
    }];
}


#pragma mark - SRActionSheetDelegate
- (void)actionSheet:(SRActionSheet *)actionSheet didSelectSheet:(NSInteger)index {
    NSLog(@"%zd", index);
    
    NSString *nickName = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickname"];
    
//    if ([Global isNullOrEmpty:nickName]) {
//        nickName = @"我";
////    }
    nickName = @"我";
    
    //微信好友
    if (index == 0) {
        if ([WXApi isWXAppInstalled]) {
            WXMediaMessage *message = [WXMediaMessage message];
//            message.title = self.name;
//            message.description = @"HS英文绘本课堂";
            // 修改后的
            message.title = @"HS英文绘本课堂";
            message.description = [NSString stringWithFormat:@"%@在HS英文绘本课堂朗读了%@绘本，快来听听吧!",nickName,self.name];
            
//            NSString *urlString = [NSString stringWithFormat:@"%@/Fof8KyLYA3xDcxiB3NbnI9maVjIi", URL_share];
             NSString *urlString = [NSString stringWithFormat:@"%@/FhoQUFJLkpWzFtouV2pAVBzsVcIN", URL_share];
            UIImage *image_pic=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];
            CGSize size = {300,300};
            UIImage *new_imagePic=  [AppTools imageByScalingAndCroppingForSize:size withSourceImage:image_pic];
            [message setThumbImage:new_imagePic];
            WXWebpageObject *webpage = [WXWebpageObject object];
            if (self.repeatPicId == 0) {
                 webpage.webpageUrl = [NSString stringWithFormat:@"%@/share/book/repeat/%ld", URL_api, self.repeatId];
            }else{
                webpage.webpageUrl = [NSString stringWithFormat:@"%@/share/course/repeat/%ld", URL_api, self.repeatId];
                
            }
            message.mediaObject = webpage;
            
            SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;
            req.message = message;
            req.scene = WXSceneSession;
            [WXApi sendReq:req];
        }else{
            [self setupAlertController];
        }
        //微信朋友圈
    }else if (index == 1){
        if ([WXApi isWXAppInstalled]) {
            WXMediaMessage *message = [WXMediaMessage message];

            // 修改后的
            message.title = [NSString stringWithFormat:@"%@在HS英文绘本课堂朗读了%@绘本，快来听听吧!",nickName,self.name];

            
//            message.description = @"";
            
            //png图片压缩成data的方法，如果是jpg就要用 UIImageJPEGRepresentation
            //message.thumbData = UIImagePNGRepresentation(image);
//             UIImage *image_pic=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/Fof8KyLYA3xDcxiB3NbnI9maVjIi", URL_share]]]];
            UIImage *image_pic=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/FhoQUFJLkpWzFtouV2pAVBzsVcIN", URL_share]]]];
            CGSize size = {300,300};
            UIImage *new_imagePic=  [AppTools imageByScalingAndCroppingForSize:size withSourceImage:image_pic];
            [message setThumbImage:new_imagePic];
            WXWebpageObject *webpage = [WXWebpageObject object];
            if (self.repeatPicId == 0) {
                webpage.webpageUrl = [NSString stringWithFormat:@"%@/share/book/repeat/%ld", URL_api, self.repeatId];
            }else{
                webpage.webpageUrl = [NSString stringWithFormat:@"%@/share/course/repeat/%ld", URL_api, self.repeatId];
                
            }

            message.mediaObject = webpage;
            
            SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;//不使用文本信息
            req.message = message;
            req.scene = WXSceneTimeline;
            [WXApi sendReq:req];
        }else{
            [self setupAlertController];
        }
    }

#pragma mark - 之前跳转到上一个界面
//    for (UIViewController *tempVC in self.navigationController.viewControllers) {
//        if ([tempVC isKindOfClass:[PicFreeDetailViewController class]] || [tempVC isKindOfClass:[PunchInViewController class]]) {
//            [self.navigationController popToViewController:tempVC animated:YES];
//        }
//    }
    
#pragma mark - Jxd-修改
//    self.repeatId = [success[@"data"][@"repeat"] integerValue];
//    self.repeatPicId = [success[@"data"][@"type"] integerValue];

    if (self.repeatPicId == 0) {
        
        MineShadowViewController *mineReadVC = [[MineShadowViewController alloc] init];
        mineReadVC.readId = self.repeatId;
        mineReadVC.nameStr = self.name;
        mineReadVC.urlStr = USER_READDETAIL;
        mineReadVC.commentUrl = USER_COMMENT;
        mineReadVC.picRepeatType = PicRepeatAppreciation;
        mineReadVC.likeUrl = USER_LIKE;
        mineReadVC.isFromPublish = YES;
        mineReadVC.rewardUrl =  PIC_RepeatReward;
        [self.navigationController pushViewController:mineReadVC animated:YES];
    } else {
        
        MineShadowViewController *mineReadVC = [[MineShadowViewController alloc] init];
        mineReadVC.readId = self.repeatId;
        mineReadVC.nameStr = self.name;
        mineReadVC.urlStr = MINE_COURSE_Detail;
        mineReadVC.commentUrl = MINE_COURSE_Comment;
        mineReadVC.picRepeatType =  CoRepeatAppreciation;
        //mineReadVC.publishTime = model.dateModel.time;
        mineReadVC.likeUrl = USERCO_LIKE;
        mineReadVC.isFromPublish = YES;
        mineReadVC.rewardUrl =  COURSE_RepeatReward;
        [self.navigationController pushViewController:mineReadVC animated:YES];
    }
}



//设置弹出提示语
- (void)setupAlertController {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请先安装微信客户端" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:actionConfirm];
    [self presentViewController:alert animated:YES completion:nil];
}



#pragma mark - 返回按钮方法
- (void)back{
    self.navigationItem.leftBarButtonItem.customView.userInteractionEnabled = NO;
    
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    //添加子视图
    alertView.backgroundColor = [UIColor whiteColor];
    [alertView setSubView:[self addSubViewWithTitle:@"跟读未完成时退出将不会\n保存草稿!"]];
    //添加按钮标题数组
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"继续跟读", @"退出跟读", nil]];
    //添加按钮点击方法
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        if (buttonIndex == 0) {
            //关闭
            [alertView close];
            self.navigationItem.leftBarButtonItem.customView.userInteractionEnabled = YES;
        }else{
            [alertView close];
            [self killNSTimer];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    //显示
    [alertView show];
}

//自定义的子视图
- (UIView *)addSubViewWithTitle:(NSString *)title{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 230, 60)];
//    view.font = [UIFont systemFontOfSize:15];
    view.font = [UIFont boldSystemFontOfSize:15];
    view.textColor = [UIColor blackColor];
    view.text = title;
    view.numberOfLines = 0;
    view.textAlignment = NSTextAlignmentCenter;
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

#pragma mark - UIScrollView代理方法

//减速停止了时执行，手触摸时执行执行
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    if (IS_IPHONE4) {
        self.pageLabel.text = [NSString stringWithFormat:@"%d/%ld", (int)(scrollView.contentOffset.x / 250 + 1), (long)self.dataArray.count];
        //    for (UIImageView *temp in [self.headView subviews]) {
        //        if (temp.tag == 1000 + (int)(scrollView.contentOffset.x / 319)) {
        //            [self.headView bringSubviewToFront:temp];
        //        }
        //    }
        //UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.headView.bounds];
        NSInteger index = (int)(scrollView.contentOffset.x / 250);
        NSURL *url = [NSURL URLWithString:[Qiniu_host stringByAppendingPathComponent:self.imageArray[index]]];
        [self.headImg sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"head_placeholder"]];
        //[self.headView addSubview:imageView];
        
        [self.headView bringSubviewToFront:self.pageLabel];
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pageNumberChange" object:[NSString stringWithFormat:@"%d", (int)(scrollView.contentOffset.x / 250 + 1)]];
    }else if (IS_IPHONE5()) {
        self.pageLabel.text = [NSString stringWithFormat:@"%d/%ld", (int)(scrollView.contentOffset.x / 280 + 1), (long)self.dataArray.count];
        //    for (UIImageView *temp in [self.headView subviews]) {
        //        if (temp.tag == 1000 + (int)(scrollView.contentOffset.x / 319)) {
        //            [self.headView bringSubviewToFront:temp];
        //        }
        //    }
        //UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.headView.bounds];
        NSInteger index = (int)(scrollView.contentOffset.x / 280);
        NSURL *url = [NSURL URLWithString:[Qiniu_host stringByAppendingPathComponent:self.imageArray[index]]];
        [self.headImg sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"head_placeholder"]];
        //[self.headView addSubview:imageView];
        
        [self.headView bringSubviewToFront:self.pageLabel];
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pageNumberChange" object:[NSString stringWithFormat:@"%d", (int)(scrollView.contentOffset.x / 280 + 1)]];

    }else{
        self.pageLabel.text = [NSString stringWithFormat:@"%d/%ld", (int)(scrollView.contentOffset.x / 319 + 1), (long)self.dataArray.count];
        //    for (UIImageView *temp in [self.headView subviews]) {
        //        if (temp.tag == 1000 + (int)(scrollView.contentOffset.x / 319)) {
        //            [self.headView bringSubviewToFront:temp];
        //        }
        //    }
        //UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.headView.bounds];
        NSInteger index = (int)(scrollView.contentOffset.x / 319);
        NSURL *url = [NSURL URLWithString:[Qiniu_host stringByAppendingPathComponent:self.imageArray[index]]];
        [self.headImg sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"head_placeholder"]];
        //[self.headView addSubview:imageView];
        
        [self.headView bringSubviewToFront:self.pageLabel];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pageNumberChange" object:[NSString stringWithFormat:@"%d", (int)(scrollView.contentOffset.x / 319 + 1)]];

    }
}

//下方草稿scrollView跟随
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
//    [UIView animateWithDuration:0.3 animations:^{
//        self.draftScrollView.contentOffset = CGPointMake(scrollView.contentOffset.x / self.myCollectionView.frame.size.width * SCREEN_WIDTH, 0);
//    }];
    
    self.draftScrollView.contentOffset = CGPointMake(scrollView.contentOffset.x / self.myCollectionView.frame.size.width * SCREEN_WIDTH, 0);
    
}

#pragma mark - 其他方法
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[LGAudioPlayer sharePlayer] stopAudioPlayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)killNSTimer{
    //取消定时器 http://www.cnblogs.com/zhang6332/p/6253466.html
    [_countDownTimer setFireDate:[NSDate distantFuture]];
    [_countDownTimer invalidate];  //将定时器从运行循环中移除
    _countDownTimer = nil;  //销毁定时器,这样可以避免控制器不死
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
