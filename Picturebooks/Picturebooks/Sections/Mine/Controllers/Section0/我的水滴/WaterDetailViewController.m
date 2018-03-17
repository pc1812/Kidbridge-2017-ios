//
//  WaterDetailViewController.m
//  PictureBook
//
//  Created by Yasin on 2017/7/11.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "WaterDetailViewController.h"
#import "BillDetail.h"

@interface WaterDetailViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, assign) NSInteger pageNum;//页数
@property (nonatomic) BOOL isMorePage;
@property (nonatomic, strong)NSMutableArray *modelArray;

@end

@implementation WaterDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView = [UINavigationItem titleViewForTitle:@"滴水明细"];
    self.modelArray = [[NSMutableArray alloc] init];
    [self.view addSubview:self.tableView];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _pageNum=0;
        [self loadData];
    }];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (_isMorePage) {
            _pageNum++;
            [self loadData];
        }else{
            [self.tableView.mj_footer endRefreshing];
            [Global showWithView:self.view withText:@"没有更多数据了～"];
        }
    }];
    // 马上进入刷新状态
    [self.tableView.mj_header beginRefreshing];
}

- (void)loadData{
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.labelText = @"加载中...";
    HUD.backgroundColor = [UIColor clearColor];
    
    //得到基本固定参数字典，加入调用接口所需参数
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:User_bill forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    //添加请求该页面接口所需参数
    [parame addEntriesFromDictionary:@{@"feeType":@(1)}];
    
    [[HttpManager sharedManager] POST:User_bill parame:parame sucess:^(id success) {
        [HUD hide:YES];
        
        if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
            [self.modelArray removeAllObjects];
            
            NSMutableArray *tmpArray = [success objectForKey:@"data"];
            for (NSDictionary *dic in tmpArray) {
                BillDetail *model = [BillDetail modelWithDictionary:dic];
                [self.modelArray addObject:model];
            }
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            [self.tableView reloadData];
        }
        else{
            NSLog(@"event = %@, describe = %@", [success objectForKey:@"event"], [success objectForKey:@"describe"]);
        }
    } failure:^(NSError *error) {
        [HUD hide:YES];
        [Global showWithView:self.view withText:@"网络错误"];
    }];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-PBNew64) style:UITableViewStylePlain];
        _tableView.dataSource=self;
        _tableView.delegate=self;
        _tableView.showsVerticalScrollIndicator=NO;
        _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _tableView.showsHorizontalScrollIndicator=NO;
    }
    return _tableView;
}

#pragma mark  -----tableview  Delegate  && datesource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.modelArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = [NSString stringWithFormat:@"cell%ld,%ld",(long)[indexPath section],(long)[indexPath row]];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    BillDetail *model = [self.modelArray objectAtIndex:indexPath.row];
    
    UILabel *nameLab = [[UILabel alloc] init];
    [cell.contentView addSubview:nameLab];
    nameLab.textColor = [UIColor blackColor];
    nameLab.font = [UIFont systemFontOfSize:14 weight:2];
    nameLab.text = model.type;
    [nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(cell.contentView.mas_left).offset(10);
        make.top.mas_equalTo(cell.contentView.mas_top).offset(12);
    }];
    
    UILabel *timeLab = [[UILabel alloc] init];
    [cell.contentView addSubview:timeLab];
    timeLab.textColor = [Global convertHexToRGB:@"999999"];
    timeLab.font = [UIFont systemFontOfSize:12];
    timeLab.text = model.time;
    [timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(nameLab.mas_left);
        make.top.mas_equalTo(nameLab.mas_bottom).offset(7);
    }];
    
    UILabel *waterLab = [[UILabel alloc] init];
    [cell.contentView addSubview:waterLab];
    //RGBHex(0x14d02f)
    if ([model.fees integerValue] > 0) {
        waterLab.textColor = RGBHex(0x14d02f);
        waterLab.text = [NSString stringWithFormat:@"+%@",model.fees];
    }else{
        waterLab.textColor = [Global convertHexToRGB:@"fe6a76"];
        waterLab.text = [NSString stringWithFormat:@"%@",model.fees];
    }
    
    waterLab.font = [UIFont systemFontOfSize:19 weight:2];
    //NSString *waterStr = [NSString stringWithFormat:@"%.2f", [model.fees doubleValue]];
//    waterLab.text = model.fees;
    [waterLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(cell.contentView.mas_right).offset(-10);
        make.centerY.mas_equalTo(cell.contentView.mas_centerY);
    }];
    [Global viewFrame:CGRectMake(10,  55 - 1, SCREEN_WIDTH - 20, 1) andBackView:cell.contentView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
