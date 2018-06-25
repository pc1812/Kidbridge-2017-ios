//
//  lllUserInfor.h
//  SYRINX_iOS
//
//  Created by SPS on 17/4/17.
//  Copyright © 2017年 SPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLLUserMessage.h"

@interface lllUserInfor : NSObject

+ (LLLUserMessage *)getUserInfo;

+ (void)saveUserMessage:(NSDictionary *)userMessage;//保存用户信息

+ (void)removeUserMessage;//删除用户信息


@end
