//
//  MainCollectionViewCell.m
//  PictureBook
//
//  Created by Yasin on 2017/7/7.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "MainCollectionViewCell.h"

@implementation MainCollectionViewCell
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //背影视图，用来设置圆角效果
        UIView *backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self.contentView addSubview:backGroundView];
        backGroundView.backgroundColor = [UIColor whiteColor];
        backGroundView.layer.masksToBounds = YES;
        backGroundView.layer.cornerRadius = 6.0;
        backGroundView.layer.borderWidth = 1.0;
        backGroundView.layer.borderColor = [[UIColor clearColor] CGColor];
        
        //在cell本身添加阴影效果
        self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
        self.contentView.layer.shadowOffset = CGSizeMake(4,4);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
        self.contentView.layer.shadowOpacity = 0.3;//阴影透明度，默认0
        self.contentView.layer.shadowRadius = 3;//阴影半径，默认3

        //主图片
        self.picImage = [[UIImageView alloc]init];
        //self.picImage.contentMode = UIViewContentModeScaleAspectFit;
//        self.picImage.clipsToBounds= YES;//  是否剪切掉超出 UIImageView 范围的图片
//        [self.picImage setContentScaleFactor:[[UIScreen mainScreen] scale]];
        [backGroundView addSubview: self.picImage];
        [self.picImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(self.contentView.frame.size.width);
            make.height.mas_equalTo(self.contentView.frame.size.width * 3/4);//115
        }];
        
        //锁
        self.lockImage = [[UIImageView alloc]init];
        [self.picImage addSubview:self.lockImage];
        self.lockImage.image = [UIImage imageNamed:@"pic_lock"];
        [self.lockImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.size.mas_equalTo(CGSizeMake(self.lockImage.image.size.width, self.lockImage.image.size.height));
        }];

        //绘本名称
        self.nameLabel = [[UILabel alloc]init];
        [backGroundView addSubview:self.nameLabel];
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.font = [UIFont systemFontOfSize:16];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.contentView.frame.size.width);
            make.height.mas_equalTo(20);
            make.top.equalTo(self.picImage.mas_bottom).offset(5);
            make.left.mas_equalTo(0);
        }];
        
        //类别标签
        self.tagLabel = [[UILabel alloc] init];
        [backGroundView addSubview:self.tagLabel];
        self.tagLabel.textColor = [UIColor whiteColor];
        self.tagLabel.backgroundColor = RGBHex(0x8fe69c);
        self.tagLabel.font = [UIFont systemFontOfSize:12];
        self.tagLabel.textAlignment = NSTextAlignmentCenter;
        // 根据字体自动调节尺寸
        [self.tagLabel sizeToFit];
        
        [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.width.mas_equalTo(32);
//            make.height.mas_equalTo(15);
            make.left.mas_equalTo(10);
            make.top.equalTo(self.nameLabel.mas_bottom).offset(5);
        }];
        
        //年龄标签
        self.ageLabel = [[UILabel alloc]init];
        [backGroundView addSubview:self.ageLabel];
        self.ageLabel.textColor = RGBHex(0x8fe69c);
        self.ageLabel.font = [UIFont systemFontOfSize:12];
        self.ageLabel.textAlignment = NSTextAlignmentCenter;
        [self.ageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(15);
            make.top.equalTo(self.nameLabel.mas_bottom).offset(5);
            make.centerX.equalTo(backGroundView.mas_centerX);
        }];

        //免费标签
        self.freeLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.freeLabel];
        self.freeLabel.textColor = RGBHex(0x8fe69c);
        self.freeLabel.font = [UIFont systemFontOfSize:12];
        self.freeLabel.textAlignment = NSTextAlignmentRight;
        [self.freeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(15);
            make.top.equalTo(self.nameLabel.mas_bottom).offset(5);
            make.right.mas_equalTo(-10);
        }];
    }
    return self;
}

@end
