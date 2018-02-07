//
//  CarouselModel.h
//  Picturebooks
//
//  Created by Yasin on 2017/8/10.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "YKBaseModel.h"

@interface CarouselModel : YKBaseModel

@property (nonatomic, copy) NSString *link;//图片链接
@property (nonatomic, copy) NSString *icon;//图片
@property (nonatomic, assign) NSInteger typeNum;

@end
