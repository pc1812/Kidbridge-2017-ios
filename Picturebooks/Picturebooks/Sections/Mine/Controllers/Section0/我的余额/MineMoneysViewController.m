//
//  MineMoneysViewController.m
//  Picturebooks
//
//  Created by Yasin on 2017/7/20.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "MineMoneysViewController.h"
#import "MoneyDetailViewController.h"
#import "SRActionSheet.h"
#import "CustomIOSAlertView.h"
#import "WXApi.h"
#import <AlipaySDK/AlipaySDK.h>

#import "MinePayListViewController.h" // 充值列表

@interface MineMoneysViewController ()<SRActionSheetDelegate, UITextFieldDelegate>

@property (nonatomic, strong)UIScrollView *rootScrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *balanceLab;
@property (nonatomic, strong) UILabel *moneyLab;
@property (nonatomic, strong) UILabel *detailLab;
@property (nonatomic, strong) UIButton *rechargeBtn;
@property (nonatomic, strong) UILabel *promptLab;
@property (nonatomic, strong) UITextField *numField;

@end

@implementation MineMoneysViewController

- (void)dealloc{
    NSLog(@"“我的H币”界面无内存泄漏");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView = [UINavigationItem titleViewForTitle:@"我的 H币"];
    
    [self.view addSubview:self.rootScrollView];
    [self.rootScrollView addSubview:self.imageView];
    [self.rootScrollView addSubview:self.balanceLab];
    [self.rootScrollView addSubview:self.moneyLab];
    [self.rootScrollView addSubview:self.detailLab];
    [self.rootScrollView addSubview:self.rechargeBtn];
    [self.rootScrollView addSubview:self.promptLab];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMyMoney) name:@"WeChatPayResult" object:nil];
    
//    [self reloadMyMoney];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    [self reloadMyMoney];
}

- (void)reloadMyMoney{
    //得到基本固定参数字典，加入调用接口所需参数
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:User_balance forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    
    [[HttpManager sharedManager] POST:User_balance parame:parame sucess:^(id success) {
        
        if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
            
            self.moneyLab.text = [NSString stringWithFormat:@"%.0f", [success[@"data"][@"balance"] floatValue]];
            
            NSDictionary *numDic = StringFont_DicK(_moneyLab.font);
            CGSize numSize = [_moneyLab.text sizeWithAttributes:numDic];
            _moneyLab.frame = FRAMEMAKE_F((SCREEN_WIDTH - numSize.width) / 2, CGRectGetMaxY( _balanceLab.frame) + 17, numSize.width, numSize.height)
        }else{
            NSLog(@"event = %@, describe = %@", [success objectForKey:@"event"], [success objectForKey:@"describe"]);
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

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
        _imageView.image = [UIImage imageNamed:@"m_balance"];
        _imageView.frame = FRAMEMAKE_F((SCREEN_WIDTH - _imageView.image.size.width) / 2, 50, _imageView.image.size.width, _imageView.image.size.height);
    }
    return _imageView;
}

- (UILabel *)balanceLab{
    if (!_balanceLab) {
        _balanceLab = [UILabel new];
        LabelSet(_balanceLab, @"H币", [UIColor blackColor], 18, waterDic, waterSize);
        _balanceLab.frame = FRAMEMAKE_F((SCREEN_WIDTH - waterSize.width) / 2, CGRectGetMaxY( _imageView.frame) + 22, waterSize.width, waterSize.height);
    }
    return _balanceLab;
}

- (UILabel *)moneyLab{
    if (!_moneyLab) {
        _moneyLab = [UILabel new];
        _moneyLab.textColor = [Global convertHexToRGB:@"14d02f"];
        _moneyLab.font = [UIFont systemFontOfSize:30 weight:2];
        _moneyLab.text = @"¥0";
        NSDictionary *numDic = StringFont_DicK(_moneyLab.font);
        CGSize numSize = [_moneyLab.text sizeWithAttributes:numDic];
        _moneyLab.frame = FRAMEMAKE_F((SCREEN_WIDTH - numSize.width) / 2, CGRectGetMaxY( _balanceLab.frame) + 17, numSize.width, numSize.height)
    }
    return _moneyLab;
}

- (UILabel *)detailLab{
    if (!_detailLab) {
        _detailLab = [UILabel new];
        _detailLab.textColor = [Global convertHexToRGB:@"fe6b76"];
        _detailLab.font = [UIFont systemFontOfSize:18];
        NSString *textStr = @"H币明细";
        // 下划线
        NSDictionary *attribtDic = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
        NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:textStr attributes:attribtDic];
        _detailLab.attributedText = attribtStr;
        
        NSDictionary *deDic = StringFont_DicK(_detailLab.font );
        CGSize deSize = [_detailLab.text sizeWithAttributes:deDic];
        _detailLab.frame = FRAMEMAKE_F((SCREEN_WIDTH - deSize.width) / 2, CGRectGetMaxY( _moneyLab.frame) + 44, deSize.width, deSize.height)
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTap:)];
        [_detailLab addGestureRecognizer:tap];
        _detailLab.userInteractionEnabled = YES;
    }
    return _detailLab;
}

