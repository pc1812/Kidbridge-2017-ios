//
//  MedalCollectionViewCell.m
//  FirstPage
//
//  Created by 尹凯 on 2017/7/17.
//  Copyright © 2017年 尹凯. All rights reserved.
//

#import "MedalCollectionViewCell.h"

@implementation MedalCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.medalImage = [[UIImageView alloc] init];
        [self.contentView addSubview:self.medalImage];
        self.medalImage.contentMode = UIViewContentModeScaleAspectFit;
        [self.medalImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.contentView.frame.size.width);
            make.height.mas_equalTo(90 * PROPORTION);
            make.left.and.top.mas_equalTo(0);
        }];
        
        self.num = [[UILabel alloc] init];
        [self.contentView addSubview:self.num];
        self.num.textAlignment = NSTextAlignmentCenter;
        self.num.font = [UIFont systemFontOfSize:12];
        [self.num mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(98 * PROPORTION);
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(self.contentView.frame.size.width);
            make.height.mas_equalTo(10 * PROPORTION);
        }];
        
        self.title = [[UILabel alloc] init];
        [self.contentView addSubview:self.title];
        self.title.textAlignment = NSTextAlignmentCenter;
        self.title.font = [UIFont systemFontOfSize:12];
        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(115 * PROPORTION);
            make.left.mas_equalTo(0);
            make.height.mas_equalTo(10 * PROPORTION);
            make.width.mas_equalTo(self.contentView.frame.size.width);
        }];
    }
    return self;
}

- (void)setMedal:(Medal *)medal{
    _medal = medal;
    
    self.title.text = medal.name;
    self.num.text = [NSString stringWithFormat:@"%ld", (long)medal.BONUS];
    NSURL *url = nil;
    if (_active) {
        url = [NSURL URLWithString:[Qiniu_host stringByAppendingString:[medal.icon objectForKey:@"active"]]];
    }else{
        url = [NSURL URLWithString:[Qiniu_host stringByAppendingString:[medal.icon objectForKey:@"quiet"]]];
    }
    [self.medalImage sd_setImageWithURL:url];
}

@end
