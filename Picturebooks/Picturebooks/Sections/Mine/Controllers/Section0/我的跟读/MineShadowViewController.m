//
//  MineShadowViewController.m
//  Picturebooks
//
//  Created by Yasin on 2017/8/19.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "MineShadowViewController.h"
#import "SRActionSheet.h"
#import "PicEnjoyViewCell.h"
#import "PicWithComTableViewCell.h"
#import "CustomIOSAlertView.h"
#import "MineWithReModel.h"
#import "MineCommentModel.h"
#import "MineReplyModel.h"
#import "PicCommentViewController.h"
#import "PicFreeDetailViewController.h"
#import "PunchInViewController.h"
#import "HMAudioComposition.h"
#import "MineCoPicReModel.h"
#import "MineMoneysViewController.h"
@interface MineShadowViewController ()<UITableViewDelegate, UITableViewDataSource, SDCycleScrollViewDelegate,SRActionSheetDelegate, UITextFieldDelegate, LGAudioPlayerDelegate,AVAudioPlayerDelegate, UIWebViewDelegate>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic,strong)UISlider *slider;

@property (nonatomic,strong) UIView *stayTopView;
@property (nonatomic,assign) CGRect tempFrame;

@property (nonatomic, strong)UIView *bottomView;
@property (nonatomic, strong)UILabel *beginLab;
@property (nonatomic, strong)UILabel *endLab;

@property (nonatomic, strong)NSMutableArray *commentArr;
@property (nonatomic, strong)NSMutableArray *replyArr;
@property (nonatomic, strong)NSArray *userArr;
@property (nonatomic, strong)NSArray *carouselArr;
@property (nonatomic, strong)NSMutableArray *audioArr;
@property (nonatomic, copy)NSString *detailStr;
@property (nonatomic, copy)NSString *likeStr;
@property (nonatomic, weak)NSTimer *avTimer;
@property (nonatomic, assign)NSInteger like;
@property (nonatomic, assign)NSInteger likeId;
@property (nonatomic) NSInteger pageNum;//页数
@property (nonatomic) BOOL isMorePage;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic) double total;//总时长
@property (nonatomic, copy) NSArray *allAudioArr;
@property (nonatomic, strong)MBProgressHUD *progressHUD;
@property (nonatomic, assign)NSInteger webId;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, copy) NSArray *pathArray;

//@property (nonatomic, strong)NSMutableArray  *iconArr;
//@property (nonatomic, strong)UIPageControl *pageControl;
// 添加一个顶部切换图片的数组
//@property (nonatomic, copy)NSArray *cycleImgArray;

// 添加一个upView
@property (nonatomic, strong)UIView *upView;
/** 上一段音频按钮 */
@property (nonatomic,strong) UIButton *preBtn;
/** 下一段音频按钮 */
@property (nonatomic,strong) UIButton *nextBtn;

/** 当前用户点赞的状态 */
@property (nonatomic,strong)  NSNumber *likeState;

@end

@implementation MineShadowViewController
{
    UITextField *_numField;
    UIButton *playBtn;
    UIButton *likeBtn;
    UIButton *heartBtn;
    NSUInteger currentTrackNumber; // 记录当前播放音频的下标
//    UIImageView *cycleScrollView;
}

#pragma mark - 懒加载
//懒加载tableCiew
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, SCREEN_HEIGHT - PBNew64 - 44 - 40) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        
        _tableView.contentInset = UIEdgeInsetsMake(9, 0, 0, 0);

        // Jxd-start----------------------------
#pragma mark - Jxd-添加上拉加载功能
        _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            if (_isMorePage) {
                _pageNum++;
                [self commentData];
            }
            [_tableView.mj_footer endRefreshing];
        }];
        // Jxd-start----------------------------
    }
    return _tableView ;
}

/** 懒加载--顶部音频播放控制器视图 */
- (UIView *)upView {
    if (!_upView) {
        _upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        _upView.backgroundColor = JXDRGBColor(211, 211, 211);
        
        [self.view addSubview:_upView];

        /** 添加子控件 */
        CGFloat btnW = 32.0;    // 按钮的宽度
        CGFloat btnH = 36.0;    // 按钮的高度
        CGFloat btnY = (CGRectGetHeight(_upView.frame) - btnH) * 0.5;   // 按钮的 Y 值
        CGFloat space = 5; // 控件间的间距
        
        // 上一段音频按钮
        self.preBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, btnY, btnW, btnH)];
//        self.preBtn.backgroundColor = JXDRandomColor;
        [_upView addSubview:self.preBtn];
        // 设置相关属性
        [self.preBtn setImage:[UIImage imageNamed:@"pic_prePart"] forState:UIControlStateNormal];
        [self.preBtn addTarget:self action:@selector(preBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        // 默认不可点击
        self.preBtn.enabled = NO;
        
        // 播放音频按钮
        playBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.preBtn.frame) + space, btnY, btnW, btnH)];
        [_upView addSubview:playBtn];
//        playBtn.backgroundColor = JXDRandomColor;
        // 设置相关属性 r_pause  r_play
        [playBtn setImage:[UIImage imageNamed:@"r_pause"] forState:UIControlStateNormal];
        [playBtn setImage:[UIImage imageNamed:@"r_play"] forState:UIControlStateSelected];
        [playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        // 下一段音频按钮
        self.nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(playBtn.frame) + space, btnY, btnW, btnH)];
        [_upView addSubview:self.nextBtn];
//        self.nextBtn.backgroundColor = JXDRandomColor;
        // 设置相关属性
        
        [self.nextBtn setImage:[UIImage imageNamed:@"pic_nextPart"] forState:UIControlStateNormal];
        [self.nextBtn addTarget:self action:@selector(nextBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        // 开始时间的 Label
        self.beginLab = [UILabel new];
        [_upView addSubview:self.beginLab];
        LabelSet(self.beginLab, [self stringWithTime:self.audioPlayer.currentTime], [UIColor whiteColor], 10, beginDic, beginSize);
        self.beginLab.frame = CGRectMake(CGRectGetMaxX(self.nextBtn.frame), (40 - beginSize.height) * 0.5, beginSize.width + 3, beginSize.height);
        
        // 收藏心形按钮 UIbutton
        likeBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - btnW, btnY, btnW, btnH)];
        [_upView addSubview:likeBtn];
        // 设置相关属性
        [likeBtn setImage:[UIImage imageNamed:@"r_unlike"] forState:UIControlStateNormal];
        [likeBtn setImage:[UIImage imageNamed:@"r_like"] forState:UIControlStateSelected];
        [likeBtn addTarget:self action:@selector(likeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        // 结束时间的 Label
        self.endLab = [UILabel new];
        [_upView addSubview:self.endLab];
        LabelSet(self.endLab, [self stringWithTime:self.audioPlayer.duration], [UIColor whiteColor], 10, endDic, endSize);
        self.endLab.frame = CGRectMake(CGRectGetMinX(likeBtn.frame) - endSize.width, (40 - endSize.height) * 0.5, endSize.width + 3, endSize.height);
        
        // 进度条 UISlider
        CGFloat sliderW = CGRectGetMinX(self.endLab.frame) - CGRectGetMaxX(self.beginLab.frame);
        self.slider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.beginLab.frame), (40 - 20) * 0.5, sliderW , 20)];
        [_upView addSubview:self.slider];
        // 设置相关属性
        self.slider.minimumTrackTintColor = [Global convertHexToRGB:@"14d02f"];
        self.slider.maximumTrackTintColor = [UIColor whiteColor];
        self.slider.thumbTintColor = [Global convertHexToRGB:@"14d02f"];
        // 正常
        UIImage *sliderImg = [self OriginImage:[UIImage imageNamed:@"r_circle"] scaleToSize:CGSizeMake(10, 10)];
        [self.slider setThumbImage:sliderImg forState:UIControlStateNormal];
        [self.slider setThumbImage:sliderImg forState:UIControlStateHighlighted];
        // 添加不同的事件
        [self.slider addTarget:self action:@selector(processChanged) forControlEvents:UIControlEventValueChanged];
        [self.slider addTarget:self action:@selector(startSlider) forControlEvents:UIControlEventTouchDown];
        [self.slider addTarget:self action:@selector(endSlider) forControlEvents:UIControlEventTouchUpInside];

    }
    return _upView;
}

