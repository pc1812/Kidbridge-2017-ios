//
//  PicCommentViewController.m
//  PictureBook
//
//  Created by Yasin on 2017/7/14.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "PicCommentViewController.h"

#define SOUND_RECORD_LIMIT 60

@interface PicCommentViewController ()<UITextViewDelegate, LGAudioPlayerDelegate>

/** 文本输入框 */
@property (nonatomic, strong) UITextView  *nickNameTextView;
@property (nonatomic, strong) UIView  *recordView;
@property (nonatomic, strong) MBProgressHUD *publishHud;//加载小菊花

@property (nonatomic, weak) NSTimer *timerOf60Second;
@property (nonatomic, strong) NSString *soundPath;
@property (nonatomic, strong) NSString *Post_url;

@property (nonatomic, assign) NSInteger recordTime;//录音时间
@end

@implementation PicCommentViewController
{
    UIButton *likeBtn;
}

- (void)dealloc{
    NSLog(@"没有内存泄漏");
    [self clearCommentSounfFileCaches];
}

/** 导航栏右侧按钮的点击事件 */
- (void)rightItemClick
{
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 导航标题
    self.navigationItem.titleView=[UINavigationItem titleViewForTitle:@"评论"];
    // 导航右侧的按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style: UIBarButtonItemStyleDone target:self action:@selector(rightItemClick)];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.view.backgroundColor = RGBHex(0xf0f0f0);
    
    [self clearCommentSounfFileCaches];
    
    //文本输入框 之前高度 180
    self.nickNameTextView=[GCPlaceholderTextView initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 150) andText:@"请输入评论内容"];
    self.nickNameTextView.delegate=self;
    self.nickNameTextView.scrollEnabled = YES;
    [self.view addSubview:self.nickNameTextView];
    
    //录音部分视图
    self.recordView = [UIView new];
    self.recordView.frame = FRAMEMAKE_F(0, CGRectGetMaxY(self.nickNameTextView.frame)-1, SCREEN_WIDTH, 30);
    self.recordView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.recordView];
    
    //播放代理协议
    [LGAudioPlayer sharePlayer].delegate = self;
    
    //录音按钮
    UIImage *image = [UIImage imageNamed:@"pic_record"];
    likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
     [self.view addSubview:likeBtn];
    likeBtn.frame = CGRectMake((SCREEN_WIDTH - image.size.width) / 2, CGRectGetMaxY( self.recordView.frame) + 15 , image.size.width, image.size.height);
    [likeBtn setImage:image forState:UIControlStateNormal];
    [likeBtn addTarget:self action:@selector(startRecordVoice) forControlEvents:UIControlEventTouchDown];
    [likeBtn addTarget:self action:@selector(cancelRecordVoice) forControlEvents:UIControlEventTouchUpOutside];
    [likeBtn addTarget:self action:@selector(confirmRecordVoice) forControlEvents:UIControlEventTouchUpInside];
    [likeBtn addTarget:self action:@selector(updateCancelRecordVoice) forControlEvents:UIControlEventTouchDragExit];
    [likeBtn addTarget:self action:@selector(updateContinueRecordVoice) forControlEvents:UIControlEventTouchDragEnter];
    
    //下部分视图
    UILabel *recodLab = [UILabel new];
    [self.view addSubview:recodLab];
    LabelSet(recodLab, @"长按录音", RGBHex(0x999999), 12, recordDic, recordSize);
    recodLab.frame = FRAMEMAKE_F((SCREEN_WIDTH - recordSize.width) / 2, CGRectGetMaxY(likeBtn.frame) + 8, recordSize.width, recordSize.height);
    
    UIButton *submitBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.frame=CGRectMake(45, CGRectGetMaxY(recodLab.frame) + 20, SCREEN_WIDTH- 90, 40);
    [submitBtn setTitle:@"提交" forState:UIControlStateNormal];
    submitBtn.titleLabel.textColor = [UIColor whiteColor];
    submitBtn.backgroundColor=[Global convertHexToRGB:@"14d02f"];
    [submitBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    submitBtn.layer.cornerRadius= 20;
    submitBtn.clipsToBounds=YES;
    [self.view addSubview:submitBtn];
    
    self.publishHud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.publishHud];
    if (self.picCommentType == PicCommentAppreciation) {
        if (self.quote == -1) {
            self.Post_url = Appreciation_comment;
        }else{
            self.Post_url = Appreciation_commentreply;
        }
    }else if(self.picCommentType == PicCommentRepeat){
        if (self.quote == -1) {
            self.Post_url = Repeat_comment;
        }else{
            self.Post_url = Repeat_commentreply;
        }
    }else if(self.picCommentType == MineCoCommentAppreciation){
        if (self.quote == -1) {
            self.Post_url = Co_comment;
        }else{
            self.Post_url = Co_commentreply;
        }
    }else {
        if (self.quote == -1) {
            self.Post_url = COURSE_COMMENT;
        }else{
            self.Post_url = COURSE_REPLY;
        }
    }
}

