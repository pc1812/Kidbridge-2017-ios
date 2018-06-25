//
//  MainCollectionViewCell.h
//  PictureBook
//
//  Created by Yasin on 2017/7/7.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) UIImageView *picImage;
@property (nonatomic,strong) UIImageView *lockImage;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *tagLabel;
@property (nonatomic,strong) UILabel *ageLabel;
@property (nonatomic,strong) UILabel *freeLabel;

@end
