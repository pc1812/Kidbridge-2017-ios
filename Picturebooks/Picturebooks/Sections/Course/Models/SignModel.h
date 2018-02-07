//
//  SingModel.h
//  Picturebooks
//
//  Created by 尹凯 on 2017/8/26.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SignModel : YKBaseModel

@property (nonatomic, assign)NSInteger userID;
@property (nonatomic, strong)NSString *nickname;//昵称
@property (nonatomic, strong)NSString *head;//图像
@property (nonatomic, strong)NSString *createTime;//时间
@property (nonatomic, assign)NSInteger repeatID;
@end
