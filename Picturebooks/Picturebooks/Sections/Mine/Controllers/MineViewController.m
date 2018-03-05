//
//  MineViewController.m
//  PictureBook
//
//  Created by Yasin on 2017/7/7.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "MineViewController.h"
#import "UIView+RedPoint.h"
#import "MineInfoViewController.h"
#import "MineWaterViewController.h"
#import "MineSuggestViewController.h"
#import "MineAboutViewController.h"
#import "MineReadViewController.h"
#import "MineCourseViewController.h"
#import "MinePicViewController.h"
#import "InfoNoticeViewController.h"
#import "MineMoneysViewController.h"
#import "ClearCacheViewController.h"
#import "AchievementViewController.h"
#import "MineEvaluateViewController.h"
#import "MineTeacherViewController.h"
#import "ZJImageMagnification.h"

@interface MineViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSArray *nameArr;
@property (nonatomic, strong)UITextField *signField;
@property (nonatomic, copy)NSString *signStr;
@property (nonatomic, strong)UILabel *moneyLab;
@property (nonatomic, copy)NSString *moneyStr;
@property (nonatomic, strong)UIImageView *photoImage;
@property (nonatomic, copy)NSString *ageStr;
@property (nonatomic, copy)NSString *nameStr;
@property (nonatomic, copy)NSString *signString;
@property (nonatomic, assign)NSInteger role;
@property (nonatomic, assign)NSInteger nowId;
@property (nonatomic, strong)NSMutableArray *imgArr;

/** 客服手机号 */
@property (nonatomic,strong)  NSNumber *telNumber;

@end

@implementation MineViewController
{
    UILabel *_titleLabel1;
    UILabel *ageLab;
    UILabel *nameLabs;
    NSURL *url;
    
    NSString *waterStr1;
    NSString *waterStr2;
    NSString *medalStr1;
    NSString *medalStr2;
    NSArray *arr2;
    NSArray *arr1;
    NSString *hideStr;
}

- (void)dealloc{
    NSLog(@"”我的“界面没有内存泄口");
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (IOS7) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.imgArr = [NSMutableArray array];
    _titleLabel1 = [UILabel new];
}

