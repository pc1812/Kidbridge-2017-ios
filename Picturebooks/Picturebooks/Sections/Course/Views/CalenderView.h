//
//  CalenderView.h
//  CalenderDemo
//
//  Created by 沈红榜 on 2017/9/20.
//  Copyright © 2017年 沈红榜. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalenderView : UIView

- (instancetype)initWithMinY:(CGFloat)minY;

@property (nonatomic, strong) void(^clickedDate)(NSDateComponents *date);
@property (nonatomic, strong) NSArray <NSDictionary *>*beginAndCycleArray;  //其中的字典是由下面的 - (NSDictionary *)beginYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day cycle:(NSInteger)cycle 方法生成

@property (nonatomic, strong) NSArray <NSDictionary *>*hadDoneArray;  //其中的字典是由下面的 - (NSDictionary *)dateDicWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day 方法生成
@property (nonatomic, assign) BOOL red;


- (void)showYear:(NSInteger)year month:(NSInteger)month;

- (NSDictionary *)dateDicWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
- (NSDictionary *)beginYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day cycle:(NSInteger)cycle;

- (void)reloadData;

@end
