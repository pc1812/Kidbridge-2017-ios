//
//  MineShadowViewController.h
//  Picturebooks
//
//  Created by Yasin on 2017/8/19.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "PBBaseViewController.h"
typedef NS_ENUM(NSUInteger, PicRepeatType) {
    PicRepeatAppreciation = 0,/**< 绘本跟读赏析 */
    CoRepeatAppreciation = 1,/**< 课程跟读赏析  */
};

@interface MineShadowViewController : PBBaseViewController

@property (nonatomic, assign)BOOL isFromPublish;
@property (nonatomic, assign)NSInteger readId;
@property (nonatomic, copy)NSString *nameStr;
@property (nonatomic, copy)NSString *urlStr;
@property (nonatomic, copy)NSString *rewardUrl;
@property (nonatomic, copy)NSString *commentUrl;
@property (nonatomic, copy)NSString *likeUrl;
@property (nonatomic, assign)PicRepeatType picRepeatType;
@property (nonatomic, copy)NSString *publishTime;
@property (nonatomic, assign)BOOL picPushShow;

/** 底部按钮标题 */
@property (nonatomic,strong) NSString *bottomTitle;

@end















