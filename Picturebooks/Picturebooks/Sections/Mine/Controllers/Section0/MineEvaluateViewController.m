//
//  MineEvaluateViewController.m
//  Picturebooks
//
//  Created by Yasin on 2017/7/21.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "MineEvaluateViewController.h"
#import "EvaluateViewCell.h"
#import "MineCommentModel.h"
#import "PicWithComTableViewCell.h"
#import "MineShadowViewController.h"
@interface MineEvaluateViewController ()<UITableViewDelegate, UITableViewDataSource, LGAudioPlayerDelegate>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *dataSource;
@property(nonatomic)UILabel *noLabel;
@end

@implementation MineEvaluateViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView = [UINavigationItem titleViewForTitle:@"老师评价"];
    [self.view addSubview:self.tableView];
    
     [LGAudioPlayer sharePlayer].delegate = self;
    
    [self commentData];
    // Do any additional setup after loading the view.
    
    
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - PBNew64) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    }
    return _tableView ;
}

-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSource;
}
-(UILabel *)noLabel
{
    if (!_noLabel) {
        self.noLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-250)/2, (SCREEN_HEIGHT-100-44-250)/2, 250, 250)];
        self.noLabel.backgroundColor=[UIColor clearColor];
        self.noLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.noLabel];
        
    }
    return _noLabel;
}

//加载评论数据
- (void)commentData{
    //得到基本固定参数字典，加入调用接口所需参数
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];//kOffset
    [parame setObject:USER_COMMENTTea forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
   
    [[HttpManager sharedManager] POST:USER_COMMENTTea parame:parame sucess:^(id success) {
        
        [self.dataSource removeAllObjects];
        
        if ([success[@"event"] isEqualToString:@"SUCCESS"]) {
            NSMutableArray *boyarray= success[@"data"];
            if (![boyarray isEqual:[NSNull null]]) {
                for (NSDictionary *dic in boyarray) {
                    MineCommentModel *model = [MineCommentModel modelWithDictionary:dic];
                    [self.dataSource addObject:model];
                }
            }
            
            if (self.dataSource.count) {
                self.noLabel.text = @"";
            }else{
                self.noLabel.text = @"暂无数据";
                
            }

            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        [Global showWithView:self.view withText:@"网络错误"];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
      return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellId =[NSString stringWithFormat:@"cellTwo%ld%ld",(long)[indexPath section],(long)[indexPath row]];
    PicWithComTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[PicWithComTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    MineCommentModel *model = self.dataSource[indexPath.section];
    NSString * url = [NSString stringWithFormat:@"%@%@", Qiniu_host, model.userModel.head];
    [cell.photoImg sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"defaultPhoto"]];
    NSString *time =  [AppTools secondsToMinutesAndSeconds:[NSString stringWithFormat:@"%ld", model.contentModel.time / 1000]];
    [cell setName:model.userModel.realname detail:model.contentModel.text time:model.time  videoTime:time videoText:model.contentModel.source  arr:model.replyArr judge:YES];
    cell.nameLab.textColor = [UIColor redColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell.playBtn addTarget:self action:@selector(clickPlay:) forControlEvents:UIControlEventTouchUpInside];
    cell.playBtn.tag = 500 + indexPath.section;
    
    return cell;
}
//播放音频
- (void)clickPlay:(UIButton *)button{
    [LGAudioPlayer sharePlayer].delegate = self;
    button.selected = !button.selected;
    MineCommentModel *model = self.dataSource[button.tag- 500];
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
#pragma mark - LGAudioPlayerDelegate
- (void)audioPlayerStateDidChanged:(LGAudioPlayerState)audioPlayerState forIndex:(NSUInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:index];
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


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak MineEvaluateViewController *preferSelf = self;
    PicWithComTableViewCell *sortCell = (PicWithComTableViewCell *)[preferSelf tableView:_tableView cellForRowAtIndexPath:indexPath];
    return sortCell.frame.size.height;
}

//设置区头高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 10;
    }else{
        return 0.001;
    }
}

//设置区尾高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

//区头
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    __strong UIView *view = [UIView new];
    view.backgroundColor = RGBHex(0xf0f0f0);
    
    return view;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    __strong UIView *view = [UIView new];
    view.backgroundColor = RGBHex(0xf0f0f0);
  
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     MineCommentModel *model = self.dataSource[indexPath.section];
    
    MineShadowViewController *mineReadVC = [[MineShadowViewController alloc] init];
    mineReadVC.readId = model.repaeatId;
    mineReadVC.nameStr = model.userModel.nickname;
    mineReadVC.urlStr = MINE_COURSE_Detail;
    mineReadVC.commentUrl = MINE_COURSE_Comment;
    mineReadVC.picRepeatType =  CoRepeatAppreciation;
    //mineReadVC.publishTime = model.dateModel.time;
    mineReadVC.likeUrl = USERCO_LIKE;
    mineReadVC.rewardUrl =  COURSE_RepeatReward;
    mineReadVC.picPushShow = YES;
    [self.navigationController pushViewController:mineReadVC animated:YES];

     
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
