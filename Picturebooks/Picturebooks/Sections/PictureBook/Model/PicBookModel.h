//
//  PicBookModel.h
//  Picturebooks
//
//  Created by Yasin on 2017/8/14.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "YKBaseModel.h"

@interface PicBookModel : YKBaseModel

@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, copy) NSString *name;//姓名
@property (nonatomic, copy) NSString *age;//年龄
@property (nonatomic, copy) NSString *icon;//图片
@property (nonatomic, strong) NSArray *tag;//标签

@end