- (void)dealloc{
    NSLog(@"没有内存泄漏");
    if (self.audioPlayer) {
        self.audioPlayer.playing ? [self.audioPlayer stop] : nil;
        self.audioPlayer.delegate = nil;
        self.audioPlayer = nil;
    }
    [self removeProgressTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//杀死定时器
- (void)removeProgressTimer{
    [self.avTimer invalidate];
    self.avTimer = nil;
}

- (void)viewDidDisappear:(BOOL)animated{
    if (self.audioPlayer) {
        if ([self.audioPlayer isPlaying]) {
            [self.audioPlayer pause];
            [self.avTimer setFireDate:[NSDate distantFuture]];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _pageNum=0;
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (IOS7) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
//    self.navigationItem.titleView = [UINavigationItem titleViewForTitle:self.nameStr];
    // 修改导航头部标题为用户的昵称
//    if (self.picRepeatType == 0) {
//        NSString *nickName = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickname"];
//        self.title = nickName ? nickName : self.nameStr;
//    }
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightBarButtonItemWithImage:[UIImage imageNamed:@"pic_share"] highlighted:[UIImage imageNamed:@"pic_share"] target:self selector:@selector(share)];
    
//    playBtn = [UIButton new];
//    likeBtn = [UIButton new];
    heartBtn = [UIButton new];
//    self.slider = [[UISlider alloc] init];
//    self.endLab = [UILabel new];
//    self.beginLab = [UILabel new];
    
    [self upView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.bottomView];
    
    [self loadData];
    
    self.audioArr = [NSMutableArray arrayWithCapacity:0];
    self.commentArr = [NSMutableArray arrayWithCapacity:0];
    self.replyArr = [NSMutableArray arrayWithCapacity:0];
    
    [self commentData];
    
    
  
    self.navigationController.navigationBar.barTintColor = RGBHex(0x14d02f);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18 weight:2], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.view.backgroundColor = RGBHex(0xefeff4);
    
    if (self.navigationController.childViewControllers.count > 1) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 30)];
        [button setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        button.adjustsImageWhenHighlighted = NO;
        [button sizeToFit];
        UIView *containView = [[UIView alloc] initWithFrame:button.bounds];
        [containView addSubview:button];
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:containView];
        self.navigationItem.leftBarButtonItem = barButton;
    }
    
    //[_webView loadHTMLString:_pictext baseURL:[NSURL fileURLWithPath: [[NSBundle mainBundle]  bundlePath]]];
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentDataNotice) name:@"readload" object:nil];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickShare:) name:@"wechatShare" object:nil];
    //[LGAudioPlayer sharePlayer].delegate = self;
    
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    _webView.delegate = self;
    _webView.scrollView.scrollEnabled = NO;
    
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
            [Global showWithView:self.view withText:@"发送失败"];
            break;
        case -4:
            [Global showWithView:self.view withText:@"授权失败"];
            break;
            
        default:
            [Global showWithView:self.view withText:@"微信不支持"];
            break;
    }
}

- (void)back{
    if (self.isFromPublish) {
       
        for (UIViewController *tempVC in self.navigationController.viewControllers) {
            if ([tempVC isKindOfClass:[PicFreeDetailViewController class]] || [tempVC isKindOfClass:[PunchInViewController class]]) {
                [self.navigationController popToViewController:tempVC animated:YES];
            }
        }
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//我的跟读详情
- (void)loadData{
    //得到基本固定参数字典，加入调用接口所需参数
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:self.urlStr forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:@(self.readId) forKey:@"id"];
    
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.labelText = @"加载中...";
    HUD.backgroundColor = [UIColor clearColor];
    
    [[HttpManager sharedManager] POST:self.urlStr parame:parame sucess:^(id success) {
        [HUD hide:YES];
        
        if ([success[@"event"] isEqualToString:@"SUCCESS"]) {
            
            MineWithReModel *model = [MineWithReModel modelWithDictionary:success[@"data"][@"repeat"]];
            self.likeId = model.readId;
            
            // Jxd-start------------------------
#pragma mark - Jxd-修改标题
            self.title = model.book[@"name"];
            // 当前用户的点赞的状态
            self.likeState = success[@"data"][@"user"][@"like"];
            likeBtn.selected = self.likeState.integerValue;
            // Jxd-end------------------------
            
            if (self.picRepeatType == 0) {
                MineWithReModel *model = [MineWithReModel modelWithDictionary:success[@"data"][@"repeat"]];
                self.userArr = @[model.userModel.nickname, model.userModel.signature, model.time];
                self.detailStr = model.picModel.outline;
                self.carouselArr = model.picModel.icon;
                self.likeStr = [NSString stringWithFormat:@"%ld", (long)model.like];
                self.webId = model.picModel.ID;
    
            }else{
                 MineCoPicReModel *model = [MineCoPicReModel modelWithDictionary:success[@"data"][@"repeat"]];
                self.userArr = @[model.userModel.nickname, model.userModel.signature,  model.time];
                self.detailStr = model.picModel.outline;
                self.carouselArr = model.picModel.icon;
                self.likeStr = [NSString stringWithFormat:@"%ld", (long)model.like];
                self.webId = model.picModel.ID;
            }
            
            
//            NSString *urlStr;
//            if (self.picRepeatType == 0) {
//                urlStr = [NSString stringWithFormat:@"%@/book/richtext/%ld", URL_api, self.webId];
//            }else{
//                urlStr = [NSString stringWithFormat:@"%@/course/richtext/%ld", URL_api, self.webId];
//            }
//            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
            
            self.like = [success[@"data"][@"user"][@"like"] integerValue];
            self.allAudioArr = success[@"data"][@"repeat"][@"segment"];
            
            // 切换图片的数组
//            self.cycleImgArray = success[@"data"][@"repeat"][@"book"][@"bookSegmentList"];
            
//            NSInteger totalInt = [success[@"data"][@"repeat"][@"segment"][@"whole"][@"time"] integerValue] / 1000;
            
//            self.total =  [[NSString stringWithFormat:@"%ld", totalInt] doubleValue];
            
          
            
//            NSString *wholePath = [DocumentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"UploadFile/%ldwhole.m4a", (long)self.readId]];
//            if ([[NSFileManager defaultManager] fileExistsAtPath:wholePath]) {
//                [self videoPlay:wholePath];
//            }else{
//                //下载音频
//                [self downloadVideo:self.allAudioArr];
//
//            }
             [self downloadVideo:self.allAudioArr];

            
//            NSString *strUrl = success[@"data"][@"repeat"][@"segment"][@"whole"][@"audio"];
          
//
//            [self videoPlay:strUrl totalTime:self.total];
            
        }else{
             [Global showWithView:self.view withText:[success objectForKey:@"describe"]];
        }
        NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:0];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    } failure:^(NSError *error) {
      
        [Global showWithView:self.view withText:@"网络错误"];
    }];
}


