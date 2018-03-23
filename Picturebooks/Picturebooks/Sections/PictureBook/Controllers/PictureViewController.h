//
//  PictureViewController.h
//  PictureBook
//
//  Created by Yasin on 2017/7/7.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "PBBaseViewController.h"

typedef NS_ENUM(NSInteger,PictureCellType) {
    PictureCellTypeOfNone = 0,
    PictureCellTypeOfToday = 1,
    PictureCellTypeOfAge = 2,
    PictureCellTypeOfHoc = 3
};

@interface PictureViewController : PBBaseViewController

/** 枚举 */
@property (nonatomic,assign) PictureCellType cellType;

@end
