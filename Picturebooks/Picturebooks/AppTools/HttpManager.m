//
//  HttpManager.h
//
//  Created by zcx on 15/3/11.
//  Copyright (c) 2015年 Caixi.Zheng. All rights reserved.
//

#import "HttpManager.h"
#import <CommonCrypto/CommonCrypto.h>

//#define DEV // 开发环境
#define TEST // 测试部测试环境
//#define RELEASE // 上架生产环境

// 开发环境
#ifdef DEV 
#define language = "English"
#define URL_API_DOMAIN @"http://52.53.124.16"
#endif

// 测试部测试环境 http://15y2926z54.imwork.net/zhefei-app-web
#ifdef TEST
#define language = "英文"
#define URL_API_DOMAIN @"http://api.kidbridge.org"
#endif

// 上架生产环境
#ifdef RELEASE
#define URL_API_DOMAIN @"http://www.srltsy.com/litong"
#endif

#define kIsNull(x) (!x || [x isKindOfClass:[NSNull class]])
#define kRequstUrl(url) [NSString stringWithFormat:@"%@%@",URL_API_DOMAIN,url]
#define kBlockSafeRun(block, ...) block ? block(__VA_ARGS__) : nil;

static NSTimeInterval kTimeoutInterval = 5;
@interface HttpManager ()

@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;

@end

@implementation HttpManager

static HttpManager *_instance;
+ (HttpManager *)sharedManager{
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        _instance = [[HttpManager alloc] init];
    });
    return _instance;
}

- (AFHTTPSessionManager *)sessionManager
{
    if (_sessionManager == nil) {
        _sessionManager = [AFHTTPSessionManager manager];
        // 超时时间
        _sessionManager.requestSerializer.timeoutInterval = kTimeoutInterval;
        
        //AFJSONRequestSerializer   AFHTTPResponseSerializer
        _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html",@"text/plain", nil];
        [_sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [_sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [_sessionManager.requestSerializer setValue:@"1.0.0" forHTTPHeaderField:@"version"];
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    }
    return _sessionManager;
}

#pragma mark - GET请求
- (void)GET:(NSString *)URLString
    success:(RequstSuccessBlock)success
    failure:(RequstFailureBlock)failure
{
    [self.sessionManager GET:URLString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString *responseString = [str stringByReplacingOccurrencesOfString:@"  "  withString:@""];
        responseString = [responseString stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        responseString = [responseString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        responseString = [responseString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        
        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

        success(responseDictionary);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

#pragma mark - POST请求
- (void)POST:(NSString *)URLString
      parame:(NSDictionary *)parame
      sucess:(RequstSuccessBlock)success
     failure:(RequstFailureBlock)failure
{
    NSString *path = [URLString hasPrefix:@"http"] ? URLString : kRequstUrl(URLString);
    //设置请求header
    NSMutableDictionary *lastParame = [NSMutableDictionary dictionaryWithDictionary:parame];
    [lastParame removeObjectForKey:@"version"];
    [lastParame removeObjectForKey:@"uri"];
    
    [self.sessionManager.requestSerializer clearCustomHeadr:@"token"];
    if ([[lastParame allKeys] containsObject:@"token"]) {
        [self.sessionManager.requestSerializer setValue:[lastParame objectForKey:@"token"] forHTTPHeaderField:@"token"];
        [lastParame removeObjectForKey:@"token"];
    }
    
    [self.sessionManager.requestSerializer setValue:[lastParame objectForKey:@"sign"] forHTTPHeaderField:@"sign"];
    [lastParame removeObjectForKey:@"sign"];
    
    [self.sessionManager.requestSerializer setValue:[lastParame objectForKey:@"timestamp"] forHTTPHeaderField:@"timestamp"];
    [lastParame removeObjectForKey:@"timestamp"];
    
    [self.sessionManager.requestSerializer setValue:[lastParame objectForKey:@"device"] forHTTPHeaderField:@"device"];
    [lastParame removeObjectForKey:@"device"];
    
    //NSLog(@"-----%@", self.sessionManager.requestSerializer.HTTPRequestHeaders);
    
    
    [self.sessionManager POST:path parameters:lastParame progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString *responseString = [str stringByReplacingOccurrencesOfString:@"  " withString:@""];
        responseString = [responseString stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        responseString = [responseString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        responseString = [responseString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        
        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if ([[responseDictionary objectForKey:@"event"] isEqualToString:@"UNAUTH"]) {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"token"] != NULL) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];
                [[NSUserDefaults standardUserDefaults] synchronize];
               
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userid"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                    
                } seq:0];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"changeRootViewController" object:@"fromUNAUTH"];

            }
        }
        
        if ([[responseDictionary objectForKey:@"event"] isEqualToString:@"AUTH_ABNORMAL"]) {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"token"] != NULL) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userid"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                    
                } seq:0];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"changeRootViewController" object:@"AUTH_ABNORMAL"];

            }
        }

        success(responseDictionary);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

