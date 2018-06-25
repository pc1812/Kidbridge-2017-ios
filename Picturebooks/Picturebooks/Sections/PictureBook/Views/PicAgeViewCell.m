//
//  PicAgeViewCell.m
//  Picturebooks
//
//  Created by Yasin on 2017/9/8.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "PicAgeViewCell.h"

@implementation PicAgeViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
       
    }
    return self;
}

-(void)setName:(NSArray *)name detail:(NSArray *)detail{
    CGRect frame = [self frame];
    
    for (int i = 0; i < name.count; i++) {
        UILabel *_greeLab = [UILabel new];
        _greeLab.frame = FRAMEMAKE_F(10, 30, 2, 20);
        _greeLab.backgroundColor = RGBHex(0X13D02F);
        
        UILabel *_nameLab = [UILabel new];
        _nameLab.text = name[i];
        _nameLab.textColor = [UIColor blackColor];
        _nameLab.font = [UIFont systemFontOfSize:16 weight:2];
        NSDictionary *conDic = StringFont_DicK(_nameLab.font);
        CGSize conSize = [_nameLab.text sizeWithAttributes:conDic];
        _nameLab.frame = FRAMEMAKE_F(CGRectGetMaxX(_greeLab.frame) + 13, CGRectGetMinY(_greeLab.frame), conSize.width, conSize.height);
        
        UILabel *_detailLab = [UILabel new];
        _detailLab.text = detail[i];
        _detailLab.textColor = [UIColor blackColor];
        _detailLab.numberOfLines = 0;
        _detailLab.font = [UIFont systemFontOfSize:14];
        CGSize receSize = [_detailLab boundingRectWithSize:CGSizeMake(SCREEN_WIDTH- 20, 0)];
        _detailLab.frame = FRAMEMAKE_F( 10,CGRectGetMaxY(_nameLab.frame) + 18, receSize.width, receSize.height);
        
    }
    
    frame.size.height = 60;
    self.frame = frame;
}

@end
