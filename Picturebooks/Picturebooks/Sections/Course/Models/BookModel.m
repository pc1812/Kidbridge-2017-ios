//
//  BookModel.m
//  Picturebooks
//
//  Created by 尹凯 on 2017/8/24.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "BookModel.h"

@implementation BookModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"id"]) {
        self.bookId = [[NSString stringWithFormat:@"%@", value] integerValue];
    }
}

@end
