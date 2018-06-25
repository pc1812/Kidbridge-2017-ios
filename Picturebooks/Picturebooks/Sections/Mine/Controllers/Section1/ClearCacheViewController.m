//
//  ClearCacheViewController.m
//  FirstPage
//
//  Created by 尹凯 on 2017/7/17.
//  Copyright © 2017年 尹凯. All rights reserved.
//

#import "ClearCacheViewController.h"

@interface ClearCacheViewController ()

@property (nonatomic, strong)MBProgressHUD *HUD;
@property (nonatomic, strong)UISwitch *mySwitch;
@property (nonatomic, strong)UILabel *fileSizeLabel;

@end

@implementation ClearCacheViewController

- (void)dealloc{
    NSLog(@"-----内存没有泄漏----");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = RGBHex(0xf0f0f0);
    self.navigationItem.title = @"设置";
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = RGBHex(0x14d02f);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18 weight:2], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 30)];
    [button setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    button.adjustsImageWhenHighlighted = NO;
    [button sizeToFit];
    UIView *containView = [[UIView alloc] initWithFrame:button.bounds];
    [containView addSubview:button];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:containView];

    self.navigationItem.leftBarButtonItem = barButton;
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.HUD];
    [self.HUD removeFromSuperViewOnHide];
    
    [self createView];
}

- (void)createView{
//    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 45)];
//    headView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:headView];
//
//    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(12, 44, SCREEN_WIDTH - 24, 1)];
//    line.backgroundColor = RGBHex(0xf0f0f0);
//    [headView addSubview:line];
//
    CGFloat temp = [AppTools heightForContent:@"只在Wifi环境下自动更新" fontoOfText:15 spacingOfLabel:12];
//    UILabel *autoUpdate = [[UILabel alloc] initWithFrame:CGRectMake(12, (44 - temp) / 2, 300, temp)];
//    autoUpdate.text = @"只在Wifi环境下自动更新";
//    autoUpdate.font = [UIFont systemFontOfSize:15];
//    [headView addSubview:autoUpdate];
//
//    self.mySwitch = [[UISwitch alloc] init];
//    /* Adjust the off-mode tint color */
//    self.mySwitch.tintColor = RGBHex(0xf0f0f0);
//    /* Adjust the on-mode tint color */
//    self.mySwitch.onTintColor = RGBHex(0x14d02f);
//    [headView addSubview:self.mySwitch];
//    [self.mySwitch mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(-8);
//        make.top.mas_equalTo(6);
//        make.width.mas_equalTo(50);
//    }];
//    [self.mySwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
    UIView *headView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    headView1.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headView1];
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearCacheTapGr:)];
    [headView1 addGestureRecognizer:tapGr];
    headView1.userInteractionEnabled = YES;
    
    UILabel *clearLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, (44 - temp) / 2, 200, temp)];
    [headView1 addSubview:clearLabel];
    clearLabel.text = @"清除缓存";
    clearLabel.font = [UIFont systemFontOfSize:15];
    
    self.fileSizeLabel = [[UILabel alloc] init];
    [headView1 addSubview:self.fileSizeLabel];
    self.fileSizeLabel.text = [NSString stringWithFormat:@"%.1fMB", [self folderSizeAtPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]]];
    self.fileSizeLabel.font = [UIFont systemFontOfSize:15];
    [self.fileSizeLabel sizeToFit];
    self.fileSizeLabel.textColor = [UIColor grayColor];
    [self.fileSizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-8);
        make.top.mas_equalTo((44 - temp) / 2);
    }];
}

- (void)switchAction:(UISwitch *)paramSwitch{
    if ([self.mySwitch isOn]) {
        //显示的文字
        self.HUD.labelText = @"已开启自动更新";
        //是否有遮罩
        self.HUD.dimBackground = NO;
        self.HUD.labelFont = [UIFont boldSystemFontOfSize:22];
        self.HUD.backgroundColor = [UIColor clearColor];
        //提示框的样式
        self.HUD.mode = MBProgressHUDModeText;
        [self.HUD show:YES];
        //两秒之后隐藏
        [self.HUD hide:YES afterDelay:1];
    }
    else{
        //显示的文字
        self.HUD.labelText = @"已关闭自动更新";
        //是否有遮罩
        self.HUD.dimBackground = NO;
        self.HUD.labelFont = [UIFont boldSystemFontOfSize:22];
        self.HUD.backgroundColor = [UIColor clearColor];
        //提示框的样式
        self.HUD.mode = MBProgressHUDModeText;
        [self.HUD show:YES];
        //两秒之后隐藏
        [self.HUD hide:YES afterDelay:1];
    }
}

- (void)clearCacheTapGr:(UITapGestureRecognizer *)tapGr{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *messageStr = [NSString stringWithFormat:@"缓存大小为: %.1fMB, 需要清除缓存么?", [self folderSizeAtPath:path]];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:messageStr preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self clearCache:path];
        [self clearSuccess];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
    [self.mySwitch setOn:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 删除缓存方法
//文件大小
- (long long)fileSizeAtPath:(NSString*)filePath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

/*整个目录的文件大小*/
- (float)folderSizeAtPath:(NSString *)folderPath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath:folderPath]) return 0;
    
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}

- (void)clearCache:(NSString *)path{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        //-(NSArray *)subpathsAtPath:(NSString *)path,用来获取指定目录下的子项（文件或文件夹）列表
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles) {
            //如有需要，加入条件，过滤掉不想删除的文件
            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
}

-(void)clearSuccess{
    MBProgressHUD *clearHud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:clearHud];
    clearHud.removeFromSuperViewOnHide = YES;
    //显示的文字
    clearHud.labelText = @"删除成功  ";
    //是否有遮罩
    clearHud.dimBackground = NO;
    clearHud.labelFont = [UIFont boldSystemFontOfSize:22];
    clearHud.backgroundColor = [UIColor clearColor];
    //提示框的样式
    clearHud.mode = MBProgressHUDModeText;
    [clearHud show:YES];
    //两秒之后隐藏
    [clearHud hide:YES afterDelay:1];
    self.fileSizeLabel.text = @"0.0MB";
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
