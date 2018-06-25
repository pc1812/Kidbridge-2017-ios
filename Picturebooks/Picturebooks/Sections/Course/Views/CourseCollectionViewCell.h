//
//  CourseTableViewCell.h
//  PictureBook
//
//  Created by Yasin on 2017/7/8.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourseCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *photoImg;
@property (nonatomic,strong) UIImageView *lockImage;
@property(nonatomic,strong)UILabel *nameLab; 
@property(nonatomic,strong)UILabel *ageLab;
@property(nonatomic,strong)UILabel *courseLab;
@property(nonatomic,strong)UILabel *dayLab;
@property(nonatomic,strong)UILabel *priceLab;
@property(nonatomic,strong)UILabel *waterLab;

- (void)setName:(NSString *)name age:(NSString *)age course:(NSString *)course day:(NSString *)day price:(NSString *)price water:(NSString *)water array:(NSArray *)arr;

@end
