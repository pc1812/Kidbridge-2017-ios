//
//  CalenderView.m
//  CalenderDemo
//
//  Created by 沈红榜 on 2017/9/20.
//  Copyright © 2017年 沈红榜. All rights reserved.
//

#import "CalenderView.h"

@interface _CanlenderItem : UICollectionViewCell

- (void)configObj:(id)obj color:(UIColor *)color;

@end

@implementation _CanlenderItem {
    UILabel     *_lbl;
    
    NSDateComponents *_currentCom;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _lbl = [[UILabel alloc] initWithFrame:self.bounds];
        _lbl.font = [UIFont systemFontOfSize:15];
        _lbl.textAlignment = NSTextAlignmentCenter;
        _lbl.layer.cornerRadius = 5;
        _lbl.layer.masksToBounds = true;
        [self addSubview:_lbl];
        
        _currentCom = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
        
    }
    return self;
}

- (void)configObj:(id)obj color:(UIColor *)color {
    if ([obj isKindOfClass:[NSString class]]) {
        _lbl.text = obj;
        _lbl.textColor = [UIColor blackColor];
        _lbl.backgroundColor = [UIColor whiteColor];
        return;
    }
    NSDateComponents *com = (NSDateComponents *)obj;
    _lbl.text = [NSString stringWithFormat:@"%ld", (long)com.day];
    _lbl.textColor = color;
    
    if (com.year == _currentCom.year && com.month == _currentCom.month && com.day == _currentCom.day) {
        _lbl.backgroundColor = [UIColor greenColor];
        _lbl.textColor = [UIColor whiteColor];
    } else {
        _lbl.backgroundColor = [UIColor whiteColor];
    }
    
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected) {
        _lbl.layer.borderColor = [UIColor greenColor].CGColor;
        _lbl.layer.borderWidth = 1;
    }else{
        _lbl.layer.borderColor = [UIColor greenColor].CGColor;
        _lbl.layer.borderWidth = 0;
    }
}
@end

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

@interface CalenderView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) UIButton *lastBtn;
@property (nonatomic, strong) UILabel   *title;
@property (nonatomic, strong) UIButton *nextBtn;

@property (nonatomic, strong) UICollectionView  *collView;

@property (nonatomic, strong, readonly) NSDateComponents *currentDateCom;

@property (nonatomic, strong) NSMutableArray <NSDateComponents *>*allInCycleDays;
@property (nonatomic, strong) NSMutableArray <NSDateComponents *>*hadDoneDays;

@end

@implementation CalenderView {
    NSCalendar      *_calendar;
    
    NSDateComponents    *_showDateCom;
    NSCalendarUnit      _showUnit;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    CGFloat minY = CGRectGetMinY(frame);
    self = [self initWithMinY:minY];
    return self;
}

- (instancetype)initWithMinY:(CGFloat)minY {
    CGFloat topH = 50;
    CGRect frame = CGRectMake(0, minY, CGRectGetWidth([UIScreen mainScreen].bounds), topH + 30 * 6);
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        _dataArray = [NSMutableArray arrayWithCapacity:0];
        _allInCycleDays = [NSMutableArray arrayWithCapacity:0];
        _hadDoneDays = [NSMutableArray arrayWithCapacity:0];
        
        _showUnit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
        
        [self addSubview:self.title];
        _title.bounds = CGRectMake(0, 0, 100, topH);
        _title.center = CGPointMake(CGRectGetWidth(frame) / 2., topH / 2.);
        
        [self addSubview:self.lastBtn];
        [self addSubview:self.nextBtn];
        
        _lastBtn.frame = CGRectMake(CGRectGetMinX(_title.frame) - 80, 0, 60, topH);
        _nextBtn.frame = CGRectMake(CGRectGetMaxX(_title.frame) + 20, 0, 60, topH);
        
        [self addSubview:self.collView];
        _collView.frame = CGRectMake(0, topH, CGRectGetWidth(frame), 30 * 6);
        
        _calendar = [NSCalendar currentCalendar];

        _currentDateCom = [_calendar components:_showUnit  fromDate:[NSDate date]];
        
        [self generateDataWithDateCom:_currentDateCom];
    }
    return self;
}



