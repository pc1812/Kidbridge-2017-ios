//
//  SaveFileTools.m
//  Picturebooks
//
//  Created by 吉晓东 on 2018/3/2.
//  Copyright © 2018年 ZhiyuanNetwork. All rights reserved.
//

#import "SaveFileTools.h"

static SaveFileTools *_instance = nil;
@implementation SaveFileTools
/** 创建单例 */
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (instancetype)defaultTool {
    if (_instance == nil) {
        _instance = [[super alloc] init];
    }
    return _instance;
}

#pragma mark - 将数据保存到 plist 文件
/** 保存数据到 指定的 plist 文件中(对应的 key为: p_key) */
- (void)saveDataWithString:(NSString *)string toPlistName:(NSString *)plistName
{
    // 获取应用程序沙盒的Documents目录
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    // 得到完整的文件路径
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:plistName];
    
    // 保存数据到数组中
    NSMutableArray *arrayM = [NSMutableArray array];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:string forKey:@"p_key"];
    [arrayM addObject:dict];
    
    // 将数组保存到 plist 文件中
    [arrayM writeToFile:plistPath atomically:YES];
}

/** 获取对应 plist 文件中的数据 */
- (void)gotDataWithPlistName:(NSString *)plistName
{
    // 获取应用程序沙盒的Documents目录
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    // 得到完整的文件路径
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:plistName];
    
    // 创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:plistPath]) { // 该文件存在
        
        NSMutableArray *arrayM = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
        
        if (arrayM.count) {
            // 文件中没有数据
            NSLog(@"%@",arrayM);
        } else {
            // 文件中没有数据
            
        }
        
    } else { // 该文件不存在
        NSLog(@"文件不存在");
    }
}

@end



















