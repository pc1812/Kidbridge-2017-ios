//
//  FollowCollectionViewCell.m
//  FirstPage
//
//  Created by 尹凯 on 2017/7/14.
//  Copyright © 2017年 尹凯. All rights reserved.
//

#import "FollowCollectionViewCell.h"
#import "LGAudioKit.h"
#import "HttpManager.h"
#import "UIImage+GIF.h"

#define SOUND_RECORD_LIMIT 300
#define DocumentPath  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@interface FollowCollectionViewCell ()<UIScrollViewDelegate>
{
    CGFloat contentScrollH;
}

@property (nonatomic, strong)UIImageView *loadingImageView;
@property (nonatomic, strong)CALayer *player;
@end

@implementation FollowCollectionViewCell

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.backgroundColor = RGBHex(0xf0f0f0);
    
    if (self) {
        //播放gif
        self.loadingImageView= [[UIImageView alloc]init];
        self.player = self.loadingImageView.layer;
        //阴影效果
        UIView *shadow = [[UIView alloc] init];
        [self.contentView addSubview:shadow];
        shadow.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
        shadow.layer.shadowOffset = CGSizeMake(-1, -1);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
        shadow.layer.shadowOpacity = 0.4;//阴影透明度，默认0
        shadow.layer.shadowRadius = 2;//阴影半径，默认3
        [shadow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            
#pragma mark - Jxd-修改:前make.right.mas_equalTo(-2);
            make.right.mas_equalTo(-1);
            make.left.mas_equalTo(12);
        }];
        
        //圆角
        UIView *boundsView = [[UIView alloc] init];
        [shadow addSubview:boundsView];
        boundsView.backgroundColor = [UIColor whiteColor];
        
        boundsView.layer.masksToBounds = YES;
        boundsView.layer.cornerRadius = 6.0;
        boundsView.layer.borderWidth = 1.0;
        boundsView.layer.borderColor = [[UIColor clearColor] CGColor];
        [boundsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.and.left.and.right.mas_equalTo(0);
        }];
        
        //页标初始化与布局
        self.pageLabel = [[UILabel alloc] init];
        self.pageLabel.textColor = [UIColor blackColor];
        
        [boundsView addSubview:self.pageLabel];
        
        [self.pageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(16);
            make.top.mas_equalTo(10);
        }];
        
#pragma mark - 文字区域
        //scrollView初始化与布局
        self.contentScroll = [[UIScrollView alloc] init];
        [boundsView addSubview:self.contentScroll];
        //取消边界反弹效果(默认是开启)
        self.contentScroll.bounces = NO;
        //是否显示水平滑动条
        self.contentScroll.showsVerticalScrollIndicator = NO;
        self.contentScroll.directionalLockEnabled = YES;
        self.contentScroll.contentOffset = CGPointMake(0, 0);
        self.contentScroll.delegate = self;

//        if (IS_IPHONE4) {
//            [self.contentScroll mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.left.mas_equalTo(16);
//                make.top.equalTo(self.pageLabel.mas_bottom).offset(12);
//                make.width.mas_equalTo(180);
//                make.height.mas_equalTo(60);
//            }];
//        }else
//        if (IS_IPHONE5()) {
//            [self.contentScroll mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.left.mas_equalTo(16);
//                make.top.equalTo(self.pageLabel.mas_bottom).offset(12);
//                make.width.mas_equalTo(230);
//                make.height.mas_equalTo(110);
//            }];
//
//        }else{
//            [self.contentScroll mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.left.mas_equalTo(16);
//                make.top.equalTo(self.pageLabel.mas_bottom).offset(12);
//                make.width.mas_equalTo(278);
//                make.height.mas_equalTo(159);
//            }];
//        }
        
        contentScrollH =  self.bounds.size.height - 90;
        
        if (IS_IPHONE4) {
            [self.contentScroll mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(16);
                make.top.equalTo(self.pageLabel.mas_bottom).offset(12);
                make.width.mas_equalTo(180);
//                make.height.mas_equalTo(95);
                make.height.mas_equalTo(contentScrollH);
            }];
        }else
            if (IS_IPHONE5()) {
                [self.contentScroll mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(16);
                    make.top.equalTo(self.pageLabel.mas_bottom).offset(12);
                    make.width.mas_equalTo(230);
//                    make.height.mas_equalTo(145);
                    make.height.mas_equalTo(contentScrollH);

                }];

            }else{
                [self.contentScroll mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(16);
                    make.top.equalTo(self.pageLabel.mas_bottom).offset(12);
                    make.width.mas_equalTo(278);
//                    make.height.mas_equalTo(194);
                    make.height.mas_equalTo(contentScrollH);
//                    make.bottom.mas_equalTo(self.line.mas_top);
                }];
            }
        
        //文本框初始化与布局
        self.content = [[UILabel alloc] init];
        self.content.numberOfLines = 0;
        self.content.textAlignment = NSTextAlignmentLeft;
        self.content.font = [UIFont systemFontOfSize:13];
        [self.contentScroll addSubview:self.content];
        