#pragma mark - Data
- (void)generateDataWithDateCom:(NSDateComponents *)dateCom {
    
    [_dataArray removeAllObjects];
    _showDateCom = dateCom;

    NSArray *weekArray = [_calendar.shortWeekdaySymbols valueForKeyPath:@"uppercaseString"];

    [_dataArray addObjectsFromArray:weekArray];
    
    _title.text = [NSString stringWithFormat:@"%ld年%ld月", (long)_showDateCom.year, (long)_showDateCom.month];
    
    NSDate *showDate = [_calendar dateFromComponents:dateCom];
    
    NSRange range = [_calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:showDate];
    NSInteger numberInThisMonth = range.length;
    
    for (int i = 1; i <= numberInThisMonth; i++) {
        
        NSDateComponents *tempCom = [[NSDateComponents alloc] init];
        tempCom.year = _showDateCom.year;
        tempCom.month = _showDateCom.month;
        tempCom.day = i;
        
        NSDate *tempDate = [_calendar dateFromComponents:tempCom];
        
        if (i == 1) {
            NSDateComponents *aa = [_calendar components:NSCalendarUnitWeekday fromDate:tempDate];
            
            NSInteger needAddPlaceDayNum = aa.weekday - 1;
            for (int a = 0; a < needAddPlaceDayNum; a++) {
                [_dataArray addObject:@""];
            }
        }
        
        [_dataArray addObject:tempCom];
    }
    [_collView reloadData];
}


- (void)showYear:(NSInteger)year month:(NSInteger)month {
    
    NSDateComponents *com = [[NSDateComponents alloc] init];
    com.year = year;
    com.month = month;
    [self generateDataWithDateCom:com];
}

- (void)reloadData {
    [_collView reloadData];
}

#pragma mark - Helps
- (NSDictionary *)beginYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day cycle:(NSInteger)cycle {
    NSDictionary *dic = @{@"year" : @(year), @"month" : @(month), @"day" : @(day), @"cycle" : @(cycle)};
    return dic;
}

- (NSDictionary *)dateDicWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    return [self beginYear:year month:month day:day cycle:0];
}

- (UIColor *)_colorWithDateCom:(NSDateComponents *)dateCom {
    
    __block BOOL inCycle = false;   //记录是否在周期内
    __block BOOL beforeToday = false;   //如果在周期内，记录是否是今天以前的时间，今天也为true

    [_allInCycleDays enumerateObjectsUsingBlock:^(NSDateComponents * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (obj.year == dateCom.year && obj.month == dateCom.month && obj.day == dateCom.day) {
            inCycle = true;

            //只能这样链式写，不能写在同一个if里
            if (obj.year < _currentDateCom.year) {
                beforeToday = true;
            } else if (obj.year == _currentDateCom.year && obj.month < _currentDateCom.month) {
                beforeToday = true;
            } else if (obj.year == _currentDateCom.year && obj.month == _currentDateCom.month && obj.day <= _currentDateCom.day) {
                beforeToday = true;
            }
            *stop = true;
        }
        
    }];
    
    if (inCycle) {
        if (beforeToday) {
            __block BOOL hadDone = false;
            [_hadDoneDays enumerateObjectsUsingBlock:^(NSDateComponents * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.day == dateCom.day && obj.month == dateCom.month && obj.year == dateCom.year) {
                    hadDone = true;
                }
            }];
            
            if (_red) {
                 return hadDone ? [UIColor greenColor] : [UIColor blackColor];
            }else{
                return hadDone ? [UIColor greenColor] : [UIColor redColor];
                
            }
            
        } else {
            return [UIColor blackColor];    //今天之后的周期内为黑
        }
    }
    
    
    return [UIColor grayColor];
}

#pragma mark - Actions
/** 上一个月的点击事件 */
- (void)clickedLastBtn {
    
    NSDate *showDate = [_calendar dateFromComponents:_showDateCom];
    
    NSDateComponents *addCom = [[NSDateComponents alloc] init];
    addCom.month = -1;
    
    NSDate *tempDate = [_calendar dateByAddingComponents:addCom toDate:showDate options:0];
    NSDateComponents *result = [_calendar components:_showUnit fromDate:tempDate];
    [self generateDataWithDateCom:result];
    
}

