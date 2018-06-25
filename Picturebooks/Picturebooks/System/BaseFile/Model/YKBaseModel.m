//
//  YKBaseModel.m
//  AutocCarApp
//
//  Created by dllo on 15/11/17.
//  Copyright © 2015年 尹凯. All rights reserved.
//

#import "YKBaseModel.h"

@implementation YKBaseModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary{
    return [[self alloc] initWithDictionary:dictionary];
}

@end