#pragma mark - Private Methods
/**
 *  开始录音
 */
- (void)startRecordVoice{
    __block BOOL isAllow = 0;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                isAllow = 1;
            } else {
                isAllow = 0;
            }
        }];
    }
    if (isAllow) {
        //		//停止播放
        [[LGAudioPlayer sharePlayer] stopAudioPlayer];
        //		//开始录音
        [[LGSoundRecorder shareInstance] startSoundRecord:self.nickNameTextView recordPath:[self recordPath] needAnimation:YES];
        //开启定时器
        if (_timerOf60Second) {
            [_timerOf60Second invalidate];
            _timerOf60Second = nil;
        }
        _timerOf60Second = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(sixtyTimeStopAndSendVedio) userInfo:nil repeats:YES];
    } else {
        
    }
}

/**
 *  录音结束
 */
- (void)confirmRecordVoice {
    if ([[LGSoundRecorder shareInstance] soundRecordTime] == 0) {
        [self cancelRecordVoice];
        return;//60s自动发送后，松开手走这里
    }
    if ([[LGSoundRecorder shareInstance] soundRecordTime] < 1.0f) {
        if (_timerOf60Second) {
            [_timerOf60Second invalidate];
            _timerOf60Second = nil;
        }
        [self showShotTimeSign];
        return;
    }
    
    [self creatUI];
    self.soundPath = [[LGSoundRecorder shareInstance] soundFilePath];
    [[LGSoundRecorder shareInstance] stopSoundRecord:self.view];
    
    if (_timerOf60Second) {
        [_timerOf60Second invalidate];
        _timerOf60Second = nil;
    }
}

/**
 *  更新录音显示状态,手指向上滑动后 提示松开取消录音
 */
- (void)updateCancelRecordVoice {
    [[LGSoundRecorder shareInstance] readyCancelSound];
}

/**
 *  更新录音状态,手指重新滑动到范围内,提示向上取消录音
 */
- (void)updateContinueRecordVoice {
    [[LGSoundRecorder shareInstance] resetNormalRecord];
}

/**
 *  取消录音
 */
- (void)cancelRecordVoice {
    [[LGSoundRecorder shareInstance] soundRecordFailed:self.view];
    if (_timerOf60Second) {
        [_timerOf60Second invalidate];
        _timerOf60Second = nil;
    }
}

/**
 *  录音时间短
 */
- (void)showShotTimeSign {
    [[LGSoundRecorder shareInstance] showShotTimeSign:self.view];
}

