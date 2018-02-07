//
//  CardStateViewController.m
//  Picturebooks
//
//  Created by Yasin on 2017/7/21.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "CardStateViewController.h"
#import "CardViewCell.h"
@interface CardStateViewController ()<UITableViewDelegate, UITableViewDataSource, CardViewCellDelagate,LGAudioPlayerDelegate>
@property (nonatomic, strong)UITableView *tableView;

@end

@implementation CardStateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    [LGAudioPlayer sharePlayer].delegate = self;
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
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellId =[NSString stringWithFormat:@"cellTwo%ld%ld",(long)[indexPath section],(long)[indexPath row]];
    CardViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[CardViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
  
    [cell setName:@"小萌" time:@"4'30''"];
    cell.photoImg.image = [UIImage imageNamed:@"ceshi.jpg"];
    cell.delegate = self;
    [cell.infoBtn addTarget:self action:@selector(clickComment:) forControlEvents:UIControlEventTouchUpInside];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)clickComment:(UIButton *)button{

}

#pragma mark - CardViewCellDelegate
- (void)voiceMessageTaped:(CardViewCell *)cell{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];

    if ( cell.playBtn.selected) {
        [[LGAudioPlayer sharePlayer] playAudioWithURLString:@"" atIndex:indexPath.row];
    }else{
        [[LGAudioPlayer sharePlayer] stopAudioPlayer];
    }
}

#pragma mark - LGAudioPlayerDelegate
- (void)audioPlayerStateDidChanged:(LGAudioPlayerState)audioPlayerState forIndex:(NSUInteger)index{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    CardViewCell *voiceMessageCell = [_tableView cellForRowAtIndexPath:indexPath];
    LGVoicePlayState voicePlayState;
    
    switch (audioPlayerState) {
        case LGAudioPlayerStateNormal:
            voicePlayState = LGVoicePlayStateNormal;
            break;
        case LGAudioPlayerStatePlaying:
            voicePlayState = LGVoicePlayStatePlaying;
            break;
        case LGAudioPlayerStateCancel:
            voicePlayState = LGVoicePlayStateCancel;
            break;
        default:
            break;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [voiceMessageCell setVoicePlayState:voicePlayState];
    });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak CardStateViewController *preferSelf = self;
    CardViewCell *sortCell = (CardViewCell *)[preferSelf tableView:_tableView cellForRowAtIndexPath:indexPath];
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

//区头
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
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
