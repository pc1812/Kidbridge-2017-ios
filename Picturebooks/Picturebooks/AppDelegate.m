//
//  AppDelegate.m
//  Picturebooks
//
//  Created by 尹凯 on 2017/7/18.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "IQKeyboardManager.h"
#import "LoginAndRegisterViewController.h"
#import "WelcomeViewController.h"
#import "WXApi.h"
#import "MinePushModel.h"
#import "MinePuComModel.h"
#import "ForumDB.h"
#import <AlipaySDK/AlipaySDK.h>
#import <AdSupport/AdSupport.h>

#import <Bugly/Bugly.h> // 崩溃收集

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#import "JxdAppPurchaseTool.h" // 内购工具类

@interface AppDelegate ()<UIApplicationDelegate, WXApiDelegate,JPUSHRegisterDelegate,UIAlertViewDelegate>

@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [NSThread sleepForTimeInterval:1];
    
    // 配置崩溃收集
    [self configBuglyLog];
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [IQKeyboardManager sharedManager].enable = YES;
    //微信注册
    if ([WXApi registerApp:@"wxb6f923a74661ce3b"]) {
        NSLog(@"微信注册成功");
    }else{
        NSLog(@"微信注册失败");
    }
    
    //激光推送
    [JPUSHService setupWithOption:launchOptions appKey:appKey
                          channel:channel
                 apsForProduction:isProduction
            advertisingIdentifier:nil];
    // 3.0.0及以后版本注册可以这样写，也可以继续用旧的注册方式
    JPUSHRegisterEntity *entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        //    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        //      NSSet<UNNotificationCategory *> *categories;
        //      entity.categories = categories;
        //    }
        //    else {
        //      NSSet<UIUserNotificationCategory *> *categories;
        //      entity.categories = categories;
        //    }
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];

    //更改根视图监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeRootViewController:) name:@"changeRootViewController" object:nil];
    
    //判断是否为新用户，新用户先走欢迎页
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"notFirst"]) {
        WelcomeViewController *welcomeVC = [[WelcomeViewController alloc] init];
        UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:welcomeVC];
        navC.navigationBarHidden = YES;
        
        self.window.rootViewController = navC;
    }else{
        //判断是否登录过，没登录过就展示登录页
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"token"]) {
            LoginAndRegisterViewController *loginAndRegisterVC = [[LoginAndRegisterViewController alloc] init];
            UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:loginAndRegisterVC];
            navC.navigationBarHidden = YES;
            
            self.window.rootViewController = navC;
        }else{
            RootViewController *viewController = [[RootViewController alloc] init];
            self.window.rootViewController = viewController;
        }
    }
    
    if ([AppTools isWiFiEnabled]) {
        NSLog(@"wifi");
    }else{
        NSLog(@"notwifi");
    }
    
    // 检测 APP 版本号
    [self updateAppVersion];
    
    // 验证内购凭据对单处理
    [[JxdAppPurchaseTool defaultTool] verifyPruchase];
    
    return YES;
}

//激光推送获取消息
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    
    NSDictionary * userInfo = [notification userInfo];
    NSString *content = [userInfo valueForKey:@"content"];
    NSDictionary *extras = [userInfo valueForKey:@"extras"];
    NSString *customizeField1 = [extras valueForKey:@"customizeField1"]; //服务端传递的Extras附加字段，key是自己定义的
    
    // info 用于我的界面中"小铃铛"添加未读小红点
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"info"];
    [[NSUserDefaults standardUserDefaults] synchronize];
  
    NSData *data = [ [self logCustomDic:content] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    if ([responseDictionary[@"type"] integerValue] == 0) {
        //评论消息
        MinePuComModel *model = [MinePuComModel modelWithDictionary:responseDictionary[@"body"]];
        [ForumDB saveSystemInfo:model];
        
    }else{
        //推送消息
        MinePushModel *model = [MinePushModel modelWithDictionary:responseDictionary[@"body"]];
        [ForumDB savePushInfo:model];
    }
    
}