/** 下一个月的点击事件 */
- (void)clickedNextBtn {
    
    NSDate *showDate = [_calendar dateFromComponents:_showDateCom];
    
    NSDateComponents *addCom = [[NSDateComponents alloc] init];
    addCom.month = 1;
    
    NSDate *tempDate = [_calendar dateByAddingComponents:addCom toDate:showDate options:0];
    NSDateComponents *result = [_calendar components:_showUnit fromDate:tempDate];
    [self generateDataWithDateCom:result];
    
}


#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    _CanlenderItem *item = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([_CanlenderItem class]) forIndexPath:indexPath];
    
    id obj = _dataArray[indexPath.item];
    if ([obj isKindOfClass:[NSString class]]) {
        [item configObj:obj color:[UIColor grayColor]];
    } else {
        UIColor *color = [self _colorWithDateCom:obj];
        
        [item configObj:obj color:color];
        
    }
    return item;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    id obj = _dataArray[indexPath.item];
    if ([obj isKindOfClass:[NSDateComponents class]]) {
        NSDateComponents *date = (NSDateComponents *)obj;
        if (_clickedDate) {
            _clickedDate(date);
        }
    }
}

#pragma mark - getter
- (UIButton *)lastBtn {
    if (!_lastBtn) {
        _lastBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lastBtn setImage:[UIImage imageNamed:@"leftarr"] forState:UIControlStateNormal];
        _lastBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_lastBtn addTarget:self action:@selector(clickedLastBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lastBtn;
}

- (UIButton *)nextBtn {
    if (!_nextBtn) {
        _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextBtn setImage:[UIImage imageNamed:@"rightarr"] forState:UIControlStateNormal];
        _nextBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_nextBtn addTarget:self action:@selector(clickedNextBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] initWithFrame:CGRectZero];
        _title.textAlignment = NSTextAlignmentCenter;
    }
    return _title;
}

- (UICollectionView *)collView {
    
    if (!_collView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        CGFloat hs = 25;
        
        layout.sectionInset = UIEdgeInsetsMake(0, hs, 0, hs);
        
        CGFloat itemW = (CGRectGetWidth(self.frame) - hs * 2.) / 7;
        CGFloat itemH = 30;
        layout.itemSize = CGSizeMake(itemW, itemH);
        
        _collView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collView.backgroundColor = [UIColor whiteColor];
        _collView.delegate = self;
        _collView.dataSource = self;
        [_collView registerClass:[_CanlenderItem class] forCellWithReuseIdentifier:NSStringFromClass([_CanlenderItem class])];
    }
    
    return _collView;
}

#pragma mark - setter
- (void)setBeginAndCycleArray:(NSArray<NSDictionary *> *)beginAndCycleArray {
    _beginAndCycleArray = beginAndCycleArray;
    [_allInCycleDays removeAllObjects];
    
    for (NSDictionary *dic in beginAndCycleArray) {
        
        NSInteger year = [dic[@"year"] integerValue];
        NSInteger month = [dic[@"month"] integerValue];
        NSInteger day = [dic[@"day"] integerValue];
        NSInteger cycle = [dic[@"cycle"] integerValue];
        
        NSDateComponents *com = [[NSDateComponents alloc] init];
        com.year = year;
        com.month = month;
        com.day = day;
        
        NSDate *beginDate = [_calendar dateFromComponents:com];
        
        for (int i = 0; i < cycle; i++) {
            NSDateComponents *addCom = [[NSDateComponents alloc] init];
            addCom.day = 1 * i;
            
            NSDate *tempDate = [_calendar dateByAddingComponents:addCom toDate:beginDate options:0];
            
            NSDateComponents *result = [_calendar components:_showUnit fromDate:tempDate];
            [_allInCycleDays addObject:result];
        }
    }
}

- (void)setHadDoneArray:(NSArray<NSDictionary *> *)hadDoneArray {
    _hadDoneArray = hadDoneArray;
    [_hadDoneDays removeAllObjects];
    
    for (NSDictionary *dic in hadDoneArray) {
        
        NSInteger year = [dic[@"year"] integerValue];
        NSInteger month = [dic[@"month"] integerValue];
        NSInteger day = [dic[@"day"] integerValue];
        
        NSDateComponents *com = [[NSDateComponents alloc] init];
        com.year = year;
        com.month = month;
        com.day = day;
        [_hadDoneDays addObject:com];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