//下载音频
- (void)downloadVideo:(NSArray *)audioArr{
     if (![[NSFileManager defaultManager] fileExistsAtPath:SoundFilesCaches]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:SoundFilesCaches withIntermediateDirectories:NO attributes:nil error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
    }

     NSMutableArray *newMessageArray = [[NSMutableArray alloc] init];
     //dispatch_queue_t queue = dispatch_queue_create("cafTo.queue", DISPATCH_QUEUE_CONCURRENT);
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.progressHUD.labelText = @"音频加载中...";
    self.progressHUD.backgroundColor = [UIColor clearColor];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSDictionary *dic in audioArr) {
            [[HttpManager sharedManager] downLoad:[NSString stringWithFormat:@"%@", dic[@"audio"][@"source"]] success:^(id success) {
                //[HUD hide:YES];
            
                NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([dic[@"id"] integerValue]), @"Id", [NSString stringWithFormat:@"%@", success], @"soundPath", nil];
                [newMessageArray addObject:tmpDic];
                
                if (newMessageArray.count == audioArr.count) {
                    [self audioSynthesis:newMessageArray];
                }
            
            } failure:^(NSError *error) {
                
                [Global showWithView:self.view withText:@"网络错误"];
            }];
        }
    });
}


//音频合成
- (void)audioSynthesis:(NSMutableArray *)newMessageArray{
    NSString *urlStr;
    if (self.picRepeatType == 0) {
        urlStr = [NSString stringWithFormat:@"%@/book/richtext/%ld", URL_api, self.webId];
    }else{
        urlStr = [NSString stringWithFormat:@"%@/course/richtext/%ld", URL_api, self.webId];
    }
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    [LameTools clearUploadFile];
//    for (int i = 0; i < newMessageArray.count - 1; i++) {
//        for (int j = i + 1; j < newMessageArray.count; j++) {
//            if ([newMessageArray[i][@"Id"] integerValue] > [newMessageArray[j][@"Id"] integerValue]) {
//                //交换
//                [newMessageArray exchangeObjectAtIndex:i withObjectAtIndex:j];
//            }
//        }
//    }
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"Id" ascending:YES]];
    [newMessageArray sortUsingDescriptors:sortDescriptors];
   
    NSString *filePath = [DocumentDirectory stringByAppendingPathComponent:@"UploadFile"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
    }
    
//    NSString *videoPath = [DocumentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"UploadFile/%ldwhole.m4a", (long)self.readId]];
//    
//    NSError *error;
//    if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
//        [[NSFileManager defaultManager] removeItemAtPath:videoPath error:&error];
//        
//    }
    


//    NSMutableData *sounds = [NSMutableData alloc];
//
//    for (NSMutableDictionary *dic in newMessageArray) {
//        //音频文件路径
//        NSString *mp3Path = [dic objectForKey:@"soundPath"];
//        //音频数据
//        NSData *soundData = [[NSData alloc] initWithContentsOfFile: mp3Path];
//        //合并音频
//        [sounds appendData:soundData];
//    }
//    //保存音频
   // NSString *wholePath = [DocumentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"UploadFile/%ldwhole.m4a", (long)self.readId]];
//    [sounds writeToFile:wholePath atomically:YES];
    
    
    //NSMutableArray *urls = [NSMutableArray arrayWithCapacity:0];

    self.pathArray = [newMessageArray valueForKeyPath:@"soundPath"];
    [self videoPlay:self.pathArray[currentTrackNumber]];
    
//    for (NSString *url in pathArray) {
//        [urls addObject:[NSURL fileURLWithPath:url]];
//    }
//    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    HUD.labelText = @"音频合成中...";
//    HUD.backgroundColor = [UIColor clearColor];
//    [HMAudioComposition sourceURLs:urls composeToURL:[NSURL fileURLWithPath:wholePath] completed:^(NSError *error) {
//        NSLog(@"-----%@", error);
//        [HUD hide:YES];
//
//        if (!error) {
//            [self videoPlay:wholePath];
//
//        }
//    }];
}

//音频播放
- (void)videoPlay:(NSString *)videoPatch{
    NSError *error;
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@", videoPatch]];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    self.audioPlayer.delegate = self;
    self.endLab.text = @"";
    self.endLab.text = [self stringWithTime: self.audioPlayer.duration];
}


- (void)videoPlay:(NSString *)string totalTime:(double)total{
    NSLog(@"----mp3%@", string);
    
    if ([HttpManager isSavedFileToLocalWithFileName:[NSString stringWithFormat:@"%@.p3", string]]) {
        
        NSURL *fileURL = [[NSURL alloc] initWithString:[SoundFilesCaches stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3",string]]];
        NSLog(@"-----路径%@",fileURL );
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        self.audioPlayer.delegate = self;
        self.endLab.text = @"";
        self.endLab.text = [self stringWithTime:self.total];
        
    }else{
        
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.removeFromSuperViewOnHide = YES;
        HUD.labelText = @"缓存中...";
        HUD.backgroundColor = [UIColor clearColor];
        
        [[HttpManager sharedManager] downLoad:string success:^(id success) {
            [HUD hide:YES];
            NSLog(@"success%@", success);
            NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@", success]];
            NSLog(@"-----123%@", url);
            
            NSError *error;
            self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
            
            NSLog(@"----cuowu%@", error);
            
            self.audioPlayer.delegate = self;
            self.endLab.text = @"";
            self.endLab.text = [self stringWithTime:total];
            
            NSLog(@"-----总时长%@", self.endLab.text);
            
            AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:success] options:nil];
            CMTime audioDuration = audioAsset.duration;
            float audioDurationSeconds =CMTimeGetSeconds(audioDuration);
            
            NSLog(@"----%f", audioDurationSeconds);
            
        } failure:^(NSError *error) {
            [HUD hide:YES];
            [Global showWithView:self.view withText:@"网络错误"];
        }];
    }
}


#pragma mark - Jxd-添加: 通知触发的事件
- (void)commentDataNotice
{
    [self.commentArr removeAllObjects];
    _pageNum = 0;
    [self commentData];
}

