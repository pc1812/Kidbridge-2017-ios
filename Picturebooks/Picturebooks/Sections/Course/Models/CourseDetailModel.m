//
//  CoureseDetailModel.m
//  Picturebooks
//
//  Created by 尹凯 on 2017/8/24.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "CourseDetailModel.h"

@implementation CourseDetailModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"id"]) {
        self.courseDetailId = [[NSString stringWithFormat:@"%@", value] integerValue];
    }
    if ([key isEqualToString:@"cycle"]) {
        self.cycleDay =  [[NSString stringWithFormat:@"%@", value] integerValue];
    }
    if ([key isEqualToString:@"book"]) {
        self.bookmodel = [BookModel modelWithDictionary:value];
    }
}

@end
