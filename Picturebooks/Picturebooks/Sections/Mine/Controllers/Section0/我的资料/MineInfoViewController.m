//
//  MineInfoViewController.m
//  PictureBook
//
//  Created by Yasin on 2017/7/10.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "MineInfoViewController.h"
#import "SRActionSheet.h"
#import "DatePickerView.h"
#import "LDImagePicker.h" // 可以裁剪图片的选择控制器
#import "MineAddressViewController.h" // 地址显示界面

#import "MineReadViewController.h"
#import "IQKeyboardManager.h"
#import "MineNickViewController.h"

@interface MineInfoViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,SRActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,LDImagePickerDelegate>
{
    UIDatePicker *datePicker;
    UILabel *birthLab;
}

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSArray *nameArr;
@property (strong, nonatomic)DatePickerView *datePickerView;
@property (nonatomic, strong)UILabel *nameLabel;
@property (nonatomic, strong)UIImageView *headImageView;
@property (nonatomic, strong)UITextField *birthdayTextField;
@property (nonatomic, strong)UILabel *phoneLabel;
// 地址
@property (nonatomic, strong)UILabel *address;

@property (nonatomic, strong)NSMutableDictionary *datasourceDic;
@property (nonatomic, strong)NSData *photoData;
@property (nonatomic, strong)UIImage *photoImg;

@end

#define NicKLenght 30  // 限制昵称的长度

@implementation MineInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView = [UINavigationItem titleViewForTitle:@"我的资料"];
    [self.view addSubview:self.tableView];
    
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    
    self.datePickerView = [[DatePickerView alloc] init];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    //    self.nameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickname"];
    // jxd-start------------------
#pragma mark - Jxd-修改:昵称的长度
    NSString *nameString = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickname"];
    if (nameString.length > NicKLenght) {
        nameString = [NSString stringWithFormat:@"%@...",[nameString substringToIndex:NicKLenght]];
    }
    self.nameLabel.text = nameString;
    // jxd-start------------------

    // 请求数据
    [self requestData];
}


- (void)requestData
{
    NSFileManager* manager = [NSFileManager defaultManager];
    NSString *plistFile = [DocumentDirectory stringByAppendingPathComponent:@"userinfo.plist"];
    
    NSLog(@"%@",NSHomeDirectory());
    if ([manager fileExistsAtPath:plistFile]){
        
        self.datasourceDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFile];
        
    }else{
        self.datasourceDic = [NSMutableDictionary dictionaryWithDictionary:@{@"nickname":@"未设置",
                                                                             @"birthday":@"请选择宝贝生日",
                                                                             @"phone":@"未设置",
                                                                             @"head":@"m_noheadimage"}];
    }
    
    //得到基本固定参数字典，加入调用接口所需参数
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:User_info forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    
    [[HttpManager sharedManager] POST:User_info parame:parame sucess:^(id success) {
        
        if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
            
            self.datasourceDic = [success objectForKey:@"data"];
            
//            self.nameLabel.text = [self.datasourceDic objectForKey:@"nickname"];
            
            // jxd-start------------------
#pragma mark - Jxd-修改:昵称的长度
            NSString *nameString = [self.datasourceDic objectForKey:@"nickname"];
            if (nameString.length > NicKLenght) {
                nameString = [NSString stringWithFormat:@"%@...",[nameString substringToIndex:NicKLenght]];
            }
            self.nameLabel.text = nameString;
            // jxd-start------------------
            
            [self.nameLabel sizeToFit];
            self.birthdayTextField.text = [AppTools timestampToTimeChinese:[self.datasourceDic objectForKey:@"birthday"]];
            [self.birthdayTextField sizeToFit];
            self.phoneLabel.text = [self.datasourceDic objectForKey:@"phone"];
            [self.phoneLabel sizeToFit];
            NSURL *url = [NSURL URLWithString:[Qiniu_host stringByAppendingString:[self.datasourceDic objectForKey:@"head"]]];
            [self.headImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"m_noheadimage"]];
            
            // 地址
            if (self.datasourceDic[@"receivingRegion"] || self.datasourceDic[@"receivingStreet"]) {
                self.address.text = [NSString stringWithFormat:@"%@%@",self.datasourceDic[@"receivingRegion"],self.datasourceDic[@"receivingStreet"]];
            }
            
            [self.datasourceDic writeToFile:plistFile atomically:YES];
        }else{
            NSLog(@"event = %@, describe = %@", [success objectForKey:@"event"], [success objectForKey:@"describe"]);
        }
    } failure:^(NSError *error) {
        [Global showWithView:self.view withText:@"网络错误"];
    }];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-PBNew64) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsHorizontalScrollIndicator = NO;
    }
    return _tableView;
}

