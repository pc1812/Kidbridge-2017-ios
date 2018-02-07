//
//  PicEnjoyModel.m
//  Picturebooks
//
//  Created by Yasin on 2017/8/21.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "PicEnjoyModel.h"

@implementation PicEnjoyModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"id"]){
        self.readId = [[NSString stringWithFormat:@"%@", value] integerValue];
    }
    
    if ([key isEqualToString:@"copyright"]){
        self.rewardStr = [NSString stringWithFormat:@"%@", value[@"user"][@"id"]];
    }

}

@end
