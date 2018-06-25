//
//  MineReadModel.h
//  Picturebooks
//
//  Created by Yasin on 2017/8/17.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PictureModel.h"

@interface MineReadModel : YKBaseModel

@property (nonatomic, strong) PictureModel *picModel;
@property (nonatomic, assign) NSInteger readId;

@end