- (NSArray *)nameArr{
    if (!_nameArr) {
        _nameArr = @[@"个人头像", @"昵称", @"生日", @"手机号",@"地址"];
    }
    return _nameArr;
}

#pragma mark  -----tableview  Delegate  && datesource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.nameArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        UILabel *personalLabel = [[UILabel alloc] init];
        [cell.contentView addSubview:personalLabel];
        personalLabel.textColor = [UIColor blackColor];
        personalLabel.font = [UIFont systemFontOfSize:15];
        personalLabel.text = self.nameArr[indexPath.row];
        [personalLabel sizeToFit];
        [personalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(cell.contentView.mas_left).offset(10);
            make.centerY.mas_equalTo(cell.contentView.mas_centerY);
        }];
        
        UIImageView *imageView = [[UIImageView alloc ] init];
        imageView.image = [UIImage imageNamed:@"m_arrow"];
        [cell.contentView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(cell.contentView.mas_right).offset(-10);
            make.centerY.mas_equalTo(cell.contentView.mas_centerY);
        }];
        
        if (indexPath.row == 0) {
            [imageView setHidden:YES];
            
            self.headImageView = [[UIImageView alloc] init];
            [cell.contentView addSubview:self.headImageView];
            if ([[self.datasourceDic objectForKey:@"head"] isEqualToString:@"m_noheadimage"]) {
                self.headImageView.image = [UIImage imageNamed:[self.datasourceDic objectForKey:@"head"]];
            }else{
                NSURL *url = [NSURL URLWithString:[Qiniu_host stringByAppendingPathComponent:[self.datasourceDic objectForKey:@"head"]]];
                [self.headImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"m_noheadimage"]];
            }
            [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(cell.contentView.mas_right).offset(-10);
                make.top.mas_equalTo(cell.contentView.mas_top).offset(12);
                make.size.mas_equalTo(CGSizeMake(86-24, 86-24));
            }];
            [Global viewFrame:CGRectMake(10,  86 - 1, SCREEN_WIDTH - 20, 1) andBackView:cell.contentView];
        }else{
            [Global viewFrame:CGRectMake(10,  44 - 1, SCREEN_WIDTH - 20, 1) andBackView:cell.contentView];
        }
        
        if (indexPath.row == 1) {
            //[imageView setHidden:YES];
            
            self.nameLabel = [UILabel new];
            [cell.contentView addSubview:self.nameLabel];
            
            
            // jxd-start------------------
#pragma mark - Jxd-修改:昵称的长度
            NSString *nameString = [self.datasourceDic objectForKey:@"nickname"];
            if (nameString.length > NicKLenght) {
                nameString = [NSString stringWithFormat:@"%@...",[nameString substringToIndex:NicKLenght]];
            }
            self.nameLabel.text = nameString;
            // jxd-start------------------
        
//            self.nameLabel.text = [self.datasourceDic objectForKey:@"nickname"];
//            self.nameLabel.text = nameString;
            self.nameLabel.textColor = [UIColor blackColor];
            self.nameLabel.font = [UIFont systemFontOfSize:15];
            self.nameLabel.textAlignment = NSTextAlignmentCenter;
            [self.nameLabel sizeToFit];
            [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(cell.contentView.mas_right).offset(-18);
                make.centerY.mas_equalTo(cell.contentView.mas_centerY);
            }];
            
        }else if (indexPath.row == 2){
            
            self.birthdayTextField = [[UITextField alloc] init];
            self.birthdayTextField.backgroundColor =[UIColor clearColor];
            self.birthdayTextField.textColor = [UIColor blackColor];
            self.birthdayTextField.text = [AppTools timestampToTimeChinese:[self.datasourceDic objectForKey:@"birthday"]];
            self.birthdayTextField.font = [UIFont systemFontOfSize:15];
            [self.birthdayTextField sizeToFit];
            self.birthdayTextField.delegate = self;
            [self.birthdayTextField setValue:RGBHex(0x999999) forKeyPath:@"_placeholderLabel.textColor"];
            [self.birthdayTextField setValue:[UIFont boldSystemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
            self.birthdayTextField.tintColor = [UIColor blackColor];
            [cell.contentView addSubview:self.birthdayTextField];
            [self.birthdayTextField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(cell.contentView.mas_right).offset(-15);
                make.centerY.mas_equalTo(cell.contentView.mas_centerY);
            }];
            
            _datePickerView = [[DatePickerView alloc] initWithCustomeHeight:250];
            
            __weak typeof (self) weakSelf = self;
            _datePickerView.confirmBlock = ^(NSString *choseDate, NSString *restDate) {
                NSArray * arr = [choseDate componentsSeparatedByString:@"-"];
                NSString *birthStr = [NSString stringWithFormat:@"%@年%@月%@日", arr[0], arr[1], arr[2]];

               
                NSString *trimmedString = [choseDate stringByReplacingOccurrencesOfString:@"-" withString:@""];
                
                MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
                HUD.backgroundColor = [UIColor clearColor];
                
                NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
                [parame setObject:USER_birth forKey:@"uri"];
                [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
                [parame setObject:trimmedString forKey:@"birthday"];
                
                [[HttpManager sharedManager]POST:USER_birth parame:parame sucess:^(id success) {
                   
                    [HUD hide:YES];
                    if ([success[@"event"] isEqualToString:@"SUCCESS"]){
                       
                        weakSelf.birthdayTextField.text = birthStr;//选择的生日
                        
                    }
                } failure:^(NSError *error) {
                    [HUD hide:YES];
                    [Global showWithView:weakSelf.view withText:@"网络错误"];

                }];
            };
            
            _datePickerView.cannelBlock = ^(){
                [weakSelf.view endEditing:YES];
            };
            //设置textfield的键盘 替换为我们的自定义view
            self.birthdayTextField.inputView = _datePickerView;
        }else if (indexPath.row == 3){
            [imageView setHidden:YES];
            
            self.phoneLabel = [UILabel new];
            self.phoneLabel.text = [self.datasourceDic objectForKey:@"phone"];
            self.phoneLabel.font = [UIFont systemFontOfSize:15];
            [self.phoneLabel sizeToFit];
            [cell.contentView addSubview:self.phoneLabel];
            [self.phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(cell.contentView.mas_right).offset(-10);
                make.centerY.mas_equalTo(cell.contentView.mas_centerY);
            }];
        } else if(indexPath.row == 4){
            // 地址Label
            self.address = [UILabel new];
            
            if (self.datasourceDic[@"receivingRegion"] || self.datasourceDic[@"receivingStreet"]) {
                self.address.text = [NSString stringWithFormat:@"%@%@",self.datasourceDic[@"receivingRegion"],self.datasourceDic[@"receivingStreet"]];
            }
            self.address.font = [UIFont systemFontOfSize:15];
            [self.address sizeToFit];
            [cell.contentView addSubview:self.address];
            [self.address mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(cell.contentView.mas_right).offset(-18);
                make.centerY.mas_equalTo(cell.contentView.mas_centerY);
            }];
            
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        return 86;
    }else {
        return 44;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        SRActionSheet *actionSheet = [SRActionSheet sr_actionSheetViewWithTitle:nil
                                                                    cancelTitle:@"取消"
                                                               destructiveTitle:nil
                                                                    otherTitles:@[@"相机", @"从相册选择"]
                                                                    otherImages:nil
                                                                       delegate:self];
        
        [actionSheet show];
    }else if (indexPath.row == 1){
        // 昵称控制器
        MineNickViewController *nickVC = [[MineNickViewController alloc] init];
        [self.navigationController pushViewController:nickVC animated:YES];
    }else if (indexPath.row == 4){
        
        // 判断地址是否有值
        if (![self.address.text isEqual: @""]) {
            // 地址显示控制器
            MineAddressViewController *addressVC = [[MineAddressViewController alloc] init];
            [self.navigationController pushViewController:addressVC animated:YES];
        } else {
            // 地址添加控制器
            MineAddAddrViewController *addAdr = [[MineAddAddrViewController alloc] init];
            [self.navigationController pushViewController:addAdr animated:YES];
        }
    }
}

