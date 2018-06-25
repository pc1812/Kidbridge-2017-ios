//
//  CardReplyViewController.m
//  Picturebooks
//
//  Created by Yasin on 2017/7/21.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "CardReplyViewController.h"
#import "EvaluateViewCell.h"
#import "QQInputView.h"
#import "IQKeyboardManager.h"

static NSString *cellIdentifier = @"Cell";

@interface CardReplyViewController ()<UITableViewDelegate, UITableViewDataSource, EvaluateViewCellDelagate,UITextFieldDelegate>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *commentArr;
@property (nonatomic, strong) UIView *bacView;
@property (nonatomic, strong) QQInputView *bottomInputView;

@property (nonatomic, assign) CGFloat commentOffset;
@property (nonatomic, strong) NSMutableArray *cellHeightArray;
@property (nonatomic, strong) NSMutableArray *commentHeightArray;
@property (nonatomic, strong) NSMutableArray *modelArray;
@property (nonatomic, assign) CGFloat currentCellOffset;

@end

@implementation CardReplyViewController

- (void)dealloc{
    NSLog(@"内存没有泄漏");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboaddShow:) name:UIKeyboardWillShowNotification object:nil];
    [self.view addSubview:self.tableView];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
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

- (NSMutableArray *)commentArr{
    if (!_commentArr) {
        _commentArr = [NSMutableArray array];
        for (int i = 0; i < 3; i++) {
            NSString *content = @"很用心,加油";
            [_commentArr addObject:content];
        }
    }
    return _commentArr;
}

- (void)loadData{
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellId =[NSString stringWithFormat:@"cellTwo%ld%ld",(long)[indexPath section],(long)[indexPath row]];
    EvaluateViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[EvaluateViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    [cell setName:@"小萌" time:@"4'30''" arr:self.commentArr];
    
    cell.photoImg.image = [UIImage imageNamed:@"ceshi.jpg"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    return cell;
}

#pragma mark - 弹出输入框
- (UIView *)bacView {
    if (_bacView == nil) {
        _bacView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removekeyboard)];
        [_bacView addGestureRecognizer:tap];
    }
    return _bacView;
}

- (QQInputView *)bottomInputView {
    if (_bottomInputView == nil) {
        _bottomInputView = [[QQInputView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.tableView.bounds.size.width, 50)];
        _bottomInputView.messageTextField.delegate = self;
        [_bottomInputView.sendButton addTarget:self action:@selector(sendCommint:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bottomInputView;
}

#pragma mark - 输入框文字改变
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSMutableString *resultString;
    if (textField.text.length == range.location) {
        resultString = [NSMutableString stringWithFormat:@"%@%@", textField.text, string];
    } else {
        resultString = [NSMutableString stringWithString:textField.text];
        [resultString replaceCharactersInRange:range withString:string];
    }
    if ([resultString isEqualToString:@""]) {
        [self makeButtonNotWork];
    } else {
        self.bottomInputView.sendButton.enabled = YES;
        [self.bottomInputView.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.bottomInputView.sendButton.backgroundColor = [UIColor colorWithRed:0 green:182 / 255.0 blue:248 / 255.0 alpha:1];
    }
    return YES;
}

- (void)makeButtonNotWork {
    self.bottomInputView.sendButton.enabled = NO;
    [self.bottomInputView.sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    self.bottomInputView.sendButton.backgroundColor = [UIColor whiteColor];
}

#pragma mark - 发表评论
- (void)sendCommint:(UIButton *)button{
    if (![self.bottomInputView.messageTextField.text isEqualToString:@""]){
        
        NSString *commint = [NSString stringWithFormat:@"小七：%@", self.bottomInputView.messageTextField.text];
        [self.commentArr addObject:commint];
        
        self.bottomInputView.messageTextField.text = @"";
        [self makeButtonNotWork];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"index" object:nil userInfo:nil];
    }
}

- (void)removekeyboard {
    _commentOffset = 0;
    [self.bacView removeFromSuperview];
    [self.bottomInputView.messageTextField resignFirstResponder];
    [self.bottomInputView removeFromSuperview];
}

- (void)cellClick:(int)row{
    [self.view.window addSubview:self.bacView];
    [self.view.window addSubview:self.bottomInputView];
    self.bottomInputView.sendButton.tag = 5000 + row;
    [self.bottomInputView.messageTextField becomeFirstResponder];
}

- (void)keyboaddShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyBoardEndY = value.CGRectValue.origin.y;
    
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView animateWithDuration:duration.doubleValue animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:[curve intValue]];
        self.bottomInputView.center = CGPointMake(self.bottomInputView.center.x, keyBoardEndY - self.bottomInputView.bounds.size.height / 2.0);
    }];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak CardReplyViewController *preferSelf = self;
    EvaluateViewCell *sortCell = (EvaluateViewCell *)[preferSelf tableView:_tableView cellForRowAtIndexPath:indexPath];
    return sortCell.frame.size.height;
}

//设置区头高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 10;
    }else{
        return 0.001;
    }
}

//设置区尾高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

//区头
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    __strong UIView *view = [UIView new];
    view.backgroundColor = RGBHex(0xf0f0f0);
    
    return view;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    __strong UIView *view = [UIView new];
    view.backgroundColor = RGBHex(0xf0f0f0);
    
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
