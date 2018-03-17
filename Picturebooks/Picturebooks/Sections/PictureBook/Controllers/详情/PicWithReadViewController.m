//
//  PicWithReadViewController.m
//  PictureBook
//
//  Created by Yasin on 2017/7/13.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "PicWithReadViewController.h"
#import "SRActionSheet.h"
#import "PicEnjoyViewCell.h"
#import "PicCommentViewCell.h"
#import "CustomIOSAlertView.h"
#import "PicCommentViewController.h"
#import "PicEnjoyModel.h"
#import "MineCommentModel.h"
#import "PicWithComTableViewCell.h"
#import "PicFreeWithViewController.h"
#import "WXApi.h"
#import "MineMoneysViewController.h"
#import "HMAudioComposition.h"

@interface PicWithReadViewController ()<UITableViewDelegate, UITableViewDataSource, SDCycleScrollViewDelegate,SRActionSheetDelegate, UITextFieldDelegate, LGAudioPlayerDelegate, AVAudioPlayerDelegate, UIWebViewDelegate>

@property (nonatomic, strong)UIView *bottomView;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)UISlider *slider;

@property (nonatomic, strong)UILabel *beginLab;
@property (nonatomic, strong)UILabel *endLab;

@property (nonatomic, strong)NSTimer *avTimer;
@property (nonatomic, strong)NSString  *detailStr;
@property (nonatomic, strong)NSMutableArray  *audioArr;

@property (nonatomic, strong)NSMutableArray  *iconArr;
@property (nonatomic, assign)NSInteger pageNum;//页数
@property (nonatomic, assign)BOOL isMorePage;
@property (nonatomic, strong)NSMutableArray *dataSource;
@property (nonatomic, strong)NSString *token;
//@property (nonatomic, strong)UIPageControl *pageControl;
@property (nonatomic, strong)AVAudioPlayer *audioPlayer;
@property (nonatomic, assign)NSInteger encourageId;
@property (nonatomic, strong)MBProgressHUD *progressHUD;
@property (nonatomic, strong)NSString  *beginStr;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, copy) NSArray *pathArray;


@property (nonatomic,strong) UIView *stayTopView;
@property (nonatomic,assign) CGRect tempFrame;

/** 课程详情标题 */
@property (nonatomic,strong)  UIView *courseTitleView;

// 添加一个upView
@property (nonatomic, strong)UIView *upView;
/** 上一段音频按钮 */
@property (nonatomic,strong) UIButton *preBtn;
/** 下一段音频按钮 */
@property (nonatomic,strong) UIButton *nextBtn;

/** 音频可变数组 */
@property (nonatomic,strong) NSMutableArray *audioArrayM;

@end

@implementation PicWithReadViewController
{
    UITextField *_numField;
    UIButton *likeBtn;
    UIButton *playBtn;
    NSUInteger currentTrackNumber;
//    UIImageView *cycleScrollView;
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
        nameLab.text = @"绘本正文";
        nameLab.textColor = [UIColor blackColor];
        nameLab.font = [UIFont systemFontOfSize:16 weight:1];
        NSDictionary *conDic = StringFont_DicK(nameLab.font);
        CGSize conSize = [nameLab.text sizeWithAttributes:conDic];
        nameLab.frame = FRAMEMAKE_F(CGRectGetMaxX(greeLab.frame) + 13, CGRectGetMinY(greeLab.frame), conSize.width, conSize.height);
        [_courseTitleView addSubview:nameLab];
    }
    return _courseTitleView;
}

