//
//  CardViewCell.m
//  Picturebooks
//
//  Created by Yasin on 2017/7/21.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "CardViewCell.h"

@implementation CardViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CellLabelAlloc_K(_nameLab);

        CellImage_K(_photoImg);
        
        self.viewOne = [UIView new];
        [self addSubview:self.viewOne];
        
        self.playBtn = [UIButton new];
        [self addSubview:self.playBtn];
        
        self.infoBtn = [UIButton new];
        [self addSubview:self.infoBtn];
        
        self.timeLab = [UILabel new];
        [self.viewOne addSubview:self.timeLab];
        
        self.videoLab = [UILabel new];
        [self.viewOne addSubview:self.videoLab];
    }
    return self;
}
-(void)setName:(NSString *)name time:(NSString *)time{
    CGRect frame = [self frame];
    _photoImg.frame = FRAMEMAKE_F(10, 20, 45, 45);
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
    [self.playBtn addTarget:self action:@selector(clickPlay:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIImage *infoImg = [UIImage imageNamed:@"m_com"];
    self.infoBtn.frame = CGRectMake(SCREEN_WIDTH - infoImg.size.width - 25, CGRectGetMinY(self.viewOne.frame), infoImg.size.width , infoImg.size.height);
    [self.infoBtn setImage:infoImg forState:UIControlStateNormal];
    
    frame.size.height = 85 ;
    [Global viewFrame:CGRectMake(10, frame.size.height - 1, SCREEN_WIDTH - 20, 1) andBackView:self];
    self.frame = frame;
}

- (void)setVoicePlayState:(LGVoicePlayState)voicePlayState{
    if (_voicePlayState != voicePlayState) {
        _voicePlayState = voicePlayState;
    }

    if (_voicePlayState == LGVoicePlayStatePlaying) {
        self.playBtn.selected = YES;
    }else{
         self.playBtn.selected = NO;
    }
}

- (void)clickPlay:(UIButton *)button{
    button.selected = !button.selected;
    if (_delegate && [_delegate respondsToSelector:@selector(voiceMessageTaped:)]) {
        [self.delegate voiceMessageTaped:self];
    }
}

@end
