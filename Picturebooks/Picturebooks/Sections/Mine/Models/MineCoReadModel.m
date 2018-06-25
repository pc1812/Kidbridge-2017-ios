//
//  MineCoReadModel.m
//  Picturebooks
//
//  Created by Yasin on 2017/9/18.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "MineCoReadModel.h"

@implementation MineCoReadModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
     if ([key isEqualToString:@"userCourse"]) {
         self.readId = [[NSString stringWithFormat:@"%@", value[@"id"]] integerValue];
        if (!self.coModel) {
            self.coModel = [CourseModel modelWithDictionary:value[@"course"]];
        }
    }
}

@end