//评论数据
- (void)commentData{
    //得到基本固定参数字典，加入调用接口所需参数
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:self.commentUrl forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:@(self.readId) forKey:@"id"];
    [parame setObject:@(_pageNum * kOffset) forKey:@"offset"];
    [parame setObject:@(kOffset) forKey:@"limit"];
    
    
    [[HttpManager sharedManager] POST:self.commentUrl parame:parame sucess:^(id success) {
        
        if ([success[@"event"] isEqualToString:@"SUCCESS"]) {
            if (_pageNum == 0) {
                [self.commentArr removeAllObjects];
            }
            
            if (_picPushShow) {
                NSMutableArray *boyarray1= success[@"data"][@"important"];
                if (![boyarray1 isEqual:[NSNull null]]) {
                    for (NSDictionary *dic in boyarray1) {
                        MineCommentModel *model = [MineCommentModel modelWithDictionary:dic];
                        [self.commentArr addObject:model];
                    }
                }
                
                NSMutableArray *boyarray= success[@"data"][@"normal"];
                if (![boyarray isEqual:[NSNull null]]) {
                    for (NSDictionary *dic in boyarray) {
                        MineCommentModel *model = [MineCommentModel modelWithDictionary:dic];
                        [self.commentArr addObject:model];
                    }
                }
                
            }else{
                
                NSMutableArray *boyarray1= success[@"data"][@"comment"];
                
                if (![boyarray1 isEqual:[NSNull null]]) {
                    for (NSDictionary *dic in boyarray1) {
                        MineCommentModel *model = [MineCommentModel modelWithDictionary:dic];
                        [self.commentArr addObject:model];
                    }
                }

            }
            
//            NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:1];
//            [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            
            // Jxd-start---------------------------
#pragma mark - Jxd-添加-上拉加载数据
            NSInteger total = 0;
            total = self.commentArr.count;
            NSInteger totalPages = total / kOffset;
            
            NSLog(@"===========================");
            NSLog(@"commentArr:%zd",self.commentArr.count);
            NSLog(@"pageNum:%zd,totalPages:%zd",self.pageNum,totalPages);
            NSLog(@"===========================");
            
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
            // Jxd-start---------------------------
            
#pragma mark - Jxd-修改-更改全局刷新
            [self.tableView reloadData];
            
        }
    } failure:^(NSError *error) {
        [Global showWithView:self.view withText:@"网络错误"];
    }];
}

//下方评价视图
- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - PBNew64 - 44, SCREEN_WIDTH, 44)];
        _bottomView.backgroundColor = [UIColor whiteColor];
        UIButton *freeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        freeBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:2];
        [freeBtn setTitle:@"评价" forState:UIControlStateNormal];
        [freeBtn addTarget:self action:@selector(commentClick:) forControlEvents:UIControlEventTouchUpInside];
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

//评价按钮触发方法
- (void)commentClick:(UIButton *)button{
    if (self.picRepeatType == 0) {
        // 绘本馆
        PicCommentViewController *picCommentVC = [[PicCommentViewController alloc] init];
        picCommentVC.picCommentType = PicCommentRepeat;
        picCommentVC.readID = self.readId;
        picCommentVC.quote = -1;
        [self.navigationController pushViewController:picCommentVC animated:YES];
        
    }else{
        // 课程馆
        PicCommentViewController *picCommentVC = [[PicCommentViewController alloc] init];
        picCommentVC.picCommentType = MineCoCommentAppreciation;
        picCommentVC.readID = self.readId;
        picCommentVC.quote = -1;
        [self.navigationController pushViewController:picCommentVC animated:YES];
    }
}

//分享
- (void)share{
    SRActionSheet *actionSheet = [SRActionSheet sr_actionSheetViewWithTitle:nil
                                                                cancelTitle:@"取消"
                                                           destructiveTitle:nil
                                                                otherTitles:@[@"分享给微信好友", @"分享到朋友圈(+1水滴)"]
                                                                otherImages:@[[UIImage imageNamed:@"pic_wechat"],
                                                                              [UIImage imageNamed:@"pic_friend"]
                                                                              ]
                                                                   delegate:self];
    actionSheet.otherActionItemAlignment = SROtherActionItemAlignmentCenter;
    [actionSheet show];
}

