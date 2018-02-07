//
//  PicFreeWithViewController.h
//  PictureBook
//
//  Created by Yasin on 2017/7/17.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "PBBaseViewController.h"

@interface PicFreeWithViewController : PBBaseViewController

@property (nonatomic, assign)NSInteger pictureId;
@property (nonatomic, assign)NSInteger unlockState;
@property (nonatomic, assign)NSInteger userCourseId;
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *token;//绘本跟读token

@end
