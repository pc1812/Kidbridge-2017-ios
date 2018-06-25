//
//  MineCoDateModel.m
//  Picturebooks
//
//  Created by Yasin on 2017/9/18.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "MineCoDateModel.h"

@implementation MineCoDateModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"id"]){
        self.dateId = [[NSString stringWithFormat:@"%@", value] integerValue];
    }
    if ([key isEqualToString:@"date"]) {
        self.time = [AppTools timestampToTime:value format:@"yyyy-MM-dd"];
    }

}
@end