#pragma mark - SRActionSheetDelegate
- (void)actionSheet:(SRActionSheet *)actionSheet didSelectSheet:(NSInteger)index {
    NSLog(@"%zd", index);
    //微信好友
    if (index == 0) {
        if ([WXApi isWXAppInstalled]) {
            WXMediaMessage *message = [WXMediaMessage message];
//            message.title = self.nameStr;
            message.title = @"HS英文绘本课堂";
//            message.description = @"HS英文绘本课堂";
            message.description = [NSString stringWithFormat:@"%@在HS英文绘本课堂朗读了%@绘本，快来听听吧!",self.userArr[0],self.nameStr];
#warning change--01--jixiaodong
//            UIImage *image_pic=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/Fof8KyLYA3xDcxiB3NbnI9maVjIi", URL_share]]]];
            UIImage *image_pic=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/FhoQUFJLkpWzFtouV2pAVBzsVcIN", URL_share]]]];
            CGSize size = {300,300};
            UIImage *new_imagePic=  [AppTools imageByScalingAndCroppingForSize:size withSourceImage:image_pic];
            [message setThumbImage:new_imagePic];
            WXWebpageObject *webpage = [WXWebpageObject object];
            if (self.picRepeatType == 0) {
                webpage.webpageUrl = [NSString stringWithFormat:@"%@/share/book/repeat/%ld", URL_api, self.readId];
            }else{
                webpage.webpageUrl = [NSString stringWithFormat:@"%@/share/course/repeat/%ld", URL_api, self.readId];
                
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
    }else if(index == 1) {
        if ([WXApi isWXAppInstalled]) {
            WXMediaMessage *message = [WXMediaMessage message];
//            message.title = self.nameStr;
            message.title = @"HS英文绘本课堂";
//            message.description = @"HS英文绘本课堂";
            message.description = [NSString stringWithFormat:@"%@在HS英文绘本课堂朗读了%@绘本，快来听听吧!",self.userArr[0],self.nameStr];
            //png图片压缩成data的方法，如果是jpg就要用 UIImageJPEGRepresentation
            //message.thumbData = UIImagePNGRepresentation(image);
//            UIImage *image_pic=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/Fof8KyLYA3xDcxiB3NbnI9maVjIi", URL_share]]]];
            UIImage *image_pic=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/FhoQUFJLkpWzFtouV2pAVBzsVcIN", URL_share]]]];
            CGSize size = {300,300};
            UIImage *new_imagePic=  [AppTools imageByScalingAndCroppingForSize:size withSourceImage:image_pic];
            [message setThumbImage:new_imagePic];

            WXWebpageObject *webpage = [WXWebpageObject object];
            if (self.picRepeatType == 0) {
                webpage.webpageUrl = [NSString stringWithFormat:@"%@/share/book/repeat/%ld", URL_api, self.readId];
            }else{
                webpage.webpageUrl = [NSString stringWithFormat:@"%@/share/course/repeat/%ld", URL_api, self.readId];
                
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
}

//设置弹出提示语
- (void)setupAlertController {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请先安装微信客户端" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:actionConfirm];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - UITableView代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    if (self.commentArr.count) {
        return self.commentArr.count;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return [self detailCellEithTableView:tableView cellForRowAtIndexPath:indexPath];
    }else{
        return [self commentCellEithTableView:tableView cellForRowAtIndexPath:indexPath ];
    }
}

- (UITableViewCell *)detailCellEithTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellId =[NSString stringWithFormat:@"cellTwo%ld%ld",(long)[indexPath section],(long)[indexPath row]];
//    PicEnjoyViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
//    if (!cell) {
//        cell = [[PicEnjoyViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
//    }
//    NSString *urlStr;
//    if (self.picRepeatType == 0) {
//        urlStr = [NSString stringWithFormat:@"%@/book/richtext/%ld", URL_api, self.webId];
//    }else{
//          urlStr = [NSString stringWithFormat:@"%@/course/richtext/%ld", URL_api, self.webId];
//    }
//    [cell setName:@"绘本正文" detail:urlStr];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.photoImg.image = [UIImage imageNamed:@"ceshi.jpg"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
   
   
    [cell.contentView addSubview:_webView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)commentCellEithTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.commentArr.count) {
        NSString *cellId =[NSString stringWithFormat:@"cellTwo%ld%ld",(long)[indexPath section],(long)[indexPath row]];
        PicWithComTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[PicWithComTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        MineCommentModel *model = self.commentArr[indexPath.row];
        NSString * url = [NSString stringWithFormat:@"%@%@", Qiniu_host, model.userModel.head];
        [cell.photoImg sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"defaultPhoto"]];
        NSString *time =  [AppTools secondsToMinutesAndSeconds:[NSString stringWithFormat:@"%ld", model.contentModel.time / 1000]];
        
        if (_picPushShow) {
            NSString *nickName;
            if (model.userModel.teacherId == -1) {
                nickName = model.userModel.nickname;
            }else{
                nickName = model.userModel.realname;
            }
            
            [cell setName:nickName detail:model.contentModel.text time:model.time  videoTime:time videoText:model.contentModel.source  arr:model.replyArr judge:YES];
            if (model.userModel.teacherId != -1) {
                cell.nameLab.textColor = [UIColor redColor];
            }
            
        }else{
             [cell setName:model.userModel.nickname detail:model.contentModel.text time:model.time  videoTime:time videoText:model.contentModel.source  arr:model.replyArr judge:NO];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        [cell.playBtn addTarget:self action:@selector(clickPlay:) forControlEvents:UIControlEventTouchUpInside];
        cell.playBtn.tag = 500 + indexPath.row;

        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIdentifier"];
    }
    
    UIImageView *imageView = [[UIImageView alloc ] init];
    imageView.image = [UIImage imageNamed:@"noComment"];
    [cell.contentView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cell.contentView.mas_top).offset(50);
        make.centerX.mas_equalTo(cell.contentView.mas_centerX);
    }];
    
    UILabel *commnetLab = [UILabel new];
    [cell.contentView addSubview:commnetLab];
    commnetLab.text = @"暂时还没评论哦~";
    commnetLab.font = [UIFont systemFontOfSize:13];
    commnetLab.textColor = [Global convertHexToRGB:@"999999"];
    [commnetLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imageView.mas_bottom).offset(10);
        make.centerX.mas_equalTo(cell.contentView.mas_centerX);
    }];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//播放音频
- (void)clickPlay:(UIButton *)button{
    [LGAudioPlayer sharePlayer].delegate = self;
    button.selected = !button.selected;
    MineCommentModel *model = self.commentArr[button.tag- 500];
    if ([HttpManager isSavedFileToLocalWithFileName:[NSString stringWithFormat:@"%@.mp3", model.contentModel.source]]) {
        [[LGAudioPlayer sharePlayer] playAudioWithURLString:[SoundFilesCaches stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", model.contentModel.source]] atIndex:button.tag- 500];
    }else{
        
//        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        HUD.removeFromSuperViewOnHide = YES;
//        HUD.labelText = @"缓存中...";
//        HUD.backgroundColor = [UIColor clearColor];
        
        [[HttpManager sharedManager] downLoad:model.contentModel.source success:^(id success) {
            
            //[HUD hide:YES];
            NSLog(@"------bofang%@", success);
            
            [[LGAudioPlayer sharePlayer] playAudioWithURLString:[NSString stringWithFormat:@"%@", success] atIndex:button.tag- 500];
        } failure:^(NSError *error) {
            //[HUD hide:YES];
            [Global showWithView:self.view withText:@"网络错误"];
        }];
    }
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
    NSLog(@"webViewDidStartLoad");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError===%@", error);
}

//cell高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak MineShadowViewController *preferSelf = self;
    if (indexPath.section == 0) {
//        PicEnjoyViewCell *sortCell = (PicEnjoyViewCell *)[preferSelf tableView:_tableView cellForRowAtIndexPath:indexPath];
//        return sortCell.frame.size.height;
         return _webView.frame.size.height;
    }else{
        if (self.commentArr.count) {
            PicWithComTableViewCell *sortCell = (PicWithComTableViewCell *)[preferSelf tableView:_tableView cellForRowAtIndexPath:indexPath];
            return sortCell.frame.size.height;
        }
        return 230;
    }
}

#pragma mark - tableView 的头部高度
//设置区头高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
//        return SCREEN_WIDTH * 5/9 + 100;
//        return SCREEN_WIDTH * 5/9 + 120;
        return 120;
    }else{
        return 65;
    }
}

//设置区尾高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 85;
    }else{
        return 0.001;
    }
}

//- (UIPageControl *)pageControl{
//    if (!_pageControl) {
//        _pageControl = [[UIPageControl alloc] init];
//        _pageControl.frame = CGRectMake((SCREEN_WIDTH - 80) / 2, 130, 80, 20);
//        _pageControl.currentPage = 0;
//        _pageControl.pageIndicatorTintColor = [UIColor grayColor];
//        _pageControl.currentPageIndicatorTintColor = [Global convertHexToRGB:@"14d02f"];
//    }
//    return _pageControl;
//}


/** 添加导航底部悬浮视图 */
- (UIView *)stayTopView {
    if (!_stayTopView) {
        _stayTopView = [UIView new];
        _stayTopView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
        [self.view addSubview:_stayTopView];
    }
    return _stayTopView;
}

