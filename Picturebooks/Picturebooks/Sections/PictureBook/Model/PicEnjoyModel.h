//
//  PicEnjoyModel.h
//  Picturebooks
//
//  Created by Yasin on 2017/8/21.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "YKBaseModel.h"

@interface PicEnjoyModel : YKBaseModel

@property (nonatomic, assign) NSInteger readId;
@property (nonatomic, strong)NSString *outline;//概要
@property (nonatomic, copy) NSString *rewardStr;

@end
