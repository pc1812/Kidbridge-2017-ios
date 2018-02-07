//
//  PunchInTableViewCell.m
//  Picturebooks
//
//  Created by 尹凯 on 2017/8/23.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "PunchInTableViewCell.h"

@implementation PunchInTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews{
    UIView *tempView = [[UIView alloc] init];
    [self.contentView addSubview:tempView];
    tempView.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    tempView.layer.shadowOpacity = 0.3;//阴影透明度，默认0
    tempView.layer.shadowRadius = 2;//阴影半径，默认3
    tempView.layer.shadowOffset = CGSizeMake(0,2);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
    [tempView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.mas_equalTo(7.5);
        make.width.and.height.mas_equalTo(45);
    }];
    
    // 用户头像
    self.headImageView = [[UIImageView alloc] init];
    [tempView addSubview:self.headImageView];
    self.headImageView.image = [UIImage imageNamed:@"touxiang.jpg"];
    self.headImageView.layer.masksToBounds = YES;
    self.headImageView.layer.cornerRadius = 22.5;
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.and.height.mas_equalTo(45);
    }];
    
    // 打卡状态
    self.statusLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.statusLabel];
    self.statusLabel.text = @"已打卡";
    self.statusLabel.font = [UIFont systemFontOfSize:14];
    [self.statusLabel sizeToFit];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.centerY.mas_equalTo(self.headImageView.center.y);
    }];
    
    // 时间
    self.timeLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.timeLabel];
    self.timeLabel.text = @"15分钟前";
    self.timeLabel.textColor = [UIColor grayColor];
    self.timeLabel.font = [UIFont systemFontOfSize:11];
    [self.timeLabel sizeToFit];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(SCREEN_WIDTH / 2);
        make.right.mas_equalTo(self.statusLabel.mas_left).offset(-XDWidthRatio(30));
        make.centerY.mas_equalTo(self.headImageView.center.y);
    }];
    
    // 用户名称
    self.nameLabel = [[UILabel alloc] init];
    
    [self.contentView addSubview:self.nameLabel];
    self.nameLabel.text = @"萌小妞";
    self.nameLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.nameLabel sizeToFit];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headImageView.mas_right).offset(10);
        make.centerY.mas_equalTo(self.headImageView.center.y);
        make.width.mas_equalTo(SCREEN_WIDTH * 0.4);
    }];
}

- (void)setSignmodel:(SignModel *)signmodel{
    if (_signmodel != signmodel) {
        _signmodel = signmodel;
    }
    
    NSURL *url = [NSURL URLWithString:[Qiniu_host stringByAppendingString:_signmodel.head]];

    // 头像
    [self.headImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"defaultPhoto"]];
   
    // 昵称
    if ([Global isNullOrEmpty:_signmodel.nickname]) {
        self.nameLabel.text = @"匿名用户";
    } else {
        self.nameLabel.text = _signmodel.nickname;
    }
//    [self.nameLabel sizeToFit];
    
    if ([_signmodel.createTime isEqualToString:@"-1"]) {
        self.timeLabel.text = @"";
        self.statusLabel.text = @"未打卡";
        self.statusLabel.textColor = RGBHex(0xfe6b76);
    }else{
        self.timeLabel.text = signmodel.createTime;
        [self.nameLabel sizeToFit];
        self.statusLabel.text = @"已打卡";
        self.statusLabel.textColor = RGBHex(0x14d02f);
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
