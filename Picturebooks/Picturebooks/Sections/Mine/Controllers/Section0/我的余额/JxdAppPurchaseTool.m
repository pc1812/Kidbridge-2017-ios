//
//  JxdAppPurchaseTool.m
//  Picturebooks
//
//  Created by 吉晓东 on 2018/3/2.
//  Copyright © 2018年 ZhiyuanNetwork. All rights reserved.
//

#import "JxdAppPurchaseTool.h"

#define A_Key @"Purchase"

@interface JxdAppPurchaseTool() <SKPaymentTransactionObserver,SKProductsRequestDelegate>

/** 商品字典 */
@property(nonatomic,strong)NSMutableDictionary *productDict;

@end

static JxdAppPurchaseTool *_instance = nil;
@implementation JxdAppPurchaseTool

#pragma mark - 创建单例
/** 创建单例 */
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (instancetype)defaultTool {
    if (_instance == nil) {
        _instance = [[super alloc] init];
        // 初始化
        [_instance setup];
    }
    return _instance;
}


#pragma mark - 初始化
/** 初始化 */
-(void)setup {
    // 支付后是否验证凭证
    self.checkAfterPay = YES;
    
    // 设置购买队列的监听器
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
}

/** 移除购买队列检测器 */
- (void)removeTransactionObserver
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}


#pragma mark 询问苹果的服务器能够销售哪些商品
/** 询问苹果的服务器能够销售哪些商品 */
- (void)requestProductsWithProductID:(NSString *)productID
{
    // 判断设置是否具备购买的条件
    if ([SKPaymentQueue canMakePayments]) {
        NSSet *productIdentifier = [NSSet setWithObject:productID];
        // "异步"询问苹果能否销售
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifier];
        request.delegate = self;
        // 启动请求
        [request start];
    } else {
        NSLog(@"程序内不可以进行购买");
    }
    
}

#pragma mark - 用户决定购买商品
/**
 用户决定购买商品

 @param product 商品
 */
- (void)buyProduct:(SKProduct *)product
{
    // 要购买产品(店员给用户开了个小票)
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    
    // 去收银台排队，准备购买(异步网络)
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}


#pragma mark - <SKProductsRequestDelegate>
/**
 *  获取询问结果，成功采取操作把商品加入可售商品字典里
 *
 *  @param request  请求内容
 *  @param response 返回的结果
 */
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{

    NSMutableArray *productArray = [NSMutableArray array];

    for (SKProduct *product in response.products) {
        
        [productArray addObject:product];
    }

    // 代理获取可购买的商品
    if ([self.delegate respondsToSelector:@selector(appPurchaseTool:gotProducts:)]) {
        [self.delegate appPurchaseTool:self gotProducts:productArray];
    }
    
}


#pragma mark - <SKPaymentTransactionObserver>
/**
 *  监测购买队列的变化,判断购买状态是否成功
 *
 *  @param queue        队列
 *  @param transactions 交易
 */
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    // 监听购买状态
    [transactions enumerateObjectsUsingBlock:^(SKPaymentTransaction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        switch (obj.transactionState) {
            case SKPaymentTransactionStatePurchasing: // 正在付款
                NSLog(@"正在支付");
                break;
                
            case SKPaymentTransactionStatePurchased: // 交易完成
                NSLog(@"支付完成");
                // 购买完成
                [self completeTransactionWithID:obj.payment.productIdentifier];
                // 将交易从交易队列中删除
                [queue finishTransaction:obj];
                break;
                
            case SKPaymentTransactionStateFailed: // 交易失败
                NSLog(@"支付失败");
                [self failedTransaction:obj];
                // 将交易从交易队列中删除
                [queue finishTransaction:obj];
                break;
                
            case SKPaymentTransactionStateDeferred: // 推迟付款
                NSLog(@"推迟支付");
                break;
                
            default:
                break;
        }
    }];
}

