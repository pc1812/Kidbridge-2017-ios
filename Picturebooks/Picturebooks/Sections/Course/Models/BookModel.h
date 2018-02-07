//
//  BookModel.h
//  Picturebooks
//
//  Created by 尹凯 on 2017/8/24.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookModel : YKBaseModel

@property (nonatomic, assign)NSInteger bookId;
@property (nonatomic, strong)NSArray *icon;//图片

@end
