//
//  RegisterViewController.m
//  Picturebooks
//
//  Created by 尹凯 on 2017/8/12.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()<UITextFieldDelegate>

//创建定时器（因为下面两个方法都使用，所以定时器设置为一个属性）
@property (nonatomic, strong)NSTimer *countDownTimer;
@property (nonatomic, assign)NSInteger secondCountDown;

@property (nonatomic, strong)UILabel *preLabel;
@property (nonatomic, strong)UIButton *arrorBtn;
@property (nonatomic, strong)UITextField *phoneNum;
@property (nonatomic, strong)UITextField *verification;
@property (nonatomic, strong)UIButton *getpassword;
@property (nonatomic, strong)UITextField *password;

@end

@implementation RegisterViewController

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
    [self.view addSubview:backImageView];
    backImageView.image = [UIImage imageNamed:@"login_background"];
    
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
            make.top.mas_equalTo((120 - 77 / 2) * PROPORTION);
        }];
    }else{
        [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.and.height.mas_equalTo(77);
            make.left.mas_equalTo((SCREEN_WIDTH - 77) / 2);
            make.top.mas_equalTo((150 - 77 / 2) * PROPORTION);
        }];
        
    }
    
#pragma mark - 第一个输入框
    UIView *firstShadow = [[UIView alloc] init];
    [self.view addSubview:firstShadow];
    firstShadow.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    firstShadow.layer.shadowOffset = CGSizeMake(1,3);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
    firstShadow.layer.shadowOpacity = 0.3;//阴影透明度，默认0
    firstShadow.layer.shadowRadius = 5;//阴影半径，默认3
    [firstShadow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(275);
        make.height.mas_equalTo(44);
        make.left.mas_equalTo((SCREEN_WIDTH - 275) / 2);
        make.top.equalTo(headImageView.mas_bottom).offset(30 * PROPORTION);
    }];
    
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
    
    //手机图标
    UIImageView *phone = [[UIImageView alloc] init];
    [firstView addSubview:phone];
    phone.image = [UIImage imageNamed:@"phone"];
    [phone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(22);
        make.width.mas_equalTo(10);
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
    
    //展示按钮
    self.arrorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [firstView addSubview:self.arrorBtn];
    [self.arrorBtn setImage:[UIImage imageNamed:@"arrow-down.png"] forState:UIControlStateNormal];
    [self.arrorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.preLabel.mas_right).offset(5);
        make.centerY.mas_equalTo(self.preLabel.mas_centerY);
        make.width.and.height.mas_equalTo(12);
    }];
    
    //输入框
    self.phoneNum = [[UITextField alloc] init];
    [firstView addSubview:self.phoneNum];
    self.phoneNum.placeholder = @"请输入手机号";
    self.phoneNum.tag = 20001;
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
        make.top.equalTo(firstShadow.mas_bottom).offset(10);
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
        make.width.mas_equalTo(275);
        make.height.mas_equalTo(44);
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
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
    self.verification = [[UITextField alloc] init];
    [secondView addSubview:self.verification];
    self.verification.placeholder = @"请输入验证码";
    self.verification.tag = 20002;
    self.verification.font = [UIFont systemFontOfSize:15];
    self.verification.delegate = self;
    self.verification.keyboardType = UIKeyboardTypeNumberPad;
    [self.verification mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lock.mas_right).offset(10);
        make.centerY.mas_equalTo(lock.mas_centerY);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(temp);
    }];
    
    //获取验证码按钮
    self.getpassword = [UIButton buttonWithType:UIButtonTypeCustom];
    [secondView addSubview:self.getpassword];
    [self.getpassword setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.getpassword setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.getpassword.titleLabel.font = [UIFont systemFontOfSize:14];
    self.getpassword.backgroundColor = RGBHex(0x14d02f);
    [self.getpassword addTarget:self action:@selector(getPassword:) forControlEvents:UIControlEventTouchUpInside];
    [self.getpassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(44);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
    }];
    
