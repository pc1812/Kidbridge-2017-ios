//
//  CourseDetailViewController.h
//  Picturebooks
//
//  Created by Yasin on 2017/7/20.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "PBBaseViewController.h"

@interface CourseDetailViewController : PBBaseViewController

@property (nonatomic, assign)NSInteger courseId;
@property (nonatomic, assign)NSInteger status; //0未开课 1正在开课 2已结束
@property (nonatomic, assign)NSInteger full; //1代表报名人数已满
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *rewardStr;
@property (nonatomic, copy)void(^callback)(NSString *value);
@end
