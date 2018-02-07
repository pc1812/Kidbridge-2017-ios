//
//  YKCalendarView.h
//  Picturebooks
//
//  Created by 尹凯 on 2017/8/26.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YKCalendarDate.h"

@protocol YKCalendarViewDelegate <NSObject>

- (void)lastOrNextMonth:(NSString *)dateYYYYMM;

@end

@interface YKCalendarView : UIView

@property (nonatomic, strong)NSDate *date;
@property (nonatomic, strong)UIButton *dayButton;//今天
@property (nonatomic, strong)NSMutableDictionary *startDateAndCycle;//开始日期及周期字典
@property (nonatomic, strong)NSMutableArray *haveDone;//打过卡的日期数组
@property (nonatomic, weak)id<YKCalendarViewDelegate>delegate;

@end
