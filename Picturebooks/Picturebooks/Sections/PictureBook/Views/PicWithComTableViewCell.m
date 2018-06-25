//
//  PicWithComTableViewCell.m
//  PictureBook
//
//  Created by Yasin on 2017/7/17.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "PicWithComTableViewCell.h"
#import "PicReplyTableViewCell.h"
#import "MineReplyModel.h"
#import "UITableView+HYBCacheHeight.h"
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"
@interface PicWithComTableViewCell () <UITableViewDataSource, UITableViewDelegate,LGAudioPlayerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSIndexPath *indexPath;
@property (nonatomic) CGFloat heightss;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat height1;
@property (nonatomic) CGFloat height2;
@property (nonatomic) BOOL isTeacher;
@end

@implementation PicWithComTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CellLabelAlloc_K(_nameLab);
        CellLabelAlloc_K(_detailLab);
        CellLabelAlloc_K(_timeLab);
        CellImage_K(_photoImg);
        
        self.viewOne = [UIView new];
        [self addSubview:self.viewOne];
        
        self.playBtn = [UIButton new];
        [self.viewOne addSubview:self.playBtn];
        self.timeLabOne = [UILabel new];
        [self.viewOne addSubview:self.timeLabOne];
        [LGAudioPlayer sharePlayer].delegate = self;
       
        self.tableView = [[UITableView alloc] init];
        self.tableView.scrollEnabled = NO;
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        
        self.tableView.estimatedRowHeight = 0;
        if (@available(iOS 11.0, *)) {
            self.tableView.estimatedSectionFooterHeight = 0;
            self.tableView.estimatedSectionHeaderHeight = 0;
        }
        
        [self.contentView addSubview:self.tableView];
       
    }
    return self;
}


/** 封装详情 Label一个方法:根据文本自动计算高度 */
- (void)setUpdetailLab:(NSString *)detail
{
    _detailLab.text = detail;
    _detailLab.textColor = RGBHex(0x999999);
    _detailLab.numberOfLines = 0;
    _detailLab.font = [UIFont systemFontOfSize:12];
    CGSize receSize = [_detailLab boundingRectWithSize:CGSizeMake(SCREEN_WIDTH- CGRectGetMaxX(_photoImg.frame) - 20, MAXFLOAT)];
    _detailLab.frame = FRAMEMAKE_F( CGRectGetMinX( _nameLab.frame),CGRectGetMaxY(_nameLab.frame) + 5, receSize.width, receSize.height);
}


