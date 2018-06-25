//
//  PictureModel.m
//  Picturebooks
//
//  Created by Yasin on 2017/8/10.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "PictureModel.h"

@implementation PictureModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]){
        self.ID = [[NSString stringWithFormat:@"%@", value] integerValue];
    }
}

@end
