//
//  MineCollectionViewCell.h
//  PictureBook
//
//  Created by Yasin on 2017/7/12.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MineCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) UIImageView *picImage;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *tagLabel;
@property (nonatomic,strong) UILabel *ageLabel;
@property (nonatomic,strong) UILabel *freeLabel;
@property (nonatomic,strong) UIButton *selbtn;

@end
