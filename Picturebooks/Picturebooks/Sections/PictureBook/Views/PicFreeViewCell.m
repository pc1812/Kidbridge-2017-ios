//
//  PicFreeViewCell.m
//  PictureBook
//
//  Created by Yasin on 2017/7/12.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "PicFreeViewCell.h"

@implementation PicFreeViewCell

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
        CellLabelAlloc_K(_greeLab);
    }
    return self;
}

-(void)setName:(NSString *)name detail:(NSString *)detail{
    CGRect frame = [self frame];
    
    _greeLab.frame = FRAMEMAKE_F(10, 30, 2, 20);
    _greeLab.backgroundColor = RGBHex(0X13D02F);
    
    _nameLab.text = name;
    _nameLab.textColor = [UIColor blackColor];
    _nameLab.font = [UIFont systemFontOfSize:16 weight:2];
    NSDictionary *conDic = StringFont_DicK(_nameLab.font);
    CGSize conSize = [_nameLab.text sizeWithAttributes:conDic];
    _nameLab.frame = FRAMEMAKE_F(CGRectGetMaxX(_greeLab.frame) + 13, CGRectGetMinY(_greeLab.frame), conSize.width, conSize.height);
    
//    _detailLab.text = detail;
//    _detailLab.textColor = [UIColor blackColor];
//    _detailLab.numberOfLines = 0;
//    _detailLab.font = [UIFont systemFontOfSize:14];

    // 详情内容：首行缩进
    _detailLab.numberOfLines = 0;
    
    [self settingLabelTextAttributesWithLineSpacing:3.0 FirstLineHeadIndent:2.0 FontOfSize:14.0 TextColor:[UIColor blackColor] text:detail AddLabel:_detailLab];
    CGSize receSize = [_detailLab boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 15, 0)];
    // 计算文本内容的行数
    CGSize textSize = [_detailLab.text sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]}];
    NSInteger textRow = (receSize.height / textSize.height);

    // 所有的行间距
    NSInteger allSpacingRow = textRow * 3;
    // 三目运算符,根据文本内容计算 Lab 的尺寸
    receSize.width = (receSize.width + 30) > (SCREEN_WIDTH - 20) ? (receSize.width) : (receSize.width + 30);
    _detailLab.frame = FRAMEMAKE_F( 10,CGRectGetMaxY(_nameLab.frame) + 18, receSize.width, receSize.height + allSpacingRow);
    
//    frame.size.height = CGRectGetMaxY(_nameLab.frame) + 18 + receSize.height ;
    frame.size.height = CGRectGetMaxY(_detailLab.frame);
    self.frame = frame;
}

// 设置Label的行间距与首行缩进的方法
- (void)settingLabelTextAttributesWithLineSpacing:(CGFloat)lineSpacing FirstLineHeadIndent:(CGFloat)firstLineHeadIndent FontOfSize:(CGFloat)fontOfSize TextColor:(UIColor *)textColor text:(NSString *)text AddLabel:(UILabel *)label{
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //行间距
    paragraphStyle.lineSpacing = lineSpacing;
    //首行缩进 (缩进个数 * 字号)
    paragraphStyle.firstLineHeadIndent = firstLineHeadIndent * fontOfSize;
    NSDictionary *attributeDic = @{
                                   NSFontAttributeName : [UIFont systemFontOfSize:fontOfSize],
                                   NSParagraphStyleAttributeName : paragraphStyle,
                                   NSForegroundColorAttributeName : textColor
                                   };
    
    label.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributeDic];
}


@end
