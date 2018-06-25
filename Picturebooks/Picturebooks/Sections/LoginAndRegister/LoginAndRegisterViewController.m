//
//  LoginAndRegisterViewController.m
//  Picturebooks
//
//  Created by 尹凯 on 2017/8/12.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "LoginAndRegisterViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "WXApi.h"
#import "BindingViewController.h"

@interface LoginAndRegisterViewController ()

@property (nonatomic, strong)LoginViewController *loginVC;
@property (nonatomic, strong)RegisterViewController *registerVC;

@end

@implementation LoginAndRegisterViewController

- (void)dealloc{
    NSLog(@"”登录注册“界面内存没有泄漏");
    //移除所有通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    self.loginVC = [[LoginViewController alloc] init];
    [self addChildViewController:self.loginVC];
    [self.view addSubview:self.loginVC.view];
    self.loginVC.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpLogin) name:@"haveAccount" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpRegister) name:@"newUser" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weChatLogin) name:@"WeChatLogin" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bindingPhoneNum:) name:@"bindingPhoneNum" object:nil];
}

- (void)bindingPhoneNum:(NSNotification *)notification{
    NSString *code = notification.object;
    if (code.length == 0) {
        [Global showWithView:self.view withText:@"未获得微信授权"];
    }else{
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.removeFromSuperViewOnHide = YES;
        HUD.labelText = @"授权验证中...";
        HUD.backgroundColor = [UIColor clearColor];
        
        NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
        [parame setObject:User_auth forKey:@"uri"];
        [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
        [parame setObject:code forKey:@"code"];
        [parame setObject:@(0) forKey:@"type"];
        
        [[HttpManager sharedManager] POST:User_auth parame:parame sucess:^(id success) {
            [HUD hide:YES];
            if ([[success objectForKey:@"event"] isEqualToString:@"UNUSER"]) {
                BindingViewController *bindingVC = [[BindingViewController alloc] init];
                bindingVC.token = [[success objectForKey:@"data"] objectForKey:@"token"];
                [JPUSHService setAlias:success[@"data"][@"id"] completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                    NSLog(@"激光%ld, %@, %ld", iResCode,iAlias, seq );
                } seq:0];
                [[NSUserDefaults standardUserDefaults] setObject:success[@"data"][@"id"] forKey:@"userid"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:bindingVC];
                navC.navigationBarHidden = YES;

                [self.navigationController presentViewController:navC animated:YES completion:^{
                    
                }];
            }else if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]){
                [Global showWithView:self.view withText:@"授权成功！即将登陆"];
                [[NSUserDefaults standardUserDefaults] setObject:[[success objectForKey:@"data"] objectForKey:@"token"] forKey:@"token"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [JPUSHService setAlias:success[@"data"][@"id"] completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                    NSLog(@"激光%ld, %@, %ld", iResCode,iAlias, seq );
                } seq:0];
                [[NSUserDefaults standardUserDefaults] setObject:success[@"data"][@"id"] forKey:@"userid"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeRootViewController" object:@"fromLogin"];
                });
            }else{
                [Global showWithView:self.view withText:[success objectForKey:@"describe"]];
            }
        } failure:^(NSError *error) {
            [HUD hide:YES];
            [Global showWithView:self.view withText:@"网络异常～"];
        }];
    }
}

#pragma mark - 微信登录方法
/*
 目前移动应用上德微信登录只提供原生的登录方式，需要用户安装微信客户端才能配合使用。
 对于iOS应用,考虑到iOS应用商店审核指南中的相关规定，建议开发者接入微信登录时，先检测用户手机是否已经安装
 微信客户端(使用sdk中的isWXAppInstall函数),对于未安装的用户隐藏微信 登录按钮，只提供其他登录方式。
 */
//收到通知后执行方法
- (void)weChatLogin{
    //判断是否安装微信，并向微信发起请求
    if ([WXApi isWXAppInstalled]) {
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        req.state = @"PicturebooksApp";
        [WXApi sendReq:req];
    }else{
        [self setupAlertController];
    }
}

//设置弹出提示语
- (void)setupAlertController {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请先安装微信客户端" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:actionConfirm];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)jumpLogin{
    [self.view bringSubviewToFront:self.loginVC.view];
}

- (void)jumpRegister{
    if (_registerVC == nil) {
        self.registerVC = [[RegisterViewController alloc] init];
        [self addChildViewController:self.registerVC];
        [self.view addSubview:self.registerVC.view];
        self.registerVC.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }
    [self.view bringSubviewToFront:self.registerVC.view];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //navigationBar隐藏
    self.navigationController.navigationBarHidden = YES;
    
    NSString *messageStr;
    if (![Global isNullOrEmpty:self.message]) {
        if ([self.message isEqualToString:@"fromUNAUTH"]) {
            messageStr = @"监测到您登录状态异常，请重新登录";
        }else{
            messageStr = @"会话失效，该账户已在其它终端登录 ~";

        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:messageStr preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定 " style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.message = nil;
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
