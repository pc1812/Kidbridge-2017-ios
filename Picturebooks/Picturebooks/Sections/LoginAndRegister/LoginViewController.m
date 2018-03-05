//
//  LoginViewController.m
//  Picturebooks
//
//  Created by 尹凯 on 2017/8/12.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "LoginViewController.h"
#import "MissViewController.h"

@interface LoginViewController ()<UITextFieldDelegate>

@property (nonatomic, strong)UITextField *phoneNum;
@property (nonatomic, strong)UITextField *password;
@property (nonatomic, strong)UIButton *arrorBtn;
@property (nonatomic, strong)UILabel *preLabel;
@property (nonatomic, strong)UIView *selectView;

@end

@implementation LoginViewController

- (void)dealloc{
    NSLog(@"------没有内存泄漏-----");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldResponse:)];
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:tap];
    
    //背景图片
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    backImageView.image = [UIImage imageNamed:@"login_background"];
    [self.view addSubview:backImageView];
    
    //头像
    UIImageView *headImageView = [[UIImageView alloc] init];
    [self.view addSubview:headImageView];
    headImageView.image = [UIImage imageNamed:@"login_headimage"];
    headImageView.layer.masksToBounds = YES;
    headImageView.layer.cornerRadius = 77 / 2;
    headImageView.layer.borderWidth = 2;
    headImageView.layer.borderColor = [UIColor whiteColor].CGColor;
   
    
    if (IS_IPHONE4) {
        [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.and.height.mas_equalTo(77);
            make.left.mas_equalTo((SCREEN_WIDTH - 77) / 2);
            make.top.mas_equalTo((120 - 77 / 2) * PROPORTION);//150
        }];
    }else{
        [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.and.height.mas_equalTo(77);
            make.left.mas_equalTo((SCREEN_WIDTH - 77) / 2);
            make.top.mas_equalTo((150 - 77 / 2) * PROPORTION);//150
        }];
        
    }
    
#pragma mark - 第一个输入框
    UIView *firstShadow = [[UIView alloc] init];
    [self.view addSubview:firstShadow];
    firstShadow.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    firstShadow.layer.shadowOffset = CGSizeMake(1,3);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
    firstShadow.layer.shadowOpacity = 0.3;//阴影透明度，默认0
    firstShadow.layer.shadowRadius = 5;//阴影半径，默认3
    if (IS_IPHONE4) {
        [firstShadow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(275);
            make.height.mas_equalTo(44);
            make.left.mas_equalTo((SCREEN_WIDTH - 275) / 2);
            make.top.mas_equalTo(225 * PROPORTION);//255
        }];
    }else{
        [firstShadow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(275);
            make.height.mas_equalTo(44);
            make.left.mas_equalTo((SCREEN_WIDTH - 275) / 2);
            make.top.mas_equalTo(255 * PROPORTION);//255
        }];
        
    }
    
    UIView *firstView = [[UIView alloc] init];
    [firstShadow addSubview:firstView];
    firstView.backgroundColor = [UIColor whiteColor];
    firstView.layer.masksToBounds = YES;
    firstView.layer.cornerRadius = 22;
    [firstView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(275);
        make.height.mas_equalTo(44);
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
    }];
    
    //user图标
    UIImageView *phone = [[UIImageView alloc] init];
    [firstView addSubview:phone];
    phone.image = [UIImage imageNamed:@"user"];
    [phone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(22);
        make.width.mas_equalTo(13.5);
        make.height.mas_equalTo(15);
        make.top.mas_equalTo((44 - 15) / 2);
    }];
    
    //+86标签
    CGFloat temp = [AppTools heightForContent:@"请输入手机号" fontoOfText:15 spacingOfLabel:12];
    self.preLabel = [[UILabel alloc] init];
    [firstView addSubview:self.preLabel];
    self.preLabel.text = @"+86";
    self.preLabel.font = [UIFont systemFontOfSize:15];
    [self.preLabel sizeToFit];
    [self.preLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(phone.mas_right).offset(10);
        make.top.mas_equalTo((44 - temp) / 2);
    }];
    
    //展示按钮（小下三角符号）
    self.arrorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [firstView addSubview:self.arrorBtn];
    [self.arrorBtn setImage:[UIImage imageNamed:@"arrow-down.png"] forState:UIControlStateNormal];
    /**添加一个点击事件*/
    [self.arrorBtn addTarget:self action:@selector(arrorBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.arrorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.preLabel.mas_right).offset(5);
        make.centerY.mas_equalTo(self.preLabel.mas_centerY);
        make.width.and.height.mas_equalTo(12);
    }];
    
    
    //输入框
    self.phoneNum = [[UITextField alloc] init];
    [firstView addSubview:self.phoneNum];
    self.phoneNum.placeholder = @"请输入手机号";
    self.phoneNum.tag = 10001;
    self.phoneNum.font = [UIFont systemFontOfSize:15];
    self.phoneNum.keyboardType = UIKeyboardTypePhonePad;
    self.phoneNum.delegate = self;
    [self.phoneNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.arrorBtn.mas_right).offset(5);
        make.centerY.mas_equalTo(self.preLabel.mas_centerY);
        make.width.mas_equalTo(170);
        make.height.mas_equalTo(temp);
    }];
    
