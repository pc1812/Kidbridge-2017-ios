//
//  MineWaterViewController.m
//  PictureBook
//
//  Created by Yasin on 2017/7/10.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "MineWaterViewController.h"
#import "WaterDetailViewController.h"
#import "SRActionSheet.h"
#import "CustomIOSAlertView.h"

@interface MineWaterViewController ()<SRActionSheetDelegate, UITextFieldDelegate>

@property (nonatomic, strong)UIScrollView *rootScrollView;
@property (nonatomic, strong)UIImageView *imageView;
@property (nonatomic, strong)UILabel *waterLab;
@property (nonatomic, strong)UILabel *numLab;
@property (nonatomic, strong)UIButton *moneyBtn;
@property (nonatomic, strong)UILabel *promptLab;
@property (nonatomic, strong) UILabel *detailLab;

@end

@implementation MineWaterViewController
{
     UITextField *_numField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView = [UINavigationItem titleViewForTitle:@"我的水滴"];
    [self.view addSubview:self.rootScrollView];

    [self.rootScrollView addSubview:self.imageView];
    [self.rootScrollView addSubview:self.waterLab];
    [self.rootScrollView addSubview:self.numLab];
    [self.rootScrollView addSubview:self.detailLab];
    [self.rootScrollView addSubview:self.moneyBtn];
    [self.rootScrollView addSubview:self.promptLab];
   
    //得到基本固定参数字典，加入调用接口所需参数
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:User_bonus forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    
    [[HttpManager sharedManager] POST:User_bonus parame:parame sucess:^(id success) {
        
        if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
            
            self.numLab.text = [NSString stringWithFormat:@"%@", [[success objectForKey:@"data"] objectForKey:@"bonus"]];
            NSDictionary *numDic = StringFont_DicK(_numLab.font);
            CGSize numSize = [_numLab.text sizeWithAttributes:numDic];
            _numLab.frame = FRAMEMAKE_F((SCREEN_WIDTH - numSize.width) / 2, CGRectGetMaxY( _waterLab.frame) + 17, numSize.width, numSize.height)
        }else{
            NSLog(@"event = %@, describe = %@", [success objectForKey:@"event"], [success objectForKey:@"describe"]);
        }
    } failure:^(NSError *error) {
        [Global showWithView:self.view withText:@"网络错误"];
    }];
}

#pragma mark -  添加子视图
-(UIScrollView *)rootScrollView{
    if (!_rootScrollView) {
        self.rootScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-PBNew64)];
        self.rootScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT-PBNew64);
        self.rootScrollView.backgroundColor = [UIColor whiteColor];
        self.rootScrollView.showsVerticalScrollIndicator = NO;
        self.rootScrollView.showsHorizontalScrollIndicator = NO;
        self.rootScrollView.alwaysBounceVertical = YES;
    }
    return _rootScrollView;
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.image = [UIImage imageNamed:@"m_water"];
        _imageView.frame = FRAMEMAKE_F((SCREEN_WIDTH - _imageView.image.size.width) / 2, 50, _imageView.image.size.width, _imageView.image.size.height);
    }
    return _imageView;
}

- (UILabel *)waterLab{
    if (!_waterLab) {
        _waterLab = [UILabel new];
        LabelSet(_waterLab, @"水滴个数", [UIColor blackColor], 18, waterDic, waterSize);
        _waterLab.frame = FRAMEMAKE_F((SCREEN_WIDTH - waterSize.width) / 2, CGRectGetMaxY( _imageView.frame) + 22, waterSize.width, waterSize.height);
    }
    return _waterLab;
}

- (UILabel *)numLab{
    if (!_numLab) {
        _numLab = [UILabel new];
        _numLab.textColor = [Global convertHexToRGB:@"14d02f"];
        _numLab.font = [UIFont systemFontOfSize:30 weight:2];
        _numLab.text = @"0";
        NSDictionary *numDic = StringFont_DicK(_numLab.font );
        CGSize numSize = [_numLab.text sizeWithAttributes:numDic];
        _numLab.frame = FRAMEMAKE_F((SCREEN_WIDTH - numSize.width) / 2, CGRectGetMaxY( _waterLab.frame) + 17, numSize.width, numSize.height)
    }
    return _numLab;
}

