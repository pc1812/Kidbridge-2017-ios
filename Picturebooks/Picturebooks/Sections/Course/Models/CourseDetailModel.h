//
//  CoureseDetailModel.h
//  Picturebooks
//
//  Created by 尹凯 on 2017/8/24.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookModel.h"

@interface CourseDetailModel : YKBaseModel

@property (nonatomic, assign)NSInteger courseDetailId;
@property (nonatomic, strong)BookModel *bookmodel;
@property (nonatomic, assign)NSInteger cycleDay;//周期
@property (nonatomic, strong)NSString *startTime;//开始时间

@end
