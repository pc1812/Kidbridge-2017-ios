//
//  MineCoPicReModel.m
//  Picturebooks
//
//  Created by Yasin on 2017/9/18.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "MineCoPicReModel.h"

@implementation MineCoPicReModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]){
        self.readId = [[NSString stringWithFormat:@"%@", value] integerValue];
    }
    if ([key isEqualToString:@"createTime"]) {
        self.time = [AppTools timestampToTime:value format:@"yyyy-MM-dd"];
    }

    if ([key isEqualToString:@"userCourse"]) {
        if (!self.picModel) {
            self.picModel = [PictureModel modelWithDictionary:value[@"course"]];
        }
    }
    if ([key isEqualToString:@"userCourse"]) {
        if (!self.userModel) {
            self.userModel = [MineUserModel modelWithDictionary:value[@"user"]];
        }
    }
}

@end