#pragma mark - tableView 的头部视图
//区头
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    __strong UIView *view = [UIView new];
    if (section == 0) {
        view.backgroundColor = [UIColor whiteColor];
        
//        SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 192) delegate:self placeholderImage:[UIImage imageNamed:@"head_placeholder"]];
//        cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
//        cycleScrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFit;
//        //         --- 模拟加载延迟
//        cycleScrollView.currentPageDotColor = [Global convertHexToRGB:@"14d02f"];

//        self.iconArr = [NSMutableArray array];
        
//        for (NSString *string in self.carouselArr) {
//            NSString * url = [NSString stringWithFormat:@"%@%@", Qiniu_host, string];
//            [self.iconArr addObject:url];
//        }
 
#pragma mark - 将上面的 for 修改为下面这个(更改获取图片的数据源)
        // 修改为
//        for (NSDictionary *dict in self.cycleImgArray) {
//            NSString * url = [NSString stringWithFormat:@"%@%@", Qiniu_host, dict[@"icon"]];
//            [self.iconArr addObject:url];
//        }
        
        // 记录发布时间标签的 Frame
        CGRect publishLabFrame = CGRectZero;
        
        NSArray *titleArr = @[@"朗读者:", @"个性签名:", @"发布时间:"];
        for (int i = 0; i < titleArr.count; i++) {
            UILabel *nameLab = [UILabel new];
            LabelSet(nameLab, titleArr[i], [UIColor blackColor], 15, nameDic, nameSize);
            
#pragma mark - jxd-修改->前:nameSize.width 后: nameSize.width + 10
//            nameLab.frame = FRAMEMAKE_F(10, CGRectGetMaxY(cycleScrollView.frame) + 15 + (i % 3) * nameSize.height  + 10 * i, nameSize.width + 10, nameSize.height);
            nameLab.frame = FRAMEMAKE_F(10, 15 + (i % 3) * nameSize.height  + 10 * i, nameSize.width + 10, nameSize.height);
            
            [nameLab setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
            [view addSubview:nameLab];
            
            UILabel *detailLab = [UILabel new];
            [view addSubview:detailLab];
            
#pragma mark - jxd-修改->增加判断:增加匿名用户标识
            NSString *detailStr = nil;
            if ([titleArr[i] isEqualToString:@"朗读者:"]) {
                if ([Global isNullOrEmpty:self.userArr[i]]) {
                    detailStr = @"匿名用户";
                } else {
                    detailStr = self.userArr[i];
                }
            }
            
            if ([titleArr[i] isEqualToString:@"个性签名:"]) {
                if ([Global isNullOrEmpty:self.userArr[i]]) {
                    detailStr = @"暂无签名";
                } else {
                    detailStr = self.userArr[i];
                }
            }
            
            if ([titleArr[i] isEqualToString:@"发布时间:"]) {
                detailStr = self.userArr[i];
                publishLabFrame = nameLab.frame;
            }
            
            LabelSet(detailLab, detailStr, [UIColor blackColor], 15, detailDic, detailSize);
//            detailLab.frame = FRAMEMAKE_F(CGRectGetMaxX(nameLab.frame) + 10, 15 + (i % 3) * detailSize.height  + 10 * i, detailSize.width, detailSize.height);
#pragma mark - Jxd-修改:限制朗读者昵称的宽度
            detailLab.frame = FRAMEMAKE_F(CGRectGetMaxX(nameLab.frame) + 10, 15 + (i % 3) * detailSize.height  + 10 * i, SCREEN_WIDTH * 0.6, detailSize.height);
        }
        
        UIImage *likePhoto = [UIImage imageNamed:@"pic_unlike"];
        UILabel *likeLab = [UILabel new];
        LabelSet(likeLab, self.likeStr, RGBHex(0x999999), 13, allDic, allSize);
        likeLab.frame = FRAMEMAKE_F(SCREEN_WIDTH - 10 - allSize.width, 15 , allSize.width, allSize.height);
        
        //添加全选图片按钮
        heartBtn.frame = CGRectMake(SCREEN_WIDTH - 20 - likePhoto.size.width -  allSize.width, CGRectGetMinY(likeLab.frame) + 2 , likePhoto.size.width + allSize.width + 20, likePhoto.size.height);
        [heartBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [heartBtn setImage:[UIImage imageNamed:@"pic_like"] forState:UIControlStateNormal];
        heartBtn.tag = 120;
        [view addSubview:likeLab];
        [view addSubview:heartBtn];
        
//        UIButton *freeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        freeBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:2];
//        [freeBtn setTitle:@"鼓励" forState:UIControlStateNormal];
//        [freeBtn addTarget:self action:@selector(encourageClick:) forControlEvents:UIControlEventTouchUpInside];
//        freeBtn.backgroundColor = [Global convertHexToRGB:@"14d02f"];
//        [view addSubview:freeBtn];
//        freeBtn.frame = FRAMEMAKE_F((SCREEN_WIDTH - 83) / 2, CGRectGetMaxY(cycleScrollView.frame) + 105, 83, 38);
//        freeBtn.layer.cornerRadius = 5;
//        freeBtn.clipsToBounds = YES;
//        [view addSubview:freeBtn];
//        
//        UILabel *encourLab = [UILabel new];
//        LabelSet(encourLab, @"宝贝,轻轻一点可以鼓励作者哦~", [Global convertHexToRGB:@"999999"], 13, enDic, enSize);
//        encourLab.frame = FRAMEMAKE_F((SCREEN_WIDTH - enSize.width) / 2, CGRectGetMaxY(freeBtn.frame) + 15, enSize.width, enSize.height);
//        [view addSubview:encourLab];
        
//        UIView *white = [[UIView alloc] initWithFrame:CGRectMake(0, 312 + 75 - 10, SCREEN_WIDTH, 10)];
//        white.backgroundColor = RGBHex(0xf0f0f0);
//        [view addSubview:white];
        
#pragma mark - Jxd 修改-添加绘本正文标签
        CGFloat tigViewY = CGRectGetMaxY(publishLabFrame);
        UIView *tigView = [[UIView alloc] initWithFrame:CGRectMake(0, tigViewY + 10, SCREEN_WIDTH, 20)];
        [view addSubview:tigView];
        
        UILabel *greenLab = [UILabel new];
        [tigView addSubview:greenLab];
        greenLab.frame = FRAMEMAKE_F(10, 0, 2, 20);
        greenLab.backgroundColor = RGBHex(0X13D02F);
        
        UILabel *nameLab = [UILabel new];
        [tigView addSubview:nameLab];
        nameLab.text = @"绘本正文";
        nameLab.textColor = [UIColor blackColor];
        nameLab.font = [UIFont systemFontOfSize:16 weight:2];
        NSDictionary *conDic = StringFont_DicK(nameLab.font);
        CGSize conSize = [nameLab.text sizeWithAttributes:conDic];
        nameLab.frame = FRAMEMAKE_F(CGRectGetMaxX(greenLab.frame) + 13, CGRectGetMinY(greenLab.frame), conSize.width, conSize.height);
        
    }else{
        view.backgroundColor = [UIColor whiteColor];
        UILabel *_greeLab = [UILabel new];
        _greeLab.frame = FRAMEMAKE_F(10, 30, 2, 20);
        _greeLab.backgroundColor = RGBHex(0X13D02F);
        
        UILabel *_nameLab = [UILabel new];
        _nameLab.text = @"评论区";
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
    view.backgroundColor = [UIColor whiteColor];
    if (section == 0) {
        UIButton *freeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        freeBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:2];
        [freeBtn setTitle:@"打赏" forState:UIControlStateNormal];
        [freeBtn addTarget:self action:@selector(encourageClick:) forControlEvents:UIControlEventTouchUpInside];
        freeBtn.backgroundColor = [Global convertHexToRGB:@"14d02f"];
        [view addSubview:freeBtn];
        freeBtn.frame = FRAMEMAKE_F((SCREEN_WIDTH - 83) / 2, 10, 83, 38);
        freeBtn.layer.cornerRadius = 5;
        freeBtn.clipsToBounds = YES;
        [view addSubview:freeBtn];
        
        UILabel *encourLab = [UILabel new];
        LabelSet(encourLab, @"宝贝,轻轻一点可以打赏作者哦~", [Global convertHexToRGB:@"999999"], 13, enDic, enSize);
        encourLab.frame = FRAMEMAKE_F((SCREEN_WIDTH - enSize.width) / 2, CGRectGetMaxY(freeBtn.frame) + 15, enSize.width, enSize.height);
        [view addSubview:encourLab];

    }else{
         view.backgroundColor = RGBHex(0xf0f0f0);
    }
    return view;
}

//播放按钮触发方法
- (void)playBtnClick:(UIButton *)button{
    playBtn.selected = !playBtn.selected;
    if (!_avTimer) {
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
        
        //设置定时器
        _avTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(avTimerAction) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_avTimer forMode:NSRunLoopCommonModes];
    }else{
        if ([_audioPlayer isPlaying]) {
            [_audioPlayer pause];
            [_avTimer setFireDate:[NSDate distantFuture]]; //关闭定时器
        }else{
            [_audioPlayer play];
            [_avTimer setFireDate:[NSDate distantPast]];//开启定时器
        }
    }
}

