//
//  MinePuComModel.m
//  Picturebooks
//
//  Created by Yasin on 2017/9/30.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "MinePuComModel.h"

@implementation MinePuComModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"comment"]){
        self.type = [[NSString stringWithFormat:@"%@", value[@"type"]] integerValue];
        self.pid = [[NSString stringWithFormat:@"%@", value[@"pid"]] integerValue];
    }
    if ([key isEqualToString:@"message"]) {
        self.createTime = [AppTools timestampToTime:value[@"createTime"] format:@"MM/dd HH:mm"];
         self.text = value[@"text"];
    }
    if ([key isEqualToString:@"user"]) {
        self.head = value[@"head"];
        self.nickname = value[@"nickname"];
    }
    
}

@end
