//
//  MissViewController.m
//  Picturebooks
//
//  Created by 尹凯 on 2017/8/12.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "MissViewController.h"

@interface MissViewController ()<UITextFieldDelegate>

@property (nonatomic, strong)UILabel *preLabel;
@property (nonatomic, strong)UIButton *arrorBtn;
@property (nonatomic, strong)UITextField *phoneNumber;
@property (nonatomic, strong)UITextField *verification;
@property (nonatomic, strong)UITextField *passwordTextField;
@property (nonatomic, strong)UITextField *confirmTextField;
@property (nonatomic, strong)UIButton *getpassword;

@property (nonatomic, weak)NSTimer *countDownTimer;
@property (nonatomic, assign)NSInteger secondCountDown;

@end

@implementation MissViewController

- (void)dealloc{
    NSLog(@"------没有内存泄漏-----");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = RGBHex(0xf0f0f0);
    self.navigationItem.title = @"修改密码";
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = RGBHex(0x14d02f);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18 weight:2], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 30)];
    [button setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    button.adjustsImageWhenHighlighted = NO;
    [button sizeToFit];
    UIView *containView = [[UIView alloc] initWithFrame:button.bounds];
    [containView addSubview:button];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:containView];
    self.navigationItem.leftBarButtonItem = barButton;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldResponse:)];
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:tap];
    
    [self createView];
}

- (void)createView{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 179)];
    headView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headView];
    
    //当前界面通用文本框高度
    CGFloat temp = [AppTools heightForContent:@"请输入手机号" fontoOfText:15 spacingOfLabel:12];
    
    //请输入手机号
    self.preLabel = [[UILabel alloc] init];
    [headView addSubview:self.preLabel];
    self.preLabel.text = @"+86";
    self.preLabel.font = [UIFont systemFontOfSize:15];
    [self.preLabel sizeToFit];
    [self.preLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.top.mas_equalTo((44 - temp) / 2);
    }];
    
    self.arrorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [headView addSubview:self.arrorBtn];
    [self.arrorBtn setImage:[UIImage imageNamed:@"arrow-down.png"] forState:UIControlStateNormal];
    [self.arrorBtn setImage:[UIImage imageNamed:@"arrow-up.png"] forState:UIControlStateSelected];
    [self.arrorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.preLabel.mas_right).offset(5);
        make.centerY.mas_equalTo(self.preLabel.mas_centerY);
        make.width.and.height.mas_equalTo(12);
    }];
    
    self.phoneNumber = [[UITextField alloc] init];
    self.phoneNumber.placeholder = @"请输入手机号";
    self.phoneNumber.tag = 30001;
    self.phoneNumber.delegate = self;
    self.phoneNumber.keyboardType = UIKeyboardTypePhonePad;
    self.phoneNumber.font = [UIFont systemFontOfSize:15];
    [headView addSubview:self.phoneNumber];
    [self.phoneNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.arrorBtn.mas_right).offset(5);
        make.centerY.mas_equalTo(self.preLabel.mas_centerY);
        make.width.mas_equalTo(100);
    }];
    
    //分割线
    UIView *lineA = [[UIView alloc] initWithFrame:CGRectMake(12, 44, SCREEN_WIDTH - 24, 1)];
    lineA.backgroundColor = RGBHex(0xf0f0f0);
    [headView addSubview:lineA];
    
    //请输入验证码
    self.verification = [[UITextField alloc] init];
    self.verification.placeholder = @"请输入验证码";
    self.verification.tag = 30002;
    self.verification.font = [UIFont systemFontOfSize:15];
    self.verification.delegate = self;
    self.verification.keyboardType = UIKeyboardTypeNumberPad;
    [headView addSubview:self.verification];
    [self.verification mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.top.mas_equalTo(45 + (44 - temp) / 2);
        make.width.mas_equalTo(150);
    }];
    
    self.getpassword = [UIButton buttonWithType:UIButtonTypeCustom];
    self.getpassword.backgroundColor = RGBHex(0x14d02f);
    [self.getpassword setTitle:@"获取验证码" forState:UIControlStateNormal];
    self.getpassword.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [self.getpassword setTintColor:[UIColor whiteColor]];
    self.getpassword.layer.masksToBounds = YES;
    self.getpassword.layer.cornerRadius = 16.5;
    [headView addSubview:self.getpassword];
    [self.getpassword addTarget:self action:@selector(getVerification:) forControlEvents:UIControlEventTouchUpInside];
    [self.getpassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-12);
        make.top.equalTo(lineA.mas_bottom).offset(5.5);
        make.height.mas_equalTo(33);
        make.width.mas_equalTo(104);
    }];
    
    //分割线
    UIView *lineB = [[UIView alloc] initWithFrame:CGRectMake(12, 89, SCREEN_WIDTH - 24, 1)];
    lineB.backgroundColor = RGBHex(0xf0f0f0);
    [headView addSubview:lineB];
    
    //请设定新密码
    self.passwordTextField = [[UITextField alloc] init];
    self.passwordTextField.placeholder = @"请设定新密码";
    self.passwordTextField.tag = 40001;
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.delegate = self;
    self.passwordTextField.font = [UIFont systemFontOfSize:15];
    [headView addSubview:self.passwordTextField];
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.top.mas_equalTo(90 + (44 - temp) / 2);
        make.width.mas_equalTo(200);
    }];
    
    //分割线
    UIView *lineC = [[UIView alloc] initWithFrame:CGRectMake(12, 134, SCREEN_WIDTH - 24, 1)];
    lineC.backgroundColor = RGBHex(0xf0f0f0);
    [headView addSubview:lineC];
    
    //请确认新密码
    self.confirmTextField = [[UITextField alloc] init];
    self.confirmTextField.placeholder = @"请确认新密码";
    self.confirmTextField.tag = 40002;
    self.confirmTextField.secureTextEntry = YES;
    self.confirmTextField.delegate = self;
    self.confirmTextField.font = [UIFont systemFontOfSize:15];
    [headView addSubview:self.confirmTextField];
    [self.confirmTextField   mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.top.mas_equalTo(135 + (44 - temp) / 2);
        make.width.mas_equalTo(200);
    }];
    
    //完成按钮
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.backgroundColor = RGBHex(0x14d02f);
    [nextBtn setTitle:@"完成" forState:UIControlStateNormal];
    nextBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [nextBtn setTintColor:[UIColor whiteColor]];
    nextBtn.layer.masksToBounds = YES;
    nextBtn.layer.cornerRadius = 22;
    [self.view addSubview:nextBtn];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(47);
        make.right.mas_equalTo(-47);
        make.top.mas_equalTo(300 * PROPORTION);
        make.height.mas_equalTo(44);
    }];
    [nextBtn addTarget:self action:@selector(nextBtnAction:) forControlEvents:UIControlEventTouchUpInside];
}

