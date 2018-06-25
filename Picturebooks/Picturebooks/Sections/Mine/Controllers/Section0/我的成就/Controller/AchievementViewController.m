//
//  AchievementViewController.m
//  FirstPage
//
//  Created by 尹凯 on 2017/7/17.
//  Copyright © 2017年 尹凯. All rights reserved.
//

#import "AchievementViewController.h"

@interface AchievementViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong)UICollectionView *myCollectionView;
@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, assign)NSInteger bonus;

@end

@implementation AchievementViewController

- (void)dealloc{
    NSLog(@"-----没有泄漏哦-----");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = RGBHex(0xf0f0f0);
    self.navigationItem.title = @"勋章墙";
    self.navigationController.navigationBar.barTintColor = RGBHex(0x14d02f);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18 weight:2], NSForegroundColorAttributeName:[UIColor whiteColor]}];
   
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 30)];
    [button setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    button.adjustsImageWhenHighlighted = NO;
    UIView *containView = [[UIView alloc] initWithFrame:button.bounds];
    [containView addSubview:button];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:containView];
    self.navigationItem.leftBarButtonItem = barButton;
    
    self.dataArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:User_medal forKey:@"uri"];
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    
    [[HttpManager sharedManager] POST:User_medal parame:parame sucess:^(id success) {
        if ([[success objectForKey:@"event"] isEqualToString:@"SUCCESS"]) {

            NSMutableDictionary *tmpDic = [success objectForKey:@"data"];
            self.bonus = [[tmpDic objectForKey:@"bonus"] integerValue];
            NSMutableArray *tmpArray = [tmpDic objectForKey:@"medalList"];
            for (NSMutableDictionary *dic in tmpArray) {
                Medal *medal = [Medal modelWithDictionary:dic];
                [self.dataArray addObject:medal];
            }
            [self createView];
        }else{
            NSLog(@"event = %@, describe = %@", [success objectForKey:@"event"], [success objectForKey:@"describe"]);
        }
    } failure:^(NSError *error) {
        [Global showWithView:self.view withText:@"网络错误"];
    }];
    
}