- (NSArray *)nameArr{
    if (!_nameArr) {
       
        _nameArr = @[arr1, arr2];
    }
    return _nameArr;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT- TabbarHeight) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsHorizontalScrollIndicator = NO;
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return arr1.count;
            break;
        default:
            return arr2.count;
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = [NSString stringWithFormat:@"cell%ld,%ld",(long)[indexPath section],(long)[indexPath row]];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        UILabel *nameLab = [[UILabel alloc] init];
        [cell.contentView addSubview:nameLab];
        nameLab.textColor = [UIColor blackColor];
        nameLab.font = [UIFont systemFontOfSize:15];
        nameLab.text = self.nameArr[indexPath.section][indexPath.row];
        [nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
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
        if (indexPath.section == 0 && indexPath.row == 1) {
            self.moneyLab = [[UILabel alloc] init];
            [cell.contentView addSubview:self.moneyLab];
            self.moneyLab.textColor = [UIColor blackColor];
            self.moneyLab.font = [UIFont systemFontOfSize:15];
//            if ([hideStr isEqualToString:@"1"]) {
//                self.moneyLab.text = @"";
//            }else{
//                self.moneyLab.text = self.moneyStr;
//
//            }
            [self.moneyLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(cell.contentView.mas_right).offset(-30);
                make.centerY.mas_equalTo(cell.contentView.mas_centerY);
            }];
        }
        [Global viewFrame:CGRectMake(10, 45 - 1, SCREEN_WIDTH - 20, 1) andBackView:cell.contentView];
    }
    
    if ([hideStr isEqualToString:@"1"]) {
        self.moneyLab.text = @"";
    }else{
        self.moneyLab.text = self.moneyStr;
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *backView=[[UIView alloc]initWithFrame:CGRectZero];
    backView.backgroundColor = RGBHex(0xf0f0f0);
    if (section == 0 ) {
        UIView *headView = [UIView new];
        headView.frame = FRAMEMAKE_F(0, 0, SCREEN_WIDTH, 245);
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:headView.bounds];
        imageView.image=[UIImage imageNamed:@"m_background"];
        [headView insertSubview:imageView atIndex:0];
        [backView addSubview:headView];
        
        //头像
        self.photoImage = [UIImageView new];
        self.photoImage = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2-38, 65, 76, 76)];
        [self.photoImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"m_noheadimage"]];
        self.photoImage.clipsToBounds=YES;
        self.photoImage.layer.cornerRadius=38;
        [self.photoImage.layer setBorderWidth:2];
        //设置边框线的颜色
        [self.photoImage.layer setBorderColor:[[UIColor yellowColor] CGColor]];
        [headView addSubview:self.photoImage];
       
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self.photoImage addGestureRecognizer:tap];
        self.photoImage.userInteractionEnabled = YES;
        
        //昵称
        nameLabs = [UILabel new];
        nameLabs.textColor = RGBHex(0xfe6a76);
        nameLabs.font = [UIFont systemFontOfSize:12 weight:2];
        nameLabs.text = self.nameStr;
        nameLabs.textAlignment = NSTextAlignmentCenter;
        nameLabs.layer.cornerRadius = 5;
        nameLabs.clipsToBounds = YES;
        nameLabs.backgroundColor = [UIColor yellowColor];
        NSDictionary *nameDic = [NSDictionary dictionaryWithObjectsAndKeys:nameLabs.font,NSFontAttributeName, nil];
        CGSize nameSize = [nameLabs.text sizeWithAttributes:nameDic];
        
        if (nameSize.width > 76) {
            nameSize.width = 76;
        }
        
        nameLabs.frame = FRAMEMAKE_F(SCREEN_WIDTH/2-(nameSize.width + 10) / 2, CGRectGetMaxY(self.photoImage.frame) - 10, nameSize.width + 10, nameSize.height);
        [headView addSubview:nameLabs];
        
        //年龄
        ageLab = [UILabel new];
        ageLab.textColor = RGBHex(0xfe6a76);
        ageLab.font = [UIFont systemFontOfSize:12 weight:2];
        ageLab.text = self.ageStr;
        NSDictionary *ageDic = [NSDictionary dictionaryWithObjectsAndKeys:ageLab.font,NSFontAttributeName, nil];
        CGSize ageSize = [ageLab.text sizeWithAttributes:ageDic];
        ageLab.frame = FRAMEMAKE_F(SCREEN_WIDTH/2-ageSize.width  / 2, CGRectGetMaxY( nameLabs.frame) + 5, ageSize.width + 10, ageSize.height);
        [headView addSubview:ageLab];
        
        //签名
        _titleLabel1.textColor = [UIColor whiteColor];
        _titleLabel1.font = [UIFont systemFontOfSize:13 weight:2];
        NSDictionary *titDic = [NSDictionary dictionaryWithObjectsAndKeys:_titleLabel1.font,NSFontAttributeName, nil];
        CGSize titSize = [_titleLabel1.text sizeWithAttributes:titDic];
               _titleLabel1.frame = FRAMEMAKE_F(SCREEN_WIDTH / 2 - 200 / 2 + 15, CGRectGetMaxY(ageLab.frame) + 5, 200, titSize.height);
        [headView addSubview:_titleLabel1];
        
        //编辑签名
        UIImageView *moreImage = [UIImageView new];
        moreImage.image = [UIImage imageNamed:@"m_sign"];
        moreImage.frame = FRAMEMAKE_F(CGRectGetMinX(_titleLabel1.frame) - moreImage.image.size.width - 5, CGRectGetMaxY(ageLab.frame) + 5,  moreImage.image.size.width,  moreImage.image.size.height);
        [headView addSubview:moreImage];
        
        UIButton *_moreButton = [UIButton new];
        [_moreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        _moreButton.frame = FRAMEMAKE_F(SCREEN_WIDTH / 2  - CGRectGetWidth(moreImage.frame) - CGRectGetWidth(_titleLabel1.frame) / 2 - 10 , _titleLabel1.frame.origin.y, 200 + CGRectGetWidth(moreImage.frame) + 10, titSize.height);
        [_moreButton addTarget:self action:@selector(signClick:) forControlEvents:UIControlEventTouchUpInside];
        [headView addSubview:_moreButton];
        
        //下方属性描述富文本
        UILabel *_shopLabel = [UILabel new];
        _shopLabel.textColor = [UIColor whiteColor];
        _shopLabel.numberOfLines = 0;
        _shopLabel.textAlignment = NSTextAlignmentCenter;

        
        NSString *str1;
        if (_nowId == -1) {
            str1 = [NSString stringWithFormat:@"宝贝已经有%@水滴啦, 距离" , waterStr1];
        }else if ([waterStr2 integerValue] == -1) {
            str1 = [NSString stringWithFormat:@"宝贝已经有%@水滴啦, 获得\"%@\",\n继续加油哦!" , waterStr1, medalStr1];
        }else{
            str1 = [NSString stringWithFormat:@"宝贝已经有%@水滴啦, 获得\"%@\", 距离" , waterStr1, medalStr1];
        }
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:str1];
        [str addAttribute:NSForegroundColorAttributeName
                    value:[UIColor yellowColor]
                    range:NSMakeRange(5, waterStr1.length)]; //5, 2
        [str addAttribute:NSForegroundColorAttributeName
                    value:[UIColor yellowColor]
                    range:NSMakeRange(13 + waterStr1.length, medalStr1.length)];//16
        _shopLabel.font = [UIFont systemFontOfSize:13];
        _shopLabel.attributedText = str;
        _shopLabel.frame = FRAMEMAKE_F(0, CGRectGetMaxY(_moreButton.frame) + 5, SCREEN_WIDTH, 14);
        
        // Jxd-start---------------
