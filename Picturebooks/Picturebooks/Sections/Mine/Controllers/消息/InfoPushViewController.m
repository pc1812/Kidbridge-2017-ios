//
//  InfoPushViewController.m
//  PictureBook
//
//  Created by Yasin on 2017/7/15.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "InfoPushViewController.h"
#import "InfoPushViewCell.h"
#import "ForumDB.h"
#import "MinePushModel.h"
@interface InfoPushViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *dataSource;
@property(nonatomic, strong)UILabel *noLabel;

@end

@implementation InfoPushViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
    //self.dataSource = [ForumDB getallPush];
    NSString *userID =  [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
    self.dataSource = [ForumDB getselectpush:userID];
    //[ForumDB deletePushTable];
    if (self.dataSource.count) {
        self.noLabel.text = @"";
    }else{
        self.noLabel.text = @"暂无数据";
        
    }
    NSLog(@"-----tuisong%@, ---suoyou%@", [ForumDB getselectpush:userID], [ForumDB getallPush]);

}

-(UILabel *)noLabel
{
    if (!_noLabel) {
        self.noLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-250)/2, (SCREEN_HEIGHT-100-44-250)/2, 250, 250)];
        self.noLabel.backgroundColor=[UIColor clearColor];
        self.noLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.noLabel];
        
    }
    return _noLabel;
}


- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString *title = [userInfo valueForKey:@"title"];
    NSString *content = [userInfo valueForKey:@"content"];
    NSDictionary *extra = [userInfo valueForKey:@"extras"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    NSString *currentContent = [NSString
                                stringWithFormat:
                                @"收到自定义消息:%@\ntitle:%@\ncontent:%@\nextra:%@\n",
                                [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                               dateStyle:NSDateFormatterNoStyle
                                                               timeStyle:NSDateFormatterMediumStyle],
                                title, content, [self logDic:extra]];
    NSLog(@"%@", currentContent);
    
}
- (NSString *)logDic:(NSDictionary *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListFromData:tempData
                                     mutabilityOption:NSPropertyListImmutable
                                               format:NULL
                                     errorDescription:NULL];
    return str;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - PBNew64 - 44) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    }
    return _tableView ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.dataSource.count == 0) {
        return 0;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellId =[NSString stringWithFormat:@"cellTwo%ld%ld",(long)[indexPath section],(long)[indexPath row]];
    InfoPushViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[InfoPushViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    MinePushModel *model = self.dataSource[indexPath.section];
    cell.photoImg.image = [UIImage imageNamed:@"defaultPhoto"];
    [cell setDetail:model.text];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

//设置区尾高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak InfoPushViewController *preferSelf = self;
    InfoPushViewCell *sortCell = (InfoPushViewCell *)[preferSelf tableView:_tableView cellForRowAtIndexPath:indexPath];
    return sortCell.frame.size.height;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    __strong UIView *view = [UIView new];
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor grayColor];
    label.textAlignment = NSTextAlignmentCenter;
    MinePushModel *model = self.dataSource[section];
    LabelSet(label, model.createTime, [UIColor whiteColor], 12, labDic, labSize);
    label.frame = FRAMEMAKE_F((SCREEN_WIDTH - labSize.width + 20) / 2, 18, labSize.width + 20, labSize.height + 10);
    label.layer.cornerRadius = 10;
    label.clipsToBounds = YES;
    
    [view addSubview:label];
    return view;
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