- (void)setName:(NSString *)name detail:(NSString *)detail time:(NSString *)time videoTime:(NSString *)video videoText:(NSString *)text arr:(NSArray *)arr judge:(BOOL) isBool{
   
    self.isTeacher = isBool;
    _commentArr = arr;
    
    [self.tableView reloadData];
    CGRect frame = [self frame];
    _photoImg.frame = FRAMEMAKE_F(10, 10, 45, 45);
    _photoImg.aliCornerRadius = 45/ 2;

#pragma mark - Jxd-修改
    NSString *nameStr = nil;
    if ([Global isNullOrEmpty:name]) {
        nameStr = @"匿名用户";
    } else {
        nameStr = name;
    }
    _nameLab.text = nameStr;
    
//    _nameLab.text = name;
    _nameLab.textColor = [UIColor blackColor];
    _nameLab.font = [UIFont systemFontOfSize:15 weight:2];
    NSDictionary *conDic = StringFont_DicK(_nameLab.font);
    CGSize conSize = [_nameLab.text sizeWithAttributes:conDic];
//    _nameLab.frame = FRAMEMAKE_F(CGRectGetMaxX(_photoImg.frame) + 12, CGRectGetMinY(_photoImg.frame), conSize.width, conSize.height);
    _nameLab.frame = FRAMEMAKE_F(CGRectGetMaxX(_photoImg.frame) + 12, CGRectGetMinY(_photoImg.frame), SCREEN_WIDTH * 0.55, conSize.height);
    
    LabelSet(_timeLab, time,  RGBHex(0x999999), 12, timeDic, timeSize);
    _timeLab.frame = FRAMEMAKE_F(SCREEN_WIDTH - 10 - timeSize.width, CGRectGetMinY(_nameLab.frame), timeSize.width, timeSize.height);
    
    
    if ([Global isNullOrEmpty:detail]) {
        
        self.viewOne.frame = FRAMEMAKE_F(CGRectGetMaxX(_photoImg.frame) + 12, CGRectGetMaxY( _nameLab.frame) + 5, 90, 30);
        self.viewOne.layer.cornerRadius = 10;
        self.viewOne.clipsToBounds = YES;
        self.viewOne.backgroundColor = [Global convertHexToRGB:@"14d02f"];
        
        UIImage *image = [UIImage imageNamed:@"c_pause"];
        
        self.playBtn.frame = CGRectMake(0, 0 , 40 , 30);
        
        [self.playBtn setImage:image forState:UIControlStateNormal];
        [self.playBtn setImage:[UIImage imageNamed:@"c_play"] forState:UIControlStateSelected];
        
        self.playBtn.userInteractionEnabled = YES;
        LabelSet(self.timeLabOne, video, [UIColor whiteColor], 12, timeDics, timeSizes);
        self.timeLabOne.frame = FRAMEMAKE_F(90 - timeSizes.width - 10, (CGRectGetHeight(self.viewOne.frame) - timeSizes.height) / 2, timeSizes.width, timeSizes.height);
        
        // Jxd-start-----------------------------
#pragma mark - Jxd-添加逻辑,没有文本评价
        self.detailLab.frame = CGRectZero;
        // Jxd-end-------------------------------

    }else if([Global isNullOrEmpty:text]){
        
        // Jxd-start---------------------------------
#pragma mark - Jxd-修改->根据文本动态计算高度
        [self setUpdetailLab:detail];
        // 没有语音评价,设置 Frame 为CGRectZero
        self.viewOne.frame = CGRectZero;
        // Jxd-end---------------------------------
        
    } else {
        
        // Jxd-start---------------------------------
#pragma mark - Jxd-修改->根据文本动态计算高度
        [self setUpdetailLab:detail];
        // Jxd-end---------------------------------
        
        self.viewOne.frame = FRAMEMAKE_F(CGRectGetMaxX(_photoImg.frame) + 12, CGRectGetMaxY(_detailLab.frame) + 5, 90, 30);
        self.viewOne.layer.cornerRadius = 10;
        self.viewOne.clipsToBounds = YES;
        self.viewOne.backgroundColor = [Global convertHexToRGB:@"14d02f"];
        
        UIImage *image = [UIImage imageNamed:@"c_pause"];
        
//        self.playBtn.frame = CGRectMake(10, (CGRectGetHeight( self.viewOne.frame) - image.size.height) / 2 , image.size.width + 10 , image.size.height);
        
        self.playBtn.frame = CGRectMake(0, 0, 40, 30);
        [self.playBtn setImage:image forState:UIControlStateNormal];
        [self.playBtn setImage:[UIImage imageNamed:@"c_play"] forState:UIControlStateSelected];
        
        self.playBtn.userInteractionEnabled = YES;
        LabelSet(self.timeLabOne, video, [UIColor whiteColor], 12, timeDics, timeSizes);
        self.timeLabOne.frame = FRAMEMAKE_F(90 - timeSizes.width - 10, (CGRectGetHeight(self.viewOne.frame) - timeSizes.height) / 2, timeSizes.width, timeSizes.height);
    }
    
    CGFloat h1 = 0.00;
    CGFloat h2 = 0.00;
    CGFloat h3 = 0.00;
    for (MineReplyModel *model in self.commentArr) {
        if ([model.contentModel.text isEqualToString:@""]) {
            h1 += _height;
        }else if ([model.contentModel.source isEqualToString:@""]){
             h2 += _height1;
        }else{
             h3 += _height2;
        }
    }

    if ([Global isNullOrEmpty:detail]) {
      
         self.tableView.frame = FRAMEMAKE_F(67, CGRectGetMaxY( self.viewOne.frame) + 5, SCREEN_WIDTH - 77, h1 + h2 + h3);
         frame.size.height = CGRectGetMaxY(self.viewOne.frame) + 5 + CGRectGetHeight(self.tableView.frame) + 5;
        
    }else  if ( [Global isNullOrEmpty:text]) {
        self.tableView.frame = FRAMEMAKE_F(67,  CGRectGetMaxY(_detailLab.frame) + 5, SCREEN_WIDTH - 77,   h1 + h2 + h3);
        frame.size.height = CGRectGetMaxY(_detailLab.frame) + 5 + CGRectGetHeight(self.tableView.frame) + 5;
    
    }else{
        
        self.tableView.frame = FRAMEMAKE_F(67, CGRectGetMaxY(self.viewOne.frame) + 5, SCREEN_WIDTH - 77,   h1 + h2 + h3);
         frame.size.height = CGRectGetMaxY(self.viewOne.frame) + 5 +CGRectGetHeight(self.tableView.frame) + 5;
    }
    
//      self.hyb_lastViewInCell = self.tableView;
//    
//    
//    CGFloat tableViewHeight = 0;
//    for (MineReplyModel *model in self.commentArr) {
//        CGFloat cellHeight = [PicReplyTableViewCell hyb_heightForTableView:self.tableView config:^(UITableViewCell *sourceCell) {
//            PicReplyTableViewCell *cell = (PicReplyTableViewCell *)sourceCell;
//            [cell setName:model.userModel.nickname detail:model.contentModel.text videoTime:time videoText:model.contentModel.source judge:model.userModel.teacherId];
//        } cache:^NSDictionary *{
//            return @{kHYBCacheUniqueKey : [NSString stringWithFormat:@"%ld", model.commentId],
//                     kHYBCacheStateKey : @"",
//                     kHYBRecalculateForStateKey : @(YES)};
//        }];
//        tableViewHeight += cellHeight;
//    }
    
    self.frame = frame;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellId =[NSString stringWithFormat:@"cellTwo%ld%ld",(long)[indexPath section],(long)[indexPath row]];
    //static NSString *cellId = @"cellID";
    PicReplyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];

    if (!cell) {
        
        cell = [[PicReplyTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    
    MineReplyModel *model = self.commentArr[indexPath.row];
     NSString *time =  [AppTools secondsToMinutesAndSeconds:[NSString stringWithFormat:@"%ld", model.contentModel.time / 1000]];
    if (_isTeacher) {
        NSString *nickName;
        if (model.userModel.teacherId == -1) {
            nickName = model.userModel.nickname;
        }else{
            nickName = model.userModel.realname;
        }
        [cell setName:nickName detail:model.contentModel.text videoTime:time videoText:model.contentModel.source judge:model.userModel.teacherId];

    }else{
        [cell setName:model.userModel.nickname detail:model.contentModel.text videoTime:time videoText:model.contentModel.source judge:-1];
    }
    
    [cell.playBtn addTarget:self action:@selector(clickPlay:) forControlEvents:UIControlEventTouchUpInside];
    cell.playBtn.tag = 600 + indexPath.row;
  
    if ([model.contentModel.text isEqualToString:@""]) {
        _height = cell.frame.size.height;
    }else if ([model.contentModel.source isEqualToString:@""]){
        _height1 = cell.frame.size.height;
    }else{
        _height2 = cell.frame.size.height;
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

//播放音频
- (void)clickPlay:(UIButton *)button{
     [LGAudioPlayer sharePlayer].delegate = self;
    button.selected = !button.selected;
    MineReplyModel *model = self.commentArr[button.tag - 600];
    if ([HttpManager isSavedFileToLocalWithFileName:[NSString stringWithFormat:@"%@.mp3", model.contentModel.source]]) {
        [[LGAudioPlayer sharePlayer] playAudioWithURLString:[SoundFilesCaches stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", model.contentModel.source]] atIndex:button.tag- 600];
    }else if ([HttpManager isSavedFileToLocalWithFileName:[NSString stringWithFormat:@"%@.amr", model.contentModel.source]]){
        [[LGAudioPlayer sharePlayer] playAudioWithURLString:[SoundFilesCaches stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.amr", model.contentModel.source]] atIndex:button.tag- 600];
    }else{
        [[HttpManager sharedManager] downLoad: model.contentModel.source success:^(id success) {
            [[LGAudioPlayer sharePlayer] playAudioWithURLString:[NSString stringWithFormat:@"%@", success] atIndex:button.tag- 600];
        } failure:^(NSError *error) {
            
        }];
    }
}

//#pragma mark - LGAudioPlayerDelegate
- (void)audioPlayerStateDidChanged:(LGAudioPlayerState)audioPlayerState forIndex:(NSUInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    PicReplyTableViewCell *cell = (PicReplyTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _commentArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    PicReplyTableViewCell *sortCell = (PicReplyTableViewCell *)[self tableView:_tableView cellForRowAtIndexPath:indexPath];
   

    return sortCell.frame.size.height;
}

@end
