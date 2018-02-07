//
//  MineContentModel.h
//  Picturebooks
//
//  Created by Yasin on 2017/8/19.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "YKBaseModel.h"

@interface MineContentModel : YKBaseModel

@property (nonatomic, strong)NSString *source;//音频资源
@property (nonatomic, assign) NSInteger  time;//时间
@property (nonatomic, strong)NSString *text;

@end