#pragma mark - 返回基本固定参数字典
+ (NSDictionary *)necessaryParameterDictionary{
    //获取当前时间戳
    NSDate *senddate = [NSDate date];
    NSString *timestamp = [NSString stringWithFormat:@"%ld", (long)([senddate timeIntervalSince1970] * 1000)];
    // NOTE: 增加不变部分数据
    NSMutableDictionary *tmpDict = [NSMutableDictionary new];
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    if (token == NULL) {
        token = @"";
    }
    [tmpDict addEntriesFromDictionary:@{@"version":@"1.0.0",
                                        @"token":token,
                                        @"timestamp":timestamp,
                                        @"device":@"ios"
                                        }];
    return tmpDict;
}

#pragma mark - 返回加盐MD5加密后的密码
+ (NSString *)getAddSaltMD5PasswordWithPhone:(NSString *)phone password:(NSString *)password{
    NSString *tempString = [NSString stringWithFormat:@"%@:%@:Picture_B00k", phone, password];
    NSString *passwordMD5 = [[HttpManager sharedManager] md5:tempString];
    return passwordMD5;
}

#pragma mark - 返回加盐MD5加密sign
+ (NSString *)getAddSaltMD5Sign:(NSMutableDictionary *)tmpDict{
    // 去空值
    for (NSString *key in [tmpDict allKeys]) {
        if ([[tmpDict objectForKey:key] isKindOfClass:[NSString class]]) {
            if ([[tmpDict objectForKey:key] isEqualToString:@""]) {
                [tmpDict removeObjectForKey:key];
                NSLog(@"who is your best friend? pizza? hhhhhhh");
            }
        }
    }
    // 排序
    NSArray* sortedKeyArray = [[tmpDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2]; //升序
    }];
    // 字符串拼接
    NSMutableArray *tmpArray = [NSMutableArray new];
    for (NSString* key in sortedKeyArray) {
        NSString *string = [NSString stringWithFormat:@"%@=%@", key, [tmpDict objectForKey:key]];
        [tmpArray addObject:string];
    }
    NSString *tmpString = [[tmpArray componentsJoinedByString:@"&"] stringByAppendingString:@"&salt=Picture_B00k"];
    // MD5加密
    NSString *sign = [[HttpManager sharedManager] md5:tmpString];
    return sign;
}

// NOTE: MD5加密
- (NSString *)md5:(NSString *) input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  [output uppercaseString];
}

#pragma mark - 下载文件请求
- (void)downLoad:(NSString *)URLString success:(RequstSuccessBlock)success failure:(RequstFailureBlock)failure{
    
    NSURL *url = [NSURL URLWithString:[Qiniu_host stringByAppendingString:URLString]];
    
    //NSLog(@"-----url%@", url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    /*
     第一个参数:请求对象
     第二个参数:progress 进度回调 downloadProgress
     第三个参数:destination 回调(目标位置)
     有返回值
     targetPath:临时文件路径
     response:响应头信息
     第四个参数:completionHandler 下载完成之后的回调
     filePath:最终的文件路径
     */
    NSURLSessionDownloadTask *download = [self.sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        //监听下载进度
        //completedUnitCount 已经下载的数据大小
        //totalUnitCount     文件数据的中大小
        //NSLog(@"%f", 1.0 *downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSString *fullPath = [SoundFilesCaches stringByAppendingPathComponent:response.suggestedFilename];
        
//        NSLog(@"targetPath:%@",targetPath);
//        NSLog(@"fullPath:%@",fullPath);
//        NSLog(@"----response%@", response.suggestedFilename);//返回和服务器文件名一样
        
        return [NSURL fileURLWithPath:fullPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        //NSLog(@"------12345%@", filePath);
    
        success([filePath.absoluteString substringFromIndex:7]);
    }];
    //3.执行Task
    [download resume];
}

/**
 *  根据url判断是否已经保存到本地了
 *
 *  @param fileName 文件名
 *
 *  @return YES：本地已经存在，NO：本地不存在
 */
+ (BOOL)isSavedFileToLocalWithFileName:(NSString *)fileName{
    // 判断是否已经下载了
    NSString *path = [SoundFilesCaches stringByAppendingPathComponent:fileName];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if (![filemanager fileExistsAtPath:SoundFilesCaches]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:SoundFilesCaches withIntermediateDirectories:NO attributes:nil error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
    }
    if ([filemanager fileExistsAtPath:path]) {
        return YES;
    }
    return NO;
}

@end
