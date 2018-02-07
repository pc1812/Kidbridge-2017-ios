//
//  ForumDB.h
//  LifeServices
//
//  Created by Snail iOS on 16/4/1.
//  Copyright © 2016年 Snail iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyDBUtil.h"

#import "MinePushModel.h"
#import "MinePuComModel.h"

@interface ForumDB : NSObject

// 保存纪录。评论
+(void)saveSystemInfo:(MinePuComModel *)comModel;
// 保存纪录。推送
+(void)savePushInfo:(MinePushModel *)pushModel;
//取出。评论
+(NSMutableArray *)getselectforum:(NSString *)userStr;

//取出。推送
+(NSMutableArray *)getselectpush:(NSString *)userStr;
//取出。评论
+(NSMutableArray *)getallforum;
//取出。推送
+(NSMutableArray *)getallPush;

//删除评论表
+ (void)deleteCommentTable;
//删除推送表
+ (void)deletePushTable;
@end
