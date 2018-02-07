//
//  Medal.m
//  FirstPage
//
//  Created by 尹凯 on 2017/7/17.
//  Copyright © 2017年 尹凯. All rights reserved.
//

#import "Medal.h"

@implementation Medal

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]){
        self.ID = [[NSString stringWithFormat:@"%@", value] integerValue];
    }
    if ([key isEqualToString:@"bonus"]) {
        self.BONUS = [[NSString stringWithFormat:@"%@", value] integerValue];
    }
}

@end