-(void)datePickerValueChanged:(UIDatePicker *)picker{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYYMMdd";
    NSString *timestamp = [formatter stringFromDate:picker.date];
    
    birthLab.text=timestamp;
}

#pragma mark - SRActionSheetDelegate
- (void)actionSheet:(SRActionSheet *)actionSheet didSelectSheet:(NSInteger)index {

    if (index == 0) {
        //拍照
        [self takePhoto];
    }else if(index == 1){
        //从相册选择
        [self localPhoto];
    }
}


//从相册选择
-(void)localPhoto{
    
    //iOS11 解决SafeArea的问题，同时能解决push到下一级被导航条遮挡问题
    if (@available(iOS 11, *)) {
        UIScrollView.appearance.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
    }
    
    // 可以进行裁剪的图片选择器
    LDImagePicker *imagePicker = [LDImagePicker sharedInstance];
    imagePicker.delegate = self;
    [imagePicker showImagePickerWithType:1 InViewController:self Scale:1.0];
    
    //    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    //    //资源类型为图片库
    //    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //    picker.delegate = self;
    //    //设置选择后的图片可被编辑
    //    picker.allowsEditing = YES;
    //    //picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    //    [self presentViewController:picker animated:YES completion:nil];
}

//拍照
-(void)takePhoto{
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        // 可以进行裁剪的图片选择器
        LDImagePicker *imagePicker = [LDImagePicker sharedInstance];
        imagePicker.delegate = self;
        [imagePicker showOriginalImagePickerWithType:0 InViewController:self];
    }
    
    //    //资源类型为照相机
    //    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    //    //判断是否有相机
    //    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    //    {
    //        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    //        picker.sourceType = sourceType;
    //        //picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    //        picker.delegate = self;
    //        picker.allowsEditing = YES;
    //        [self presentViewController:picker animated:YES completion:nil];
    //    }
}

