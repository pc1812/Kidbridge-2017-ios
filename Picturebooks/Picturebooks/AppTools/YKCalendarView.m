//
//  YKCalendarView.m
//  Picturebooks
//
//  Created by 尹凯 on 2017/8/26.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "YKCalendarView.h"

@implementation YKCalendarView
{
    UIButton  *_selectButton;
    UILabel *headlabel;
    UIButton *rightButton;
    UIImageView *rightImg;
    
    NSDate *lpDate;
    NSMutableArray *_daysArray;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _daysArray = [NSMutableArray arrayWithCapacity:42];
        
        for (int i = 0; i < 42; i++) {
            UIButton *button = [[UIButton alloc] init];
            [self addSubview:button];
            [_daysArray addObject:button];
        }
    }
    return self;
}

#pragma mark - create View
- (void)setDate:(NSDate *)date{
    _date = date;
    [self createCalendarViewWith:date];
}

- (void)createCalendarViewWith:(NSDate *)date{
    
    lpDate = self.date;
    
    CGFloat itemW = self.frame.size.width / 7;
    CGFloat itemH = self.frame.size.height / 7;
    
    // 1.year month
    headlabel = [[UILabel alloc] init];
    headlabel.text = [NSString stringWithFormat:@"%ld年%ld月", (long)[YKCalendarDate year:date], (long)[YKCalendarDate month:date]];
    headlabel.font = [UIFont systemFontOfSize:14];
    headlabel.frame = CGRectMake( self.frame.size.width/2 - 40, 0, 80, itemH);
    headlabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:headlabel];
    
    //last month
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    leftButton.frame = CGRectMake(headlabel.frame.origin.x - 50, headlabel.frame.origin.y, 40, itemH);
    [leftButton addTarget:self action:@selector(clickMonth:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:leftButton];
    
    UIImageView *leftImg = [[UIImageView alloc] init];
    leftImg.image = [UIImage imageNamed:@"leftarr"];
    [leftButton addSubview:leftImg];
    [leftImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-5);
        make.top.mas_equalTo(3);
        make.width.and.height.mas_equalTo(20);
    }];
    
    //next month   if greater than the current month does not show
    rightButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    rightButton.frame = CGRectMake(headlabel.frame.origin.x + 90, leftButton.frame.origin.y, leftButton.frame.size.width, leftButton.frame.size.height);
    [rightButton addTarget:self action:@selector(clickMonth:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:rightButton];
    
    rightImg = [[UIImageView alloc] init];
    rightImg.image = [UIImage imageNamed:@"rightarr"];
    [rightButton addSubview:rightImg];
    [rightImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(3.5);
        make.top.mas_equalTo(3);
        make.width.and.height.mas_equalTo(20);
    }];
    
    // 2.weekday
    NSArray *array = @[@"SUN", @"MON", @"THE", @"WED", @"THU", @"FRI", @"SAT"];
    UIView *weekBg = [[UIView alloc] init];
    weekBg.frame = CGRectMake(0, CGRectGetMaxY(headlabel.frame), self.frame.size.width, itemH-10);
    [self addSubview:weekBg];
    
    for (int i = 0; i < 7; i++) {
        UILabel *week = [[UILabel alloc] init];
        week.text = array[i];
        week.font = [UIFont systemFontOfSize:13];
        week.frame = CGRectMake(itemW * i, 0, itemW, itemH);
        week.textAlignment = NSTextAlignmentCenter;
        week.backgroundColor = [UIColor clearColor];
        week.textColor = [UIColor blackColor];
        [weekBg addSubview:week];
    }
    
    NSInteger daysInLastMonth = [YKCalendarDate totaldaysInMonth:[YKCalendarDate lastMonth:date]];
    NSInteger daysInThisMonth = [YKCalendarDate totaldaysInMonth:date];
    NSInteger firstWeekday = [YKCalendarDate firstWeekdayInThisMonth:date];
    
    // this month
    //NSInteger todayIndex = [YKCalendarDate day:[NSDate date]] + firstWeekday - 1;
    
    //  3.days (1-31)
    for (int i = 0; i < 42; i++) {
        
        CGFloat x = (i % 7) * itemW ;
        CGFloat y = (i / 7 + 0.5) * itemH + CGRectGetMaxY(weekBg.frame);
        
        UIButton *dayButton = _daysArray[i];
        
        dayButton.frame = CGRectMake(x, y, itemW, itemH);
        [dayButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        dayButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
        dayButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        dayButton.layer.cornerRadius = 5;
        
        NSInteger day = 0;
        
        if (i < firstWeekday) {
            day = daysInLastMonth - firstWeekday + i + 1;
            [self setStyle_BeyondThisMonth:dayButton];
        }else if (i > firstWeekday + daysInThisMonth - 1){
            day = i + 1 - firstWeekday - daysInThisMonth;
            [self setStyle_BeyondThisMonth:dayButton];
        }else{
            day = i - firstWeekday + 1;
//            if ([YKCalendarDate year:date] < [YKCalendarDate year:self.date]) {
//                [self setStyle_BeforeToday:dayButton];
//            }else if ([YKCalendarDate year:date] == [YKCalendarDate year:self.date]){
//                if ([YKCalendarDate month:date] < [YKCalendarDate month:self.date]) {
//                    [self setStyle_BeforeToday:dayButton];
//                }else if ([YKCalendarDate month:date] == [YKCalendarDate month:self.date]){
//                    if (day < todayIndex + 1 - firstWeekday) {
//                        [self setStyle_BeforeToday:dayButton];
//                    }else{
//                        [self setStyle_AfterToday:dayButton];
//                    }
//                }else{
//                    [self setStyle_AfterToday:dayButton];
//                }
//            }else{
//                [self setStyle_AfterToday:dayButton];
//            }
            [dayButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            
            
            
//            if ([YKCalendarDate year:date] == [YKCalendarDate year:[NSDate dateWithTimeIntervalSince1970:[[self.startDateAndCycle objectForKey:@"startDate"] doubleValue] / 1000]] && [YKCalendarDate month:date] == [YKCalendarDate month:[NSDate dateWithTimeIntervalSince1970:[[self.startDateAndCycle objectForKey:@"startDate"] doubleValue] / 1000]]) {
//                NSMutableArray *courseDate = [self getCourseDate];
//                for (NSDate *tmpDate in courseDate) {
//                    if (day == [YKCalendarDate day:tmpDate]) {
//                        [dayButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//                    }
//                }
//                
//                if (day >= [YKCalendarDate day:[NSDate dateWithTimeIntervalSince1970:[[self.startDateAndCycle objectForKey:@"startDate"] doubleValue] / 1000]] && day <= ([YKCalendarDate day:[NSDate dateWithTimeIntervalSince1970:([[self.startDateAndCycle objectForKey:@"startDate"] doubleValue] + [[self.startDateAndCycle objectForKey:@"cycle"] integerValue] * 24 * 3600 * 1000) / 1000]] < [YKCalendarDate day:self.date] ? [YKCalendarDate day:[NSDate dateWithTimeIntervalSince1970:([[self.startDateAndCycle objectForKey:@"startDate"] doubleValue] + [[self.startDateAndCycle objectForKey:@"cycle"] integerValue] * 24 * 3600 * 1000) / 1000]] : [YKCalendarDate day:self.date])) {
//                    [dayButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//                }
//                
//                if (self.haveDone.count > 0) {
//                    for (NSString *timeStamp in self.haveDone) {
//                        if (day == [YKCalendarDate day:[NSDate dateWithTimeIntervalSince1970:[timeStamp doubleValue] / 1000]]) {
//                            [dayButton setTitleColor:RGBHex(0x14d02f) forState:UIControlStateNormal];
//                        }
//                    }
//                }
//            }
            
            

            if ([YKCalendarDate year:date] == [YKCalendarDate year:[NSDate dateWithTimeIntervalSince1970:[[self.startDateAndCycle objectForKey:@"startDate"] doubleValue] / 1000]] && [YKCalendarDate month:date] == [YKCalendarDate month:[NSDate dateWithTimeIntervalSince1970:[[self.startDateAndCycle objectForKey:@"startDate"] doubleValue] / 1000]]) {
                NSMutableArray *courseDate = [self getCourseDate];
                for (NSDate *tmpDate in courseDate) {
                    if (day == [YKCalendarDate day:tmpDate] ) {
                        [dayButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    }
                }
                
                if (day >= [YKCalendarDate day:[NSDate dateWithTimeIntervalSince1970:[[self.startDateAndCycle objectForKey:@"startDate"] doubleValue] / 1000]] && day <= ([YKCalendarDate day:[NSDate dateWithTimeIntervalSince1970:([[self.startDateAndCycle objectForKey:@"startDate"] doubleValue] + [[self.startDateAndCycle objectForKey:@"cycle"] integerValue] * 24 * 3600 * 1000) / 1000]] < [YKCalendarDate day:self.date] ? [YKCalendarDate day:[NSDate dateWithTimeIntervalSince1970:([[self.startDateAndCycle objectForKey:@"startDate"] doubleValue] + [[self.startDateAndCycle objectForKey:@"cycle"] integerValue] * 24 * 3600 * 1000) / 1000]] : [YKCalendarDate day:self.date])) {
                    [dayButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                }
                
                if (self.haveDone.count > 0) {
                    for (NSString *timeStamp in self.haveDone) {
                        if (day == [YKCalendarDate day:[NSDate dateWithTimeIntervalSince1970:[timeStamp doubleValue] / 1000]]) {
                            [dayButton setTitleColor:RGBHex(0x14d02f) forState:UIControlStateNormal];
                        }
                    }
                }
            }

            
            
            
            
        }
        [dayButton setTitle:[NSString stringWithFormat:@"%ld", (long)day] forState:UIControlStateNormal];
        
        NSInteger todayIndex = [YKCalendarDate day:[NSDate date]] + firstWeekday - 1;

        if([self judgementMonth] && i == todayIndex && [YKCalendarDate year:date] == [YKCalendarDate year:self.date]){
            [self setStyle_Today:dayButton];
            _dayButton = dayButton;
        }else{
            dayButton.backgroundColor = [UIColor whiteColor];
        }
    }
}

#pragma mark - date button style
//设置不是本月的日期字体颜色   ---白色  看不到
- (void)setStyle_BeyondThisMonth:(UIButton *)btn{
    btn.enabled = NO;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

//设置在今天之后的日期颜色   ---灰色
- (void)setStyle_AfterToday:(UIButton *)btn{
    btn.enabled = YES;
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
}

//设置今在天之前的日期颜色   ---红色
- (void)setStyle_BeforeToday:(UIButton *)btn{
    btn.enabled = YES;
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
}

-(BOOL)judgementMonth{
    //获取当前月份
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM";
    NSInteger dateMon = [[formatter stringFromDate:[NSDate date]] integerValue];
    
    //获取选择的月份
    NSInteger mon = [[headlabel.text substringFromIndex:5] integerValue];
    
    if (mon == dateMon){
        return YES;
    }else
        return NO;
}

- (void)setStyle_Today:(UIButton *)btn{
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[btn setBackgroundColor:[UIColor colorWithRed:94/255.0 green:169/255.0 blue:251/255.0 alpha:1]];
    [btn setBackgroundColor:RGBHex(0x14d02f)];
}

-(void)clickMonth:(UIButton *)btn{
    if (btn == rightButton){
        lpDate = [YKCalendarDate nextMonth:lpDate];
    }else{
        lpDate = [YKCalendarDate lastMonth:lpDate];
    }
    
    NSDate *date = lpDate;
    
    headlabel.text = [NSString stringWithFormat:@"%ld年%ld月", (long)[YKCalendarDate year:date], (long)[YKCalendarDate month:date]];
    
    NSInteger daysInLastMonth = [YKCalendarDate totaldaysInMonth:[YKCalendarDate lastMonth:date]];
    NSInteger daysInThisMonth = [YKCalendarDate totaldaysInMonth:date];
    NSInteger firstWeekday = [YKCalendarDate firstWeekdayInThisMonth:date];
    
    //NSInteger todayIndex = [YKCalendarDate day:[NSDate date]] + firstWeekday - 1;
    
    //执行代理方法
    NSString *dateYYYYMM = [NSString stringWithFormat:@"%ld%02ld", (long)[YKCalendarDate year:date], (long)[YKCalendarDate month:date]];
    [self.delegate lastOrNextMonth:dateYYYYMM];
    
    
    
    for (int i = 0; i < 42; i++) {
        
        UIButton *dayButton = _daysArray[i];
        NSInteger day = 0;
        
        if (i < firstWeekday) {
            day = daysInLastMonth - firstWeekday + i + 1;
            [self setStyle_BeyondThisMonth:dayButton];
        }else if (i > firstWeekday + daysInThisMonth - 1){
            day = i + 1 - firstWeekday - daysInThisMonth;
            [self setStyle_BeyondThisMonth:dayButton];
        }else{
            day = i - firstWeekday + 1;
//            if ([YKCalendarDate year:date] < [YKCalendarDate year:self.date]) {
//                [self setStyle_BeforeToday:dayButton];
//            }else if ([YKCalendarDate year:date] == [YKCalendarDate year:self.date]){
//                if ([YKCalendarDate month:date] < [YKCalendarDate month:self.date]) {
//                    [self setStyle_BeforeToday:dayButton];
//                }else if ([YKCalendarDate month:date] == [YKCalendarDate month:self.date]){
//                    if (day < todayIndex + 1 - firstWeekday) {
//                        [self setStyle_BeforeToday:dayButton];
//                    }else{
//                        [self setStyle_AfterToday:dayButton];
//                    }
//                }else{
//                    [self setStyle_AfterToday:dayButton];
//                }
//            }else{
//                [self setStyle_AfterToday:dayButton];
//            }
            [dayButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            
            if ([YKCalendarDate year:date] == [YKCalendarDate year:[NSDate dateWithTimeIntervalSince1970:[[self.startDateAndCycle objectForKey:@"startDate"] doubleValue] / 1000]] && [YKCalendarDate month:date] == [YKCalendarDate month:[NSDate dateWithTimeIntervalSince1970:[[self.startDateAndCycle objectForKey:@"startDate"] doubleValue] / 1000]]) {
                NSMutableArray *courseDate = [self getCourseDate];
                for (NSDate *tmpDate in courseDate) {
                    if (day == [YKCalendarDate day:tmpDate]) {
                        [dayButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    }
                }
                
                if (day >= [YKCalendarDate day:[NSDate dateWithTimeIntervalSince1970:[[self.startDateAndCycle objectForKey:@"startDate"] doubleValue] / 1000]] && day <= ([YKCalendarDate day:[NSDate dateWithTimeIntervalSince1970:([[self.startDateAndCycle objectForKey:@"startDate"] doubleValue] + [[self.startDateAndCycle objectForKey:@"cycle"] integerValue] * 24 * 3600 * 1000) / 1000]] < [YKCalendarDate day:self.date] ? [YKCalendarDate day:[NSDate dateWithTimeIntervalSince1970:([[self.startDateAndCycle objectForKey:@"startDate"] doubleValue] + [[self.startDateAndCycle objectForKey:@"cycle"] integerValue] * 24 * 3600 * 1000) / 1000]] : [YKCalendarDate day:self.date])) {
                    [dayButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                }
                
                if (self.haveDone.count > 0) {
                    for (NSString *timeStamp in self.haveDone) {
                        if (day == [YKCalendarDate day:[NSDate dateWithTimeIntervalSince1970:[timeStamp doubleValue] / 1000]]) {
                            [dayButton setTitleColor:RGBHex(0x14d02f) forState:UIControlStateNormal];
                        }
                    }
                }
            }
        }
        [dayButton setTitle:[NSString stringWithFormat:@"%ld", (long)day] forState:UIControlStateNormal];
        
//        // this month
        NSInteger todayIndex = [YKCalendarDate day:[NSDate date]] + firstWeekday - 1;

        if([self judgementMonth] && i == todayIndex && [YKCalendarDate year:date] == [YKCalendarDate year:self.date]){
            [self setStyle_Today:dayButton];
            _dayButton = dayButton;
        }else{
            dayButton.backgroundColor = [UIColor whiteColor];
        }
        
        
    }
}

//课程日期
- (NSMutableArray *)getCourseDate{
    //课程日期
    NSInteger cycle = [[self.startDateAndCycle objectForKey:@"cycle"] integerValue];
    NSMutableArray *courseDate = [NSMutableArray arrayWithCapacity:cycle];
    
    for (int i = 0; i < cycle; i ++) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:([[self.startDateAndCycle objectForKey:@"startDate"] doubleValue] / 1000 + i * 3600 * 24)];
        [courseDate addObject:date];
    }
    return courseDate;
}

@end
