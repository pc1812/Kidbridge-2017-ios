//
//  CourseTableViewCell.m
//  PictureBook
//
//  Created by Yasin on 2017/7/8.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "CourseCollectionViewCell.h"

@interface CourseCollectionViewCell()

/** tagView--标签视图容器 View */
@property (nonatomic,strong) UIView *tagView;

@end

@implementation CourseCollectionViewCell

/** 懒加载--标签 Lab 的容器 View */
- (UIView *)tagView {
    if (!_tagView) {
        _tagView = [UIView new];
        [self.contentView addSubview:_tagView];
    }
    return _tagView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self ) {
        self.backgroundColor = [UIColor whiteColor];
       
        self.layer.cornerRadius = 6;
        self.contentView.layer.cornerRadius = 6.0;
        self.contentView.layer.borderWidth = 3.0;
        self.contentView.layer.borderColor = [[UIColor clearColor] CGColor];
        self.contentView.layer.masksToBounds = YES;
        
        //在cell本身添加阴影效果
        self.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
        self.layer.shadowOffset = CGSizeMake(4,4);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
        self.layer.shadowOpacity = 0.3;//阴影透明度，默认0
        self.layer.shadowRadius = 3;//阴影半径，默认3
        self.layer.masksToBounds = NO;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius].CGPath;
        
        self.photoImg = [[UIImageView alloc] init];
        self.lockImage = [[UIImageView alloc] init];
        [self.photoImg addSubview:self.lockImage];
        self.nameLab = [UILabel new];
        self.ageLab = [UILabel new];
        self.courseLab = [UILabel new];
        self.dayLab = [UILabel new];
        self.priceLab = [UILabel new];
        self.waterLab = [UILabel new];
        
        [self.contentView addSubview:self.photoImg];
        [self.contentView addSubview:self.nameLab];
        [self.contentView addSubview:self.ageLab];
        [self.contentView addSubview:self.courseLab];
        [self.contentView addSubview:self.dayLab];
        [self.contentView addSubview:self.priceLab];
        [self.contentView addSubview:self.waterLab];
    }
    return  self;
}

- (void)setName:(NSString *)name age:(NSString *)age course:(NSString *)course day:(NSString *)day price:(NSString *)price water:(NSString *)water array:(NSArray *)arr{
    
    CGRect frame = [self frame];
    self.photoImg.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width * 5/ 9);
    //self.photoImg.contentMode = UIViewContentModeScaleAspectFit;
   
    self.lockImage.image = [UIImage imageNamed:@"pic_lock"];
    self.lockImage.frame = CGRectMake(0, 0,  self.lockImage.image.size.width, self.lockImage.image.size.height);
    
    // 课程名称
    LabelSet(self.nameLab, name, [UIColor blackColor], 13, nameDic, nameSize);
//    self.nameLab.frame = FRAMEMAKE_F(10, CGRectGetMaxY(self.photoImg.frame) + 8, self.frame.size.width/ 2 - 80, nameSize.height);
    self.nameLab.frame = FRAMEMAKE_F(10, CGRectGetMaxY(self.photoImg.frame) + 8, self.frame.size.width/ 2 - 50, nameSize.height);

    // 年龄
    LabelSet(self.ageLab, age, RGBHex(0x8fe69c), 12, ageDic, ageSize);
    self.ageLab.frame = FRAMEMAKE_F(self.frame.size.width/ 2 - ageSize.width, CGRectGetMinY( self.nameLab.frame), ageSize.width, ageSize.height);
    
    // 开课状态
    LabelSet(self.courseLab, course, RGBHex(0x8fe69c), 13, courseDic, courseSize);
    self.courseLab.frame = FRAMEMAKE_F(self.frame.size.width/ 2 + 30, CGRectGetMinY( self.nameLab.frame), courseSize.width, courseSize.height);
    
    // 天数
    NSString *dayStr = [NSString stringWithFormat:@"%@天",day];
    LabelSet(self.dayLab, dayStr, [UIColor blackColor], 13, dayDic, daySize);
    self.dayLab.frame = FRAMEMAKE_F(self.frame.size.width - 10 - daySize.width, CGRectGetMinY( self.nameLab.frame), daySize.width, daySize.height);
    
    // 价格
    LabelSet(self.priceLab, price, RGBHex(0xfe6a76), 12, priceDic, priceSize);
    self.priceLab.frame = FRAMEMAKE_F(self.frame.size.width - priceSize.width - 10, CGRectGetMaxY(self.dayLab.frame) + 10, priceSize.width, priceSize.height);
    
//    // 标签容器 View
//    for (int i = 0; i < arr.count; i++) {
//        UILabel * _tagLabel = [[UILabel alloc]init];
//        _tagLabel.textColor = [UIColor whiteColor];
//        _tagLabel.backgroundColor = RGBHex(0x8fe69c);
//        _tagLabel.font = [UIFont systemFontOfSize:12];
//        _tagLabel.textAlignment = NSTextAlignmentCenter;
//        _tagLabel.text = arr[i];
//        _tagLabel.frame = FRAMEMAKE_F(10 + (8 + 32) * i, CGRectGetMaxY(self.nameLab.frame) + 5, 32, 15);
//        [self addSubview:_tagLabel];
//    }
#pragma mark - 修改 bug-- 重复加载子控件
    // 标签容器 View
    CGFloat tagVWidth = CGRectGetMinX(self.priceLab.frame) - 15;
    self.tagView.frame = CGRectMake(10, CGRectGetMaxY(self.nameLab.frame) + 5, tagVWidth, 15);
    [self.tagView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // 根据 数组数据添加标签 Label
    if (arr.count) {
        
        for (int i = 0; i < arr.count; i++) {
            UILabel *tagLabel = [[UILabel alloc]init];
            tagLabel.backgroundColor = RGBHex(0x8fe69c);
            tagLabel.textAlignment = NSTextAlignmentCenter;
            LabelSet(tagLabel, arr[i], [UIColor whiteColor], 12, tagDic, tagSize)
            CGFloat tagLabW = tagSize.width + 5;
            tagLabel.frame = FRAMEMAKE_F((8 + tagLabW) * i, 0, tagLabW, 15);
            [self.tagView addSubview:tagLabel];
        }
    } else {
        [self.tagView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    
    

    frame.size.height = self.frame.size.width * 5/ 9 + 50;
    self.frame = frame;
}

@end


