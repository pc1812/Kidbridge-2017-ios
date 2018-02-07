//
//  PicDetailModel.m
//  Picturebooks
//
//  Created by Yasin on 2017/8/11.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "PicDetailModel.h"

@implementation PicDetailModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]){
        self.ID = [[NSString stringWithFormat:@"%@", value] integerValue];
    }
    if ([key isEqualToString:@"copyright"]){
        self.rewardStr = [NSString stringWithFormat:@"%@", value[@"user"][@"id"]];
    }

}

@end
