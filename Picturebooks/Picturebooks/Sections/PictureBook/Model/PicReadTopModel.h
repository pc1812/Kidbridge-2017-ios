//
//  PicReadTopModel.h
//  Picturebooks
//
//  Created by Yasin on 2017/8/21.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "YKBaseModel.h"
#import "MineUserModel.h"

@interface PicReadTopModel : YKBaseModel

@property (nonatomic, assign)NSInteger readId;
@property (nonatomic, assign)NSInteger like;//赞
@property (nonatomic, strong)NSString *time;//时间
@property (nonatomic, strong) MineUserModel *userModel;

@end
