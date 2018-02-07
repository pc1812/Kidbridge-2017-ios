//
//  PunchInTableViewCell.h
//  Picturebooks
//
//  Created by 尹凯 on 2017/8/23.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignModel.h"

@interface PunchInTableViewCell : UITableViewCell

@property (nonatomic, strong)SignModel *signmodel;

@property (nonatomic, strong)UIImageView *headImageView;
@property (nonatomic, strong)UILabel *nameLabel;
@property (nonatomic, strong)UILabel *timeLabel;
@property (nonatomic, strong)UILabel *statusLabel;

@end
