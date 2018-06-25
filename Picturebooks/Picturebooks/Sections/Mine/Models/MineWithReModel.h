//
//  MineWithReModel.h
//  Picturebooks
//
//  Created by Yasin on 2017/8/19.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "YKBaseModel.h"
#import "PictureModel.h"
#import "MineUserModel.h"

@interface MineWithReModel : YKBaseModel

@property (nonatomic, assign) NSInteger readId;
@property (nonatomic, assign) NSInteger like;//赞
@property (nonatomic, strong) NSString *time;//时间
@property (nonatomic, strong) PictureModel *picModel;
@property (nonatomic, strong) MineUserModel *userModel;

// 新增字段
@property (nonatomic, strong) NSMutableDictionary *book;

@end