// Jxd-start ------------------------------------------------
#pragma mark - Jxd- 添加:播放上一段音频
/** 播放上一段音频 */
- (void)preBtnClick:(UIButton *)sender
{
    if ([_audioPlayer isPlaying]) {
        [_audioPlayer pause];
        [_avTimer setFireDate:[NSDate distantFuture]]; //关闭定时器
    }
    
    sender.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
        
        currentTrackNumber--;
        self.nextBtn.enabled = YES;
        if (currentTrackNumber == 0) {
            sender.enabled = NO;
        }
        // 播放音频
        [self playAudioVideo];
        
     });
    
}
// Jxd-end ------------------------------------------------

// Jxd-start ------------------------------------------------
#pragma mark - Jxd-添加:播放下一段音频
/** 播放下一段音频 */
- (void)nextBtnClick:(UIButton *)sender
{
    if ([_audioPlayer isPlaying]) {
        [_audioPlayer pause];
        [_avTimer setFireDate:[NSDate distantFuture]]; //关闭定时器
    }
    
    sender.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
        
        currentTrackNumber++;
        self.preBtn.enabled = YES;
        if (currentTrackNumber == [self.pathArray count] - 1) {
            self.nextBtn.enabled = NO;
        }
        // 播放音频
        [self playAudioVideo];
        
    });
    
    
}
// Jxd-end ------------------------------------------------

// Jxd-start ------------------------------------------------
#pragma mark - Jxd-添加- 封装播放音频的代码
- (void)playAudioVideo
{
    // 更改播放按钮的状态
    playBtn.selected = YES;
    
    if (currentTrackNumber <= [self.pathArray count] - 1) {
        if (_audioPlayer) {
            [_audioPlayer stop];
            _audioPlayer = nil;
            [self.avTimer setFireDate:[NSDate distantFuture]];
            self.slider.value = 0;
            self.beginLab.text = @"00:00";
        }
        
        [self videoPlay:self.pathArray[currentTrackNumber]];
        [_audioPlayer play];
        _avTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(avTimerAction) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_avTimer forMode:NSRunLoopCommonModes];
    }
}
// Jxd-end ------------------------------------------------

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (flag) {
        
        if (currentTrackNumber < [self.pathArray count] - 1) {
            currentTrackNumber ++;
            
            // Jxd-start ------------------------------------------------
#pragma mark - Jxd-添加判断:添加判断当前音频下标的值不为0,上一段按钮可以点击
            if (currentTrackNumber != 0) {
                self.preBtn.enabled = YES;
            }
            if (currentTrackNumber == [self.pathArray count] - 1) {
                self.nextBtn.enabled = NO;
            }
            // Jxd-end ------------------------------------------------
            
            if (_audioPlayer) {
                [_audioPlayer stop];
                _audioPlayer = nil;
                [self.avTimer setFireDate:[NSDate distantFuture]];
                self.slider.value = 0;
                self.beginLab.text = @"00:00";
            }
   
//            [cycleScrollView sd_setImageWithURL:[NSURL URLWithString:self.iconArr[currentTrackNumber]]];
//            self.pageControl.currentPage = currentTrackNumber;
            
            [self videoPlay:self.pathArray[currentTrackNumber]];
            [_audioPlayer play];
            _avTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(avTimerAction) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:_avTimer forMode:NSRunLoopCommonModes];
            // [self.tableView reloadData];
            
        }else{
            
            // Jxd-start ------------------------------------------------
#pragma mark - Jxd-添加判断:音频播放结算后上一段与下一段音频按钮不可以点击
            self.preBtn.enabled = NO;
            self.nextBtn.enabled = YES;
            // Jxd-end ------------------------------------------------
            
            currentTrackNumber = 0;
            playBtn.selected = NO;
            [self.avTimer setFireDate:[NSDate distantFuture]];
            self.slider.value = 0;
            [self videoPlay:self.pathArray[currentTrackNumber]];
            self.beginLab.text = @"00:00";
            
//            [cycleScrollView sd_setImageWithURL:[NSURL URLWithString:self.iconArr[currentTrackNumber]]];
//            self.pageControl.currentPage = currentTrackNumber;
        }
        
        //        playBtn.selected = NO;
        //        [self.avTimer setFireDate:[NSDate distantFuture]];
        //        self.slider.value = 0;
        //        self.beginLab.text = @"00:00";
        
    }
}

//将时间转换成字符串
- (NSString *)stringWithTime:(NSTimeInterval)time{
//    NSInteger min = time / 60;
//    NSInteger second = (NSInteger)time % 60;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"mm:ss";
    NSString *timeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
    return timeStr;
    
    //return [NSString stringWithFormat:@"%02ld:%02ld", (long)min, (long)second];
}

//定时器调用方法
- (void)avTimerAction{
    //1.更新当前播放时间
    self.beginLab.text = [self stringWithTime:self.audioPlayer.currentTime];
    //2.更新滑块的位置
    self.slider.value = self.audioPlayer.currentTime / self.audioPlayer.duration;
    
}

#pragma mark - slider监听事件
//值改变时执行
-(void)processChanged{
    //1.设置当前播放时间的label
    self.beginLab.text = [self stringWithTime:(self.audioPlayer.duration * self.slider.value)];
}

//开始触碰滑块时执行
- (void)startSlider{
    if (playBtn.selected == YES) {
        [self.audioPlayer pause];
        [self.avTimer setFireDate:[NSDate distantFuture]];
    }
}