- (UILabel *)detailLab{
    if (!_detailLab) {
        _detailLab = [UILabel new];
        _detailLab.textColor = [Global convertHexToRGB:@"fe6b76"];
        _detailLab.font = [UIFont systemFontOfSize:18];
        NSString *textStr = @"水滴明细";
        // 下划线
        NSDictionary *attribtDic = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
        NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:textStr attributes:attribtDic];
        _detailLab.attributedText = attribtStr;
        
        NSDictionary *deDic = StringFont_DicK(_detailLab.font );
        CGSize deSize = [_detailLab.text sizeWithAttributes:deDic];
        _detailLab.frame = FRAMEMAKE_F((SCREEN_WIDTH - deSize.width) / 2, CGRectGetMaxY( _numLab.frame) + 35, deSize.width, deSize.height)
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTap:)];
        [_detailLab addGestureRecognizer:tap];
        _detailLab.userInteractionEnabled = YES;
    }
    return _detailLab;
}

- (UIButton *)moneyBtn{
    if (!_moneyBtn) {
        _moneyBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        _moneyBtn.frame=CGRectMake(45, CGRectGetMaxY( _detailLab.frame) + 15, SCREEN_WIDTH- 90, 40);
        [_moneyBtn setTitle:@"兑换成 H币" forState:UIControlStateNormal];
        _moneyBtn.titleLabel.textColor = [UIColor whiteColor];
        _moneyBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:2];
        _moneyBtn.backgroundColor=[Global convertHexToRGB:@"14d02f"];
        [_moneyBtn addTarget:self action:@selector(moneyClick:) forControlEvents:UIControlEventTouchUpInside];
        _moneyBtn.layer.cornerRadius= 20;
        _moneyBtn.clipsToBounds=YES;
    }
    return _moneyBtn;
}


- (UILabel *)promptLab{
    if (!_promptLab) {
        _promptLab = [UILabel new];
        _promptLab.textColor = [Global convertHexToRGB:@"999999"];
        _promptLab.font = [UIFont systemFontOfSize:12 weight:2];
        _promptLab.text = @"提示: 100水滴可兑换1 H币";
        NSDictionary *proDic = StringFont_DicK(_promptLab.font );
        CGSize proSize = [_promptLab.text  sizeWithAttributes:proDic];
        _promptLab.frame = FRAMEMAKE_F((SCREEN_WIDTH - proSize.width) / 2, CGRectGetMaxY( _moneyBtn.frame) + 20, proSize.width, proSize.height)
    }
    return _promptLab;
}

#pragma mark - 充值、兑换触发方法
//充值
- (void)btnClick:(UIButton *)button{
    SRActionSheet *actionSheet = [SRActionSheet sr_actionSheetViewWithTitle:nil
                                                                cancelTitle:@"取消"
                                                           destructiveTitle:nil
                                                                otherTitles:@[@"支付宝支付", @"微信支付"]
                                                                otherImages:@[[UIImage imageNamed:@"m_ali"],
                                                                              [UIImage imageNamed:@"m_wechat"]
                                                                             ]
                                                                   delegate:self];
    actionSheet.otherActionItemAlignment = SROtherActionItemAlignmentCenter;
    [actionSheet show];
}

