//
//  MineAddressCell.m
//  Picturebooks
//
//  Created by jixiaodong on 2017/12/19.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "MineAddressCell.h"

@interface MineAddressCell()
/** 联系人 */
@property (nonatomic,strong) UILabel *nameLab;
/** 手机号 */
@property (nonatomic,strong) UILabel *phoneLab;
/** 收货地址 */
@property (nonatomic,strong) UILabel *detialLab;

@end

@implementation MineAddressCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //  添加子控制器
        [self setUpChildUI];
    }
    return self;
}

- (void)setUpChildUI
{
    UILabel *nameLab = [[UILabel alloc] init];
    self.nameLab = nameLab;
    [self.contentView addSubview:nameLab];
    nameLab.textColor = [UIColor blackColor];
    nameLab.font = [UIFont systemFontOfSize:14];
//    if (self.addressDictM[@"receivingContact"]) {
//        nameLab.text = self.addressDictM[@"receivingContact"];
//    }
    [nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(10);
        make.top.mas_equalTo(self.contentView.mas_top).offset(15);
    }];
    
    UILabel *phoneLab = [[UILabel alloc] init];
    self.phoneLab = phoneLab;
    [self.contentView addSubview:phoneLab];
    phoneLab.textColor = [UIColor blackColor];
    phoneLab.font = [UIFont systemFontOfSize:14];
//    if (self.addressDictM[@"receivingPhone"]) {
//        phoneLab.text = self.addressDictM[@"receivingPhone"];
//    }
    [phoneLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(nameLab.mas_right).offset(30);
        make.top.mas_equalTo(nameLab.mas_top);
    }];
    
    UILabel *detialLab = [[UILabel alloc] init];
    self.detialLab = detialLab;
    [self.contentView addSubview:detialLab];
    //        detialLab.textColor = [Global convertHexToRGB:@"999999"];
    detialLab.textColor = [UIColor blackColor];
    detialLab.font = [UIFont systemFontOfSize:12];
    
//    if (self.addressDictM[@"receivingRegion"] || self.addressDictM[@"receivingStreet"]) {
//        detialLab.text = [NSString stringWithFormat:@"%@%@",self.addressDictM[@"receivingRegion"],self.addressDictM[@"receivingStreet"]];
//    }
    [detialLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(10);
        make.top.mas_equalTo(nameLab.mas_bottom).offset(10);
    }];
    
    [Global viewFrame:CGRectMake(0,  65 - 1, SCREEN_WIDTH, 1) andBackView:self.contentView];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setNameStr:(NSString *)nameStr
{
    _nameStr = nameStr;
    self.nameLab.text = nameStr;
}

- (void)setPhoneStr:(NSString *)phoneStr
{
    _phoneStr = phoneStr;
    self.phoneLab.text = phoneStr;
}

- (void)setDetialStr:(NSString *)detialStr
{
    _detialStr = detialStr;
    self.detialLab.text = detialStr;
}

@end



























