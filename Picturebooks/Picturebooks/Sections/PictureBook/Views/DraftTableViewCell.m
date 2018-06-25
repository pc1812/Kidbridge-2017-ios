//
//  DraftTableViewCell.m
//  Picturebooks
//
//  Created by 尹凯 on 2017/8/19.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "DraftTableViewCell.h"

@implementation DraftTableViewCell

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createSubViews];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellButtonChange:) name:@"cellButtonChange" object:nil];
    }
    return self;
}

- (void)cellButtonChange:(NSNotification *)notification{
    if ([[NSString stringWithFormat:@"%ld", (long)self.pageNum] isEqualToString:[NSString stringWithFormat:@"%ld", (long)[notification.object integerValue]]]) {
        self.playBtn.selected = NO;
    }
}

- (void)createSubViews{
    UIView *tempView = [[UIView alloc] init];
    [self.contentView addSubview:tempView];
    tempView.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    tempView.layer.shadowOpacity = 0.3;//阴影透明度，默认0
    tempView.layer.shadowRadius = 2;//阴影半径，默认3
    tempView.layer.shadowOffset = CGSizeMake(0,2);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
    [tempView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.top.mas_equalTo(12);
        make.width.and.height.mas_equalTo(47);
    }];
    
    //头像的初始化与布局
    self.headImageView = [[UIImageView alloc] init];
    [tempView addSubview:self.headImageView];
    self.headImageView.backgroundColor = [UIColor greenColor];
    self.headImageView.layer.masksToBounds = YES;
    self.headImageView.layer.cornerRadius = 23.5;
    
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.mas_equalTo(0);
        make.width.and.height.mas_equalTo(47);
    }];
    
    //音频草稿栏初始化与布局
    UIView *soundView = [[UIView alloc] init];
    [self.contentView addSubview:soundView];
    soundView.backgroundColor = RGBHex(0x14d02f);
    soundView.layer.masksToBounds = YES;
    soundView.layer.cornerRadius = 10;
    
    [soundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20); // 之前20
        make.width.mas_equalTo(182);
        make.left.equalTo(self.headImageView.mas_right).offset(12);
//        make.top.mas_equalTo(55 / 2);
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    //音频草稿label
    UILabel *draftLabel = [[UILabel alloc] init];
    [soundView addSubview:draftLabel];
    draftLabel.text = @"音频草稿";
    draftLabel.font = [UIFont systemFontOfSize:11];
    draftLabel.textColor = [UIColor whiteColor];
    draftLabel.textAlignment = NSTextAlignmentCenter;
    
    [draftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
//        make.top.mas_equalTo(3);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(soundView);
    }];
    
    //时间label
    self.timeLabel = [[UILabel alloc] init];
    [soundView addSubview:self.timeLabel];
    self.timeLabel.font = [UIFont systemFontOfSize:11];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
//        make.top.mas_equalTo(3);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(soundView);
    }];
    
    //播放按钮初始化与布局
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:self.playBtn];
    [self.playBtn setImage:[UIImage imageNamed:@"repeat_play"] forState:UIControlStateNormal];
    [self.playBtn setImage:[UIImage imageNamed:@"repeat_pause"] forState:UIControlStateSelected];
    self.playBtn.layer.masksToBounds = YES;
    self.playBtn.layer.cornerRadius = 12.5;
    
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(soundView.mas_right).offset(18);
//        make.top.mas_equalTo(25);
        make.height.and.width.mas_equalTo(32); // 之前25
        make.centerY.mas_equalTo(self.contentView);
    }];
    [self.playBtn addTarget:self action:@selector(playAndStop:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *line = [[UIView alloc] init];
    [self.contentView addSubview:line];
    line.backgroundColor = RGBHex(0xf0f0f0);
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(0);
    }];
}

//播放按钮触发方法
- (void)playAndStop:(UIButton *)btn{
    btn.selected = !btn.selected;
    [self.delegate playAudioRequestFrom:self.pageNum];
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
