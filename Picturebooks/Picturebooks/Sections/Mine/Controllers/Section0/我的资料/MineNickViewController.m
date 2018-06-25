//
//  MineNickViewController.m
//  Picturebooks
//
//  Created by Yasin on 2017/8/4.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "MineNickViewController.h"

@interface MineNickViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITextField *tf1;
}
@property (nonatomic, strong)UITableView *tableView;

@end

@implementation MineNickViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView = [UINavigationItem titleViewForTitle:@"昵称"];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightBarButtonItemWithTitle:@"确定" target:self selector:@selector(sureClick:)];
    [self.view addSubview:self.tableView];
    
    tf1=[[UITextField alloc]initWithFrame:CGRectMake(100,15, SCREEN_WIDTH-120, 35)];
    tf1.placeholder=@"请输入自己喜欢的昵称";
    tf1.tag=8;
//    tf1.keyboardType =  UIKeyboardTypeDecimalPad;
    tf1.font= [UIFont systemFontOfSize:15];
    tf1.backgroundColor=[UIColor clearColor];
    tf1.textColor= [UIColor blackColor];
    
    _array=[NSArray arrayWithObjects:@"您的昵称", nil];
}

- (void)sureClick:(UIBarButtonItem *)button{
    [self.view endEditing:YES];
    
    if ([Global isNullOrEmpty:tf1.text]) {
        [Global showWithView:self.view withText:@"请先输入昵称"];
        return;
    }
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.backgroundColor = [UIColor clearColor];
    
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:USER_nick forKey:@"uri"];
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:tf1.text forKey:@"nickname"];
    
    [[HttpManager sharedManager]POST:USER_nick parame:parame sucess:^(id success) {
        [HUD hide:YES];
       if ([success[@"event"] isEqualToString:@"SUCCESS"]){
           
           [Global showWithView:self.view withText:@"修改成功！"];
           [[NSUserDefaults standardUserDefaults] setObject:tf1.text forKey:@"nickname"];
           [[NSUserDefaults standardUserDefaults] synchronize];
           
           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
               [self.navigationController popViewControllerAnimated:YES];
           });
           
        }
    } failure:^(NSError *error) {

        [HUD hide:YES];
        [Global showWithView:self.view withText:@"网络错误"];

    }];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-PBNew64) style:UITableViewStyleGrouped];
        _tableView.dataSource=self;
        _tableView.delegate=self;
        _tableView.showsVerticalScrollIndicator=NO;
        _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _tableView.showsHorizontalScrollIndicator=NO;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.estimatedRowHeight = 0;
        if (@available(iOS 11.0, *)) {
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
        }
    }
    return _tableView;
}

//设置每个区cell的个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}

//cell上显示的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell1"];
    if (cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
        [cell addSubview:tf1];
        [tf1 becomeFirstResponder];
    }
    cell.textLabel.text=[_array objectAtIndex:indexPath.row];
    cell.textLabel.textColor= [UIColor blackColor];
    cell.textLabel.font= [UIFont systemFontOfSize:16];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

// cell点击时调用的方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

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