#pragma mark - 第二个输入框
    UIView *secondShadow = [[UIView alloc] init];
    [self.view addSubview:secondShadow];
    secondShadow.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    secondShadow.layer.shadowOffset = CGSizeMake(1,3);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
    secondShadow.layer.shadowOpacity = 0.3;//阴影透明度，默认0
    secondShadow.layer.shadowRadius = 5;//阴影半径，默认3
    [secondShadow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(firstShadow.mas_bottom).offset(15);
        make.width.mas_equalTo(275);
        make.height.mas_equalTo(44);
        make.left.mas_equalTo((SCREEN_WIDTH - 275) / 2);
    }];
    
    UIView *secondView = [[UIView alloc] init];
    [secondShadow addSubview:secondView];
    secondView.backgroundColor = [UIColor whiteColor];
    secondView.layer.masksToBounds = YES;
    secondView.layer.cornerRadius = 22;
    [secondView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(275);
        make.height.mas_equalTo(44);
        make.left.mas_equalTo(0);
    }];
    
    //锁头图标
    UIImageView *lock = [[UIImageView alloc] init];
    [secondView addSubview:lock];
    lock.image = [UIImage imageNamed:@"password"];
    [lock mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(12);
        make.height.mas_equalTo(15);
        make.left.mas_equalTo(22);
        make.top.mas_equalTo((44 - 15) / 2);
    }];
    
    //输入框
    self.password = [[UITextField alloc] init];
    [secondView addSubview:self.password];
    self.password.placeholder = @"请输入密码";
    self.password.tag = 10002;
    self.password.font = [UIFont systemFontOfSize:15];
    self.password.secureTextEntry = YES;
    self.password.delegate = self;
    self.password.clearsOnBeginEditing = YES;
    self.password.returnKeyType = UIReturnKeyDone;
    self.password.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.password mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lock.mas_right).offset(10);
        make.centerY.mas_equalTo(lock.mas_centerY);
        make.width.mas_equalTo(220);
        make.height.mas_equalTo(temp);
    }];
    
