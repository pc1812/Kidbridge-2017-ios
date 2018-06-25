//
//  MineContentModel.m
//  Picturebooks
//
//  Created by Yasin on 2017/8/19.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "MineContentModel.h"

@implementation MineContentModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"audio"]){
        
        self.time = [[NSString stringWithFormat:@"%@", value[@"time"]] integerValue];
        self.source = [NSString stringWithFormat:@"%@", value[@"source"]];
       

    }

}

@end
