//
//  YKBaseModel.h
//  AutocCarApp
//
//  Created by dllo on 15/11/17.
//  Copyright © 2015年 尹凯. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YKBaseModel : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary;

@end
