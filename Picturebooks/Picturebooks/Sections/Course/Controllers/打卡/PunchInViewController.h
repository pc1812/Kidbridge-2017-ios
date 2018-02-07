//
//  PunchInViewController.h
//  Picturebooks
//
//  Created by 尹凯 on 2017/8/23.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PunchInViewController : UIViewController

@property (nonatomic, assign)NSInteger courseId;
@property (nonatomic, assign)NSInteger belong;
@property (nonatomic, assign)NSInteger status;
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *rewardStr;
@property (nonatomic, assign)BOOL hideBottom;
@end
