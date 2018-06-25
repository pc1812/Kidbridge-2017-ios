//
//  MineCoPicReModel.h
//  Picturebooks
//
//  Created by Yasin on 2017/9/18.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "YKBaseModel.h"
#import "PictureModel.h"
#import "MineUserModel.h"
@interface MineCoPicReModel : YKBaseModel
@property (nonatomic, assign) NSInteger readId;
@property (nonatomic, assign) NSInteger like;
@property (nonatomic, strong)NSString *time;
@property (nonatomic, strong) PictureModel *picModel;
@property (nonatomic, strong) MineUserModel *userModel;

// 新增字段
@property (nonatomic, strong) NSMutableDictionary *book;
@end
