//
//  PicFreeDetailViewController.h
//  PictureBook
//
//  Created by Yasin on 2017/7/12.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "PBBaseViewController.h"

@interface PicFreeDetailViewController : PBBaseViewController

@property (nonatomic, strong)NSString *name;
@property (nonatomic, assign)NSInteger picId;
@property (nonatomic, strong)NSString *token;//绘本跟读token
@property (nonatomic, copy) void(^callback)(NSString *value);
@end