- (UIButton *)rechargeBtn{
    if (!_rechargeBtn) {
        _rechargeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        _rechargeBtn.frame=CGRectMake(45, CGRectGetMaxY( _detailLab.frame) + 20, SCREEN_WIDTH- 90, 40);
        [_rechargeBtn setTitle:@"充值" forState:UIControlStateNormal];
        _rechargeBtn.titleLabel.textColor = [UIColor whiteColor];
        _rechargeBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:2];
        _rechargeBtn.backgroundColor=[Global convertHexToRGB:@"fe6b76"];
        [_rechargeBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        _rechargeBtn.layer.cornerRadius= 20;
        _rechargeBtn.clipsToBounds=YES;
    }
    return _rechargeBtn;
}

- (UILabel *)promptLab{
    if (!_promptLab) {
        _promptLab = [UILabel new];
        _promptLab.textColor = [Global convertHexToRGB:@"999999"];
        _promptLab.font = [UIFont systemFontOfSize:12 weight:2];
        _promptLab.text = @"注:H币可用于解锁绘本或兑换其他商品,不可提现.";
        _promptLab.textAlignment = NSTextAlignmentCenter;
        _promptLab.numberOfLines = 0;
        double height=[Global getSizeOfString:_promptLab.text  maxWidth:SCREEN_WIDTH- 60 maxHeight:10000 withFontSize:12].height;
        _promptLab.frame = FRAMEMAKE_F(0, CGRectGetMaxY( _rechargeBtn.frame) + 20, SCREEN_WIDTH, height);
    }
    return _promptLab;
}

- (void)clickTap:(UITapGestureRecognizer *)tap{
    MoneyDetailViewController *moneyDetail = [[MoneyDetailViewController alloc] init];
    [self.navigationController pushViewController:moneyDetail animated:YES];
}


#pragma mark - 充值、兑换触发方法
//充值
- (void)btnClick:(UIButton *)button{
    
    // 充值列表
    MinePayListViewController *payListVC = [[MinePayListViewController alloc] init];
    [self.navigationController pushViewController:payListVC animated:YES];
    
//    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
//    //添加子视图
//    alertView.backgroundColor = [UIColor whiteColor];
//    [alertView setSubView:[self addSubView]];
//    //添加按钮标题数组
//    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"确定", @"取消", nil]];
//    //添加按钮点击方法
//    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
//        if (buttonIndex == 0) {
//            [alertView close];
//
//            if ([Global isNullOrEmpty:self.numField.text]) {
//                [Global showWithView:self.view withText:@"请输入充值金额"];
//                return;
//            }else if ([self.numField.text isEqualToString:@"0"] || [self.numField.text isEqualToString:@"0.0"] || [self.numField.text isEqualToString:@"0.00"]){
//                [Global showWithView:self.view withText:@"输入的金额不能为0"];
//                return;
//
//            }
//            SRActionSheet *actionSheet = [SRActionSheet sr_actionSheetViewWithTitle:nil
//                                                                        cancelTitle:@"取消"
//                                                                   destructiveTitle:nil
//                                                                        otherTitles:@[@"支付宝支付", @"微信支付"]
//                                                                        otherImages:@[[UIImage imageNamed:@"m_ali"],
//                                                                                      [UIImage imageNamed:@"m_wechat"]]
//                                                                           delegate:self];
//            actionSheet.otherActionItemAlignment = SROtherActionItemAlignmentCenter;
//            [actionSheet show];
//        }
//        //关闭
//        [alertView close];
//    }];
//    //显示
//    [alertView show];
    
}

//自定义的子视图
- (UIView *)addSubView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 230, 90)];
    
    UILabel *view1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 230, 50)];
    [view addSubview:view1];
    view1.font = [UIFont systemFontOfSize:15 weight:2];
    view1.textColor = [UIColor blackColor];
    view1.text = @"请输入充值金额";
    view1.textAlignment = NSTextAlignmentCenter;
    
    _numField = [[UITextField alloc] init];
    _numField.backgroundColor = [UIColor whiteColor];
    _numField.textColor = [UIColor blackColor];
    _numField.font = [UIFont systemFontOfSize:15];
    _numField.delegate = self;
    
    //光标颜色
    [_numField addTarget:self action:@selector(textFieldChangeMethod:) forControlEvents:UIControlEventEditingChanged];
    _numField.tintColor = [UIColor blackColor];
    _numField.keyboardType = UIKeyboardTypeDecimalPad;
    _numField.returnKeyType = UIReturnKeyDone;
    [view addSubview:_numField];
    _numField.frame = FRAMEMAKE_F(15 , CGRectGetMaxY(view1.frame), 230 - 30, 30);
    
    NSMutableParagraphStyle *style = [_numField.defaultTextAttributes[NSParagraphStyleAttributeName] mutableCopy];
    style.minimumLineHeight = _numField.font.lineHeight - (_numField.font.lineHeight - [UIFont systemFontOfSize:15.0].lineHeight) / 2.0;
    _numField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入充值金额"
                                                                      attributes:@{
                                                                                   NSForegroundColorAttributeName: RGBHex(0x999999),
                                                                                   NSFontAttributeName : [UIFont systemFontOfSize:15.0],
                                                                                   NSParagraphStyleAttributeName : style
                                                                                   }
                                       ];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}


