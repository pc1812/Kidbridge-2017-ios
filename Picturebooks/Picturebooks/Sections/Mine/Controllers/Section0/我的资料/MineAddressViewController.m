//
//  MindAddressViewController.m
//  PictureBook
//
//  Created by Yasin on 2017/7/11.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "MineAddressViewController.h"

#import "MineAddressCell.h" // cell
@interface MineAddressViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;
// 收货地址字典
@property (nonatomic, strong)NSMutableDictionary *addressDictM;
/** 姓名 */
@property (nonatomic,strong) NSString *nameLabStr;
/** 手机号 */
@property (nonatomic,strong) NSString *phoneLabStr;
/** 地址 */
@property (nonatomic,strong) NSString *detialLabStr;

@end

static NSString *addressCell_identifier = @"addressCell_identifier";
@implementation MineAddressViewController

- (NSMutableDictionary *)addressDictM {
    if (!_addressDictM) {
        _addressDictM = [NSMutableDictionary new];
    }
    return _addressDictM;
}

/** 懒加载-- tableView */
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-PBNew64) style:UITableViewStylePlain];
        _tableView.dataSource=self;
        _tableView.delegate=self;
        _tableView.showsVerticalScrollIndicator=NO;
        _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _tableView.showsHorizontalScrollIndicator=NO;
        // 注册 cell
        [_tableView registerClass:[MineAddressCell class] forCellReuseIdentifier:addressCell_identifier];
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView = [UINavigationItem titleViewForTitle:@"地址"];
    
//    self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightBarButtonItemWithTitle:@"添加地址" target:self selector:@selector(addClick:)];
    
    [self.view addSubview:self.tableView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 请求数据
    [self requestData];
}

- (void)requestData
{
    // 请求地址数据
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.backgroundColor = [UIColor clearColor];
    
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:User_info forKey:@"uri"];
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    
    [[HttpManager sharedManager]POST:User_info parame:parame sucess:^(id success) {
        [HUD hide:YES];
        if ([success[@"event"] isEqualToString:@"SUCCESS"]) {
            self.addressDictM = [NSMutableDictionary dictionaryWithDictionary:success[@"data"]];
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        [HUD hide:YES afterDelay:1];
        [Global showWithView:self.view withText:@"网络错误"];
    }];
}

//添加地址
//- (void)addClick:(UIButton *)button{
//    MineAddAddrViewController *mineAddVC = [[MineAddAddrViewController alloc] init];
//    [self.navigationController pushViewController:mineAddVC animated:YES];
//}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MineAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:addressCell_identifier forIndexPath:indexPath];
    cell.nameStr = self.addressDictM[@"receivingContact"];
    cell.phoneStr = self.addressDictM[@"receivingPhone"];
    if (self.addressDictM[@"receivingRegion"] || self.addressDictM[@"receivingStreet"]) {
        cell.detialStr = [NSString stringWithFormat:@"%@%@",self.addressDictM[@"receivingRegion"],self.addressDictM[@"receivingStreet"]];
    }
    
    return cell;
    
//    static NSString *cellIdentifier = @"cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//    }
//        UILabel *nameLab = [[UILabel alloc] init];
//        [cell.contentView addSubview:nameLab];
//        nameLab.textColor = [UIColor blackColor];
//        nameLab.font = [UIFont systemFontOfSize:14];
////        nameLab.text = @"小美美";
//        if (self.addressDictM[@"receivingContact"]) {
//            nameLab.text = self.addressDictM[@"receivingContact"];
//        }
//        [nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(cell.contentView.mas_left).offset(10);
//            make.top.mas_equalTo(cell.contentView.mas_top).offset(15);
//        }];
//
//        UILabel *phoneLab = [[UILabel alloc] init];
//        [cell.contentView addSubview:phoneLab];
//        phoneLab.textColor = [UIColor blackColor];
//        phoneLab.font = [UIFont systemFontOfSize:14];
////        phoneLab.text = @"15617685591";
//        if (self.addressDictM[@"receivingPhone"]) {
//             phoneLab.text = self.addressDictM[@"receivingPhone"];
//        }
//        [phoneLab mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(nameLab.mas_right).offset(30);
//            make.top.mas_equalTo(nameLab.mas_top);
//        }];
//
//        UILabel *detialLab = [[UILabel alloc] init];
//        [cell.contentView addSubview:detialLab];
////        detialLab.textColor = [Global convertHexToRGB:@"999999"];
//        detialLab.textColor = [UIColor blackColor];
//        detialLab.font = [UIFont systemFontOfSize:12];
////        detialLab.text = @"浙江省杭州市江干区秋涛北路佰富时代中心1幢666";
//
//        if (self.addressDictM[@"receivingRegion"] || self.addressDictM[@"receivingStreet"]) {
//            detialLab.text = [NSString stringWithFormat:@"%@%@",self.addressDictM[@"receivingRegion"],self.addressDictM[@"receivingStreet"]];
//        }
//        [detialLab mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(cell.contentView.mas_left).offset(10);
//            make.top.mas_equalTo(nameLab.mas_bottom).offset(10);
//        }];
//
//        [Global viewFrame:CGRectMake(0,  65 - 1, SCREEN_WIDTH, 1) andBackView:cell.contentView];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//
//    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MineAddAddrViewController *addVC = [[MineAddAddrViewController alloc] init];
    addVC.addressDictM = _addressDictM;
    [self.navigationController pushViewController:addVC animated:YES];
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
