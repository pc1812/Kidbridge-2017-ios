//
//  InfoPushViewCell.m
//  PictureBook
//
//  Created by Yasin on 2017/7/15.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "InfoPushViewCell.h"

@implementation InfoPushViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = RGBHex(0xf0f0f0);
        
        CellImage_K(_photoImg);
//        CellLabelAlloc_K(_detailLab);
        _detailLab = [EdgeLabel new];
        [self addSubview:_detailLab];
    }
    return self;
}

-(void)setDetail:(NSString *)detail{
    CGRect frame = [self frame];
    _photoImg.frame = FRAMEMAKE_F(10, 5, 45, 45);
    _photoImg.aliCornerRadius = 45/ 2;
    
    _detailLab.text = detail;
    _detailLab.textColor = [UIColor blackColor];
    _detailLab.numberOfLines = 0;
    _detailLab.font = [UIFont systemFontOfSize:13];
    _detailLab.backgroundColor = [UIColor whiteColor];
    CGSize receSize = [_detailLab boundingRectWithSize:CGSizeMake(SCREEN_WIDTH- CGRectGetMaxX(_photoImg.frame) - 90, 0)];
    
//    _detailLab.frame = FRAMEMAKE_F(CGRectGetMaxX(_photoImg.frame) + 12,CGRectGetMinY(_photoImg.frame), receSize.width + 40, receSize.height + 25);
    _detailLab.frame = FRAMEMAKE_F(CGRectGetMaxX(_photoImg.frame) + 12,CGRectGetMinY(_photoImg.frame), receSize.width + 40, receSize.height + 10);
    
    _detailLab.layer.cornerRadius = 8;
    _detailLab.clipsToBounds = YES;
    _detailLab.contentInset = UIEdgeInsetsMake(0, 10, 0, 10);
    
    //    frame.size.height =  receSize.height + 18 + 25;
    CGFloat cell_height = receSize.height + 5 + 15;
    if (cell_height < CGRectGetMaxY(_photoImg.frame)) {
        cell_height = CGRectGetMaxY(_photoImg.frame) + 5;
    }
    
    frame.size.height =  cell_height;
    
    
    self.frame = frame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