#pragma mark - 第三个输入框
    UIView *thirdShadow = [[UIView alloc] init];
    [self.view addSubview:thirdShadow];
    thirdShadow.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    thirdShadow.layer.shadowOffset = CGSizeMake(1,3);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
    thirdShadow.layer.shadowOpacity = 0.3;//阴影透明度，默认0
    thirdShadow.layer.shadowRadius = 5;//阴影半径，默认3
    [thirdShadow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(secondShadow.mas_bottom).offset(10);
        make.width.mas_equalTo(275);
        make.height.mas_equalTo(44);
        make.left.mas_equalTo((SCREEN_WIDTH - 275) / 2);
    }];
    
    UIView *thirdView = [[UIView alloc] init];
    [thirdShadow addSubview:thirdView];
    thirdView.backgroundColor = [UIColor whiteColor];
    thirdView.layer.masksToBounds = YES;
    thirdView.layer.cornerRadius = 22;
    [thirdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(275);
        make.height.mas_equalTo(44);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
    }];
    
    //锁头图标
    UIImageView *lock_ = [[UIImageView alloc] init];
    [thirdView addSubview:lock_];
    lock_.image = [UIImage imageNamed:@"password"];
    [lock_ mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(12);
        make.height.mas_equalTo(15);
        make.left.mas_equalTo(22);
        make.top.mas_equalTo((44 - 15) / 2);
    }];
    
    //输入框
    self.password = [[UITextField alloc] init];
    [thirdView addSubview:self.password];
    self.password.placeholder = @"请设置登录密码";
    self.password.tag = 20003;
    self.password.font = [UIFont systemFontOfSize:15];
    self.password.secureTextEntry = YES;
    self.password.delegate = self;
    self.password.clearsOnBeginEditing = YES;
    self.password.returnKeyType = UIReturnKeyDone;
    self.password.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.password mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lock_.mas_right).offset(10);
        make.centerY.mas_equalTo(lock_.mas_centerY);
        make.width.mas_equalTo(220);
        make.height.mas_equalTo(temp);
    }];
    
#pragma mark - 富文本
    UIButton *haved = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:haved];
    haved.backgroundColor = [UIColor clearColor];
    [haved addTarget:self action:@selector(changeLoginView:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [haved addSubview:label];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"已有账号"];
    [string addAttributes:@{NSForegroundColorAttributeName : RGBHex(0x14d02f),
                            NSUnderlineColorAttributeName : RGBHex(0x14d02f),
                            NSUnderlineStyleAttributeName : [NSNumber numberWithInteger:NSUnderlineStyleSingle]}
                    range:NSMakeRange(0, 4)];
    label.attributedText = string;
    [label sizeToFit];
    label.font = [UIFont systemFontOfSize:12];
    
    [haved mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(label.frame.size.width);
        make.height.mas_equalTo(label.frame.size.height);
        make.top.equalTo(thirdShadow.mas_bottom).offset(13);
        make.right.equalTo(thirdShadow.mas_right);
    }];
    
#pragma mark - 下部分视图
    UIView *forthShadow = [[UIView alloc] init];
    [self.view addSubview:forthShadow];
    forthShadow.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    forthShadow.layer.shadowOffset = CGSizeMake(1,3);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
    forthShadow.layer.shadowOpacity = 0.3;//阴影透明度，默认0
    forthShadow.layer.shadowRadius = 5;//阴影半径，默认3
    [forthShadow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(168);
        make.height.mas_equalTo(44);
        make.left.mas_equalTo((SCREEN_WIDTH - 168) / 2);
        make.top.equalTo(thirdShadow.mas_bottom).offset(52.5 * PROPORTION);
    }];
    
    //登陆按钮
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [forthShadow addSubview:registerButton];
    [registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    registerButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    registerButton.backgroundColor = RGBHex(0x14d02f);
    registerButton.layer.masksToBounds = YES;
    registerButton.layer.cornerRadius = 22;
    [registerButton addTarget:self action:@selector(registerBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(168);
        make.height.mas_equalTo(44);
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
    }];
    
#pragma mark - 微信登录
//    UIView *weixin = [[UIView alloc] init];
//    [self.view addSubview:weixin];
//    if (IS_IPHONE4) {
//        [weixin mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(120 * PROPORTION);//140
//            make.width.mas_equalTo(SCREEN_WIDTH);
//            make.bottom.mas_equalTo(0);
//            make.left.mas_equalTo(0);
//        }];
//
//    }else{
//        [weixin mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(140 * PROPORTION);//140
//            make.width.mas_equalTo(SCREEN_WIDTH);
//            make.bottom.mas_equalTo(0);
//            make.left.mas_equalTo(0);
//        }];
//    }
//
//    UILabel *weixinlogin = [[UILabel alloc] init];
//    [weixin addSubview:weixinlogin];
//    weixinlogin.text = @"微信登陆";
//    weixinlogin.font = [UIFont systemFontOfSize:12];
//    [weixinlogin sizeToFit];
//    CGFloat width = weixinlogin.frame.size.width;
//    weixinlogin.textColor = RGBHex(0x999999);
//    if (IS_IPHONE4) {
//        [weixinlogin mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(15);//0
//            make.left.mas_equalTo((SCREEN_WIDTH - width) / 2);
//        }];
//
//    }else{
//        [weixinlogin mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(0);//0
//            make.left.mas_equalTo((SCREEN_WIDTH - width) / 2);
//        }];
//    }
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
//    if (![WXApi isWXAppInstalled]) {
//        weixin.hidden = YES;
//    }else{
//        weixin.hidden = NO;
//    }
}

//微信登录
//- (void)weixinLogin:(UIButton *)button{
//    [self.phoneNum resignFirstResponder];
//    [self.verification resignFirstResponder];
//    [self.password resignFirstResponder];
//
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"WeChatLogin" object:@"微信登录"];
//}

