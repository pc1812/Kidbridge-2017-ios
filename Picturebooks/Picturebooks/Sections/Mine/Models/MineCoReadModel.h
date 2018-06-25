//
//  MineCoReadModel.h
//  Picturebooks
//
//  Created by Yasin on 2017/9/18.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "YKBaseModel.h"
#import "CourseModel.h"

@interface MineCoReadModel : YKBaseModel
@property (nonatomic, strong) CourseModel *coModel;
@property (nonatomic, assign) NSInteger readId;
@end