#pragma mark - 侧面自定义scrollBar
        //自定义scrollBar背景初始化与布局
        UIView *scrollBarBackground = [[UIView alloc] init];
        [boundsView addSubview:scrollBarBackground];
        scrollBarBackground.backgroundColor = RGBHex(0xf0f0f0);
        scrollBarBackground.layer.masksToBounds = YES;
        scrollBarBackground.layer.cornerRadius = 4;
        
        if (IS_IPHONE5()) {
            [scrollBarBackground mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentScroll.mas_top);
                make.bottom.equalTo(self.contentScroll.mas_bottom);
                make.width.mas_equalTo(8);
                make.right.equalTo(self.contentScroll.mas_right);
            }];
            
        }else{
            [scrollBarBackground mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentScroll.mas_top);
                make.bottom.equalTo(self.contentScroll.mas_bottom);
                make.width.mas_equalTo(8);
                make.right.equalTo(self.contentScroll.mas_right);
            }];
        }
        
        //自定义scrollBar初始化与布局
        self.scrollBar = [[UIView alloc] init];
        [scrollBarBackground addSubview:self.scrollBar];
        self.scrollBar.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.2];
        self.scrollBar.layer.masksToBounds = YES;
        self.scrollBar.layer.cornerRadius = 4;
        
#pragma mark - 下方子视图
        //灰线初始化与布局 :文本区域与播放按钮,录音按钮中间的灰色的分割线
        self.line = [[UIView alloc] init];
        self.line.backgroundColor = RGBHex(0xf0f0f0);
        [boundsView addSubview:self.line];
        
        [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(16);
            make.right.mas_equalTo(-16);
            make.bottom.mas_equalTo(-44);
            make.height.mas_equalTo(1);
        }];
        
        
        //播放按钮初始化与布局
        self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.playButton];
        [self.playButton setImage:[UIImage imageNamed:@"repeat_play"] forState:UIControlStateNormal];
        [self.playButton setImage:[UIImage imageNamed:@"repeat_pause"] forState:UIControlStateSelected];
        self.playButton.layer.masksToBounds = YES;
        self.playButton.layer.cornerRadius = 16;
        [self.playButton addTarget:self action:@selector(playAndStop:) forControlEvents:UIControlEventTouchUpInside];
        
        
        // 原值 32 顶部偏移量原值 6
        CGFloat btnWAndH = 36.0;
        if (IS_IPHONE4) {
            [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(80);
                make.top.equalTo(self.line.mas_bottom).offset(4);
                make.size.mas_equalTo(CGSizeMake(btnWAndH, btnWAndH));
            }];
        }else if (IS_IPHONE5()){
            [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(90);
                make.top.equalTo(self.line.mas_bottom).offset(4);
                make.size.mas_equalTo(CGSizeMake(btnWAndH, btnWAndH));
            }];
        }else{
            [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(100);
                make.top.equalTo(self.line.mas_bottom).offset(4);
                make.size.mas_equalTo(CGSizeMake(btnWAndH, btnWAndH));
            }];
        }
       
        
        //录音按钮初始化与布局
        self.recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.recordButton];
        [self.recordButton setImage:[UIImage imageNamed:@"recorder"] forState:UIControlStateNormal];
        self.recordButton.layer.masksToBounds = YES;
        self.recordButton.layer.cornerRadius = 16;
        
        if (IS_IPHONE4) {
            [self.recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(-80);
                make.top.equalTo(self.line.mas_bottom).offset(4);
                make.size.mas_equalTo(CGSizeMake(btnWAndH, btnWAndH));
            }];
        }else if (IS_IPHONE5()){
            [self.recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(-90);
                make.top.equalTo(self.line.mas_bottom).offset(4);
                make.size.mas_equalTo(CGSizeMake(btnWAndH, btnWAndH));
            }];
        }else{
            [self.recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(-100);
                make.top.equalTo(self.line.mas_bottom).offset(4);
                make.size.mas_equalTo(CGSizeMake(btnWAndH, btnWAndH));
            }];
        }
       
        //这里可以修改要实现播放的gif的frame
        self.loadingImageView = [[UIImageView alloc] init];
        [self addSubview:self.loadingImageView];
        [self.loadingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.recordButton.mas_right);
            make.top.mas_equalTo(self.recordButton.mas_top);
            make.size.mas_equalTo(CGSizeMake(32, 32));
        }];
        self.player = self.loadingImageView.layer;
        
       
        //录音按钮触发方法
        [self.recordButton addTarget:self action:@selector(recordBtnAct:) forControlEvents:UIControlEventTouchUpInside];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageNumChange:) name:@"pageNumberChange" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageButtonChange:) name:@"pageButtonChange" object:nil];
    }
    
    return self;
}