//手指离开滑块时执行
- (void)endSlider{
//    if (playBtn.selected == YES) {
        //设置歌曲的播放时间
        self.audioPlayer.currentTime = self.slider.value * self.audioPlayer.duration;
        [self.audioPlayer play];
        [self.avTimer setFireDate:[NSDate distantPast]];
//    }
//    else{
//        //设置歌曲的播放时间
//        self.audioPlayer.currentTime = self.slider.value * self.audioPlayer.duration;
//    }
}

- (void)videoSynthesisWithPathArray:(NSMutableArray *)pathArray resultPath:(NSString *)resultPath{
    //合并音频数据
    NSMutableData *totalSoundData = [[NSMutableData alloc] init];
    for (NSString *path in pathArray) {
        NSData *soundData = [[NSData alloc] initWithContentsOfFile:path];
        [totalSoundData appendData:soundData];
    }
    //保存音频
    [totalSoundData writeToFile:resultPath atomically:YES];
}


//tableview cell点击方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (self.commentArr.count && indexPath.section == 1) {
        if (self.picRepeatType == 0) {
            MineCommentModel *model = self.commentArr[indexPath.row];
            PicCommentViewController *picCommentVC = [[PicCommentViewController alloc] init];
            picCommentVC.picCommentType = PicCommentRepeat;
            picCommentVC.readID = self.readId;
            picCommentVC.quote = model.commentId;
            [self.navigationController pushViewController:picCommentVC animated:YES];
            
        }else{
            MineCommentModel *model = self.commentArr[indexPath.row];
            PicCommentViewController *picCommentVC = [[PicCommentViewController alloc] init];
            picCommentVC.picCommentType = MineCoCommentAppreciation;
            picCommentVC.readID = self.readId;
            picCommentVC.quote = model.commentId;
            [self.navigationController pushViewController:picCommentVC animated:YES];
        }
      }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(UIImage *)OriginImage:(UIImage *)image scaleToSize:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage *scaleImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaleImage;
}

-(void)updateTimer{
    
}

#pragma mark - LGAudioPlayerDelegate
- (void)audioPlayerStateDidChanged:(LGAudioPlayerState)audioPlayerState forIndex:(NSUInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:1];
    PicWithComTableViewCell *cell = (PicWithComTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    switch (audioPlayerState) {
        case LGAudioPlayerStateNormal:
            cell.playBtn.selected = NO;
            break;
        case LGAudioPlayerStatePlaying:
            cell.playBtn.selected = YES;
            break;
        case LGAudioPlayerStateCancel:
            cell.playBtn.selected = NO;
            break;
        default:
            cell.playBtn.selected = NO;
            break;
    }
}

//点赞
- (void)likeBtnClick:(UIButton *)button{
    //得到基本固定参数字典，加入调用接口所需参数
  
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:self.likeUrl forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:@(self.likeId) forKey:@"id"];
    
    [[HttpManager sharedManager] POST:self.likeUrl parame:parame sucess:^(id success) {
        
        if ([success[@"event"] isEqualToString:@"SUCCESS"]) {
             button.selected = !button.selected;
            if ([success[@"data"][@"status"] integerValue] == 0) {
                self.like = 0;
                self.likeStr = [NSString stringWithFormat:@"%ld", (long)[self.likeStr integerValue] - 1];
            }else{
                self.like = 1;
                self.likeStr = [NSString stringWithFormat:@"%ld", (long)[self.likeStr integerValue] + 1];
            }
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [Global showWithView:self.view withText:@"网络错误"];
    }];
}

//鼓励
- (void)encourageClick:(UIButton *)button{
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    //添加子视图
    alertView.backgroundColor = [UIColor whiteColor];
    [alertView setSubView:[self addSubView]];
    //添加按钮标题数组
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"确定", @"取消", nil]];
    //添加按钮点击方法
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        //关闭
        if (buttonIndex == 0) {
            //得到基本固定参数字典，加入调用接口所需参数
            NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
            [parame setObject:self.rewardUrl forKey:@"uri"];
            //得到加盐MD5加密后的sign，并添加到参数字典
            [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
            [parame setObject:@(self.readId) forKey:@"id"];
            [parame setObject:@([_numField.text  doubleValue]) forKey:@"fee"];
            
            MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD.backgroundColor = [UIColor clearColor];
            
            [[HttpManager sharedManager] POST:self.rewardUrl parame:parame sucess:^(id success) {
                [HUD hide:YES];
                if ([success[@"event"] isEqualToString:@"SUCCESS"]){
                    [Global showWithView:self.view withText:@"打赏成功"];
                    
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

        [alertView close];
    }];
    //显示
    [alertView show];
}

//自定义的子视图
- (UIView *)addSubView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 230, 90)];
    UILabel *view1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 230, 50)];
    view1.font = [UIFont systemFontOfSize:15 weight:2];
    view1.textColor = [UIColor blackColor];
//    view1.text = @"请输入打赏水滴数";
    view1.text = @"请输入打赏金额数";
    view1.textAlignment = NSTextAlignmentCenter;
    
    [view addSubview:view1];
    
    _numField = [[UITextField alloc] init];
    _numField.backgroundColor = [UIColor whiteColor];
    
    _numField.textColor = [UIColor blackColor];
    _numField.font = [UIFont systemFontOfSize:15];
    _numField.delegate = self;
    //光标颜色
    [_numField addTarget:self action:@selector(textFieldChangeMethod:) forControlEvents:UIControlEventEditingChanged];
    _numField.tintColor = [UIColor blackColor];
    _numField.keyboardType = UIKeyboardTypeDecimalPad;
    _numField.returnKeyType = UIReturnKeyDone;
    [view addSubview:_numField];
    _numField.frame = FRAMEMAKE_F(15 , CGRectGetMaxY(view1.frame), 230 - 30, 30);
    
    NSMutableParagraphStyle *style = [_numField.defaultTextAttributes[NSParagraphStyleAttributeName] mutableCopy];
    
    style.minimumLineHeight = _numField.font.lineHeight - (_numField.font.lineHeight - [UIFont systemFontOfSize:15.0].lineHeight) / 2.0;
    
    _numField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入整数数字"
                                                                      attributes:@{
                                                                                   NSForegroundColorAttributeName: RGBHex(0x999999),
                                                                                   NSFontAttributeName : [UIFont systemFontOfSize:15.0],
                                                                                   NSParagraphStyleAttributeName : style
                                                                                   }
                                       ];
    view.backgroundColor = [UIColor whiteColor];
    
    return view;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableString * futureString = [NSMutableString stringWithString:textField.text];
    [futureString  insertString:string atIndex:range.location];
    NSInteger flag=0;
    const NSInteger limited = 2;//小数点后需要限制的个数
    for (int i = futureString.length-1; i>=0; i--) {
        
        if ([futureString characterAtIndex:i] == '.') {
            if (flag > limited) {
                return NO;
            }
            break;
        }
        flag++;
    }
    return YES;
}

#pragma mark - UITextFiled代理方法
-(void)textFieldChangeMethod:(UITextField *)textField{
    if (textField == _numField) {
        
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField endEditing:YES];
    [_numField resignFirstResponder];
    return YES;
}

@end
