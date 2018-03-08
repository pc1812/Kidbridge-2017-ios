//
//  CourseModel.m
//  Picturebooks
//
//  Created by Yasin on 2017/8/14.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "CourseModel.h"

@implementation CourseModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]){
        self.ID = [[NSString stringWithFormat:@"%@", value] integerValue];
    }
    if ([key isEqualToString:@"fit"]) {
        if ([[NSString stringWithFormat:@"%@", value] integerValue] == 0) {
            self.age = @"3-5岁";
        } else if([[NSString stringWithFormat:@"%@", value] integerValue] == 1){
            self.age = @"6-8岁";
        } else if([[NSString stringWithFormat:@"%@", value] integerValue] == 3){
            self.age = @"4-7岁";
        } else if([[NSString stringWithFormat:@"%@", value] integerValue] == 4){
            self.age = @"8-10岁";
        }else{
            self.age = @"9-12岁";
        }
        
    }
    if ([key isEqualToString:@"copyright"]){
        self.rewardStr = [NSString stringWithFormat:@"%@", value[@"user"][@"id"]];
    }

}

@end
