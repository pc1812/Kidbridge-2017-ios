//
//  AddressViewCell.m
//  Picturebooks
//
//  Created by Yasin on 2017/8/3.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "AddressViewCell.h"

@implementation AddressViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _nameLab = [[UILabel alloc] init];
        [self.contentView addSubview:self.nameLab];
        _nameLab.textColor = [UIColor blackColor];
        _nameLab.font = [UIFont systemFontOfSize:14 weight:2];
        
        [_nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView.mas_left).offset(10);
            make.top.mas_equalTo(self.contentView.mas_top).offset(15);
        }];
        
        _textField = [[UITextField alloc] init];
        [self.contentView addSubview:self.textField];
        _textField.backgroundColor =[UIColor clearColor];
        _textField.textColor = [UIColor blackColor];
        _textField.font = [UIFont systemFontOfSize:15];
        [_textField setValue:RGBHex(0x999999) forKeyPath:@"_placeholderLabel.textColor"];
        [_textField setValue:[UIFont boldSystemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
        _textField.tintColor = [UIColor blackColor];
      
        [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView.mas_left).offset(10);
            make.top.mas_equalTo(self.nameLab.mas_bottom).offset(12);
        }];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
