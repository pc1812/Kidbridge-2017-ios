//
//  MineReplyModel.h
//  Picturebooks
//
//  Created by Yasin on 2017/8/19.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "YKBaseModel.h"
#import "MineUserModel.h"
#import "MineContentModel.h"

@interface MineReplyModel : YKBaseModel

@property (nonatomic, assign) NSInteger commentId;
@property (nonatomic, strong)NSString *time;
@property (nonatomic, strong) MineContentModel *contentModel;
@property (nonatomic, strong) MineUserModel *userModel;

@end
