//
//  MineWithReModel.m
//  Picturebooks
//
//  Created by Yasin on 2017/8/19.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "MineWithReModel.h"

@implementation MineWithReModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    if ([key isEqualToString:@"id"]){
        self.readId = [[NSString stringWithFormat:@"%@", value] integerValue];
    }
    
    if ([key isEqualToString:@"createTime"]) {
        self.time = [AppTools timestampToTime:value format:@"yyyy-MM-dd"];
    }
    
    if ([key isEqualToString:@"userBook"]) {
        if (!self.picModel) {
            self.picModel = [PictureModel modelWithDictionary:value[@"book"]];
        }
    }
    
    if ([key isEqualToString:@"userBook"]) {
        if (!self.userModel) {
            self.userModel = [MineUserModel modelWithDictionary:value[@"user"]];
        }
    }
}

@end