#pragma mark - Jxd-修改
//        CGFloat shopLabH = CGRectGetMaxY(headView.frame) - CGRectGetMaxY(_moreButton.frame) - 10;
//        _shopLabel.frame = FRAMEMAKE_F(0, CGRectGetMaxY(_moreButton.frame) + 5, SCREEN_WIDTH, shopLabH);
        // Jxd-end-----------------
        
        [headView addSubview:_shopLabel];
        NSString *str2;
        if ([waterStr2 integerValue] == -1) {
             str2 = @"";
        }else{
            
           str2 = [NSString stringWithFormat:@"\"%@\"还差%@水滴, 继续加油哦!" ,  medalStr2, waterStr2];
            UILabel *_shopLabel1 = [UILabel new];
            _shopLabel1.textColor = [UIColor whiteColor];
            _shopLabel1.textAlignment = NSTextAlignmentCenter;
            _shopLabel1.numberOfLines = 0;
            
            NSMutableAttributedString *strOne = [[NSMutableAttributedString alloc] initWithString:str2];
            [strOne addAttribute:NSForegroundColorAttributeName
                           value:[UIColor yellowColor]
                           range:NSMakeRange(1, medalStr2.length)];
            [strOne addAttribute:NSForegroundColorAttributeName
                           value:[UIColor yellowColor]
                           range:NSMakeRange(8, waterStr2.length)];
            _shopLabel1.font = [UIFont systemFontOfSize:13];
            _shopLabel1.attributedText = strOne;
            _shopLabel1.frame = FRAMEMAKE_F(0, CGRectGetMaxY(_shopLabel.frame) + 5, SCREEN_WIDTH, 14);
            
            // Jxd-start---------------
//#pragma mark - Jxd-修改
//            CGFloat shopLabH = CGRectGetMaxY(headView.frame) - CGRectGetMaxY(_moreButton.frame) - 10;
//            _shopLabel1.frame = FRAMEMAKE_F(0, CGRectGetMaxY(_moreButton.frame) + 5, SCREEN_WIDTH, shopLabH);
            // Jxd-end-----------------
            
            [headView addSubview:_shopLabel1];
        }
        

        //右上角小铃铛 25 40
        UIImage *infoImage = [UIImage imageNamed:@"m_info"];
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        backButton.frame = CGRectMake(SCREEN_WIDTH - infoImage.size.width - 30, 40, infoImage.size.width + 20,infoImage.size.height + 10);
        [backButton setImage:infoImage forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(infoBtnClick:)
             forControlEvents:UIControlEventTouchUpInside];
       
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"info"]) {
            [backButton showRedAtOffSetX:-18 AndOffSetY:0.01 OrValue:nil];
        }
        [headView addSubview:backButton];
        
        return backView;
    }
    return backView;
}

- (void)tapAction:(UITapGestureRecognizer *)tap{
    [ZJImageMagnification scanBigImageWithImageView:(UIImageView *)tap.view alpha:1.0];
}

