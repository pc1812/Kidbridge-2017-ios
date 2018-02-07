//
//  MineCoPicModel.h
//  Picturebooks
//
//  Created by Yasin on 2017/9/18.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "YKBaseModel.h"
#import "MineCoDateModel.h"
@interface MineCoPicModel : YKBaseModel
@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, copy) NSString *name;//名字
@property (nonatomic, copy) NSString *age;//年龄
@property (nonatomic, copy) NSArray *icon;//图片
@property (nonatomic, strong) NSArray *tag;//标签
@property (nonatomic, strong)NSMutableArray *dateArr;
@property (nonatomic, strong) MineCoDateModel *dateModel;
@end
