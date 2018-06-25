//
//  BillDetail.h
//  Picturebooks
//
//  Created by 尹凯 on 2017/8/10.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YKBaseModel.h"

@interface BillDetail : YKBaseModel

@property (nonatomic, strong)NSString *fees;//money
@property (nonatomic, strong)NSString *type;
@property (nonatomic, strong)NSString *time;//时间

@end