- (void)pageButtonChange:(NSNotification *)notification{
    if ([[NSString stringWithFormat:@"%ld", (long)self.pageNum] isEqualToString:[NSString stringWithFormat:@"%ld", (long)([notification.object integerValue])]]) {
        self.playButton.selected = NO;
    }
}

//collectionView滑动时，cell的页标提亮
- (void)pageNumChange:(NSNotification *)notification{
    if ([[NSString stringWithFormat:@"%ld", (long)self.pageNum + 1] isEqualToString:notification.object]) {
        NSString *str = [NSString stringWithFormat:@"%ld", _pageNum + 1];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld/%ld", (long)_pageNum + 1, (long)self.totalPage]];
        [string addAttributes:@{NSForegroundColorAttributeName : RGBHex(0x14d02f)}
                        range:NSMakeRange(0, str.length)];
        self.pageLabel.attributedText = string;
    }
    else{
        self.pageLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)_pageNum + 1, (long)self.totalPage];
    }
}

//录音按钮触发方法
- (void)recordBtnAct:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.selected) {
        //[self resumeLayer:self.player];
        [self.recordButton setImage:[UIImage imageNamed:@"record_sel"] forState:UIControlStateNormal];
        [self startRecordVoice];
        [self.delegate recordStatus:btn.selected];
    }else{
        //[self pauseLayer:self.player];
        [self.recordButton setImage:[UIImage imageNamed:@"recorder"] forState:UIControlStateNormal];
        [self confirmRecordVoice];
        [self.delegate recordStatus:btn.selected];
    }
    
    
//    NSString  *name = @"a_record@2x.gif";
//    NSString  *filePath = [[NSBundle bundleWithPath:[[NSBundle mainBundle] bundlePath]] pathForResource:name ofType:nil];
//    NSData  *imageData = [NSData dataWithContentsOfFile:filePath];
//    
//  
//    self.loadingImageView.backgroundColor = [UIColor clearColor];
//    
//    self.loadingImageView.image = [UIImage sd_animatedGIFWithData:imageData];
    
  
}

//暂停gif的方法

-(void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

//继续gif的方法
-(void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] -    pausedTime;
    layer.beginTime = timeSincePause;
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
        [[LGSoundRecorder shareInstance] startSoundRecord:self recordPath:[self recordPath] needAnimation:NO];
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
    
    NSInteger seconds = floor([[LGSoundRecorder shareInstance] soundRecordTime]);
    NSDictionary *dic =@{@"soundPath" : [[LGSoundRecorder shareInstance] soundFilePath],
                         @"soundSeconds" : [NSString stringWithFormat:@"%ld", (long)seconds],
                         @"pageNum" : @(self.pageNum)
                         };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"endRecordVoice" object:nil userInfo:dic];
    [[LGSoundRecorder shareInstance] stopSoundRecord:self];
    
    if (_timerOf60Second) {
        [_timerOf60Second invalidate];
        _timerOf60Second = nil;
    }
}

/**
 *  更新录音显示状态,手指向上滑动后 提示松开取消录音
 */
- (void)updateCancelRecordVoice {
    [_timerOf60Second invalidate];
    _timerOf60Second = nil;
    [[LGSoundRecorder shareInstance] readyCancelSound];
}

/**
 *  更新录音状态,手指重新滑动到范围内,提示向上取消录音
 */
- (void)updateContinueRecordVoice {
    [_timerOf60Second invalidate];
    _timerOf60Second = nil;
    [[LGSoundRecorder shareInstance] resetNormalRecord];
}

