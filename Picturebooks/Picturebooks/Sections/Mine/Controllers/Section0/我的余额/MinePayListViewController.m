//
//  MinePayListViewController.m
//  Picturebooks
//
//  Created by 吉晓东 on 2018/3/1.
//  Copyright © 2018年 ZhiyuanNetwork. All rights reserved.
//

#import "MinePayListViewController.h"
#import "JxdAppPurchaseTool.h"

@interface MinePayListViewController ()<UITableViewDelegate, UITableViewDataSource,JxdAppPurchaseToolDelegate>

/** tableView */
@property (nonatomic,strong) UITableView *tableView;

/** 充值列表数组 */
@property (nonatomic,strong) NSArray *productsArray;

/** 内购工具类 */
@property (nonatomic,strong) JxdAppPurchaseTool *purchaseTool;

@end

static NSString *const identifier = @"cell_identifier";

@implementation MinePayListViewController

/** 懒加载-- tableView */
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-PBNew64) style:UITableViewStylePlain];
        [self.view addSubview:_tableView];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.tableFooterView = [UIView new];
        
        // 注册 cell
//        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
    }
    return _tableView;
    
}

/** 懒加载--充值列表数组 */
- (NSArray *)productsArray {
    if (!_productsArray) {
        _productsArray = [NSArray array];
    }
    return _productsArray;
}

/** 懒加载--内购工具类 */
- (JxdAppPurchaseTool *)purchaseTool {
    if (!_purchaseTool) {
        PBLog(@"创建内购工具类");
        _purchaseTool = [JxdAppPurchaseTool defaultTool];
        _purchaseTool.delegate = self;
    }
    return _purchaseTool;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = [UINavigationItem titleViewForTitle:@"充值列表"];
    
    // 获取商品列表数据
    [self loadProductsListData];
    
    // 初始化内购工具类
    [self purchaseTool];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 购买成功:移除购买队列检测器
    PBLog(@"移除购买队列监听器");
    [self.purchaseTool removeTransactionObserver];
    self.purchaseTool = nil;
}


#pragma mark - 服务器获取商品列表数据
- (void)loadProductsListData
{
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.labelText = @"加载中...";
    HUD.backgroundColor = [UIColor clearColor];
    
    //得到基本固定参数字典，加入调用接口所需参数
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:Iap_ios forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    
    
    [[HttpManager sharedManager] POST:Iap_ios parame:parame sucess:^(id success) {
        [HUD hide:YES];
        
        NSLog(@"%@",success);
        if ([success[@"event"] isEqualToString:@"SUCCESS"]) {
            self.productsArray = success[@"data"];
            [self.tableView reloadData];
        } else {
            PBLog(@"%@",success[@"describe"]);
        }
        
    } failure:^(NSError *error) {
        [HUD hide:YES];
        [Global showWithView:self.view withText:@"网络错误"];
    }];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.productsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    
    cell.textLabel.text = self.productsArray[indexPath.row][@"name"];
    cell.detailTextLabel.text = self.productsArray[indexPath.row][@"des"];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // 返回按钮不可以点击
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    NSString *productId = self.productsArray[indexPath.row][@"product"];
    // 根据商品 id 从苹果服务器获取对应的商品
    [self.purchaseTool requestProductsWithProductID:productId];
    
}

#pragma mark - JxdAppPurchaseToolDelegate
/**
 代理：已刷新可购买商品
 
 @param products 商品数组
 */
- (void)appPurchaseTool:(JxdAppPurchaseTool *)appPurchaseTool gotProducts:(NSMutableArray *)products
{
    // 进行购买该商品
    [appPurchaseTool buyProduct:products[0]];
}


/**
 代理：取消购买,没有购买成功
 
 @param productID 商品ID
 */
-(void)appPurchaseTool:(JxdAppPurchaseTool *)appPurchaseTool canceldWithProductID:(NSString *)productID andErrorString:(NSString *)string
{
    // 返回按钮可以点击
    self.navigationItem.leftBarButtonItem.enabled = YES;
    [Global showWithView:self.view withText:string];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

/**
 代理：购买成功
 
 @param info 成功信息
 */
-(void)appPurchaseTool:(JxdAppPurchaseTool *)appPurchaseTool checkSuccessedWithInfo:(NSString *)info
{
    // 返回按钮可以点击
    self.navigationItem.leftBarButtonItem.enabled = YES;
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    PBLog(@"购买成功:%@",info);
    // 进行界面的跳转:上一个界面
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 代理：验证失败
 
 @param info 失败信息
 */
-(void)appPurchaseTool:(JxdAppPurchaseTool *)appPurchaseTool checkFailedWithInfo:(NSString *)info
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    // 继续验证凭据
    [appPurchaseTool verifyPruchase];
    PBLog(@"验证失败:%@",info);
}

@end