//懒加载UITableView
- (UITableView *)tableView{
    if (!_tableView) {
        if (_isFromPublish) {
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, SCREEN_HEIGHT - PBNew64 - 44) style:UITableViewStyleGrouped];
            
        }else{
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, SCREEN_HEIGHT - PBNew64 - 44) style:UITableViewStyleGrouped];
        }
        [self.view addSubview:_tableView];
        
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
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
//        self.preBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, btnY, btnW, btnH)];
//        [_upView addSubview:self.preBtn];
//        // 设置相关属性
//        [self.preBtn setImage:[UIImage imageNamed:@"pic_prePart"] forState:UIControlStateNormal];
//        [self.preBtn addTarget:self action:@selector(preBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//        // 默认不可点击
//        self.preBtn.enabled = NO;
        
        // 播放音频按钮
        playBtn = [[UIButton alloc] initWithFrame:CGRectMake(space, btnY, btnW, btnH)];
        [_upView addSubview:playBtn];
        // 设置相关属性 r_pause  r_play
        [playBtn setImage:[UIImage imageNamed:@"r_pause"] forState:UIControlStateNormal];
        [playBtn setImage:[UIImage imageNamed:@"r_play"] forState:UIControlStateSelected];
        [playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        // 下一段音频按钮
//        self.nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(playBtn.frame), btnY, btnW, btnH)];
//        [_upView addSubview:self.nextBtn];
//        // 设置相关属性
//        [self.nextBtn setImage:[UIImage imageNamed:@"pic_nextPart"] forState:UIControlStateNormal];
//        [self.nextBtn addTarget:self action:@selector(nextBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        // 开始时间的 Label
        self.beginLab = [UILabel new];
        [_upView addSubview:self.beginLab];
        LabelSet(self.beginLab, [self stringWithTime:self.audioPlayer.currentTime], [UIColor whiteColor], 10, beginDic, beginSize);
        self.beginLab.frame = CGRectMake(CGRectGetMaxX(playBtn.frame), (40 - beginSize.height) * 0.5, beginSize.width + 3, beginSize.height);
        
        // 收藏心形按钮 UIbutton
        likeBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - btnW, btnY, btnW, btnH)];
        [_upView addSubview:likeBtn];
        // 设置相关属性
//        [likeBtn setImage:[UIImage imageNamed:@"r_unlike"] forState:UIControlStateNormal];
//        [likeBtn setImage:[UIImage imageNamed:@"r_like"] forState:UIControlStateSelected];
        [likeBtn addTarget:self action:@selector(likeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        // 结束时间的 Label
        self.endLab = [UILabel new];
        [_upView addSubview:self.endLab];
        LabelSet(self.endLab, [self stringWithTime:self.audioPlayer.duration], [UIColor whiteColor], 10, endDic, endSize);
        self.endLab.frame = CGRectMake(CGRectGetMinX(likeBtn.frame) - endSize.width, (40 - endSize.height) * 0.5, endSize.width + 3, endSize.height);
        
        // 进度条 UISlider
        CGFloat sliderW = CGRectGetMinX(self.endLab.frame) - CGRectGetMaxX(self.beginLab.frame) - space * 2;
        self.slider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.beginLab.frame) + space, (40 - 20) * 0.5, sliderW , 20)];
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


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    if (self.audioPlayer) {
        if ([self.audioPlayer isPlaying]) {
            [self.audioPlayer pause];
            [self.avTimer setFireDate:[NSDate distantFuture]];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
//    self.navigationItem.title = self.name;
    self.navigationItem.titleView = [UINavigationItem titleViiewWithTitle:self.name];
        
    self.automaticallyAdjustsScrollViewInsets = NO;
    ///self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightBarButtonItemWithImage:[UIImage imageNamed:@"pic_share"] highlighted:[UIImage imageNamed:@"pic_share"] target:self selector:@selector(share)];
    [LGAudioPlayer sharePlayer].delegate = self;

    [self upView];
    
//    [self.view addSubview:self.tableView];
    // 添加 tableView
    [self tableView];
    
    

    likeBtn = [UIButton new];
//    self.slider = [[UISlider alloc] init];
//    playBtn = [UIButton new];
    
    self.audioArr = [NSMutableArray arrayWithCapacity:0];
    self.iconArr = [NSMutableArray arrayWithCapacity:0];

    self.audioArrayM = [NSMutableArray array];
    
    [self loadData];
    
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    _webView.delegate = self;
    _webView.scrollView.scrollEnabled = NO;
    //[_webView loadHTMLString:_pictext baseURL:[NSURL fileURLWithPath: [[NSBundle mainBundle]  bundlePath]]];
     //[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/book/richtext/%ld", URL_api, self.picId]]]];
    
//    NSString *path = [[NSBundle mainBundle] bundlePath];
//    NSURL *baseURL = [NSURL fileURLWithPath:path];
//    NSString * htmlPath = [[NSBundle mainBundle] pathForResource:@"test"
//                                                          ofType:@"html"];
//    NSString * htmlCont = [NSString stringWithContentsOfFile:htmlPath
//                                                    encoding:NSUTF8StringEncoding
//                                                       error:nil];
//    [self.webView loadHTMLString:htmlCont baseURL:baseURL];

    if (!_isFromPublish) {
        [self commentData];
        
        self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            _pageNum=0;
            [self commentData];
            [self.tableView.mj_header endRefreshing];
        }];
        
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            if (_isMorePage) {
                _pageNum++;
                [self commentData];
            }
            [self.tableView.mj_footer endRefreshing];
        }];

        [self.view addSubview:self.bottomView];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentNotice) name:@"dataload" object:nil];
    