- (void)sixtyTimeStopAndSendVedio {
    int countDown = SOUND_RECORD_LIMIT - [[LGSoundRecorder shareInstance] soundRecordTime];
    NSLog(@"countDown is %d soundRecordTime is %f",countDown,[[LGSoundRecorder shareInstance] soundRecordTime]);
    if (countDown <= 10) {
        [[LGSoundRecorder shareInstance] showCountdown:countDown];
    }
    if ([[LGSoundRecorder shareInstance] soundRecordTime] >= SOUND_RECORD_LIMIT && [[LGSoundRecorder shareInstance] soundRecordTime] <= SOUND_RECORD_LIMIT + 1) {
        
        if (_timerOf60Second) {
            [_timerOf60Second invalidate];
            _timerOf60Second = nil;
        }
        [likeBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

/**
 *  语音文件存储路径
 *
 *  @return 路径
 */
- (NSString *)recordPath {
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if (![filemanager fileExistsAtPath:CommentSoundFilesCaches]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:CommentSoundFilesCaches withIntermediateDirectories:NO attributes:nil error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
    }
    return CommentSoundFilesCaches;
}

//录音后创建录音视图
- (void)creatUI {
    
    // Jxd-start------------------ // 180  35
#pragma mark - Jxd-修改
    [self.recordView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat viewW = XDWidthRatio(150);
    CGFloat viewX = XDWidthRatio(5);
    CGFloat viewH = XDHightRatio(30);
    
    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    playBtn.frame = CGRectMake(viewX, 0, viewW, viewH);
    [self.recordView addSubview:playBtn];
    playBtn.backgroundColor = [Global convertHexToRGB:@"14d02f"];
    playBtn.frame = FRAMEMAKE_F(viewX, 0, viewW, viewH);
    playBtn.layer.cornerRadius = viewH * 0.5;
    playBtn.layer.masksToBounds = YES;
    playBtn.tag = 1201;
    
    [playBtn setImage:[UIImage imageNamed:@"c_pause"] forState:UIControlStateNormal];
    [playBtn setImage:[UIImage imageNamed:@"c_play"] forState:UIControlStateSelected];
    [playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    NSInteger seconds = floor([[LGSoundRecorder shareInstance] soundRecordTime]);
    self.recordTime = seconds * 1000;
    NSString *timeString = [AppTools secondsToMinutesAndSeconds:[NSString stringWithFormat:@"%ld", (long)seconds]];
    [playBtn setTitle:timeString forState:UIControlStateNormal];
    playBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    
    playBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    playBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    playBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 65, 0, 0);
    // Jxd-end--------------------
    
    
//    for (UIView *view in self.recordView.subviews) {
//        [view removeFromSuperview];
//    }
    
//    UIView *view = [[UIView alloc] init];
//    view.frame = FRAMEMAKE_F(10, 0, 90, 20);
//    view.layer.cornerRadius = 10;
//    view.clipsToBounds = YES;
//    view.backgroundColor = [Global convertHexToRGB:@"14d02f"];
//    view.backgroundColor = JXDRandomColor;
//    [self.recordView addSubview:view];
    
//    UIImage *image = [UIImage imageNamed:@"c_pause"];
//    UIButton *playBtn = [UIButton new];
//    playBtn.frame = CGRectMake(CGRectGetMinX(view.frame), (CGRectGetHeight(view.frame) - image.size.width) / 2 , image.size.width , image.size.height);
//    playBtn.tag = 1201;
//    [playBtn setImage:image forState:UIControlStateNormal];
//    [playBtn setImage:[UIImage imageNamed:@"c_play"] forState:UIControlStateSelected];
//    [playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    playBtn.userInteractionEnabled = YES;
//    [view addSubview:playBtn];
//
//    UILabel *timeLab = [UILabel new];
//    NSInteger seconds = floor([[LGSoundRecorder shareInstance] soundRecordTime]);
//    self.recordTime = seconds * 1000;
//    NSString *timeString = [AppTools secondsToMinutesAndSeconds:[NSString stringWithFormat:@"%ld", (long)seconds]];
//    LabelSet(timeLab, timeString, [UIColor whiteColor], 12, timeDic, timeSize);
//    timeLab.frame = FRAMEMAKE_F(CGRectGetMaxX(view.frame) - timeSize.width - 15, (CGRectGetHeight(view.frame) - timeSize.height) / 2, timeSize.width, timeSize.height);
//    [view addSubview:timeLab];
    
    
}

//录音播放按钮
- (void)playBtnClick:(UIButton *)button{
    button.selected = !button.selected;
    [[LGAudioPlayer sharePlayer] playAudioWithURLString:self.soundPath atIndex:0];
}

#pragma mark - LGAudioPlayerDelegate
- (void)audioPlayerStateDidChanged:(LGAudioPlayerState)audioPlayerState forIndex:(NSUInteger)index {
    NSInteger tmpTag = [[NSString stringWithFormat:@"%lu", (long)index] integerValue];
    if (audioPlayerState == 2) {
        
    }else if (audioPlayerState == 0){
        ((UIButton *)[self.recordView viewWithTag:1201]).selected = NO;
    }else{
        if (tmpTag != -1) {
            ((UIButton *)[self.recordView viewWithTag:1201]).selected = NO;
        }
    }
}

//提交按钮触发方法
-(void)btnClick{
    
    if ([Global isNullOrEmpty:self.nickNameTextView.text] && [Global isNullOrEmpty:self.soundPath]) {
        [Global showWithView:self.view withText:@"录音和文字至少填一项"];
        return;
    }else if ([Global isNullOrEmpty:self.nickNameTextView.text] || [Global isNullOrEmpty:self.soundPath]){
        if ([Global isNullOrEmpty:self.soundPath]) {
            [self postPublishCommentWithPicId:self.readID text:self.nickNameTextView.text audio:nil];
        }else{
            NSString *mp3FileName = [CommentSoundFilesCaches stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", [AppTools getTimestamp]]];
            [LameTools cafTransToMP3WithCafFilePath:self.soundPath mp3FilePath:mp3FileName];
            self.soundPath = mp3FileName;
            [self getQiniuToken];
        }
    }else{
        NSString *mp3FileName = [CommentSoundFilesCaches stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", [AppTools getTimestamp]]];
        [LameTools cafTransToMP3WithCafFilePath:self.soundPath mp3FilePath:mp3FileName];
        self.soundPath = mp3FileName;
        [self getQiniuToken];
    }
    //显示的文字
    self.publishHud.labelText = @"提交中...";
    //是否有遮罩
    self.publishHud.dimBackground = NO;
    self.publishHud.backgroundColor = [UIColor clearColor];
    //提示框的样式
    self.publishHud.mode = MBProgressHUDModeIndeterminate;
    [self.publishHud show:YES];
    
}

//从后台请求到上传文件到七牛的token
- (void)getQiniuToken{
    //得到基本固定参数字典，加入调用接口所需参数
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:Upload_token forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    
    [[HttpManager sharedManager] POST:Upload_token parame:parame sucess:^(id success) {
        
        if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
            [self uploadAudioToQiniu:[[success objectForKey:@"data"] objectForKey:@"token"]];
        }else{
            NSLog(@"event = %@, describe = %@", [success objectForKey:@"event"], [success objectForKey:@"describe"]);
        }
    } failure:^(NSError *error) {
        [Global showWithView:self.view withText:@"网络错误"];
    }];
}

//得到token后，将文件上传七牛，并得到返回的文件名（文件名和id整理成键值对的形式，和后台传来的数据要对应上）
- (void)uploadAudioToQiniu:(NSString *)uplaod_token{
    
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    NSData *data = [NSData dataWithContentsOfFile:self.soundPath];
    [upManager putData:data key:nil token:uplaod_token complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        [self postPublishCommentWithPicId:self.readID text:self.nickNameTextView.text audio:[resp objectForKey:@"key"]];
    } option:nil];
}

#pragma mark - 绘本跟读发布评论
- (void)postPublishCommentWithPicId:(NSInteger)picID text:(NSString *)text audio:(NSString *)audio{
    //得到基本固定参数字典，加入调用接口所需参数
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:self.Post_url forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:@(picID) forKey:@"id"];
    if (self.quote != -1) {
        [parame setObject:@(self.quote) forKey:@"quote"];
    }
    if (![Global isNullOrEmpty:text]) {
        [parame setObject:text forKey:@"text"];
    }
    if (![Global isNullOrEmpty:audio]) {
        NSDictionary *dic = @{@"source" : audio, @"time":  @(self.recordTime)};
        [parame setObject:dic forKey:@"audio"];
    }
    
    [[HttpManager sharedManager] POST:self.Post_url parame:parame sucess:^(id success) {
        [self.publishHud hide:YES];
        if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
            [Global showWithView:self.view withText:@"评论成功！"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"dataload" object:self userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"readload" object:self userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"codataload" object:self userInfo:nil];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
            
        }else{
            [Global showWithView:self.view withText:[success objectForKey:@"describe"]];
        }
    } failure:^(NSError *error) {
        [self.publishHud hide:YES];
        [Global showWithView:self.view withText:@"网络错误"];
    }];
}

#pragma mark  -textview  delegate
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

-(void)textViewDidChange:(UITextView *)textView{
//    if (textView.text.length==0) {
//
//    }else if (textView.text.length>100) {
//        self.nickNameTextView.text=[textView.text substringToIndex:100];
//    }else{
//        
//    }

}

//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
//    // 文本换行
//    if ([text isEqualToString:@"\n"]){
////        [textView resignFirstResponder];
//        return NO;
//    }
//    return YES;
//}

#pragma mark - 其他方法
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//清除录音缓存
- (void)clearCommentSounfFileCaches{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:CommentSoundFilesCaches]) {
        //-(NSArray *)subpathsAtPath:(NSString *)path,用来获取指定目录下的子项（文件或文件夹）列表
        NSArray *childerFiles = [fileManager subpathsAtPath:CommentSoundFilesCaches];
        for (NSString *fileName in childerFiles) {
            //如有需要，加入条件，过滤掉不想删除的文件
            NSString *absolutePath = [CommentSoundFilesCaches stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [[LGAudioPlayer sharePlayer] stopAudioPlayer];
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