/** 交易失败 */
- (void)failedTransaction:(SKPaymentTransaction *)obj
{
    NSString *errorString;
    if (obj.error.code == SKErrorPaymentCancelled) {
        errorString = @"你已取消购买!";
        
    } else if(obj.error.code == SKErrorPaymentInvalid) {
        errorString = @"支付无效!";
        
    } else if(obj.error.code == SKErrorPaymentNotAllowed) {
        errorString = @"不允许支付!";
        
    } else if(obj.error.code == SKErrorStoreProductNotAvailable) {
        errorString = @"产品无效!";
        
    } else if(obj.error.code == SKErrorClientInvalid) {
        errorString = @"客服端无效!";
        
    } else if (obj.error.code == SKErrorCloudServiceNetworkConnectionFailed) {
        errorString = @"网络异常!";
        
    } else if (obj.error.code == SKErrorUnknown) {
        errorString = @"购买:支付失败!";
    }
    
    // 通知代理
    if ([self.delegate respondsToSelector:@selector(appPurchaseTool:canceldWithProductID:andErrorString:)]) {
        [self.delegate appPurchaseTool:self canceldWithProductID:obj.payment.productIdentifier andErrorString:errorString];
    }
    
}

/**
 购买完成

 @param productID 商品 ID
 */
- (void)completeTransactionWithID:(NSString *)productID
{
    NSLog(@"交易完成");
    // 获取购买凭据
    if (productID.length > 0) {
        // 获取到苹果返回的交易凭据
        // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
        NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
        // 从沙盒中获取到购买凭据
        NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
        NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        
        // 保存购买凭据,用于对单处理
        [[NSUserDefaults standardUserDefaults] setObject:encodeStr forKey:@"verify_Pruchase"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // 对凭据进行验证
        // 1.直接向苹果服务器进行验证
        // 2.将凭证交给自己的服务器进行验证 (推荐做法)
        [self verifyPruchase];
    }
    
}

#pragma mark - 将凭据交给自己的服务器进行验证
/** 将凭据交给自己的服务器进行验证 */
- (void)verifyPruchase
{
    PBLog(@"开始向服务器进行验证!");
    
    NSString *receipt = [[NSUserDefaults standardUserDefaults] objectForKey:@"verify_Pruchase"];

//    NSLog(@"凭证:%@",receipt);
    
    // 有可用的凭据
    if (![Global isNullOrEmpty:receipt]) {
        /** 后台服务器进行验证凭据的代码 */
        //得到基本固定参数字典，加入调用接口所需参数
        NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
        [parame setObject:Iap_iosValidate forKey:@"uri"];
        //得到加盐MD5加密后的sign，并添加到参数字典
        [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
        // 添加对应的参数
        [parame setValue:receipt forKey:@"receipt-data"];
        
        [[HttpManager sharedManager] POST:Iap_iosValidate parame:parame sucess:^(id success) {
            
            if ([success[@"event"] isEqualToString:@"SUCCESS"]) {
                
//                NSLog(@"success:%@",success);
                // 验证成功:移除保存的购买凭据
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"verify_Pruchase"];
                
                // 验证成功:通知代理
                if ([self.delegate respondsToSelector:@selector(appPurchaseTool:checkSuccessedWithInfo:)]) {
                    [self.delegate appPurchaseTool:self checkSuccessedWithInfo:@"SUCCESS"];
                }
                
            } else {
                // 验证成功:通知代理
                if ([self.delegate respondsToSelector:@selector(appPurchaseTool:checkFailedWithInfo:)]) {
                    [self.delegate appPurchaseTool:self checkFailedWithInfo:success[@"describe"]];
                }
                
            }
    
        } failure:^(NSError *error) {
            // 验证成功:通知代理
            if ([self.delegate respondsToSelector:@selector(appPurchaseTool:checkFailedWithInfo:)]) {
                [self.delegate appPurchaseTool:self checkFailedWithInfo:@"网络异常"];
            }
            
        }];
        
    } else {
        NSLog(@"不存在凭据");
    }
    
}



@end





