#pragma mark - +1/+86的小视图View
    // +1/+86的小视图View
    self.selectView = [[UIView alloc] init];
    [self.view addSubview:self.selectView];
    self.selectView.hidden = YES;
    self.selectView.backgroundColor = [UIColor whiteColor];
    // 设置阴影
    self.selectView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.selectView.layer.shadowOffset = CGSizeMake(3, 3);
    self.selectView.layer.shadowRadius = 3.0f;
    self.selectView.layer.shadowOpacity = 0.5f;
    [self.selectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.preLabel);
        make.centerX.mas_equalTo(self.preLabel).offset(-2.0f);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(50);
    }];
    
    // +86的按钮
    UIButton *firstBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.selectView addSubview:firstBtn];
    [firstBtn setTitle:@"+86" forState:UIControlStateNormal];
    firstBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [firstBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [firstBtn addTarget:self action:@selector(firstBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [firstBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.selectView);
        make.leading.mas_equalTo(self.selectView);
        make.width.mas_equalTo(self.selectView);
        make.height.mas_equalTo(self.selectView).multipliedBy(0.5f);
    }];
    
    // +1的按钮
    UIButton *secondBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.selectView addSubview:secondBtn];
    [secondBtn setTitle:@"+1" forState:UIControlStateNormal];
    secondBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [secondBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [secondBtn addTarget:self action:@selector(sencondBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [secondBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(firstBtn.mas_bottom);
        make.leading.mas_equalTo(firstBtn);
        make.width.height.mas_equalTo(firstBtn);
    }];
    
    
    
#pragma mark - 下方富文本按钮
    //新用户注册
    UIButton *newUser = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:newUser];
    newUser.backgroundColor = [UIColor clearColor];
    [newUser addTarget:self action:@selector(changeRegisterView:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *newUserlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [newUser addSubview:newUserlabel];
    NSMutableAttributedString *newUserString = [[NSMutableAttributedString alloc] initWithString:@"新用户注册"];
    [newUserString addAttributes:@{NSForegroundColorAttributeName : RGBHex(0x14d02f),
                                   NSUnderlineColorAttributeName : RGBHex(0x14d02f),
                                   NSUnderlineStyleAttributeName : [NSNumber numberWithInteger:NSUnderlineStyleSingle]}
                           range:NSMakeRange(0, 5)];
    newUserlabel.attributedText = newUserString;
    [newUserlabel sizeToFit];
    newUserlabel.font = [UIFont systemFontOfSize:13];
    
    [newUser mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(secondShadow.mas_left).offset(22);
        make.top.equalTo(secondShadow.mas_bottom).offset(12);
        make.width.mas_equalTo(newUserlabel.mas_width);
        make.height.mas_equalTo(newUserlabel.mas_height);
    }];
    
    //忘记密码
    UIButton *miss = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:miss];
    miss.backgroundColor = [UIColor clearColor];
    [miss addTarget:self action:@selector(changeMissView:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *missLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [miss addSubview:missLabel];
    NSMutableAttributedString *missString = [[NSMutableAttributedString alloc] initWithString:@"忘记密码"];
    [missString addAttributes:@{NSForegroundColorAttributeName : RGBHex(0x14d02f),
                                NSUnderlineColorAttributeName : RGBHex(0x14d02f),
                                NSUnderlineStyleAttributeName : [NSNumber numberWithInteger:NSUnderlineStyleSingle]}
                        range:NSMakeRange(0, 4)];
    missLabel.attributedText = missString;
    [missLabel sizeToFit];
    missLabel.font = [UIFont systemFontOfSize:13];
    
    [miss mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(missLabel.mas_width);
        make.height.mas_equalTo(missLabel.mas_height);
        make.right.equalTo(secondShadow.mas_right);
        make.top.equalTo(secondShadow.mas_bottom).offset(12);
    }];
    
#pragma mark - 下部分视图
    UIView *thirdShadow = [[UIView alloc] init];
    [self.view addSubview:thirdShadow];
    thirdShadow.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    thirdShadow.layer.shadowOffset = CGSizeMake(1,3);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
    thirdShadow.layer.shadowOpacity = 0.3;//阴影透明度，默认0
    thirdShadow.layer.shadowRadius = 5;//阴影半径，默认3
    [thirdShadow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(168);
        make.height.mas_equalTo(44);
        make.left.mas_equalTo((SCREEN_WIDTH - 168) / 2);
        make.top.equalTo(secondShadow.mas_bottom).offset(72 * PROPORTION);
    }];
    
    //登陆按钮
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [thirdShadow addSubview:loginButton];
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    loginButton.backgroundColor = RGBHex(0x14d02f);
    loginButton.layer.masksToBounds = YES;
    loginButton.layer.cornerRadius = 22;
    [loginButton addTarget:self action:@selector(loginBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(168);
        make.height.mas_equalTo(44);
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
    }];
    
#pragma mark - 微信登录
//    UIView *weixin = [[UIView alloc] init];
//    [self.view addSubview:weixin];
//    [weixin mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(140 * PROPORTION);//140
//        make.width.mas_equalTo(SCREEN_WIDTH);
//        make.bottom.mas_equalTo(0);
//        make.left.mas_equalTo(0);
//    }];
//
//    UILabel *weixinlogin = [[UILabel alloc] init];
//    [weixin addSubview:weixinlogin];
//    weixinlogin.text = @"微信登陆";
//    weixinlogin.font = [UIFont systemFontOfSize:12];
//    [weixinlogin sizeToFit];
//    CGFloat width = weixinlogin.frame.size.width;
//    weixinlogin.textColor = RGBHex(0x999999);
//    [weixinlogin mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(10);//0
//        make.left.mas_equalTo((SCREEN_WIDTH - width) / 2);
//    }];
//
//    UIView *line = [[UIView alloc] init];
//    [weixin addSubview:line];
//    line.backgroundColor = RGBHex(0x999999);
//    [line mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(70);
//        make.right.equalTo(weixinlogin.mas_left).offset(-10);
//        make.height.mas_equalTo(1);
//        make.centerY.mas_equalTo(weixinlogin.mas_centerY);
//    }];
//
//    UIView *line_ = [[UIView alloc] init];
//    [weixin addSubview:line_];
//    line_.backgroundColor = RGBHex(0x999999);
//    [line_ mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(-70);
//        make.left.equalTo(weixinlogin.mas_right).offset(10);
//        make.height.mas_equalTo(1);
//        make.centerY.mas_equalTo(weixinlogin.mas_centerY);
//    }];
//
//    UIImageView *weixinImage = [[UIImageView alloc] init];
//    [weixin addSubview:weixinImage];
//    weixinImage.image = [UIImage imageNamed:@"weixin_login"];
//    weixinImage.layer.masksToBounds = YES;
//    weixinImage.layer.cornerRadius = 22;
//    weixinImage.backgroundColor = [UIColor whiteColor];
//    [weixinImage mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.and.height.mas_equalTo(44);
//        make.top.mas_equalTo(40);
//        make.left.mas_equalTo((SCREEN_WIDTH - 44) / 2);
//    }];
//    UITapGestureRecognizer *tap_ = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(weixinLogin:)];
//    weixinImage.userInteractionEnabled = YES;
//    [weixinImage addGestureRecognizer:tap_];
//
//    if (![WXApi isWXAppInstalled]) {
//        weixin.hidden = YES;
//    }else{
//         weixin.hidden = NO;
//    }
   
}

