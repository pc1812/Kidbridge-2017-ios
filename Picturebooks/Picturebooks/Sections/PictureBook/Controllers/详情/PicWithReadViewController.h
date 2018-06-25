//
//  PicWithReadViewController.h
//  PictureBook
//
//  Created by Yasin on 2017/7/13.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "PBBaseViewController.h"

@interface PicWithReadViewController : PBBaseViewController

@property (nonatomic, assign)NSInteger picId;
@property (nonatomic, strong)NSString *name;
@property (nonatomic, assign)NSInteger belong;
@property (nonatomic, strong)NSString *rewardId;
@property (nonatomic, copy)NSString *rewardUrl;
@property (nonatomic, assign)BOOL isFromPublish;
@property (nonatomic, assign)BOOL isFromCalendar;
@end
