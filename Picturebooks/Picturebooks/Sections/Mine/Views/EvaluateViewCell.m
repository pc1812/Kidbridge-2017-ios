//
//  EvaluateViewCell.m
//  Picturebooks
//
//  Created by Yasin on 2017/7/21.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "EvaluateViewCell.h"
#import "PicReplyTableViewCell.h"

@interface EvaluateViewCell ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, copy)NSIndexPath *indexPath;
@property (nonatomic) CGFloat height;

@end

@implementation EvaluateViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CellLabelAlloc_K(_nameLab);
       
        CellImage_K(_photoImg);
        
        self.viewOne = [UIView new];
        [self addSubview:self.viewOne];
        
        self.playBtn = [UIButton new];
        [self addSubview:self.playBtn];
     
        self.timeLab = [UILabel new];
        [self.viewOne addSubview:self.timeLab];
        
        self.videoLab = [UILabel new];
        [self.viewOne addSubview:self.videoLab];
    }
    return self;
}

-(void)setName:(NSString *)name time:(NSString *)time arr:(NSArray *)arr{
    
    _commentArr = arr;
    CGRect frame = [self frame];
    _photoImg.frame = FRAMEMAKE_F(10, 15, 45, 45);
    _photoImg.aliCornerRadius = 45/ 2;
    
    _nameLab.text = name;
    _nameLab.textColor = [UIColor blackColor];
    _nameLab.font = [UIFont systemFontOfSize:15 weight:2];
    NSDictionary *conDic = StringFont_DicK(_nameLab.font);
    CGSize conSize = [_nameLab.text sizeWithAttributes:conDic];
    _nameLab.frame = FRAMEMAKE_F(CGRectGetMaxX(_photoImg.frame) + 12, CGRectGetMinY(_photoImg.frame), conSize.width, conSize.height);
    
    self.viewOne.frame = FRAMEMAKE_F(CGRectGetMaxX(_photoImg.frame) + 12, CGRectGetMaxY(_nameLab.frame) + 10, 180, 20);
    self.viewOne.layer.cornerRadius = 10;
    self.viewOne.clipsToBounds = YES;
    self.viewOne.backgroundColor = [Global convertHexToRGB:@"14d02f"];
    
    LabelSet(self.videoLab, @"音频草稿", [UIColor whiteColor], 12, videoDic, videoSize);
    self.videoLab.frame = FRAMEMAKE_F( 10, (CGRectGetHeight(self.viewOne.frame) - videoSize.height) / 2, videoSize.width, videoSize.height);
    
    LabelSet(self.timeLab, time, [UIColor whiteColor], 12, timeDic, timeSize);
    self.timeLab.frame = FRAMEMAKE_F(180 - timeSize.width - 10, (CGRectGetHeight(self.viewOne.frame) - timeSize.height) / 2, timeSize.width, timeSize.height);
    
    UIImage *image = [UIImage imageNamed:@"m_pause"];
    self.playBtn.frame = CGRectMake(CGRectGetMaxX(self.viewOne.frame) + 21, CGRectGetMaxY(_nameLab.frame) + 5, image.size.width , image.size.height);
    [self.playBtn setImage:image forState:UIControlStateNormal];
    [self.playBtn setImage:[UIImage imageNamed:@"m_play"] forState:UIControlStateSelected];
    self.playBtn.userInteractionEnabled = YES;
   
    self.tableView = [[UITableView alloc] init];
    self.tableView.scrollEnabled = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self addSubview:self.tableView];
    [self.tableView reloadData];
    self.tableView.frame = FRAMEMAKE_F(67, CGRectGetMaxY( self.viewOne.frame) + 10, SCREEN_WIDTH - 77, _height * 3);

    frame.size.height = CGRectGetMaxY(_nameLab.frame) + 10 + 25 +  3 * _height;
    self.frame = frame;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellId =[NSString stringWithFormat:@"cellTwo%ld%ld",(long)[indexPath section],(long)[indexPath row]];
    PicReplyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[PicReplyTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    [cell setName:@"萌萌" detail:_commentArr[indexPath.row] videoTime:@"30''" videoText:@"" judge:NO];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _commentArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PicReplyTableViewCell *sortCell = (PicReplyTableViewCell *)[self tableView:_tableView cellForRowAtIndexPath:indexPath];
    _height = sortCell.frame.size.height;
    return sortCell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_delegate && [_delegate respondsToSelector:@selector(cellClick:)]) {
        [_delegate cellClick:(int)indexPath.row];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
