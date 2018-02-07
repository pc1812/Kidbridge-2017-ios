//
//  MineAddAddrViewController.m
//  PictureBook
//
//  Created by Yasin on 2017/7/11.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "MineAddAddrViewController.h"
#import "AddressViewCell.h"

@interface MineAddAddrViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    UITextField * textField;
}

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSArray *nameArr;
@property (nonatomic, strong)NSArray *placeArr;


@end

@implementation MineAddAddrViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView = [UINavigationItem titleViewForTitle:@"填写地址"];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightBarButtonItemWithTitle:@"保存" target:self selector:@selector(saveClick)];
    [self.view addSubview:self.tableView];
    
}

- (void)saveClick{
    
    AddressViewCell *name = (AddressViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

    AddressViewCell *phone = (AddressViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];

    AddressViewCell *areaAddress = (AddressViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];

    AddressViewCell *detailAddress = (AddressViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    

    if ([Global isNullOrEmpty:name.textField.text]) {
        [Global showWithView:self.view withText:@"请输入收货人姓名"];
        return;
    }
    
    if (![Global isValidatePhone:phone.textField.text]) {
        [Global showWithView:self.view withText:@"手机号码不正确"];
        return;
    }
    
    if ([Global isNullOrEmpty:areaAddress.textField.text]) {
        [Global showWithView:self.view withText:@"请输入区域信息"];
        return;
    }
    
    if ([Global isNullOrEmpty:detailAddress.textField.text]) {
        [Global showWithView:self.view withText:@"请输入详细地址"];
        return;
    }
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.backgroundColor = [UIColor clearColor];
    
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:USER_UpAddress forKey:@"uri"];
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    // 上传信息
    [parame setObject:name.textField.text forKey:@"contact"];
    [parame setObject:phone.textField.text forKey:@"phone"];
    [parame setObject:areaAddress.textField.text forKey:@"region"];
    [parame setObject:detailAddress.textField.text forKey:@"street"];
    
    [[HttpManager sharedManager]POST:USER_UpAddress parame:parame sucess:^(id success) {
    
        [HUD hide:YES afterDelay:0.5];
        if ([success[@"event"] isEqualToString:@"SUCCESS"]) {
            // 保存收货地址
            NSString *addressStr = [NSString stringWithFormat:@"%@%@",areaAddress.textField.text,detailAddress.textField.text];
            [[NSUserDefaults standardUserDefaults] setObject:addressStr forKey:@"user_address"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
        
    } failure:^(NSError *error) {
        [HUD hide:YES afterDelay:1];
        [Global showWithView:self.view withText:@"网络错误"];
    }];
    
}

- (NSArray *)nameArr{
    if (!_nameArr) {
        _nameArr = @[@"收件人", @"联系方式", @"区域地址", @"详细地址"];
    }
    return _nameArr;
}

- (NSArray *)placeArr{
    if (!_placeArr) {
        _placeArr = @[@"请填写收货人姓名", @"请填写联系方式", @"请填写区域地址", @"请填写详细地址"];
    }
    return _placeArr;
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

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    AddressViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[AddressViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.nameLab.text = self.nameArr[indexPath.row];
    cell.textField.placeholder = self.placeArr[indexPath.row];
    if (indexPath.row == 1) {
        cell.textField.keyboardType = UIKeyboardTypeNumberPad;
    }

    // 如果收货地址字典中有值,就进行赋值
    if (_addressDictM) {
        if (indexPath.row == 0) {
            
            cell.textField.text = _addressDictM[@"receivingContact"];
        }
        if (indexPath.row == 1) {
            
            cell.textField.text = _addressDictM[@"receivingPhone"];
        }
        if (indexPath.row == 2) {
            
            cell.textField.text = _addressDictM[@"receivingRegion"];
        }
        if (indexPath.row == 3) {
            
            cell.textField.text = _addressDictM[@"receivingStreet"];
        }
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
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
