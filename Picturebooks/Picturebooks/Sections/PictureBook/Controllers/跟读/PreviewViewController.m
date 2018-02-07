//
//  PreviewViewController.m
//  Picturebooks
//
//  Created by 尹凯 on 2017/8/18.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "PreviewViewController.h"
#import "Segment.h"
#import "DraftTableViewCell.h"
#import "CustomIOSAlertView.h"
#import "PicFreeDetailViewController.h"
#import "PunchInViewController.h"
#import "MineShadowViewController.h"
#import "SRActionSheet.h"
static NSString * const cellIdentifier = @"draftCell";

@interface PreviewViewController ()<UITableViewDelegate, UITableViewDataSource, LGAudioPlayerDelegate, DraftTableViewCellDelegate,SRActionSheetDelegate>

@property (nonatomic, strong)UIView *headView;
@property (nonatomic, strong)UIImageView *headImg;
@property (nonatomic, strong)UITableView *draftTableView;
@property (nonatomic, strong)MBProgressHUD *publishHud;//加载小菊花

@property (nonatomic, strong)NSMutableArray *preArray;

@property (nonatomic, assign) NSInteger totalTime;
@property (nonatomic, assign)NSInteger repeatId;
@property (nonatomic, assign)NSInteger repeatPicId;
@property (nonatomic, copy)NSString *repeatName;
@end

@implementation PreviewViewController

- (void)dealloc{
    NSLog(@"没有内存泄漏");
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
    self.navigationItem.title = self.name;
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
    
    //音频播放代理协议
    [LGAudioPlayer sharePlayer].delegate = self;
    //预览数组构建
    self.preArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.dataArray.count; i++) {
        for (NSMutableDictionary *dic in self.messageArray) {
            if ([[dic objectForKey:@"pageNum"] integerValue] == i) {
                [self.preArray addObject:dic];
            }
        }
    }
    [self createView];
    self.publishHud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.publishHud];
}

#pragma mark - 创建视图
- (void)createView{
    [self createImageView];
    [self createTableView];
    [self createPublishBtn];
}

//创建发布按钮
- (void)createPublishBtn{
    UIButton *publishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:publishBtn];
    publishBtn.backgroundColor = RGBHex(0x14d02f);
    publishBtn.tag = 12301;
    [publishBtn setTitle:@"发  布" forState:UIControlStateNormal];
    publishBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [publishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [publishBtn addTarget:self action:@selector(publishBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [publishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_offset(0);
        make.width.mas_offset(SCREEN_WIDTH);
        make.height.mas_offset(44);
    }];
}

//发布按钮触发方法
- (void)publishBtnAction:(UIButton *)btn{
    [[LGAudioPlayer sharePlayer] stopAudioPlayer];
    self.navigationItem.leftBarButtonItem.customView.userInteractionEnabled = NO;

    // Jxd-start--------------------------------------
#pragma mark - Jxd-修改:暂停计时器
    [self.currentTimer setFireDate:[NSDate distantFuture]];
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
        NSMutableDictionary *dic = [self.preArray objectAtIndex:i];
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(model.ID), @"Id", [dic objectForKey:@"soundPath"], @"soundPath", nil];
        [tempMessageArray addObject:tmpDic];
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
    
#pragma mark - Jxd-temp
    NSLog(@"前tempMessageArray:%@",tempMessageArray);
    
    NSMutableArray *newMessageArray = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *dic in tempMessageArray) {
        dispatch_async(queue, ^{
            [LameTools cafTransToMP3WithCafFilePath:[dic objectForKey:@"soundPath"] mp3FilePath:[DocumentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"UploadFile/%ld.mp3", (long)[[dic objectForKey:@"Id"] integerValue]]]];
            NSInteger singleTime = [self singleTime:[DocumentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"UploadFile/%ld.mp3", (long)[[dic objectForKey:@"Id"] integerValue]]]];
            [newMessageArray addObject:@{@"Id" : @([[dic objectForKey:@"Id"] integerValue]), @"soundPath" : [DocumentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"UploadFile/%ld.mp3" , (long)[[dic objectForKey:@"Id"] integerValue]]], @"time" : @(singleTime)}];
        });
    }
    
    //栅栏
    dispatch_barrier_async(queue, ^{
        [LameTools clearSoundFile];
        
#pragma mark - Jxd-temp
        NSLog(@"后newMessageArray:%@",newMessageArray);
        
        [self getQiniuToken:newMessageArray];
    });
}

//获取音频的时间