//兑换成H币
- (void)moneyClick:(UIButton *)button{
    
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    //添加子视图
    alertView.backgroundColor = [UIColor whiteColor];
    [alertView setSubView:[self addSubView]];
    //添加按钮标题数组
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"确定", @"取消", nil]];
    //添加按钮点击方法
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        
        if (buttonIndex == 0) {
            if ([Global isNullOrEmpty:_numField.text]) {
                [Global showWithView:self.view withText:@"输入的水滴不能为空～"];
                return;
            }
            
            MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD.labelText = @"提交中...";
            HUD.backgroundColor = [UIColor clearColor];
            
            NSMutableDictionary *params = [HttpManager necessaryParameterDictionary];
            [params setObject:Balance_ratio forKey:@"uri"];
            //得到加盐MD5加密后的sign，并添加到参数字典
            [params setObject:[HttpManager getAddSaltMD5Sign:params] forKey:@"sign"];
            
            [params setObject:@([_numField.text integerValue]) forKey:@"bonus"];
            
            
            [[HttpManager sharedManager]POST:Balance_ratio parame:params sucess:^(id success) {
                
                if ([success[@"event"] isEqualToString:@"SUCCESS"]) {
                    NSInteger waterNum = [_numLab.text integerValue];
                    waterNum = waterNum - _numField.text.integerValue;
                    _numLab.text = [NSString stringWithFormat:@"%zd",waterNum];
                    NSDictionary *numDic = StringFont_DicK(_numLab.font );
                    CGSize numSize = [_numLab.text sizeWithAttributes:numDic];
                    _numLab.frame = FRAMEMAKE_F((SCREEN_WIDTH - numSize.width) / 2, CGRectGetMaxY( _waterLab.frame) + 17, numSize.width, numSize.height)
                }
                
                if (![Global isNullOrEmpty:success[@"describe"]]) {
                    [Global showWithView:self.view withText:success[@"describe"]];
                }
                
                [alertView close];
                [HUD hide:YES];
            } failure:^(NSError *error) {
                [Global showWithView:self.view withText:@"网络错误"];
                [HUD hide:YES afterDelay:1];
                [alertView close];
            }];
        }else{
            //关闭
            [alertView close];
        }
        
    }];
    //显示
    [alertView show];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    [self.view endEditing:YES];
    
}

//自定义的子视图
- (UIView *)addSubView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 230, 90)];
    UILabel *view1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 230, 50)];
    view1.font = [UIFont systemFontOfSize:15 weight:2];
    view1.textColor = [UIColor blackColor];
    view1.text = @"请输入要兑换的水滴数";
    view1.textAlignment = NSTextAlignmentCenter;
    [view addSubview:view1];
    
    _numField = [[UITextField alloc] init];
    _numField.backgroundColor = [UIColor whiteColor];
    _numField.textColor = [UIColor blackColor];
    _numField.font = [UIFont systemFontOfSize:15];
    _numField.delegate = self;
    
    //光标颜色
    [_numField addTarget:self action:@selector(textFieldChangeMethod:) forControlEvents:UIControlEventEditingChanged];
    _numField.tintColor = [UIColor blackColor];
    _numField.keyboardType = UIKeyboardTypeNumberPad;
    _numField.returnKeyType = UIReturnKeyDone;
    [view addSubview:_numField];
    _numField.frame = FRAMEMAKE_F(15 , CGRectGetMaxY(view1.frame), 230 - 30, 30);
    
    NSMutableParagraphStyle *style = [_numField.defaultTextAttributes[NSParagraphStyleAttributeName] mutableCopy];
    
    style.minimumLineHeight = _numField.font.lineHeight - (_numField.font.lineHeight - [UIFont systemFontOfSize:15.0].lineHeight) / 2.0;
    
    _numField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入整数数字"
                                                                      attributes:@{
                                                                                   NSForegroundColorAttributeName: RGBHex(0x999999),
                                                                                   NSFontAttributeName : [UIFont systemFontOfSize:15.0],
                                                                                   NSParagraphStyleAttributeName : style
                                                                                   }];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

#pragma mark - UITextField代理方法
-(void)textFieldChangeMethod:(UITextField *)textField{
    if (textField == _numField) {
        
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField endEditing:YES];
    [_numField resignFirstResponder];
    return YES;
}

#pragma mark - SRActionSheetDelegate
- (void)actionSheet:(SRActionSheet *)actionSheet didSelectSheet:(NSInteger)index {
    NSLog(@"%zd", index);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)clickTap:(UIButton *)button{
    WaterDetailViewController *detailVC = [[WaterDetailViewController alloc] init];
    [self.navigationController pushViewController:detailVC animated:YES];
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
