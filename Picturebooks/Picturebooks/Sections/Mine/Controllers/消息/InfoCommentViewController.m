//
//  InfoCommentViewController.m
//  PictureBook
//
//  Created by Yasin on 2017/7/15.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "InfoCommentViewController.h"
#import "InfoCommentViewCell.h"
#import "ForumDB.h"
#import "MinePuComModel.h"
@interface InfoCommentViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *dataSource;
@property(nonatomic, strong)UILabel *noLabel;
@end

@implementation InfoCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
  
    [self.view addSubview:self.tableView];
    
    NSString *userID =  [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
    //self.dataSource = [ForumDB getallforum];

    self.dataSource = [ForumDB getselectforum:userID];
    
//    NSLog(@"%@",self.dataSource);
//    NSLog(@"0000000000000000000");
//    NSLog(@"userID:%@",userID);
//    NSLog(@"dataSource:%@,count:%zd",self.dataSource,self.dataSource.count);
//    for (MinePuComModel *item  in self.dataSource) {
//        NSLog(@"%zd",item.pid);
//        NSLog(@"%@",item.nickname);
//        NSLog(@"%zd",item.sid);
//        NSLog(@"mainID:%zd",item.mainID);
//    }
//    NSLog(@"0000000000000000000");
    
    //[ForumDB deleteCommentTable];
//    NSLog(@"-----%@--全部%@", [ForumDB getselectforum:userID], [ForumDB getallforum]);
    if (self.dataSource.count) {
        self.noLabel.text = @"";
    }else{
        self.noLabel.text = @"暂无数据";
        
    }

    // Do any additional setup after loading the view.
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

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - PBNew64 - 44) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    }
    return _tableView ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellId =[NSString stringWithFormat:@"cellTwo%ld%ld",(long)[indexPath section],(long)[indexPath row]];
    InfoCommentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[InfoCommentViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    MinePuComModel *model = self.dataSource[indexPath.row];
    NSString * url = [NSString stringWithFormat:@"%@%@", Qiniu_host, model.head];

    [cell.photoImg sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"defaultPhoto"]];
    NSString * nickStr;
    if ([Global isNullOrEmpty:model.nickname]) {
        nickStr = @"未设置";
    }else{
         nickStr = model.nickname;
    }
    [cell setName:nickStr detail:model.text time:model.createTime];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

//设置区尾高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak InfoCommentViewController *preferSelf = self;
    InfoCommentViewCell *sortCell = (InfoCommentViewCell *)[preferSelf tableView:_tableView cellForRowAtIndexPath:indexPath];
    return sortCell.frame.size.height;
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