- (NSInteger)singleTime:(NSString *)filePath{
    AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:filePath] options:nil];
    
    CMTime audioDuration = audioAsset.duration;
    
    float audioDurationSeconds =CMTimeGetSeconds(audioDuration) * 1000.0f;
    
    return [[NSString stringWithFormat:@"%f",audioDurationSeconds] integerValue];
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
//            
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
//            
//            AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:wholePath]];
//            NSTimeInterval durationTime = asset.duration.value / asset.duration.timescale * 1000.0f;
//            self.totalTime = [[NSString stringWithFormat:@"%f",durationTime] integerValue];
            
            [self uploadAudioToQiniu:[[success objectForKey:@"data"] objectForKey:@"token"] array:newMessageArray];
        }else{
            [Global showWithView:self.view withText:[success objectForKey:@"describe"]];
        }
    } failure:^(NSError *error) {
        [Global showWithView:self.view withText:@"网络异常~"];
    }];
}

//得到token后，将文件上传七牛，并得到返回的文件名（文件名和id整理成键值对的形式，和后台传来的数据要对应上）
- (void)uploadAudioToQiniu:(NSString *)uplaod_token array:(NSMutableArray *)array{
    //创建多线程队列
    dispatch_queue_t queue = dispatch_queue_create("uploadToQiniu.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSMutableArray *postArray = [[NSMutableArray alloc] init];
        for (NSMutableDictionary *dic in array) {
            QNUploadManager *upManager = [[QNUploadManager alloc] init];
            NSData *data = [NSData dataWithContentsOfFile:[dic objectForKey:@"soundPath"]];
            // 七牛上传音频的put 请求
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
//                                             NSMutableDictionary *wholeDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[resp objectForKey:@"key"], @"audio", nil];
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
    
//    for (int i = 0; i < array.count - 1; i++) {
//        for (int j = i + 1; j < array.count; j++) {
//            if ([array[i][@"id"] integerValue] > [array[j][@"id"] integerValue]) {
//                //交换
//                [array exchangeObjectAtIndex:i withObjectAtIndex:j];
//            }
//        }
//    }
    
    // Jxd-start------------------------------------
#pragma mark - Jxd-重新排序(按照原来的数组排序)
    NSMutableArray *tempArrayM = [NSMutableArray array];
    
    if (array.count == self.dataArray.count) {
        for (Segment *item in self.dataArray) {
            for (NSInteger i = 0; i <= array.count - 1; i++) {
                if ([array[i][@"id"] integerValue] == item.ID) {
                    [tempArrayM addObject:array[i]];
                }
            }
        }
        // 重新进行赋值
        [array removeAllObjects];
        array = tempArrayM;
    }
    // Jxd-end------------------------------------

    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:Book_repeat forKey:@"uri"];
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    //提交跟读信息接口参数
//    NSMutableDictionary *segment = [[NSMutableDictionary alloc] init];
//    [segment setObject:array forKey:@"segmentation"];
//    [segment setObject:whole forKey:@"whole"];
    [parame setObject:@{@"segment" : array, @"token" : self.token} forKey:@"repeat"];

    [[HttpManager sharedManager] POST:Book_repeat parame:parame sucess:^(id success) {
        [LameTools clearUploadFile];
        [self.publishHud hide:YES];
        if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
            self.repeatId = [success[@"data"][@"repeat"] integerValue];
            self.repeatPicId = [success[@"data"][@"type"] integerValue];

            CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
            //添加子视图
            alertView.backgroundColor = [UIColor whiteColor];
            [alertView setSubView:[self addSubViewWithTitle:@"是否分享？"]];
            //添加按钮标题数组
            [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"分享", @"不分享", nil]];
            //添加按钮点击方法
            [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"killNSTimer" object:nil];
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
                                                                                otherTitles:@[@"分享给微信好友", @"分享到朋友圈(+1水滴)"]
                                                                                otherImages:@[[UIImage imageNamed:@"pic_wechat"],
                                                                                              [UIImage imageNamed:@"pic_friend"]
                                                                                              ]
                                                                                   delegate:self];
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
                        mineReadVC.rewardUrl =  COURSE_RepeatReward;
                        [self.navigationController pushViewController:mineReadVC animated:YES];
                        
                    }
                    
                }
            }];
            //显示
            [alertView show];
        }
        else{
            [Global showWithView:self.view withText:[success objectForKey:@"describe"]];
        }
    } failure:^(NSError *error) {
        [LameTools clearUploadFile];
        [self.publishHud hide:YES];
    }];
}

