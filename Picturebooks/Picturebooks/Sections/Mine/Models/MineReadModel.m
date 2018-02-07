//
//  MineReadModel.m
//  Picturebooks
//
//  Created by Yasin on 2017/8/17.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "MineReadModel.h"

@implementation MineReadModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]){
        self.readId = [[NSString stringWithFormat:@"%@", value] integerValue];
    }
    if ([key isEqualToString:@"userBook"]) {
        if (!self.picModel) {
            self.picModel = [PictureModel modelWithDictionary:value[@"book"]];
        }
    }
}

@end
