//
//  MineUserModel.m
//  Picturebooks
//
//  Created by Yasin on 2017/8/19.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "MineUserModel.h"

@implementation MineUserModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]){
        self.userId = [[NSString stringWithFormat:@"%@", value] integerValue];
    }
    if ([key isEqualToString:@"teacher"]){
        self.teacherId = [[NSString stringWithFormat:@"%@", value[@"id"]] integerValue];
         self.realname = value[@"realname"];
    }

}

@end