//    NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"339744.mp3" withExtension:nil];
//    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
//    self.audioPlayer.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickShare:) name:@"wechatShare" object:nil];
    
    //[self weChat];
}


- (void)weChat{
    AFHTTPSessionManager *manage = [AFHTTPSessionManager manager];
   
    //设置登录参数
//    _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html",@"text/plain", nil];
    manage.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html",@"text/plain", nil];
    manage.responseSerializer = [AFHTTPResponseSerializer serializer];
    //设置登录参数
    NSString *url = [NSString stringWithFormat:@"%@/book/richtext/%ld", URL_api, self.picId];
   // NSString *stringUrl = [NSString stringWithFormat:@"%@pay/%@/wxpay2",httpUrl_K,_orderId];

    // NSLog(@"创建订单---------->%@balance/add_order?orderId=%@&payChannel=%@",httpUrl_K);
    //3.请求

   
    [manage GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
       
    
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString *responseString = [str stringByReplacingOccurrencesOfString:@"  "  withString:@""];
        responseString = [responseString stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        responseString = [responseString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        responseString = [responseString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
         //[_webView loadHTMLString:responseString baseURL:[NSURL fileURLWithPath: [[NSBundle mainBundle]  bundlePath]]];
        NSLog(@"-----shuju%@", responseString);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"-----cuowu%@", error);
        
    }];
}

#pragma mark - 服务器-- User_book_repeatShare
- (void)requestUserBookRepeatShareData
{
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:User_book_repeatShare forKey:@"uri"];
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    //提交跟读信息接口参数
    // 绘本跟读编号 id 
    
    [[HttpManager sharedManager] POST:User_book_repeatShare parame:parame sucess:^(id success) {
        
    } failure:^(NSError *error) {
        
    }];
    
}

#pragma mark - 分享回调
//分享回调
- (void)clickShare:(NSNotification *)notification{

    switch ([notification.object integerValue]) {
        case 0:
            [Global showWithView:self.view withText:@"分享成功"];
            
            // 服务器
            
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

//加载主数据
- (void)loadData{
    //得到基本固定参数字典，加入调用接口所需参数
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:PICTUREBOOK_ENJOY forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:@(self.picId) forKey:@"id"];
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.labelText = @"加载中...";
    HUD.backgroundColor = [UIColor clearColor];
    
    [[HttpManager sharedManager] POST:PICTUREBOOK_ENJOY parame:parame sucess:^(id success) {
        
        NSLog(@"success:%@",success);
        NSDictionary *dict = success[@"data"];
//        [dict writeToFile:@"/Users/jixiaodong/Desktop/plist/audio.plist" atomically:YES];
        
        if ([success[@"event"] isEqualToString:@"SUCCESS"]) {
            [HUD hide:YES];
            PicEnjoyModel *model = [PicEnjoyModel modelWithDictionary:success[@"data"][@"book"]];
            self.detailStr = model.outline;
            if (_isFromCalendar) {
                self.rewardId = model.rewardStr;
            }
            
           self.audioArr = success[@"data"][@"book"][@"bookSegmentList"];
            
            // Jxd-start--------------
#pragma mark - Jxd-修改
            NSDictionary *dict = [NSDictionary dictionaryWithObject:success[@"data"][@"book"][@"audio"] forKey:@"audio"];
            [self.audioArrayM addObject:dict];
            NSLog(@"audioArrayM:%@",self.audioArrayM);
            // Jxd-end--------------
            
            if (![self.audioArr isEqual:[NSNull null]]) {
                for (NSDictionary *dic in self.audioArr) {
                    NSString * iconUrl = [NSString stringWithFormat:@"%@%@", Qiniu_host, dic[@"icon"]];
                    [self.iconArr addObject:iconUrl];
                }
            }
        }
        
        NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:0];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
        
//        NSString *wholePath = [DocumentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"UploadFile/%ldwhole.m4a", (long)self.picId]];
//        if ([[NSFileManager defaultManager] fileExistsAtPath:wholePath]) {
//              [self videoPlay:wholePath];
//        }else{
//            //下载音频
//            [self downloadVideo:self.audioArr];
//        }
        

        // Jxd-start--------------
#pragma mark - Jxd-修改
//         [self downloadVideo:self.audioArr]; // 之前
        
        [self downloadVideo:self.audioArrayM]; // 修改
        // Jxd-end--------------


    } failure:^(NSError *error) {
        [HUD hide:YES ];
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
    self.progressHUD .labelText = @"音频加载中...";
    self.progressHUD .backgroundColor = [UIColor clearColor];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSDictionary *dic in audioArr) {
            [[HttpManager sharedManager] downLoad:[NSString stringWithFormat:@"%@", dic[@"audio"]] success:^(id success) {
                //[HUD hide:YES];
                
                NSLog(@"success:%@",success);
                
                NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([dic[@"id"] integerValue]), @"Id", [NSString stringWithFormat:@"%@", success], @"soundPath", nil];
                [newMessageArray addObject:tmpDic];
                
                if (newMessageArray.count == audioArr.count) {
                    [self audioSynthesis:newMessageArray];
                }
                
            } failure:^(NSError *error) {
                //[HUD hide:YES];
                [Global showWithView:self.view withText:@"网络错误"];
            }];
            
        }
        
    });
    

}