/**
 *  取消录音
 */
- (void)cancelRecordVoice {
    [_timerOf60Second invalidate];
    _timerOf60Second = nil;
    [[LGSoundRecorder shareInstance] soundRecordFailed:self];
}

/**
 *  录音时间短
 */
- (void)showShotTimeSign {
    [[LGSoundRecorder shareInstance] showShotTimeSign:self];
}

- (void)sixtyTimeStopAndSendVedio {
    int countDown = SOUND_RECORD_LIMIT - [[LGSoundRecorder shareInstance] soundRecordTime];
    NSLog(@"countDown is %d soundRecordTime is %f", countDown, [[LGSoundRecorder shareInstance] soundRecordTime]);
    if (countDown <= 10) {
        [[LGSoundRecorder shareInstance] showCountdown:countDown];
    }
    if ([[LGSoundRecorder shareInstance] soundRecordTime] >= SOUND_RECORD_LIMIT && [[LGSoundRecorder shareInstance] soundRecordTime] <= SOUND_RECORD_LIMIT + 1) {
        
        if (_timerOf60Second) {
            [_timerOf60Second invalidate];
            _timerOf60Second = nil;
        }
        [self.recordButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

/**
 *  语音文件存储路径
 *
 *  @return 路径
 */
- (NSString *)recordPath {
    if (![[NSFileManager defaultManager] fileExistsAtPath:[DocumentPath stringByAppendingPathComponent:@"SoundFile"]]){
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:[DocumentPath stringByAppendingPathComponent:@"SoundFile"] withIntermediateDirectories:NO attributes:nil error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
    }
    
//    NSString *filePath = [DocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"SoundFile/%@", [AppTools transformToPinyin:self.name]]];
    NSString *string = @"RecordSound";
    NSString *filePath = [DocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"SoundFile/%@", string]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:[DocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"SoundFile/%@", string]] withIntermediateDirectories:NO attributes:nil error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
    }
    return filePath;
}

#pragma mark - LGSoundRecorderDelegate
- (void)showSoundRecordFailed{
    //	[[SoundRecorder shareInstance] soundRecordFailed:self];
    if (_timerOf60Second) {
        [_timerOf60Second invalidate];
        _timerOf60Second = nil;
    }
}

- (void)didStopSoundRecord {
    NSLog(@"over, it's over");
}

#pragma mark - cell的属性及按钮方法
- (void)playAndStop:(UIButton *)button{
    button.selected = !button.selected;
    [self.delegate playAudioWithURLString:self.soundUrl index:self.pageNum];
}

- (void)setPageNum:(NSInteger)pageNum{
    _pageNum = pageNum;
    self.pageLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)_pageNum + 1, (long)self.totalPage];
    [self.pageLabel sizeToFit];
    if (_pageNum == 0) {
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld/%ld", (long)_pageNum + 1, (long)self.totalPage]];
        [string addAttributes:@{NSForegroundColorAttributeName : RGBHex(0x14d02f)}
                        range:NSMakeRange(0, 1)];
        self.pageLabel.attributedText = string;
    }
}

- (void)setSegment:(Segment *)segment{
    _segment = segment;
    
    NSString *conversation = _segment.text;
//    for (NSString *sentence in _segment.text) {
//        conversation = [conversation stringByAppendingFormat:@"%@\n", sentence];
//    }
    //富文本
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:conversation];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5];//调整行间距
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedString length])];
    //将富文本复制给label的富文本Text
    self.content.attributedText = attributedString;