#pragma mark - SRActionSheetDelegate
- (void)actionSheet:(SRActionSheet *)actionSheet didSelectSheet:(NSInteger)index {
    
    if (index == 0) {
        NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
        [parame setObject:Payment_alipay forKey:@"uri"];
        [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
        [parame setObject:@([self.numField.text doubleValue]) forKey:@"fee"];
        
        [[HttpManager sharedManager] POST:Payment_alipay parame:parame sucess:^(id success) {
            if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
                //应用注册scheme,在AliSDKDemo-Info.plist定义URL types
                NSString *appScheme = @"picturebooksalipay";
                // NOTE: 将签名成功字符串格式化为订单字符串,请严格按照该格式
                NSString *orderString = [[success objectForKey:@"data"] objectForKey:@"payment"];
                
                // NOTE: 调用支付结果开始支付
                [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                    NSString *strTitle = @"支付结果";
                    NSString *strMsg;
                    if ([[resultDic objectForKey:@"resultStatus"] isEqualToString:@"9000"]) {
                        strMsg = @"支付结果：成功！";
                    }else if ([[resultDic objectForKey:@"resultStatus"] isEqualToString:@"8000"]){
                        strMsg = @"支付结果：正在处理中，请稍后查询商户订单列表中订单的支付状态";
                    }else{
                        strMsg = @"支付结果：失败！";
                    }
                    //前端提示支付结果
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:strTitle message:strMsg preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        //刷新H币
                        [self reloadMyMoney];
                    }];
                    [alert addAction:action];
                    [self presentViewController:alert animated:YES completion:nil];
                }];
            }else{
                [Global showWithView:self.view withText:[success objectForKey:@"describe"]];
            }
        } failure:^(NSError *error) {
            [Global showWithView:self.view withText:@"网络异常"];
        }];
    }else if(index == 1){
        if (![WXApi isWXAppInstalled]) {
            [self setupAlertController];
        }else{
            NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
            [parame setObject:Payment_wechat forKey:@"uri"];
            [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
            [parame setObject:@([self.numField.text doubleValue]) forKey:@"fee"];
            
            [[HttpManager sharedManager] POST:Payment_wechat parame:parame sucess:^(id success) {
                if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
                    NSMutableDictionary *orderDic = [[success objectForKey:@"data"] objectForKey:@"payment"];
                    NSLog(@"%@", orderDic);
                    PayReq *req = [[PayReq alloc] init];
                    req.partnerId = [orderDic objectForKey:@"partnerid"];
                    NSLog(@"%@", req.partnerId);
                    req.prepayId = [orderDic objectForKey:@"prepayid"];
                    NSLog(@"%@", req.prepayId);
                    req.nonceStr = [orderDic objectForKey:@"noncestr"];
                    NSLog(@"%@", req.nonceStr);
                    //字符串转换为UInt32
                    req.timeStamp = [[orderDic objectForKey:@"timestamp"] intValue];
                    NSLog(@"%u", (unsigned int)req.timeStamp);
                    req.package = @"Sign=WXPay";
                    NSLog(@"%@", req.package);
                    req.sign = [orderDic objectForKey:@"sign"];
                    NSLog(@"%@", req.sign);
                    
                    if (![WXApi sendReq:req]){
                        [Global showWithView:self.view withText:@"调起微信支付失败~"];
                    }
                }else{
                    [Global showWithView:self.view withText:[success objectForKey:@"describe"]];
                }
            } failure:^(NSError *error) {
                [Global showWithView:self.view withText:@"网络异常"];
            }];
            
        }
    }
    
}

//设置弹出提示语
- (void)setupAlertController {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请先安装微信客户端" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:actionConfirm];
    [self presentViewController:alert animated:YES completion:nil];
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
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableString * futureString = [NSMutableString stringWithString:textField.text];
    [futureString  insertString:string atIndex:range.location];
    NSInteger flag=0;
    const NSInteger limited = 2;//小数点后需要限制的个数
    for (int i = futureString.length-1; i>=0; i--) {
        
        if ([futureString characterAtIndex:i] == '.') {
            if (flag > limited) {
                return NO;
            }
            break;
        }
        flag++;
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
