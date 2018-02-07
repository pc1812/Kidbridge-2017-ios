//
//  Segment.m
//  FirstPage
//
//  Created by 尹凯 on 2017/8/14.
//  Copyright © 2017年 尹凯. All rights reserved.
//

#import "Segment.h"

@implementation Segment

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"id"]) {
        self.ID = [[NSString stringWithFormat:@"%@", value] integerValue];
    }
}

@end
