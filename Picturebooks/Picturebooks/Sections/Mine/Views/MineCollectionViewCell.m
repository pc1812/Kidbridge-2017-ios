//
//  MineCollectionViewCell.m
//  PictureBook
//
//  Created by Yasin on 2017/7/12.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "MineCollectionViewCell.h"

@implementation MineCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.cornerRadius = 5;
        self.contentView.clipsToBounds = YES;
        
        self.picImage = [[UIImageView alloc]init];
        self.picImage.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.width * 3/4);
        //self.picImage.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview: self.picImage];
        
        self.selbtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *img = [UIImage imageNamed:@"m_unsel"];
        self.selbtn.frame = CGRectMake(CGRectGetWidth(self.picImage.frame) - 6 -  img.size.width, CGRectGetMinX(self.picImage.frame) + 6 , img.size.width , img.size.height);
        [self.selbtn setImage:img forState:UIControlStateNormal];
        [self.selbtn setImage:[UIImage imageNamed:@"m_sel"] forState:UIControlStateSelected];
        [self.picImage addSubview:self.selbtn];
        
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.frame = CGRectMake(0, CGRectGetMaxY(self.picImage.frame) + 8, self.contentView.frame.size.width, 20);
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_nameLabel];
        
        _tagLabel = [[UILabel alloc]init];
        _tagLabel.textColor = [UIColor whiteColor];
        _tagLabel.backgroundColor = RGBHex(0x8fe69c);
        _tagLabel.font = [UIFont systemFontOfSize:12];
        _tagLabel.textAlignment = NSTextAlignmentCenter;
        _tagLabel.frame = FRAMEMAKE_F(8, CGRectGetMaxY(_nameLabel.frame) + 5, 32, 15);
        [self.contentView addSubview:_tagLabel];
        
        _ageLabel = [[UILabel alloc]init];
        _ageLabel.textColor = RGBHex(0x8fe69c);
        _ageLabel.font = [UIFont systemFontOfSize:12];
        _ageLabel.frame = FRAMEMAKE_F(0, CGRectGetMinY(_tagLabel.frame), self.contentView.frame.size.width, 20);
        _ageLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_ageLabel];
        
        _freeLabel = [[UILabel alloc]init];
        _freeLabel.textColor = RGBHex(0x8fe69c);
        _freeLabel.font = [UIFont systemFontOfSize:12];
        _freeLabel.frame = FRAMEMAKE_F(self.contentView.frame.size.width - 10 - 40, CGRectGetMinY(_tagLabel.frame), 40, 20);
        _freeLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_freeLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    
    self.selbtn.selected = selected ? YES : NO;
    //_label.textColor = selected ? [UIColor whiteColor] : [UIColor blackColor];
}

@end