#pragma mark - 这个方法是用于从微信返回三方App
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    if ([url.scheme isEqualToString:@"picturebooksalipay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSString *strTitle = @"支付结果";
            NSString *strMsg;
            if ([[resultDic objectForKey:@"resultStatus"] isEqualToString:@"9000"]) {
                strMsg = @"支付结果：成功！";
            }else if ([[resultDic objectForKey:@"resultStatus"] isEqualToString:@"8000"]){
                strMsg = @"支付结果：正在处理中，请稍后查询商户订单列表中订单的支付状态";
            }else{
                strMsg = @"支付结果：失败！";
            }
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:strTitle message:strMsg preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"知道了");
            }];
            [alert addAction:action];
            [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
        }];
    }
    if ([url.scheme isEqualToString:@"wxb6f923a74661ce3b"]) {
        // 跳转到URL scheme中配置的地址
        NSLog(@"跳转到URL scheme中配置的地址-->%@",url);
        return [WXApi handleOpenURL:url delegate:self];
    }
    return YES;
}

// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    if ([url.scheme isEqualToString:@"picturebooksalipay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSString *strTitle = @"支付结果";
            NSString *strMsg;
            if ([[resultDic objectForKey:@"resultStatus"] isEqualToString:@"9000"]) {
                strMsg = @"支付结果：成功！";
            }else if ([[resultDic objectForKey:@"resultStatus"] isEqualToString:@"8000"]){
                strMsg = @"支付结果：正在处理中，请稍后查询商户订单列表中订单的支付状态";
            }else{
                strMsg = @"支付结果：失败！";
            }
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:strTitle message:strMsg preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"知道了");
            }];
            [alert addAction:action];
            [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
        }];
    }
    if ([url.scheme isEqualToString:@"wxb6f923a74661ce3b"]) {
        // 跳转到URL scheme中配置的地址
        NSLog(@"9.0跳转到URL scheme中配置的地址-->%@",url);
        return [WXApi handleOpenURL:url delegate:self];
    }
    return YES;
}

//跳转微信后得到的响应结果
- (void)onResp:(BaseResp *)resp{
    // 向微信请求授权后,得到响应结果
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *temp = (SendAuthResp *)resp;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"bindingPhoneNum" object:temp.code];
    }
    
    // 微信分享后，得到相应结果
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        SendMessageToWXResp *response = (SendMessageToWXResp *)resp;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"wechatShare" object:[NSString stringWithFormat:@"%d", response.errCode]];
    }
    
    // 微信支付后，得到相应结果
    if([resp isKindOfClass:[PayResp class]]){
        NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
        NSString *strTitle = [NSString stringWithFormat:@"支付结果"];
        switch (resp.errCode) {
            case WXSuccess:{
                strMsg = @"支付结果：成功！";
                break;
            }
            default:{
                strMsg = [NSString stringWithFormat:@"支付结果：失败！"];
                break;
            }
        }
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:strTitle message:strMsg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WeChatPayResult" object:nil];
        }];
        [alert addAction:action];
        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - 收到通知，变更视图控制器
//收到通知后执行的方法
- (void)changeRootViewController:(NSNotification *)notification{
    if ([notification.object isEqualToString:@"fromWelcome"] || [notification.object isEqualToString:@"fromLogout"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"yep" forKey:@"notFirst"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        LoginAndRegisterViewController *loginAndRegisterVC = [[LoginAndRegisterViewController alloc] init];
        UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:loginAndRegisterVC];
        navC.navigationBarHidden = YES;
        
        self.window.rootViewController = navC;
    }else if ([notification.object isEqualToString:@"fromUNAUTH"]){
        LoginAndRegisterViewController *loginAndRegisterVC = [[LoginAndRegisterViewController alloc] init];
        loginAndRegisterVC.message = @"fromUNAUTH";
        UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:loginAndRegisterVC];
        navC.navigationBarHidden = YES;
        
        self.window.rootViewController = navC;
    }else if ([notification.object isEqualToString:@"AUTH_ABNORMAL"]){
        LoginAndRegisterViewController *loginAndRegisterVC = [[LoginAndRegisterViewController alloc] init];
        loginAndRegisterVC.message = @"AUTH_ABNORMAL";
        UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:loginAndRegisterVC];
        navC.navigationBarHidden = YES;
        
        self.window.rootViewController = navC;
    }
    else{
        RootViewController *viewController = [[RootViewController alloc] init];
        self.window.rootViewController = viewController;
    }
}
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"后台状态");
    //取消设置屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"当前状态");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //设置屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
- (void)application:(UIApplication *)application
didRegisterUserNotificationSettings:
(UIUserNotificationSettings *)notificationSettings {
}