//消息
- (void)infoBtnClick:(UIButton *)button{
    [button hideRedPoint];
    InfoNoticeViewController *infoVC = [[InfoNoticeViewController alloc] init];
    [self.navigationController pushViewController:infoVC animated:YES];
}

//设置不同字体颜色
-(void)fuwenbenLabel:(UILabel *)labell FontNumber:(id)font AndRange:(NSRange)range AndColor:(UIColor *)vaColor
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:labell.text];
    //设置字号
    [str addAttribute:NSFontAttributeName value:font range:range];
    //设置文字颜色
    [str addAttribute:NSForegroundColorAttributeName value:vaColor range:range];
    labell.attributedText = str;
}

//签名
- (void)signClick:(UIButton *)button{
   
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"签名" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"请输入签名";
       
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *signField = alertController.textFields.firstObject;
        if ([Global isNullOrEmpty:signField.text]) {
            return;
        }
       
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.backgroundColor = [UIColor clearColor];
        //得到基本固定参数字典，加入调用接口所需参数
        NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
        [parame setObject:USER_sign forKey:@"uri"];
        //得到加盐MD5加密后的sign，并添加到参数字典
        [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
        [parame setObject:signField.text forKey:@"signature"];
        
        [[HttpManager sharedManager]POST:USER_sign parame:parame sucess:^(id success) {
            [HUD hide:YES afterDelay:1];
            if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]){
                _titleLabel1.text = signField.text;
                [Global showWithView:self.view withText:@"修改成功"];
            }
        } failure:^(NSError *error) {
            [HUD hide:YES afterDelay:1];
            [Global showWithView:self.view withText:@"网络错误"];
        }];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 255;
            break;
        default:
            return 0.001f;
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 10;
            break;
        default:
            return 10;
            break;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    double height = 10;

    UIView *backView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, height)];
    backView.backgroundColor = RGBHex(0xf0f0f0);
    return backView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        //隐藏我的余额
        if ([hideStr isEqualToString:@"1"]) {
            if (indexPath.row == 0) {
                AchievementViewController *achieveVC = [[AchievementViewController alloc] init];
                [self.navigationController pushViewController:achieveVC animated:YES];
            }else if (indexPath.row == 1) {
                MineInfoViewController *infoVC = [[MineInfoViewController alloc] init];
                [self.navigationController pushViewController:infoVC animated:YES];
            }else if (indexPath.row == 2){
                MineWaterViewController *waterVC = [[MineWaterViewController alloc] init];
                [self.navigationController pushViewController:waterVC animated:YES];
            }else if (indexPath.row == 3){
                MineReadViewController *readVC = [[MineReadViewController alloc] init];
                [self.navigationController pushViewController:readVC animated:YES];
            }else if (indexPath.row == 4){
                MinePicViewController *picVC = [[MinePicViewController alloc] init];
                [self.navigationController pushViewController:picVC animated:YES];
            }else if (indexPath.row == 5){
                MineCourseViewController *courseVC = [[MineCourseViewController alloc] init];
                [self.navigationController pushViewController:courseVC animated:YES];
            }else{
                MineEvaluateViewController *evaluateVC = [[MineEvaluateViewController alloc] init];
                [self.navigationController pushViewController:evaluateVC animated:YES];
            }
        }else{
            if (indexPath.row == 0) {
                AchievementViewController *achieveVC = [[AchievementViewController alloc] init];
                [self.navigationController pushViewController:achieveVC animated:YES];
            }else if (indexPath.row == 1) {
                MineMoneysViewController *moneyVC = [[MineMoneysViewController alloc] init];
                [self.navigationController pushViewController:moneyVC animated:YES];
            }else if (indexPath.row == 2) {
                MineInfoViewController *infoVC = [[MineInfoViewController alloc] init];
                [self.navigationController pushViewController:infoVC animated:YES];
            }else if (indexPath.row == 3) {
                MineWaterViewController *waterVC = [[MineWaterViewController alloc] init];
                [self.navigationController pushViewController:waterVC animated:YES];
            }else if (indexPath.row == 4){
                MineReadViewController *readVC = [[MineReadViewController alloc] init];
                [self.navigationController pushViewController:readVC animated:YES];
            }else if (indexPath.row == 5){
                MinePicViewController *picVC = [[MinePicViewController alloc] init];
                [self.navigationController pushViewController:picVC animated:YES];
            }else if (indexPath.row == 6){
                MineCourseViewController *courseVC = [[MineCourseViewController alloc] init];
                [self.navigationController pushViewController:courseVC animated:YES];
            }else{
                MineEvaluateViewController *evaluateVC = [[MineEvaluateViewController alloc] init];
                [self.navigationController pushViewController:evaluateVC animated:YES];
            }
            
        }
        
    }else{
        
        if (self.role == 1) {
            
            if (indexPath.row == 0) {
                MineTeacherViewController *suggestVC = [[MineTeacherViewController alloc] init];
                [self.navigationController pushViewController:suggestVC animated:YES];
            }else if(indexPath.row == 1) {
                ClearCacheViewController *clearVC = [[ClearCacheViewController alloc] init];
                [self.navigationController pushViewController:clearVC animated:YES];
            }else if(indexPath.row == 2) {
                MineSuggestViewController *suggestVC = [[MineSuggestViewController alloc] init];
                [self.navigationController pushViewController:suggestVC animated:YES];
            }else if(indexPath.row == 3) {
                MineAboutViewController *suggestVC = [[MineAboutViewController alloc] init];
                [self.navigationController pushViewController:suggestVC animated:YES];
            }else if (indexPath.row == 4){
                // 联系客服
                [self contactMe];
                
            } else{
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示"
                                                                                         message:@"您确定要退出登录吗？"
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                
                //添加取消到UIAlertController中
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:cancelAction];
                
                //添加确定到UIAlertController中
                UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    HUD.removeFromSuperViewOnHide = YES;
                    HUD.labelText = @"请求中...";
                    HUD.backgroundColor = [UIColor clearColor];
                    
                    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
                    [parame setObject:User_logout forKey:@"uri"];
                    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
                    
                    [[HttpManager sharedManager] POST:User_logout parame:parame sucess:^(id success) {
                        if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
                            
                            [HUD hide:YES];
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userid"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"hide"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            
                            [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                                
                            } seq:0];
                            
                            
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"changeRootViewController" object:@"fromLogout"];
                            });
                        }else{
                            [Global showWithView:self.view withText:@"退出失败，请重试！"];
                        }
                    } failure:^(NSError *error) {
                        [Global showWithView:self.view withText:@"网络错误"];
                    }];
                }];
                [alertController addAction:OKAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }else{
            if(indexPath.row == 0) {
                ClearCacheViewController *clearVC = [[ClearCacheViewController alloc] init];
                [self.navigationController pushViewController:clearVC animated:YES];
            }else if(indexPath.row == 1){
                MineSuggestViewController *suggestVC = [[MineSuggestViewController alloc] init];
                [self.navigationController pushViewController:suggestVC animated:YES];
            }else if(indexPath.row == 2) {
                MineAboutViewController *suggestVC = [[MineAboutViewController alloc] init];
                [self.navigationController pushViewController:suggestVC animated:YES];
            }else if (indexPath.row == 3){
                // 联系客服
                [self contactMe];
                
            } else{
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示"
                                                                                         message:@"您确定要退出登录吗？"
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                
                //添加取消到UIAlertController中
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:cancelAction];
                
                //添加确定到UIAlertController中
                UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    HUD.removeFromSuperViewOnHide = YES;
                    HUD.labelText = @"请求中...";
                    HUD.backgroundColor = [UIColor clearColor];
                    
                    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
                    [parame setObject:User_logout forKey:@"uri"];
                    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
                    
                    [[HttpManager sharedManager] POST:User_logout parame:parame sucess:^(id success) {
                        if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
                            
                            [HUD hide:YES];
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"changeRootViewController" object:@"fromLogout"];
                            });
                        }else{
                            [Global showWithView:self.view withText:@"退出失败，请重试！"];
                        }
                    } failure:^(NSError *error) {
                        [Global showWithView:self.view withText:@"网络错误"];
                    }];
                }];
                [alertController addAction:OKAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
    }
}

