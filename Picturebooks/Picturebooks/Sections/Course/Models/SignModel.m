//
//  SingModel.m
//  Picturebooks
//
//  Created by 尹凯 on 2017/8/26.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "SignModel.h"

@implementation SignModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"id"]) {
        self.userID = [[NSString stringWithFormat:@"%@", value] integerValue];
    }
    
    if ([key isEqualToString:@"repeat"]) {
        self.repeatID = [[NSString stringWithFormat:@"%@", value] integerValue];
    }

}

- (void)setCreateTime:(NSString *)createTime{
    if ([createTime integerValue] == -1) {
        _createTime = @"-1";
        return;
    }
    //时间戳转换成date
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:createTime.doubleValue / 1000];
    //设置时间格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    //转换成NSString
    _createTime = [formatter stringFromDate:date];
}

@end
