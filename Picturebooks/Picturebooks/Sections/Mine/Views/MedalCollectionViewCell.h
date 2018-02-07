//
//  MedalCollectionViewCell.h
//  FirstPage
//
//  Created by 尹凯 on 2017/7/17.
//  Copyright © 2017年 尹凯. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Medal.h"

@interface MedalCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong)Medal *medal;

@property (nonatomic, strong)UIImageView *medalImage;
@property (nonatomic ,strong)UILabel *num;
@property (nonatomic, strong)UILabel *title;
@property (nonatomic, assign)BOOL active;

@end
