//
//  CourseViewController.h
//  PictureBook
//
//  Created by Yasin on 2017/7/7.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "PBBaseViewController.h"

typedef NS_ENUM(NSInteger,CourseCellType) {
    CourseCellTypeOfNone = 0,
    CourseCellTypeOfAge = 1,
    CourseCellTypeOfHoc = 2
};

@interface CourseViewController : PBBaseViewController

/** 枚举 */
@property (nonatomic,assign) CourseCellType cellType;

@end
