//
//  CoDiscussViewController.m
//  Picturebooks
//
//  Created by Yasin on 2017/9/1.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "CoDiscussViewController.h"
#import "MineCommentModel.h"
#import "PicWithComTableViewCell.h"
#import "PicCommentViewController.h"

@interface CoDiscussViewController ()<UITableViewDelegate, UITableViewDataSource, LGAudioPlayerDelegate>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *dataSource;
@property (nonatomic, strong)UIView *bottomView;

/** 判断是否有更多的数据 */
@property (nonatomic, assign) BOOL isMorePage;
/** 记录数据的页数 */
@property (nonatomic, assign) NSInteger pageNum;

@end

/** 一次加载分页的数据量 */
static NSInteger limit = 10;

@implementation CoDiscussViewController

-(void)dealloc{
    NSLog(@"讨论界面没有内存泄漏");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 懒加载

-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSource;
}

//懒加载UITableView
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - PBNew64 - 44) style:UITableViewStylePlain];
        
        [self.view addSubview:_tableView];
        
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        
#pragma mark -Jxd 修改--添加上拉刷新功能
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            if (_isMorePage) {
                _pageNum++;
                [self commentData];
            }
            [self.tableView.mj_footer endRefreshing];
        }];
    }
    return _tableView ;
}

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
            make.right.mas_equalTo(_bottomView.mas_right);
            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 44));
        }];
    }
    return _bottomView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"讨论区";

    // 添加 tableView
    [self tableView];
    
    [self.view addSubview:self.bottomView];
    //[LGAudioPlayer sharePlayer].delegate = self;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentData) name:@"codataload" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Jxd-添加更新数据
    [self updataData];

}

#pragma mark - Jxd-添加更新数据
- (void)updataData
{
    self.isMorePage = YES;
    self.pageNum = 0;

    // 请求数据
    [self commentData];
}

//评论
- (void)commentClick:(UIButton *)button{
    PicCommentViewController *commentVC = [[PicCommentViewController alloc] init];
    commentVC.picCommentType = CoCommentAppreciation;
    commentVC.readID = self.picId;
    commentVC.quote = -1;
    [self.navigationController pushViewController:commentVC animated:YES];
}

//加载评论数据
- (void)commentData{
    
    //得到基本固定参数字典，加入调用接口所需参数
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];//kOffset
    [parame setObject:COURSE_DISCUSS forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:@(self.picId) forKey:@"id"];
    
#pragma mark - Jxd- 添加更多数据参数
    [parame setObject:@(self.pageNum * kOffset) forKey:@"offset"];
    [parame setObject:@(kOffset) forKey:@"limit"];
    
    [[HttpManager sharedManager] POST:COURSE_DISCUSS parame:parame sucess:^(id success) {

        if (_pageNum == 0) {
            [self.dataSource removeAllObjects];
        }

        if ([success[@"event"] isEqualToString:@"SUCCESS"]) {
            NSMutableArray *boyarray = success[@"data"][@"comment"];
            
            if (![boyarray isEqual:[NSNull null]]) {
                for (NSDictionary *dic in boyarray) {
                    MineCommentModel *model = [MineCommentModel modelWithDictionary:dic];
                    [self.dataSource addObject:model];
                }
            }
            
            // Jxd-start---------------------------------
#pragma mark - Jxd-添加->上拉刷新功能 MJRefreshStateWillRefresh
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
            // Jxd-end---------------------------------
            
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        [Global showWithView:self.view withText:@"网络错误"];
    }];
}

#pragma mark -UITableView代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellId =[NSString stringWithFormat:@"cellTwo%ld%ld",(long)[indexPath section],(long)[indexPath row]];
    //static NSString *cellId = @"cellID";
    PicWithComTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        
        // Jxd-start--------------------------
#pragma mark - Jxd-修改->处理重用问题
        [cell removeFromSuperview];
        // Jxd-end--------------------------
        
        cell = [[PicWithComTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    MineCommentModel *model = self.dataSource[indexPath.row];
      NSString *time =  [AppTools secondsToMinutesAndSeconds:[NSString stringWithFormat:@"%ld", model.contentModel.time / 1000]];
    [cell setName:model.userModel.nickname detail:model.contentModel.text time:model.time  videoTime:time videoText:model.contentModel.source  arr:model.replyArr judge:NO];
    NSString * url = [NSString stringWithFormat:@"%@%@", Qiniu_host, model.userModel.head];
    [cell.photoImg sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"defaultPhoto"]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.playBtn addTarget:self action:@selector(clickPlay:) forControlEvents:UIControlEventTouchUpInside];
    cell.playBtn.tag = 500 + indexPath.row;
    
    return cell;
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
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.removeFromSuperViewOnHide = YES;
        HUD.labelText = @"缓存中...";
        HUD.backgroundColor = [UIColor clearColor];
        
        [[HttpManager sharedManager] downLoad:model.contentModel.source success:^(id success) {
            [HUD hide:YES];
            [[LGAudioPlayer sharePlayer] playAudioWithURLString:[NSString stringWithFormat:@"%@", success] atIndex:button.tag - 500];
        } failure:^(NSError *error) {
            [Global showWithView:self.view withText:@"网络错误"];
        }];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
      __weak CoDiscussViewController *preferSelf = self;
    PicWithComTableViewCell *sortCell = (PicWithComTableViewCell *)[preferSelf tableView:_tableView cellForRowAtIndexPath:indexPath];
    return sortCell.frame.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.001;
}

//tableview cell点击方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.dataSource.count) {
        MineCommentModel *model = self.dataSource[indexPath.row];
        PicCommentViewController *picCommentVC = [[PicCommentViewController alloc] init];
        picCommentVC.picCommentType = CoCommentAppreciation;
        picCommentVC.readID = self.picId;
        picCommentVC.quote = model.commentId;
        [self.navigationController pushViewController:picCommentVC animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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
