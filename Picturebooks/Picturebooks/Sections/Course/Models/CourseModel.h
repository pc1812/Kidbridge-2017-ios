//
//  CourseModel.h
//  Picturebooks
//
//  Created by Yasin on 2017/8/14.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "YKBaseModel.h"

@interface CourseModel : YKBaseModel

@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, assign) NSInteger lock;//锁
@property (nonatomic, copy) NSString *name;//名字
@property (nonatomic, copy) NSString *age;//年龄
@property (nonatomic, copy) NSString *outline;//概要
@property (nonatomic, strong) NSArray *icon;//图片
@property (nonatomic, strong) NSArray *tag;//标签
@property (nonatomic, assign) double price;//价格
@property (nonatomic, assign) NSInteger enter;//报名人数
@property (nonatomic, assign) NSInteger status;//报名状态
@property (nonatomic, assign) NSInteger cycle;//开课天数
@property (nonatomic, assign) NSInteger limit;//总人数
@property (nonatomic, copy) NSString *rewardStr;

@end