//完成按钮触发方法
- (void)nextBtnAction:(UIButton *)btn{
    [self.phoneNumber resignFirstResponder];
    [self.verification resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.confirmTextField resignFirstResponder];
    
    if ([Global isNullOrEmpty:self.phoneNumber.text]) {
        [Global showWithView:self.view withText:@"手机号不能为空"];
    }else if ([Global isNullOrEmpty:self.verification.text]){
        [Global showWithView:self.view withText:@"请先获取验证码"];
    }else if ([Global isNullOrEmpty:self.passwordTextField.text]){
        [Global showWithView:self.view withText:@"密码不能为空"];
    }else{
        if ([AppTools isNotPhoneNumber:self.phoneNumber.text]) {
            [Global showWithView:self.view withText:@"手机号格式不正确"];
        }else if (self.passwordTextField.text.length < 8){
            [Global showWithView:self.view withText:@"密码不能少于8位！"];
        }else if (![self.passwordTextField.text isEqualToString:self.confirmTextField.text]){
            [Global showWithView:self.view withText:@"两次输入的密码不一致"];
        }else{
            MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD.removeFromSuperViewOnHide = YES;
            HUD.labelText = @"修改中...";
            HUD.backgroundColor = [UIColor clearColor];
            
            NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
            [parame setObject:User_update_password forKey:@"uri"];
            [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
            [parame setObject:[self.preLabel.text stringByAppendingString:self.phoneNumber.text] forKey:@"phone"];
            [parame setObject:self.passwordTextField.text forKey:@"password"];
            [parame setObject:self.verification.text forKey:@"code"];
            
            [[HttpManager sharedManager] POST:User_update_password parame:parame sucess:^(id success) {
                [HUD hide:YES];
                if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
                    [self killNSTimer];
                    
                    [Global showWithView:self.view withText:@"修改成功！"];
                    
                    self.getpassword.userInteractionEnabled = YES;
                    [self.getpassword setTitle:@"获取验证码" forState:UIControlStateNormal];
                    [self.getpassword setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.navigationController popViewControllerAnimated:YES];
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

//获取验证码按钮触发方法
- (void)getVerification:(UIButton *)button{
    [self.phoneNumber resignFirstResponder];
    [self.verification resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.confirmTextField resignFirstResponder];
    //对手机号进行判断
    if ([Global isNullOrEmpty:self.phoneNumber.text]) {
        [Global showWithView:self.view withText:@"手机号不能为空"];
        return;
    }
    if ([AppTools isNotPhoneNumber:self.phoneNumber.text]) {
        [Global showWithView:self.view withText:@"手机号格式不正确"];
        return;
    }
    
    //判断手机号码正常后
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:Update_password_verification forKey:@"uri"];
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:[self.preLabel.text stringByAppendingString:self.phoneNumber.text] forKey:@"phone"];
    
    [[HttpManager sharedManager] POST:Update_password_verification parame:parame sucess:^(id success) {
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

#pragma mark - 其他点击触发方法
- (void)textFieldResponse:(UITapGestureRecognizer *)tap{
    [self.phoneNumber resignFirstResponder];
    [self.verification resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.confirmTextField resignFirstResponder];
}

- (void)back{
    [self.phoneNumber resignFirstResponder];
    [self.verification resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.confirmTextField resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self killNSTimer];
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