- (void)createView{
    UIView *headView = [[UIView alloc] init];
    [self.view addSubview:headView];
    headView.backgroundColor = [UIColor whiteColor];
    [headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(180 * PROPORTION); // 140
    }];
    
    UILabel *titleLabel1 = [[UILabel alloc] init];
    titleLabel1.text = @"我的进度";
    titleLabel1.font = [UIFont boldSystemFontOfSize:18 * PROPORTION];
    [titleLabel1 sizeToFit];
    [headView addSubview:titleLabel1];
    [titleLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12 * PROPORTION);
        make.top.mas_equalTo(21 * PROPORTION);
    }];
    
    for (int i = 0; i < 5; i++) {
        Medal *medal = [self.dataArray objectAtIndex:i];
        
        UIImageView *imageview = [[UIImageView alloc] init];
        [headView addSubview:imageview];
        if (self.bonus >= medal.BONUS) {
            imageview.image = [UIImage imageNamed:@"m_xunzhangget.png"];
        }else{
            imageview.image = [UIImage imageNamed:@"m_xunzhangwu.png"];
        }
        [imageview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel1.mas_bottom).offset(25);
            make.left.mas_equalTo(36 * PROPORTION + i * (27.5 + 42) * PROPORTION);
            make.width.mas_equalTo(27.5 * PROPORTION);
            make.height.mas_equalTo(32 * PROPORTION);
        }];
        
        UILabel *label = [[UILabel alloc] init];
        [headView addSubview:label];
        label.font = [UIFont systemFontOfSize:12 * PROPORTION];
        label.text = medal.name;
        [label sizeToFit];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageview.mas_bottom).offset(9 * PROPORTION);
            make.centerX.mas_equalTo(imageview.mas_centerX);
        }];
        
        if (i < 4) {
            UIView *line = [[UIView alloc] init];
            [headView addSubview:line];
            line.backgroundColor = RGBHex(0xf0f0f0);
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(42 * PROPORTION);
                make.height.mas_equalTo(2 * PROPORTION);
                make.top.equalTo(imageview.mas_top).offset(11 * PROPORTION);
                make.left.equalTo(imageview.mas_right).offset(0);
            }];
        }
        
        if (self.bonus >= medal.BONUS) {
            UIView *line = [[UIView alloc] init];
            [headView addSubview:line];
            line.backgroundColor = RGBHex(0x14d02f);
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(((self.bonus - medal.BONUS) > 30.0 ? 30.0 : (self.bonus - medal.BONUS)) / 30.0 * 42 * PROPORTION);
                make.height.mas_equalTo(2 * PROPORTION);
                make.top.equalTo(imageview.mas_top).offset(11 * PROPORTION);
                make.left.equalTo(imageview.mas_right).offset(0);
            }];
            
            if (self.bonus - medal.BONUS < 30) {
                UILabel *label = [[UILabel alloc] init];
                [headView addSubview:label];
                label.text = [NSString stringWithFormat:@"%ld", (long)self.bonus];
                label.font = [UIFont systemFontOfSize:10 * PROPORTION];
                [label sizeToFit];
                label.textColor = RGBHex(0x14d02f);
                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.bottom.equalTo(line.mas_top).offset(0);
                    make.right.equalTo(line.mas_right).offset(6 * PROPORTION);
                }];
            }
        }
    }
    
    UIView *backgroundView = [[UIView alloc] init];
    [self.view addSubview:backgroundView];
    backgroundView.backgroundColor = [UIColor whiteColor];
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(189 * PROPORTION); // 149
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(360 * PROPORTION);
    }];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"我的勋章墙";
    titleLabel.font = [UIFont boldSystemFontOfSize:18 * PROPORTION];
    [titleLabel sizeToFit];
    [backgroundView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12 * PROPORTION);
        make.top.mas_equalTo(22 * PROPORTION);
    }];
    
    UILabel *remarkLabel = [[UILabel alloc] init];
    [backgroundView addSubview:remarkLabel];
    remarkLabel.text = @"（注：购买的水滴不计算在内）";
    remarkLabel.font = [UIFont systemFontOfSize:14 * PROPORTION];
    remarkLabel.textColor = [UIColor grayColor];
    [remarkLabel sizeToFit];
    [remarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel.mas_right).offset(3 * PROPORTION);
        make.centerY.mas_equalTo(titleLabel.mas_centerY);
    }];
    [backgroundView addSubview:self.myCollectionView];
}

- (UICollectionView *)myCollectionView{
    if (!_myCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        
        //设置每个item(cell)的大小
        flowLayout.itemSize = CGSizeMake(79 * PROPORTION, 125 * PROPORTION);
        //设置最小行间距
        flowLayout.minimumLineSpacing = 27 * PROPORTION;
        //设置最小列间距
        flowLayout.minimumInteritemSpacing = 40 * PROPORTION;
        //设置item与四周边界的距离  上左下右
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 27.5 * PROPORTION, 25 * PROPORTION, 27.5 * PROPORTION);
        //设置滚动方向
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        //设置头部区域大小
        //flowLayout.headerReferenceSize = CGSizeMake(375, 150);
        
        _myCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 63 * PROPORTION, SCREEN_WIDTH, 300 * PROPORTION) collectionViewLayout:flowLayout];
        _myCollectionView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_myCollectionView];
        _myCollectionView.scrollEnabled = NO;
        _myCollectionView.delegate = self;
        _myCollectionView.dataSource = self;
        _myCollectionView.showsVerticalScrollIndicator = NO;
        
        [_myCollectionView registerClass:[MedalCollectionViewCell class] forCellWithReuseIdentifier:@"collectionFirstViewCell"];
    }
    return _myCollectionView;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MedalCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionFirstViewCell" forIndexPath:indexPath];
    Medal *medal = [self.dataArray objectAtIndex:indexPath.row];
    
    if (self.bonus >= medal.BONUS) {
        cell.active = YES;
    }else{
        cell.active = NO;
    }
    cell.medal = medal;
    return cell;
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
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
