//
//  MineCommentModel.m
//  Picturebooks
//
//  Created by Yasin on 2017/8/19.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "MineCommentModel.h"

@implementation MineCommentModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]){
        self.commentId = [[NSString stringWithFormat:@"%@", value] integerValue];
    }
    if ([key isEqualToString:@"createTime"]) {
        self.time = [AppTools timestampToTime:value format:@"MM/dd HH:mm"];
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
    
    if ([key isEqualToString:@"userCourseRepeat"]) {
       self.repaeatId = [[NSString stringWithFormat:@"%@", value[@"id"]] integerValue];
    }
    if ([key isEqualToString:@"replyList"]) {
        if (!self.replyModel) {
            self.replyArr = [NSMutableArray array];
             NSMutableArray *boyarray= value;
            if (![boyarray isEqual:[NSNull null]]) {
                for (NSDictionary *dic in boyarray) {
                   self.replyModel = [MineReplyModel modelWithDictionary:dic];
                   [self.replyArr addObject:self.replyModel];
                }
            }
        }
    }
}

@end
