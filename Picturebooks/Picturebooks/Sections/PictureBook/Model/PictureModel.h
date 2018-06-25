//
//  PictureModel.h
//  Picturebooks
//
//  Created by Yasin on 2017/8/10.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "YKBaseModel.h"

@interface PictureModel : YKBaseModel

@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, assign) NSInteger fit;//年龄段
@property (nonatomic, assign) NSInteger lock;//锁
@property (nonatomic, copy) NSString *name;//名字
@property (nonatomic, copy) NSString *outline;//概要
@property (nonatomic, strong) NSArray *icon;//图片
@property (nonatomic, assign) double price;//价格
@property (nonatomic, strong) NSArray *tag;//标签

@end