//微信登录
//- (void)weixinLogin:(UITapGestureRecognizer *)tap{
//    [self.phoneNum resignFirstResponder];
//    [self.password resignFirstResponder];
//
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"WeChatLogin" object:@"微信登录"];
//}

//登录逻辑
- (void)loginBtnAction:(UIButton *)btn{
    [self.phoneNum resignFirstResponder];
    [self.password resignFirstResponder];
    
    if ([Global isValidatePhone:self.phoneNum.text]) {
        if (![Global isNullOrEmpty:self.password.text]) {
            if (self.password.text.length < 8) {
                [Global showWithView:self.view withText:@"密码不能少于8位！"];
            }
            else{
                MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                HUD.removeFromSuperViewOnHide = YES;
                HUD.labelText = @"登录中...";
                HUD.backgroundColor = [UIColor clearColor];
                
                NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
                [parame setObject:@"/user/login" forKey:@"uri"];
                [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
                [parame setObject:[self.preLabel.text stringByAppendingString:self.phoneNum.text] forKey:@"phone"];
                [parame setObject:[HttpManager getAddSaltMD5PasswordWithPhone:[self.preLabel.text stringByAppendingString:self.phoneNum.text] password:self.password.text] forKey:@"password"];
                
                [[HttpManager sharedManager] POST:@"/user/login" parame:parame sucess:^(id success) {
                    [HUD hide:YES];
                    if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
                        
                        [Global showWithView:self.view withText:@"验证成功！即将登录"];
                        [[NSUserDefaults standardUserDefaults] setObject:[[success objectForKey:@"data"] objectForKey:@"token"] forKey:@"token"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        if (success[@"data"][@"hide"]) {
                            [[NSUserDefaults standardUserDefaults] setObject:success[@"data"][@"hide"] forKey:@"hide"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                    
                        }
                        
                       [JPUSHService setAlias:success[@"data"][@"id"] completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                           NSLog(@"激光%ld, %@, %ld", iResCode,iAlias, seq );
                       } seq:0];
                        
                        [[NSUserDefaults standardUserDefaults] setObject:success[@"data"][@"id"] forKey:@"userid"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeRootViewController" object:@"fromLogin"];
                        });
                    }
                    else{
                        [Global showWithView:self.view withText:[success objectForKey:@"describe"]];
                    }
                } failure:^(NSError *error) {
                    [HUD hide:YES];
                    [Global showWithView:self.view withText:@"网络异常～"];
                }];
            }
        }
        else{
            [Global showWithView:self.view withText:@"密码不能为空！"];
        }
    }
    else{
        if ([Global isNullOrEmpty:self.phoneNum.text]) {
            [Global showWithView:self.view withText:@"手机号不能为空！"];
        }
        else{
            [Global showWithView:self.view withText:@"手机号格式不正确！"];
        }
    }
}

#pragma mark - UITextField代理方法
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.text.length < 18) {
        return YES;
    }
    else{
        if ([string isEqualToString:@""]) {
            return YES;
        }
        return NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - 其他点击触发方法
- (void)textFieldResponse:(UITapGestureRecognizer *)tap{
    [self.phoneNum resignFirstResponder];
    [self.password resignFirstResponder];
}

- (void)changeRegisterView:(UIButton *)btn{
    [self.phoneNum resignFirstResponder];
    [self.password resignFirstResponder];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newUser" object:@"注册"];
}

- (void)changeMissView:(UIButton *)btn{
    [self.phoneNum resignFirstResponder];
    [self.password resignFirstResponder];
    
    MissViewController *missVC = [[MissViewController alloc] init];
    [self.navigationController pushViewController:missVC animated:YES];
}

// 下三角按钮的响应事件
- (void)arrorBtnClick:(UIButton *)sender {
    self.selectView.hidden = !self.selectView.isHidden;
    
}

- (void)firstBtnClick:(UIButton *)sender {
    self.preLabel.text = @"+86";
    self.selectView.hidden = YES;
}

- (void)sencondBtnClick:(UIButton *)sender {
    self.preLabel.text = @"+1";
    self.selectView.hidden = YES;
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
