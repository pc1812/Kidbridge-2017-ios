//
//  PicDetailModel.h
//  Picturebooks
//
//  Created by Yasin on 2017/8/11.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "YKBaseModel.h"

@interface PicDetailModel : YKBaseModel

@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, assign) NSInteger belong; //0未解锁 1已解锁
@property (nonatomic, assign) NSInteger fit;//
@property (nonatomic, copy) NSString *name;//名字
@property (nonatomic, strong) NSArray *icon;//图片
@property (nonatomic, assign) double price;//价格
@property (nonatomic, strong) NSArray *tag;//标签
@property (nonatomic, copy) NSString *outline;//概要
@property (nonatomic, copy) NSString *feeling;//详情
@property (nonatomic, copy) NSString *difficulty;//困难度
@property (nonatomic, copy) NSString *rewardStr;//奖励
@end