//注册按钮逻辑
- (void)registerBtnAction:(UIButton *)btn{
    [self.phoneNum resignFirstResponder];
    [self.verification resignFirstResponder];
    [self.password resignFirstResponder];
    
    if ([Global isNullOrEmpty:self.phoneNum.text]) {
        [Global showWithView:self.view withText:@"手机号不能为空"];
    }else if ([Global isNullOrEmpty:self.verification.text]){
        [Global showWithView:self.view withText:@"请先获取验证码"];
    }else if ([Global isNullOrEmpty:self.password.text]){
        [Global showWithView:self.view withText:@"密码不能为空"];
    }else{
        if ([AppTools isNotPhoneNumber:self.phoneNum.text]) {
            [Global showWithView:self.view withText:@"手机号格式不正确"];
        }else if (self.password.text.length < 8){
            [Global showWithView:self.view withText:@"密码不能少于8位！"];
        }else{
            MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD.removeFromSuperViewOnHide = YES;
            HUD.labelText = @"注册中...";
            HUD.backgroundColor = [UIColor clearColor];

            NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
            [parame setObject:User_register forKey:@"uri"];
            [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
            [parame setObject:[self.preLabel.text stringByAppendingString:self.phoneNum.text] forKey:@"phone"];
            [parame setObject:self.password.text forKey:@"password"];
            [parame setObject:self.verification.text forKey:@"code"];
            
            [[HttpManager sharedManager] POST:User_register parame:parame sucess:^(id success) {
                [HUD hide:YES];
                if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
                    [self killNSTimer];
                    
                    self.getpassword.userInteractionEnabled = YES;
                    [self.getpassword setTitle:@"获取验证码" forState:UIControlStateNormal];
                    [self.getpassword setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    
                    [Global showWithView:self.view withText:@"注册成功！即将登陆"];
                    [[NSUserDefaults standardUserDefaults] setObject:[[success objectForKey:@"data"] objectForKey:@"token"] forKey:@"token"];
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
}

//获取验证码
- (void)getPassword:(UIButton *)button{
    [self.phoneNum resignFirstResponder];
    [self.verification resignFirstResponder];
    [self.password resignFirstResponder];
    //对手机号进行判断
    if ([Global isNullOrEmpty:self.phoneNum.text]) {
        [Global showWithView:self.view withText:@"手机号不能为空"];
        return;
    }
    if ([AppTools isNotPhoneNumber:self.phoneNum.text]) {
        [Global showWithView:self.view withText:@"手机号格式不正确"];
        return;
    }
    
    //判断手机号码正常后
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:Register_verification forKey:@"uri"];
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:[self.preLabel.text stringByAppendingString:self.phoneNum.text] forKey:@"phone"];
    
    [[HttpManager sharedManager] POST:Register_verification parame:parame sucess:^(id success) {
        if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"验证码已发送" message:@"验证码已发送至您的手机，请查收短信，并在120秒内填写验证码" preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }]];
            
            //由于它是一个控制器 直接modal出来就好了
            [self presentViewController:alertController animated:YES completion:nil];
            
            self.secondCountDown = 120;
            //设置定时器
            _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDownAction) userInfo:nil repeats:YES];
            //设置倒计时显示的时间
            NSString *str_second = [NSString stringWithFormat:@"%02ld", (long)_secondCountDown];//秒
            [self.getpassword setTitle:[NSString stringWithFormat:@"重新发送(%@)", str_second] forState:UIControlStateNormal];
            [self.getpassword setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            
            self.getpassword.userInteractionEnabled = NO;
        }else{
            [Global showWithView:self.view withText:[success objectForKey:@"describe"]];
        }
    } failure:^(NSError *error) {
        [Global showWithView:self.view withText:@"网络异常～"];
    }];
}

//定时器执行方法
- (void)countDownAction{
    //倒计时-1
    _secondCountDown --;
    
    //重新计算
    NSString *str_second = [NSString stringWithFormat:@"%02ld", (long)_secondCountDown];//秒
    
    //修改倒计时标签及显示内容
    [self.getpassword setTitle:[NSString stringWithFormat:@"重新发送(%@)", str_second] forState:UIControlStateNormal];
    
    //当倒计时到0时需要的操作,比如验证码过期不能提交
    if (_secondCountDown == 0) {
        [self killNSTimer];
        
        self.getpassword.userInteractionEnabled = YES;
        [self.getpassword setTitle:@"获取验证码" forState:UIControlStateNormal];
        [self.getpassword setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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
- (void)changeLoginView:(UIButton *)button{
    [self.phoneNum resignFirstResponder];
    [self.verification resignFirstResponder];
    [self.password resignFirstResponder];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"haveAccount" object:@"登陆"];
}

- (void)textFieldResponse:(UITapGestureRecognizer *)tap{
    [self.phoneNum resignFirstResponder];
    [self.verification resignFirstResponder];
    [self.password resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)killNSTimer{
    [self.countDownTimer invalidate];
    self.countDownTimer = nil;
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
