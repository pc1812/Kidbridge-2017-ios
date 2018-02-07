//
//  MineCoPicModel.m
//  Picturebooks
//
//  Created by Yasin on 2017/9/18.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "MineCoPicModel.h"

@implementation MineCoPicModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]){
        self.ID = [[NSString stringWithFormat:@"%@", value] integerValue];
    }
    if ([key isEqualToString:@"fit"]) {
        if ([[NSString stringWithFormat:@"%@", value] integerValue] == 0) {
            self.age = @"3-5岁";
        }
        else if([[NSString stringWithFormat:@"%@", value] integerValue] == 1){
            self.age = @"6-8岁";
        }else{
            self.age = @"9-12岁";
        }
    }
    if ([key isEqualToString:@"repeat"]) {
        self.dateArr = [NSMutableArray array];
        NSMutableArray *boyarray= value;
        if (![boyarray isEqual:[NSNull null]]) {
            for (NSDictionary *dic in boyarray) {
                self.dateModel = [MineCoDateModel modelWithDictionary:dic];
                [self.dateArr addObject:self.dateModel];
            }
        }
    }
    
}

@end
