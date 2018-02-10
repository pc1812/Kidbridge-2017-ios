//
//  InfoCommentViewCell.m
//  PictureBook
//
//  Created by Yasin on 2017/7/15.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "InfoCommentViewCell.h"

@implementation InfoCommentViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CellLabelAlloc_K(_nameLab);
        CellLabelAlloc_K(_detailLab);
        CellLabelAlloc_K(_timeLab);
        CellImage_K(_photoImg);
    }
    return self;
}

-(void)setName:(NSString *)name detail:(NSString *)detail time:(NSString *)time{
    CGRect frame = [self frame];
    _photoImg.frame = FRAMEMAKE_F(10, 10, 45, 45);
    _photoImg.aliCornerRadius = 45/ 2;
    
    _nameLab.text = name;
    _nameLab.textColor = [UIColor blackColor];
    _nameLab.font = [UIFont systemFontOfSize:15 weight:2];
    NSDictionary *conDic = StringFont_DicK(_nameLab.font);
    CGSize conSize = [_nameLab.text sizeWithAttributes:conDic];
    _nameLab.frame = FRAMEMAKE_F(CGRectGetMaxX(_photoImg.frame) + 12, CGRectGetMinY(_photoImg.frame), SCREEN_WIDTH * 0.45, conSize.height);

    _detailLab.text = detail;
    _detailLab.textColor = RGBHex(0x999999);
    _detailLab.numberOfLines = 0;
    _detailLab.font = [UIFont systemFontOfSize:12];
    CGSize receSize = [_detailLab boundingRectWithSize:CGSizeMake(SCREEN_WIDTH- CGRectGetMaxX(_photoImg.frame) - 20, 0)];
    _detailLab.frame = FRAMEMAKE_F( CGRectGetMinX( _nameLab.frame),CGRectGetMaxY(_nameLab.frame) + 8, receSize.width, receSize.height);
    
    LabelSet(_timeLab, time,  RGBHex(0x999999), 12, timeDic, timeSize);
    _timeLab.frame = FRAMEMAKE_F(SCREEN_WIDTH - 10 - timeSize.width, CGRectGetMinY(_nameLab.frame), timeSize.width, timeSize.height);
    frame.size.height = CGRectGetMaxY(_nameLab.frame) + 8 + receSize.height + 15;
    [Global viewFrame:CGRectMake(CGRectGetMaxX(_photoImg.frame),  frame.size.height - 1, SCREEN_WIDTH - CGRectGetWidth(_photoImg.frame) - 20, 1) andBackView:self];
    
    self.frame = frame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
