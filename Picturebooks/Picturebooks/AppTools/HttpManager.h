//
//  HttpManager.h
//
//  Created by zcx on 15/3/11.
//  Copyright (c) 2015年 Caixi.Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RequstSuccessBlock)(id success);
typedef void (^RequstFailureBlock)(NSError *error);

@interface HttpManager : NSObject

+ (HttpManager *)sharedManager;

/**
 *  GET请求
 *
 *  @param URLString 请求路径
 *  @param success   请求成功回调
 *  @param failure   请求失败回调
 */
- (void)GET:(NSString *)URLString
    success:(RequstSuccessBlock)success
    failure:(RequstFailureBlock)failure;

/**
 *  POST请求
 *
 *  @param URLString 请求路径（拼接在BaseURL后面）
 *  @param parame    请求参数
 *  @param success   请求成功回调
 *  @param failure   请求失败回调
 */
- (void)POST:(NSString *)URLString
      parame:(NSDictionary *)parame
      sucess:(RequstSuccessBlock)success
     failure:(RequstFailureBlock)failure;

/**
 *  返回基本固定参数字典
 *
 *  @return 字典
 */
+ (NSMutableDictionary *)necessaryParameterDictionary;

/**
 *  返回加盐MD5加密后的密码
 *
 *@param phone 手机号
 *@param password 密码
 *@return 字符串
 */
+ (NSString *)getAddSaltMD5PasswordWithPhone:(NSString *)phone password:(NSString *)password;

/**
 *  返回加盐MD5加密sign
 *
 *  @param tmpDict 参数字典
 *  @return sign 字符串
 */
+ (NSString *)getAddSaltMD5Sign:(NSMutableDictionary *)tmpDict;

/**
 *  下载文件
 *
 *  @param URLString 请求路径
 *  @param success 请求成功回调
 *  @param failure 请求失败回调
 */
- (void)downLoad:(NSString *)URLString
         success:(RequstSuccessBlock)success
         failure:(RequstFailureBlock)failure;

/**
 *  根据url判断是否已经保存到本地了
 *
 *  @param fileName 文件的名字
 *
 *  @return YES：本地已经存在，NO：本地不存在
 */
+ (BOOL)isSavedFileToLocalWithFileName:(NSString *)fileName;

@end

