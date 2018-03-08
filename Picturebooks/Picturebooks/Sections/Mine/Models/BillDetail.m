//
//  BillDetail.m
//  Picturebooks
//
//  Created by 尹凯 on 2017/8/10.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "BillDetail.h"

@implementation BillDetail

- (void)setValue:(id)value forUndefinedKey:(nonnull NSString *)key{
    if ([key isEqualToString:@"billType"]) {
        if ([[NSString stringWithFormat:@"%@", value] isEqualToString:@"0"]) {
            self.type = @"解锁绘本";
        }else if ([[NSString stringWithFormat:@"%@", value] isEqualToString:@"1"]) {
            self.type = @"解锁课程";
        }else if ([[NSString stringWithFormat:@"%@", value] isEqualToString:@"2"]) {
            self.type = @"H币充值";
        }else if ([[NSString stringWithFormat:@"%@", value] isEqualToString:@"3"]) {
            self.type = @"打赏";
        }else if ([[NSString stringWithFormat:@"%@", value] isEqualToString:@"4"]) {
            self.type = @"被打赏";
        }else if ([[NSString stringWithFormat:@"%@", value] isEqualToString:@"5"]) {
            self.type = @"H币兑换";
        }else if ([[NSString stringWithFormat:@"%@", value] isEqualToString:@"6"]) {
            self.type = @"H币兑换";
        }else if ([[NSString stringWithFormat:@"%@", value] isEqualToString:@"7"]) {
            self.type = @"绘本跟读";
        }else if ([[NSString stringWithFormat:@"%@", value] isEqualToString:@"8"]) {
            self.type = @"课程跟读";
        }else if ([[NSString stringWithFormat:@"%@", value] isEqualToString:@"9"]) {
            self.type = @"系统赠送";
        }else if ([[NSString stringWithFormat:@"%@", value] isEqualToString:@"10"]) {
            self.type = @"系统扣除";
        }else if ([[NSString stringWithFormat:@"%@", value] isEqualToString:@"11"]) {
            self.type = @"H币充值";
        }
    }
    if ([key isEqualToString:@"createTime"]) {
        self.time = [AppTools timestampToTimeChinese:value];
    }
    if ([key isEqualToString:@"fee"]) {
        self.fees = [NSString stringWithFormat:@"%@", value];
    }
}

@end
