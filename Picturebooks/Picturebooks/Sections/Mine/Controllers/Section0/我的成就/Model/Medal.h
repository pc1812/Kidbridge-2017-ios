//
//  Medal.h
//  FirstPage
//
//  Created by 尹凯 on 2017/7/17.
//  Copyright © 2017年 尹凯. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Medal : YKBaseModel
@property (nonatomic, assign)NSInteger ID;
@property (nonatomic, copy)NSString *name;//名字
@property (nonatomic, strong)NSMutableDictionary *icon;//图片
@property (nonatomic, assign)NSInteger BONUS;//奖励数

@end