//音频合成
- (void)audioSynthesis:(NSMutableArray *)newMessageArray{
     //[self.progressHUD  hide:YES];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/book/richtext/%ld", URL_api, self.picId]]]];
    [LameTools clearUploadFile];
    
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
    
      //    //保存音频
    //NSString *wholePath = [DocumentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"UploadFile/%ldwhole.m4a", (long)self.picId]];
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
//         [HUD hide:YES];
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


//得到音频数据
- (void)getAudioSource{
    
}

- (void)commentNotice{
     [self.dataSource removeAllObjects];
    _pageNum = 0;
    [self commentData];
}

//加载评论数据
- (void)commentData{

    //得到基本固定参数字典，加入调用接口所需参数
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];//kOffset
    [parame setObject:PICTUREBOOK_COMMENT forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:@(self.picId) forKey:@"id"];
    [parame setObject:@(_pageNum * kOffset) forKey:@"offset"];
    [parame setObject:@(kOffset) forKey:@"limit"];
    
    [[HttpManager sharedManager] POST:PICTUREBOOK_COMMENT parame:parame sucess:^(id success) {
//        NSLog(@"------评论数据%@", success);
        if (_pageNum == 0) {
            [self.dataSource removeAllObjects];
        }

        if ([success[@"event"] isEqualToString:@"SUCCESS"]) {
            NSMutableArray *boyarray= success[@"data"][@"comment"];
            if (![boyarray isEqual:[NSNull null]]) {
                for (NSDictionary *dic in boyarray) {
                    MineCommentModel *model = [MineCommentModel modelWithDictionary:dic];
                    [self.dataSource addObject:model];
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

            // 局部刷新:只刷新第二组的数组,这种刷新方式是有问题的,出现刷新卡顿的情况
//            NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:1];
//            [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [self.tableView reloadData];
            
        }
        //[self.tableView reloadData];
    } failure:^(NSError *error) {
        [Global showWithView:self.view withText:@"网络错误"];
    }];
}

//分享
- (void)share{
    SRActionSheet *actionSheet = [SRActionSheet sr_actionSheetViewWithTitle:nil
                                                                cancelTitle:@"取消"
                                                           destructiveTitle:nil
                                                                otherTitles:@[@"分享给微信好友", @"分享到朋友圈(+1滴水)"]
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
    NSString *nickName = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickname"];
    
//    if ([Global isNullOrEmpty:nickName]) {
//        nickName = @"我";
//    }
    nickName = @"我";
    
    //微信好友
    if (index == 0) {
        if ([WXApi isWXAppInstalled]) {
            WXMediaMessage *message = [WXMediaMessage message];

            message.title = @"HS英文绘本课堂";
            message.description = message.description = [NSString stringWithFormat:@"%@在HS英文绘本课堂朗读了%@绘本，快来听听吧!",nickName,self.name];
            
            [message setThumbImage:[UIImage imageNamed:@"m_wechat"]];
            WXWebpageObject *webpage = [WXWebpageObject object];
            webpage.webpageUrl = @"https://open.weixin.qq.com";
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

            message.title = [NSString stringWithFormat:@"%@在HS英文绘本课堂朗读了%@绘本，快来听听吧!",nickName,self.name];
//            message.description = @"";
            
            //png图片压缩成data的方法，如果是jpg就要用 UIImageJPEGRepresentation
            //message.thumbData = UIImagePNGRepresentation(image);
            [message setThumbImage:[UIImage imageNamed:@"m_wechat"]];
            WXWebpageObject *webpage = [WXWebpageObject object];
            webpage.webpageUrl = @"https://open.weixin.qq.com";
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


-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSource;
}



#pragma mark -UITableView代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    if (self.dataSource.count) {
        return self.dataSource.count;
    }else{
        return 1;
        
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_isFromPublish) {
        return 1;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return [self detailCellEithTableView:tableView cellForRowAtIndexPath:indexPath];
    }else{
        return [self commentCellEithTableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (UITableViewCell *)detailCellEithTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellId =[NSString stringWithFormat:@"cellTwo%ld%ld",(long)[indexPath section],(long)[indexPath row]];
//    PicEnjoyViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
//    if (!cell) {
//        cell = [[PicEnjoyViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
//    }
//
//    [cell setName:@"" detail:[NSString stringWithFormat:@"%@/book/richtext/%ld", URL_api, self.picId]];

   
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    [cell.contentView addSubview:_webView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}


- (UITableViewCell *)commentCellEithTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.dataSource.count) {
        
        NSString *cellId =[NSString stringWithFormat:@"cellTwo%ld%ld",(long)[indexPath section],(long)[indexPath row]];
        
        PicWithComTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        if (!cell) {
            cell = [[PicWithComTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        
        MineCommentModel *model = self.dataSource[indexPath.row];
        NSString *time =  [AppTools secondsToMinutesAndSeconds:[NSString stringWithFormat:@"%ld", model.contentModel.time / 1000]];
    
        [cell.photoImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", Qiniu_host, model.userModel.head]] placeholderImage:[UIImage imageNamed:@"defaultPhoto"]];
        [cell.playBtn addTarget:self action:@selector(clickPlay:) forControlEvents:UIControlEventTouchUpInside];
        cell.playBtn.tag = 500 + indexPath.row;

        [cell setName:model.userModel.nickname detail:model.contentModel.text time:model.time  videoTime:time videoText:model.contentModel.source  arr:model.replyArr judge:NO];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }else{
        
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
    
}
#pragma mark - UIWebView Delegate Methods
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.progressHUD  hide:YES];
    
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

//播放音频
- (void)clickPlay:(UIButton *)button{
    [LGAudioPlayer sharePlayer].delegate = self;
    button.selected = !button.selected;
    MineCommentModel *model = self.dataSource[button.tag- 500];
    if ([HttpManager isSavedFileToLocalWithFileName:[NSString stringWithFormat:@"%@.mp3", model.contentModel.source]]) {
        [[LGAudioPlayer sharePlayer] playAudioWithURLString:[SoundFilesCaches stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", model.contentModel.source]] atIndex:button.tag - 500];
    }else if ([HttpManager isSavedFileToLocalWithFileName:[NSString stringWithFormat:@"%@.amr", model.contentModel.source]]){
        [[LGAudioPlayer sharePlayer] playAudioWithURLString:[SoundFilesCaches stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.amr", model.contentModel.source]] atIndex:button.tag - 500];
    }else{
//        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        HUD.removeFromSuperViewOnHide = YES;
//        HUD.labelText = @"缓存中...";
//        HUD.backgroundColor = [UIColor clearColor];
        
        [[HttpManager sharedManager] downLoad:model.contentModel.source success:^(id success) {
            //[HUD hide:YES];
            [[LGAudioPlayer sharePlayer] playAudioWithURLString:[NSString stringWithFormat:@"%@", success] atIndex:button.tag - 500];
        } failure:^(NSError *error) {
            [Global showWithView:self.view withText:@"网络错误"];
        }];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak PicWithReadViewController *preferSelf = self;
    if (indexPath.section == 0) {
//        PicEnjoyViewCell *sortCell = (PicEnjoyViewCell *)[preferSelf tableView:_tableView cellForRowAtIndexPath:indexPath];
//        return sortCell.frame.size.height;
         return _webView.frame.size.height;
    }else{
        if (self.dataSource.count) {
            PicWithComTableViewCell *sortCell = (PicWithComTableViewCell *)[preferSelf tableView:_tableView cellForRowAtIndexPath:indexPath];
            return sortCell.frame.size.height;
            
        }else{
            return 230;
            
        }
    }
}

//设置区头高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
//        if ([self.rewardId isEqualToString:@"-1"]) {
//            return 192;
//        }else{
//            return 192 + 100;
//            
//        }
        // 修改前
//         return SCREEN_WIDTH * 5 / 9;
#pragma mark - jxd修改--区头的高度
        return 40;
    }else{
        return 65;
    }
}

//设置区尾高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        if ([self.rewardId isEqualToString:@"-1"]) {
            return 0.001;
        }else{
            return  100;
        }
    }else{
        return 0.001;
    }
}

/** 添加导航底部悬浮视图 */
- (UIView *)stayTopView {
    if (!_stayTopView) {
        _stayTopView = [UIView new];
        _stayTopView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
        [self.view addSubview:_stayTopView];
    }
    return _stayTopView;
}


//区头
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    __strong UIView *view = [UIView new];
    if (section == 0) {
        view.backgroundColor = [UIColor whiteColor];
        
#pragma mark - jxd修改--添加->绘本正文标题
        self.courseTitleView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 20);
        [view addSubview:self.courseTitleView];
        
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
    if (section == 0) {
        view.backgroundColor = [UIColor whiteColor];
        if (![self.rewardId isEqualToString:@"-1"]) {
            UIButton *freeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            freeBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:2];
            [freeBtn setTitle:@"打赏" forState:UIControlStateNormal];
            [freeBtn addTarget:self action:@selector(encourageClick:) forControlEvents:UIControlEventTouchUpInside];
            freeBtn.backgroundColor = [Global convertHexToRGB:@"14d02f"];
            [view addSubview:freeBtn];
            freeBtn.frame = FRAMEMAKE_F((SCREEN_WIDTH - 83) / 2, 30, 83, 38);
            freeBtn.layer.cornerRadius = 5;
            freeBtn.clipsToBounds = YES;
            [view addSubview:freeBtn];
            
            UILabel *encourLab = [UILabel new];
            LabelSet(encourLab, @"宝贝，轻轻一点即可打赏鼓励小伙伴哦!", [Global convertHexToRGB:@"999999"], 13, enDic, enSize);
            encourLab.frame = FRAMEMAKE_F((SCREEN_WIDTH - enSize.width) / 2, CGRectGetMaxY(freeBtn.frame) + 15, enSize.width, enSize.height);
            [view addSubview:encourLab];
            
        }else{
           
            UIView *white = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
            white.backgroundColor = [UIColor whiteColor];
            [view addSubview:white];
            view.backgroundColor = RGBHex(0xf0f0f0);
           
        }

    }
    return view;
}

/** 图片滚动回调 */
//- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index{
//    self.pageControl.currentPage = index;
//    NSLog(@"----距离1%f---%ld", cycleScrollView.frame.origin.x, (long)index);
//}

/** 点击图片回调 */
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
   
}

//播放按钮触发方法
- (void)playBtnClick:(UIButton *)button{
    playBtn.selected = !playBtn.selected;
    if (!_avTimer) {
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
        //[self videoPlay:self.pathArray[currentTrackNumber]];
        //设置定时器
        _avTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(avTimerAction) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_avTimer forMode:NSRunLoopCommonModes];
    }else{
        if ([_audioPlayer isPlaying]) {
            [_audioPlayer pause];
            [_avTimer setFireDate:[NSDate distantFuture]];
        }else{
            //[self videoPlay:self.pathArray[currentTrackNumber]];
            [_audioPlayer play];
            [_avTimer setFireDate:[NSDate distantPast]];
        }
    }
}


// Jxd-start ------------------------------------------------
#pragma mark - Jxd- 添加:播放上一段音频
/** 播放上一段音频 */
- (void)preBtnClick:(UIButton *)sender
{
    currentTrackNumber--;
    self.nextBtn.enabled = YES;
    if (currentTrackNumber == 0) {
        sender.enabled = NO;
    }
    // 播放音频
    [self playAudioVideo];
    
}
// Jxd-end ------------------------------------------------

// Jxd-start ------------------------------------------------
#pragma mark - Jxd-添加:播放下一段音频
/** 播放下一段音频 */
- (void)nextBtnClick:(UIButton *)sender
{
    currentTrackNumber++;
    self.preBtn.enabled = YES;
    if (currentTrackNumber == [self.pathArray count] - 1) {
        self.nextBtn.enabled = NO;
    }
    // 播放音频
    [self playAudioVideo];
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
//            if (currentTrackNumber != 0) {
//                self.preBtn.enabled = YES;
//            }
//            if (currentTrackNumber == [self.pathArray count] - 1) {
//                self.nextBtn.enabled = NO;
//            }
            // Jxd-end ------------------------------------------------
            
            if (_audioPlayer) {
                [_audioPlayer stop];
                _audioPlayer = nil;
                [self.avTimer setFireDate:[NSDate distantFuture]];
                self.slider.value = 0;
                self.beginLab.text = @"00:00";
            }
            
//             [cycleScrollView sd_setImageWithURL:[NSURL URLWithString:self.iconArr[currentTrackNumber]]];
//            self.pageControl.currentPage = currentTrackNumber;
            
            [self videoPlay:self.pathArray[currentTrackNumber]];
            [_audioPlayer play];
            _avTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(avTimerAction) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:_avTimer forMode:NSRunLoopCommonModes];
           // [self.tableView reloadData];
        }else{
            
            // Jxd-start ------------------------------------------------
#pragma mark - Jxd-添加判断:音频播放结算后上一段与下一段音频按钮不可以点击
//            self.preBtn.enabled = NO;
//            self.nextBtn.enabled = YES;
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
    NSInteger min = time / 60;
    NSInteger second = (NSInteger)time % 60;
    
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)min, (long)second];
}

//定时器调用方法
- (void)avTimerAction{
    //1.更新当前播放时间
   
    self.beginLab.text = [self stringWithTime:self.audioPlayer.currentTime];
    self.beginStr = self.beginLab.text;
    //2.更新滑块的位置
    self.slider.value = self.audioPlayer.currentTime / self.audioPlayer.duration;
}

#pragma mark - slider监听事件
//值改变时执行
-(void)processChanged{
    //1.设置当前播放时间的label
    self.beginLab.text = [self stringWithTime:(self.audioPlayer.duration * self.slider.value)];
    self.beginStr = self.beginLab.text;
}

//开始触碰滑块时执行
- (void)startSlider{
    if (playBtn.selected == YES) {
        [self.audioPlayer pause];
        [self.avTimer setFireDate:[NSDate distantFuture]];//关闭定时器
    }
}

//手指离开滑块时执行
- (void)endSlider{
    if (playBtn.selected == YES) {
        //设置歌曲的播放时间
        self.audioPlayer.currentTime = self.slider.value * self.audioPlayer.duration;
        [self.audioPlayer play];
        [self.avTimer setFireDate:[NSDate distantPast]];//开启定时器
    }
    else{
        //设置歌曲的播放时间
        self.audioPlayer.currentTime = self.slider.value * self.audioPlayer.duration;
    }
}

//杀死定时器
- (void)removeProgressTimer{
    [self.avTimer invalidate];
    self.avTimer = nil;
}


//tableview cell点击方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (self.dataSource.count && indexPath.section == 1) {
        MineCommentModel *model = self.dataSource[indexPath.row];
        PicCommentViewController *picCommentVC = [[PicCommentViewController alloc] init];
        picCommentVC.picCommentType = PicCommentAppreciation;
        picCommentVC.readID = self.picId;
        picCommentVC.quote = model.commentId;
        [self.navigationController pushViewController:picCommentVC animated:YES];
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

#pragma mark - LGAudioPlayerDelegate
 -(void)audioPlayerStateDidChanged:(LGAudioPlayerState)audioPlayerState forIndex:(NSUInteger)index{
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
    button.selected = !button.selected;
    
    
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
            
            
            // Jxd-start-----------------
#pragma mark - Jxd-添加判断, 判断不能输入小数,0
            if ([_numField.text containsString:@"."] || [_numField.text isEqualToString:@"0"] || [Global isNullOrEmpty:_numField.text] || [_numField.text hasPrefix:@"0"]) {
                [Global showWithView:self.view withText:@"请输入整数金额"];
                _numField.text = @"";
                return;
            }
            // Jxd-end-------------------
            
            
            //得到基本固定参数字典，加入调用接口所需参数
            NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
            [parame setObject:self.rewardUrl forKey:@"uri"];
            //得到加盐MD5加密后的sign，并添加到参数字典
            [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
            [parame setObject:@(_picId) forKey:@"id"];
            [parame setObject:@([_numField.text  doubleValue]) forKey:@"fee"];
            
            
            MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD.backgroundColor = [UIColor clearColor];
            
            [[HttpManager sharedManager] POST:self.rewardUrl parame:parame sucess:^(id success) {
                [HUD hide:YES];
                if ([success[@"event"] isEqualToString:@"SUCCESS"]){
                    [Global showWithView:self.view withText:@"打赏成功"];
                  
                }else if ([success[@"event"] isEqualToString:@"INSUFFICIENT_BALANCE"]){
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您的H币不足，是否需要充值？" preferredStyle:UIAlertControllerStyleAlert];
                    
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

//自定义的子视图
- (UIView *)addSubView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 230, 90)];
    
    UILabel *view1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 230, 50)];
    [view addSubview:view1];
    view1.font = [UIFont systemFontOfSize:15 weight:2];
    view1.textColor = [UIColor blackColor];
    view1.text = @"请输入打赏金额";
    view1.textAlignment = NSTextAlignmentCenter;
    
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

#pragma mark - 评论区视图
- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - PBNew64 - 44, SCREEN_WIDTH, 44)];
        _bottomView.backgroundColor = [UIColor whiteColor];
        
        UIButton *freeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        freeBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:2];
        [freeBtn setTitle:@"评论" forState:UIControlStateNormal];
        [freeBtn addTarget:self action:@selector(commentClick:) forControlEvents:UIControlEventTouchUpInside];
        freeBtn.backgroundColor = [Global convertHexToRGB:@"14d02f"];
        [_bottomView addSubview:freeBtn];
        [freeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_bottomView.mas_top);
            make.right.mas_equalTo(_bottomView.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH / 2, 44));
        }];
        
        UIButton *enjoyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        enjoyBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:2];
        [enjoyBtn setTitle:@"我也要跟读" forState:UIControlStateNormal];
        [enjoyBtn addTarget:self action:@selector(withReadClick:) forControlEvents:UIControlEventTouchUpInside];
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

