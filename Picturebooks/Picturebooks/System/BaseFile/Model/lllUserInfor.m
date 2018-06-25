//
//  lllUserInfor.m
//  SYRINX_iOS
//
//  Created by SPS on 17/4/17.
//  Copyright © 2017年 SPS. All rights reserved.
//

#import "lllUserInfor.h"

@implementation lllUserInfor

//文件路径
+ (NSString *)filePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"picUserMessage.plist"];
    return filePath;
}

+ (BOOL)checkFilePathForFile
{
    NSString *filepath = [lllUserInfor filePath];
    NSFileManager *fileManger = [NSFileManager defaultManager];
    if ( [fileManger fileExistsAtPath:filepath] )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

//读取文件
+ (NSMutableDictionary *)getFile
{
    NSString *filepath = [lllUserInfor filePath];
    return [NSMutableDictionary dictionaryWithContentsOfFile:filepath];
}

//把用户信息写入文件
+ (void)save:(NSDictionary *)dictionary
{
    NSString *filepath = [lllUserInfor filePath];
    [dictionary writeToFile:filepath atomically:NO];
}

//保存用户信息
+ (void)saveUserMessage:(NSDictionary *)userMessage
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [userMessage enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if (![obj isEqual:[NSNull null]])
         {
             [dic setObject:obj forKey:key];
         }
     }];
    [lllUserInfor save:dic];
}

+ (LLLUserMessage *)getUserInfo{
    if ([self checkFilePathForFile])
    {
        NSMutableDictionary *dict = (NSMutableDictionary*)[NSDictionary dictionaryWithContentsOfFile:[lllUserInfor filePath]];
        LLLUserMessage *userinfo = [[LLLUserMessage alloc] init];
        userinfo.isBacklist = dict[@"isBacklist"];
        userinfo.addr = dict[@"memberDetailVo"][@"addr"];
        userinfo.areaName = dict[@"memberDetailVo"][@"areaName"];
        userinfo.createTime = dict[@"memberDetailVo"][@"createTime"];
        userinfo.idNo = dict[@"memberDetailVo"][@"idNo"];
        userinfo.name = dict[@"memberDetailVo"][@"name"];
        userinfo.saleLevelCode = dict[@"memberDetailVo"][@"saleLevelCode"];
        userinfo.saleLevelName = dict[@"memberDetailVo"][@"saleLevelName"];
        userinfo.sta = dict[@"memberDetailVo"][@"sta"];
        userinfo.username = dict[@"memberDetailVo"][@"username"];
        userinfo.wx = dict[@"memberDetailVo"][@"wx"];
        
        return userinfo;
    }
    else
    {
        return nil;
    }
}

+ (void)removeUserMessage
{
    if ([self checkFilePathForFile])
    {
        NSFileManager* fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:[lllUserInfor filePath] error:nil];
    }
}

@end