#pragma mark - SRActionSheetDelegate
- (void)actionSheet:(SRActionSheet *)actionSheet didSelectSheet:(NSInteger)index {
    NSLog(@"%zd", index);
    //微信好友
    if (index == 0) {
        if ([WXApi isWXAppInstalled]) {
            WXMediaMessage *message = [WXMediaMessage message];
//            message.title = self.name;
             message.title = @"HS英文绘本课堂";
//            message.description = @"HS英文绘本课堂";
             message.description = [NSString stringWithFormat:@"%@在HS英文绘本课堂朗读了，快来听听吧!",self.name];
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
            message.title = self.name;
            message.description = @"HS英文绘本课堂";
            //png图片压缩成data的方法，如果是jpg就要用 UIImageJPEGRepresentation
            //message.thumbData = UIImagePNGRepresentation(image);
//            UIImage *image_pic=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/Fof8KyLYA3xDcxiB3NbnI9maVjIi", URL_share]]]];
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
    
//    for (UIViewController *tempVC in self.navigationController.viewControllers) {
//        if ([tempVC isKindOfClass:[PicFreeDetailViewController class]] || [tempVC isKindOfClass:[PunchInViewController class]]) {
//            [self.navigationController popToViewController:tempVC animated:YES];
//        }
//    }
    
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

//创建tableView
- (void)createTableView{
    self.draftTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 200, SCREEN_WIDTH, SCREEN_HEIGHT - PBNew64 - 200 - 44) style:UITableViewStylePlain];
    [self.view addSubview:self.draftTableView];
    self.draftTableView.backgroundColor = [UIColor whiteColor];
    self.draftTableView.dataSource = self;
    self.draftTableView.delegate = self;
    self.draftTableView.showsVerticalScrollIndicator = NO;
    [self.draftTableView registerClass:[DraftTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    self.draftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - UITableView代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.imageArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DraftTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSString *headImage = [[NSUserDefaults standardUserDefaults] objectForKey:@"User_headimage"];
    if ([Global isNullOrEmpty:headImage]) {
        cell.headImageView.image = [UIImage imageNamed:@"m_noheadimage"];
    }else{
        NSURL *imageUrl = [NSURL URLWithString:headImage];
        [cell.headImageView sd_setImageWithURL:imageUrl];
    }
    cell.pageNum = indexPath.row;
    cell.timeLabel.text = [AppTools secondsToMinutesAndSeconds:[[self.preArray objectAtIndex:indexPath.row] objectForKey:@"soundSeconds"]];
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - DraftTableViewCell代理方法
- (void)playAudioRequestFrom:(NSUInteger)index{
    [[LGAudioPlayer sharePlayer] playAudioWithURLString:[[self.preArray objectAtIndex:index] objectForKey:@"soundPath"] atIndex:index];
    for (UIImageView *temp in [self.headView subviews]) {
        if (temp.tag == 1000 + [[NSString stringWithFormat:@"%lu", (long)index] integerValue]) {
            [self.headView bringSubviewToFront:temp];
        }
    }
}

#pragma mark - LGAudioPlayer代理方法
- (void)audioPlayerStateDidChanged:(LGAudioPlayerState)audioPlayerState forIndex:(NSUInteger)index{
    NSInteger tmpTag = [[NSString stringWithFormat:@"%lu", (long)index] integerValue];
    if (audioPlayerState == 2) {
        
    }else if (audioPlayerState == 0){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cellButtonChange" object:@(tmpTag)];
    }else{
        if (tmpTag != -1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"cellButtonChange" object:@(tmpTag)];
        }
    }
}

//创建上方图片视图
- (void)createImageView{
    self.headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 190)];
    [self.view addSubview:self.headView];
    
//    for (int i = 0; i < self.imageArray.count; i++) {
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.headView.bounds];
//        [self.headView addSubview:imageView];
//        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ou396fprt.bkt.clouddn.com/%@", self.imageArray[self.imageArray.count - 1 - i]]];
//        [imageView sd_setImageWithURL:url];
//        imageView.tag = 1000 + self.imageArray.count - 1 - i;
//    }
    
    self.headImg = [[UIImageView alloc] initWithFrame:self.headView.bounds];
    NSURL *url = [NSURL URLWithString:[Qiniu_host stringByAppendingPathComponent:self.imageArray[0]]];
    [self.headImg sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"head_placeholder"]];
    self.headImg.contentMode = UIViewContentModeScaleAspectFit;
    [self.headView addSubview:self.headImg];
}

#pragma mark - 返回按钮方法
- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 其他方法
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[LGAudioPlayer sharePlayer] stopAudioPlayer];
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
