//
//  MineUserModel.h
//  Picturebooks
//
//  Created by Yasin on 2017/8/19.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "YKBaseModel.h"

@interface MineUserModel : YKBaseModel

@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong)NSString *nickname;//昵称
@property (nonatomic, strong)NSString *signature;//签名
@property (nonatomic, strong)NSString *head;//图像
@property (nonatomic, assign) NSInteger teacherId;//老师id
@property (nonatomic, strong)NSString *realname;//姓名
@end