//    if (IS_IPHONE4) {
//        self.content.frame = CGRectMake(0, 0, 180, [AppTools heightForAttributeContent:conversation fontoOfText:13 width:180 lineSpace:5]);
//        //根据content高度，给scrollview核心属性赋值
//        self.contentScroll.contentSize = CGSizeMake(0, self.content.frame.size.height);
//        self.contentScroll.contentOffset = CGPointMake(0, 0);
//        self.scrollBar.frame = CGRectMake(0, 0, 8, 60 / self.content.frame.size.height * 60);
//    }else
//    if (IS_IPHONE5()) {
//        self.content.frame = CGRectMake(0, 0, 220, [AppTools heightForAttributeContent:conversation fontoOfText:13 width:220 lineSpace:5]);
//        //根据content高度，给scrollview核心属性赋值
//        self.contentScroll.contentSize = CGSizeMake(0, self.content.frame.size.height);
//        self.contentScroll.contentOffset = CGPointMake(0, 0);
//        self.scrollBar.frame = CGRectMake(0, 0, 8, 110 / self.content.frame.size.height * 110);
//
//
//    }else{
//        self.content.frame = CGRectMake(0, 0, 250, [AppTools heightForAttributeContent:conversation fontoOfText:13 width:250 lineSpace:5]);
//        //根据content高度，给scrollview核心属性赋值
//        self.contentScroll.contentSize = CGSizeMake(0, self.content.frame.size.height);
//        self.contentScroll.contentOffset = CGPointMake(0, 0);
//        self.scrollBar.frame = CGRectMake(0, 0, 8, 159 / self.content.frame.size.height * 159);
//
//    }
    
    if (IS_IPHONE4) {
        self.content.frame = CGRectMake(0, 0, 180, [AppTools heightForAttributeContent:conversation fontoOfText:13 width:180 lineSpace:5]);
        //根据content高度，给scrollview核心属性赋值
        self.contentScroll.contentSize = CGSizeMake(0, self.content.frame.size.height);
        self.contentScroll.contentOffset = CGPointMake(0, 0);
//        self.scrollBar.frame = CGRectMake(0, 0, 8, 95 / self.content.frame.size.height * 95);
    }else
        if (IS_IPHONE5()) {
            self.content.frame = CGRectMake(0, 0, 220, [AppTools heightForAttributeContent:conversation fontoOfText:13 width:220 lineSpace:5]);
            //根据content高度，给scrollview核心属性赋值
            self.contentScroll.contentSize = CGSizeMake(0, self.content.frame.size.height);
            self.contentScroll.contentOffset = CGPointMake(0, 0);
//            self.scrollBar.frame = CGRectMake(0, 0, 8, 145 / self.content.frame.size.height * 145);
            
        }else{
            self.content.frame = CGRectMake(0, 0, 250, [AppTools heightForAttributeContent:conversation fontoOfText:13 width:250 lineSpace:5]);
            //根据content高度，给scrollview核心属性赋值
            self.contentScroll.contentSize = CGSizeMake(0, self.content.frame.size.height);
            self.contentScroll.contentOffset = CGPointMake(0, 0);
//            self.scrollBar.frame = CGRectMake(0, 0, 8, 194 / self.content.frame.size.height * 194);
        }
    
    self.scrollBar.frame = CGRectMake(0, 0, 8, contentScrollH / self.content.frame.size.height * contentScrollH);
    
    self.soundUrl = _segment.audio;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    if (IS_IPHONE4) {
//        [UIView animateWithDuration:0.3 animations:^{
//            self.scrollBar.frame = CGRectMake(0, scrollView.contentOffset.y / self.content.frame.size.height * 60, 8, 60 / self.content.frame.size.height * 60);
//        }];
//    }else
//    if (IS_IPHONE5()) {
//        [UIView animateWithDuration:0.3 animations:^{
//            self.scrollBar.frame = CGRectMake(0, scrollView.contentOffset.y / self.content.frame.size.height * 110, 8, 110 / self.content.frame.size.height * 110);
//        }];
//
//    }else{
//
//        [UIView animateWithDuration:0.3 animations:^{
//            self.scrollBar.frame = CGRectMake(0, scrollView.contentOffset.y / self.content.frame.size.height * 159, 8, 159 / self.content.frame.size.height * 159);
//        }];
//    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollBar.frame = CGRectMake(0, scrollView.contentOffset.y / self.content.frame.size.height * contentScrollH, 8, contentScrollH / self.content.frame.size.height * contentScrollH);

    }];
    
//    if (IS_IPHONE4) {
//        [UIView animateWithDuration:0.3 animations:^{
//            self.scrollBar.frame = CGRectMake(0, scrollView.contentOffset.y / self.content.frame.size.height * 95, 8, 95 / self.content.frame.size.height * 95);
//        }];
//    }else if (IS_IPHONE5()) {
//            [UIView animateWithDuration:0.3 animations:^{
//                self.scrollBar.frame = CGRectMake(0, scrollView.contentOffset.y / self.content.frame.size.height * 145, 8, 145 / self.content.frame.size.height * 145);
//            }];
//
//    }else{
//
//        [UIView animateWithDuration:0.3 animations:^{
//            self.scrollBar.frame = CGRectMake(0, scrollView.contentOffset.y / self.content.frame.size.height * 194, 8, 194 / self.content.frame.size.height * 194);
//        }];
//    }
}

@end
