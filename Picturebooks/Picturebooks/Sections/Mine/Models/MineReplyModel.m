//
//  MineReplyModel.m
//  Picturebooks
//
//  Created by Yasin on 2017/8/19.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "MineReplyModel.h"

@implementation MineReplyModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]){
        self.commentId = [[NSString stringWithFormat:@"%@", value] integerValue];
    }
    if ([key isEqualToString:@"createTime"]) {
        self.time = [AppTools timestampToTime:value format:@"yyyy-MM-dd"];
    }
    if ([key isEqualToString:@"content"]) {
        if (!self.contentModel) {
            self.contentModel = [MineContentModel modelWithDictionary:value];
        }
    }
    if ([key isEqualToString:@"user"]) {
        if (!self.userModel) {
            self.userModel = [MineUserModel modelWithDictionary:value];
        }
    }
}

@end
