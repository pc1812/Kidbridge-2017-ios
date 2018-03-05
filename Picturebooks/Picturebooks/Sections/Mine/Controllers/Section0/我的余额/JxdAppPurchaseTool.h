//
//  JxdAppPurchaseTool.h
//  Picturebooks
//
//  Created by 吉晓东 on 2018/3/2.
//  Copyright © 2018年 ZhiyuanNetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>  // 内购

@class JxdAppPurchaseTool;
@protocol JxdAppPurchaseToolDelegate <NSObject>

/**
 代理：已刷新可购买商品

 @param products 商品数组
 */
- (void)appPurchaseTool:(JxdAppPurchaseTool *)appPurchaseTool gotProducts:(NSMutableArray *)products;


/**
 代理：取消购买,没有购买成功

 @param productID 商品ID
 */
-(void)appPurchaseTool:(JxdAppPurchaseTool *)appPurchaseTool canceldWithProductID:(NSString *)productID andErrorString:(NSString *)string;

/**
 代理：购买成功

 @param info 成功信息
 */
-(void)appPurchaseTool:(JxdAppPurchaseTool *)appPurchaseTool checkSuccessedWithInfo:(NSString *)info;

/**
 代理：验证失败

 @param info 失败信息
 */
-(void)appPurchaseTool:(JxdAppPurchaseTool *)appPurchaseTool checkFailedWithInfo:(NSString *)info;

@end

@interface JxdAppPurchaseTool : NSObject

/** 内购工具类代理 */
@property(nonatomic,weak) id <JxdAppPurchaseToolDelegate> delegate;

/** 购买完后是否在iOS端向服务器验证一次,默认为YES */
@property (nonatomic,assign) BOOL checkAfterPay;

/** 单例 */
+ (instancetype)defaultTool;

/** 移除购买队列检测器 */
- (void)removeTransactionObserver;

/** 询问苹果的服务器能够销售哪些商品 */
- (void)requestProductsWithProductID:(NSString *)productID;

/**  用户决定购买商品 */
- (void)buyProduct:(SKProduct *)product;

/** 将凭据交给自己的服务器进行验证 */
- (void)verifyPruchase;

@end
