#pragma mark - Jxd-修改->联系我们
- (void)contactMe
{
    NSMutableString *telString = [[NSMutableString alloc] initWithFormat:@"tel:%@",self.telNumber];
    UIWebView *callWebView = [[UIWebView alloc] init];
    [callWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:telString]]];
    [self.view addSubview:callWebView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:USER_MESSAGE forKey:@"uri"];
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    
    [[HttpManager sharedManager] POST:USER_MESSAGE parame:parame sucess:^(id success) {
        
//        NSLog(@"=======================");
//        NSLog(@"%@",success);
//        NSLog(@"=======================");
        
        if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {
            
            // Jxd-start----------------------------------------
#pragma mark - Jxd-添加:保存客服手机号
            self.telNumber = success[@"data"][@"customerservice"];
            // Jxd-start----------------------------------------
            
            url = [NSURL URLWithString:[Qiniu_host stringByAppendingString:success[@"data"][@"user"][@"head"]]];
            //头像地址存在NSUserDefault里，方便在其他地方取用
            [[NSUserDefaults standardUserDefaults] setObject:[Qiniu_host stringByAppendingString:success[@"data"][@"user"][@"head"]] forKey:@"User_headimage"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            self.moneyStr = [NSString stringWithFormat:@"%.2f", [success[@"data"][@"user"][@"balance"] floatValue]];
          
            //年龄
            self.ageStr = [NSString stringWithFormat:@"%@", success[@"data"][@"user"][@"age"]];
            
//            if ([Global isNullOrEmpty:self.ageStr]) {
//                self.ageStr = @"未设置";
//            }else{
//                self.ageStr = [NSString stringWithFormat:@"%@岁", success[@"data"][@"user"][@"age"]];
//            }
            
            //昵称
            self.nameStr = [NSString stringWithFormat:@"%@", success[@"data"][@"user"][@"nickname"]];
            if ([Global isNullOrEmpty:self.nameStr]) {
                self.nameStr = @"未设置";
            }else{
                self.nameStr = [NSString stringWithFormat:@"%@", success[@"data"][@"user"][@"nickname"]];
            }
            
            //签名
            self.signString =  [NSString stringWithFormat:@"%@", success[@"data"][@"user"][@"signature"]];
            if ([Global isNullOrEmpty:self.signString]) {
                self.signString = @"请设置你的个性签名";
            }else{
                self.signString = [NSString stringWithFormat:@"%@", success[@"data"][@"user"][@"signature"]];
            }

            if ([success[@"data"][@"phase"] isEqual:[NSNull null]]) {
                medalStr1 = @"暂无数据";
                medalStr2 = @"暂无数据";
            }else{
                medalStr1 = [NSString stringWithFormat:@"%@", success[@"data"][@"phase"][@"now"][@"name"]];
                medalStr2 = [NSString stringWithFormat:@"%@", success[@"data"][@"phase"][@"future"][@"name"]];
                self.nowId = [[NSString stringWithFormat:@"%@", success[@"data"][@"phase"][@"now"][@"id"]] integerValue];
            }
            waterStr1 = [NSString stringWithFormat:@"%@", success[@"data"][@"user"][@"bonus"]];
            waterStr2 = [NSString stringWithFormat:@"%@", success[@"data"][@"phase"][@"over"]];
            self.role = [[NSString stringWithFormat:@"%@", success[@"data"][@"role"]] integerValue];
            
            if (self.role == 1) {
//                arr2 = @[@"我是老师", @"设置", @"反馈", @"关于我们", @"退出登录"];
                arr2 = @[@"我是老师", @"系统设置", @"意见反馈", @"关于我们",@"联系客服", @"退出登录"];
            }else{
//                arr2 = @[@"设置", @"反馈", @"关于我们", @"退出登录"];
                arr2 = @[@"系统设置", @"意见反馈", @"关于我们",@"联系客服", @"退出登录"];
            }
            
            hideStr = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"hide"]];
            if ([hideStr isEqualToString:@"1"]) {
                arr1 = @[@"我的成就", @"我的资料", @"我的水滴", @"我的跟读", @"我的绘本", @"我的课程", @"老师评价"];
            }else{
                arr1 = @[@"我的成就",@"我的余额", @"我的资料", @"我的水滴", @"我的跟读", @"我的绘本", @"我的课程", @"老师评价"];
            }
            
            _titleLabel1.text = self.signString;
            [self.view addSubview:self.tableView];
            
            [self.tableView reloadData];
        }else{
            NSLog(@"event = %@, describe = %@", [success objectForKey:@"event"], [success objectForKey:@"describe"]);
        }
    } failure:^(NSError *error) {
        [Global showWithView:self.view withText:@"网络错误"];
    }];
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
