//
//  PicReadTopModel.m
//  Picturebooks
//
//  Created by Yasin on 2017/8/21.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "PicReadTopModel.h"

@implementation PicReadTopModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]){
        self.readId = [[NSString stringWithFormat:@"%@", value] integerValue];
    }
    if ([key isEqualToString:@"createTime"]) {
        self.time = [AppTools timestampToTime:value format:@"yyyy/MM/dd HH:mm"];
    }
    if ([key isEqualToString:@"userBook"]) {
        if (!self.userModel) {
            self.userModel = [MineUserModel modelWithDictionary:value[@"user"]];
        }
    }
}

@end