// Called when your app has been activated by the user selecting an action from
// a local notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forLocalNotification:(UILocalNotification *)notification
  completionHandler:(void (^)())completionHandler {
}

// Called when your app has been activated by the user selecting an action from
// a remote notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forRemoteNotification:(NSDictionary *)userInfo
  completionHandler:(void (^)())completionHandler {
}
#endif


- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:
(void (^)(UIBackgroundFetchResult))completionHandler {
    [JPUSHService handleRemoteNotification:userInfo];
    NSLog(@"iOS7及以上系统，收到通知:%@", [self logDic:userInfo]);
    
    if ([[UIDevice currentDevice].systemVersion floatValue]<10.0 || application.applicationState>0) {
       
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application
didReceiveLocalNotification:(UILocalNotification *)notification {
    [JPUSHService showLocalNotificationAtFront:notification identifierKey:nil];
}

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#pragma mark- JPUSHRegisterDelegate
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        NSLog(@"iOS10 前台收到远程通知:%@", [self logDic:userInfo]);
        
    } else {
        // 判断为本地通知
        NSLog(@"iOS10 前台收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        NSLog(@"iOS10 收到远程通知:%@", [self logDic:userInfo]);
       
    }
    else {
        // 判断为本地通知
        NSLog(@"iOS10 收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    completionHandler();  // 系统要求执行这个方法
}
#endif

// log NSSet with UTF8
// if not ,log will be \Uxxx
- (NSString *)logCustomDic:(NSString *)customStr{
    NSString *tempStr1 =
    [customStr stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListFromData:tempData
                                     mutabilityOption:NSPropertyListImmutable
                                               format:NULL
                                     errorDescription:NULL];
    return str;
}

- (NSString *)logDic:(NSDictionary *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListFromData:tempData
                                     mutabilityOption:NSPropertyListImmutable
                                               format:NULL
                                     errorDescription:NULL];
    return str;
}


#pragma mark - 检测 APP 的版本号是否需要更新
- (void)updateAppVersion
{
    [[HttpManager sharedManager] POST:@"https://itunes.apple.com/cn/lookup?id=1353729754" parame:nil sucess:^(id success) {
        NSArray *result = success[@"results"];
        
//        NSLog(@"======================");
//        NSLog(@"%@",result);
//        NSLog(@"======================");
        
        if (result) {
            NSDictionary *dict = [result firstObject];
            if (dict) {
                NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
                NSString *newAppVersion = dict[@"version"];
                if (![appCurVersion isEqualToString:newAppVersion]) {
                    [self showAppHaveNewVeresion];
                }
                
//                if ([newAppVersion compare:appCurVersion] == NSOrderedDescending) {
//                    NSDate *lastDate = [NSDate fs_dateFromString:[CPUserDefaultsTool getValueForKey:CPAppVersioncancelDate] format:@"yyyy-MM-dd"];
//                    NSDate *nowDate = [NSDate date];
//                    if ([nowDate fs_day] - [lastDate fs_day] > 1) {
//                        self.releaseNotes = dict[@"releaseNotes"];
//                        [self showAppHaveNewVeresion];
//                    }
//                }
            }
        }
        
    } failure:^(NSError *error) {
        [Global showWithView:self.window withText:@"网络异常～"];
    }];
}

// APP 更新提示弹窗
- (void)showAppHaveNewVeresion{
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"App 有更新"
                                                       message:nil
                                                      delegate:self
                                             cancelButtonTitle:@"取消"
                                             otherButtonTitles:@"确定", nil];
    //显示alertView
    [alertView show];
}

// alertView 的代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // 前往 App Store 1297122816
        NSString *appleID = @"1353729754";// iOS7和iOS8的打开方式不一样
        if (IOS7) {
            NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appleID];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
            
        } else {
            NSString *str = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", appleID];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }
    }
}

//每天进行一次版本判断
- (BOOL)judgeNeedVersionUpdate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    //获取年-月-日
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSString *currentDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentDate"];
    if ([currentDate isEqualToString:dateString]) {
        return NO;
    }
    [[NSUserDefaults standardUserDefaults] setObject:dateString forKey:@"currentDate"];
    return YES;
}


/** 配置崩溃日志 */
- (void)configBuglyLog
{
    [Bugly startWithAppId:@"ec31f24378"];
}

@end


