#pragma mark - LDImagePickerDelegate
// 确定选择的图片
- (void)imagePicker:(LDImagePicker *)imagePicker didFinished:(UIImage *)editedImage{
    
    [self getQiniuToken];
    UIImage *selectImage = editedImage;//选取的照片
    UIImage *image = [self imageWithImageSimple:selectImage scaledToSize:CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH*selectImage.size.height/(CGFloat)selectImage.size.width)];
    self.photoImg = image;
    self.photoData = UIImageJPEGRepresentation(image, 1.0);
}

// 取消
- (void)imagePickerDidCancel:(LDImagePicker *)imagePicker{
    if (@available(iOS 11, *)) {
        //iOS11 解决SafeArea的问题，同时能解决pop时上级页面scrollView抖动的问题
        [UIScrollView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

#pragma Delegate method UIImagePickerControllerDelegate
//图像选取器的委托方法，选完图片后回调该方法
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
//{
//    [picker dismissViewControllerAnimated:YES completion:^(){
//
//        [self getQiniuToken];
//        UIImage *selectImage = info[@"UIImagePickerControllerEditedImage"];//选取的照片
//        UIImage *image = [self imageWithImageSimple:selectImage scaledToSize:CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH*selectImage.size.height/(CGFloat)selectImage.size.width)];
//        self.photoImg = image;
//        self.photoData = UIImageJPEGRepresentation(image, 1.0);
//    }];
//}

//对图片尺寸进行压缩
- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//从后台请求到上传文件到七牛的token
- (void)getQiniuToken{
    //得到基本固定参数字典，加入调用接口所需参数
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:Upload_token forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    
    [[HttpManager sharedManager] POST:Upload_token parame:parame sucess:^(id success) {
        
        if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
            [self uploadAudioToQiniu:[[success objectForKey:@"data"] objectForKey:@"token"]];
        }else{
            NSLog(@"event = %@, describe = %@", [success objectForKey:@"event"], [success objectForKey:@"describe"]);
        }
    } failure:^(NSError *error) {
        [Global showWithView:self.view withText:@"网络错误"];
    }];
}

//得到token后，将文件上传七牛，并得到返回的文件名（文件名和id整理成键值对的形式，和后台传来的数据要对应上）
- (void)uploadAudioToQiniu:(NSString *)uplaod_token{
    
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    [upManager putData:self.photoData key:nil token:uplaod_token complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        [self postAudio:[resp objectForKey:@"key"]];
    } option:nil];
}

#pragma mark -----上传头像
- (void)postAudio:(NSString *)photo{
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.labelText = @"上传中...";
    HUD.backgroundColor = [UIColor clearColor];
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:USER_head forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:photo forKey:@"head"];
    [[HttpManager sharedManager] POST:USER_head parame:parame sucess:^(id success) {
        [HUD hide:YES];
        if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
            self.headImageView.image = self.photoImg;
            [self.tableView reloadData];
        }else{
            [Global showWithView:self.view withText:[success objectForKey:@"describe"]];
        }
    } failure:^(NSError *error) {
        [HUD hide:YES];
        [Global showWithView:self.view withText:@"网络错误"];
    }];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
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
