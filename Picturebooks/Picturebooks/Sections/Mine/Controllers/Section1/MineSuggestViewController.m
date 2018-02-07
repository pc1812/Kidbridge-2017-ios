//
//  MineSuggestViewController.m
//  PictureBook
//
//  Created by Yasin on 2017/7/10.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "MineSuggestViewController.h"

@interface MineSuggestViewController ()<UITextViewDelegate>

@property(nonatomic,strong)  UITextView  *nickNameTextView;

@end

@implementation MineSuggestViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.titleView=[UINavigationItem titleViewForTitle:@"反馈"];
    
    self.nickNameTextView=[GCPlaceholderTextView initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 250) andText:@"请填写您的意见或建议，我们会及时处理..."];
    self.nickNameTextView.delegate = self;
    self.nickNameTextView.scrollEnabled = YES;
    [self.view addSubview:self.nickNameTextView];
    
    UIButton *submitBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.frame=CGRectMake(45, 320, SCREEN_WIDTH- 90, 40);
    [submitBtn setTitle:@"提交" forState:UIControlStateNormal];
    submitBtn.titleLabel.textColor = [UIColor whiteColor];
    submitBtn.backgroundColor=[Global convertHexToRGB:@"14d02f"];
    [submitBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    submitBtn.layer.cornerRadius= 20;
    submitBtn.clipsToBounds=YES;
    [self.view addSubview:submitBtn];
}

-(void)btnClick{
    if ([self.nickNameTextView.text isEqualToString:@""]) {
        [Global showWithView:self.view withText:@"请输入内容"];
        return;
    }else{
        [self.view endEditing:YES];
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.labelText = @"提交中...";
        HUD.backgroundColor = [UIColor clearColor];
       
        //得到基本固定参数字典，加入调用接口所需参数
        NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
        [parame setObject:User_feedback forKey:@"uri"];
        //得到加盐MD5加密后的sign，并添加到参数字典
        [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
        [parame setObject:self.nickNameTextView.text forKey:@"content"];
        
        [[HttpManager sharedManager] POST:User_feedback parame:parame sucess:^(id success) {
            [HUD hide:YES];
            if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
                [Global showWithView:self.view withText:@"提交成功"];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
            else{
                [Global showWithView:self.view withText:[success objectForKey:@"describe"]];
            }
        } failure:^(NSError *error) {
            [HUD hide:YES];
            [Global showWithView:self.view withText:@"网络错误"];
        }];
    }
}

#pragma mark  -textview  delegate
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

-(void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length==0) {
        //self.signLabel.text = @"还可以输入100字";
    }else if (textView.text.length>100) {
        self.nickNameTextView.text=[textView.text substringToIndex:100];
        //self.signLabel.text = @"还可以输入0字";
    }else{
        //self.signLabel.text = [NSString stringWithFormat:@"还可以输入%ld字",(100 -(long)textView.text.length)];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
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