//评论按钮触发方法
- (void)commentClick:(UIButton *)button{
    PicCommentViewController *commentVC = [[PicCommentViewController alloc] init];
    commentVC.picCommentType = PicCommentAppreciation;
    commentVC.readID = self.picId;
    commentVC.quote = -1;
    [self.navigationController pushViewController:commentVC animated:YES];
}

//跟读按钮触发方法
- (void)withReadClick:(UIButton *)button{
    NSMutableDictionary *parame_ = [HttpManager necessaryParameterDictionary];
    [parame_ setObject:Repeat_token forKey:@"uri"];
    [parame_ setObject:[HttpManager getAddSaltMD5Sign:parame_] forKey:@"sign"];
    [parame_ setObject:@(self.belong) forKey:@"id"];
    
    // Jxd-start-----------------------------
#pragma mark - Jxd-添加 显示数据加载提示框
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // Jxd-end-----------------------------
    
    [[HttpManager sharedManager] POST:Repeat_token parame:parame_ sucess:^(id success) {
        if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
            self.token = [[success objectForKey:@"data"] objectForKey:@"token"];
            
            PicFreeWithViewController *freeVC = [[PicFreeWithViewController alloc] init];
            freeVC.name = self.name;
            freeVC.token = self.token;
            freeVC.unlockState = self.belong;
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
//        NSLog(@"error = %@", error);
    }];
}

#pragma mark - UITextField代理方法
-(void)textFieldChangeMethod:(UITextField *)textField{
    if (textField == _numField) {
        
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField endEditing:YES];
    [_numField resignFirstResponder];
    return YES;
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
