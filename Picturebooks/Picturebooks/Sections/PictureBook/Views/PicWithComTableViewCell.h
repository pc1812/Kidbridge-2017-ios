//
//  PicWithComTableViewCell.h
//  PictureBook
//
//  Created by Yasin on 2017/7/17.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PicWithComTableViewCell : UITableViewCell

@property (nonatomic, strong)UILabel *nameLab;
@property (nonatomic, strong)UILabel *detailLab;
@property (nonatomic, strong)UILabel *timeLab;
@property (nonatomic, strong)UILabel *timeLabOne;
@property (nonatomic, strong)UIImageView *photoImg;
@property (nonatomic, strong)UIView *viewOne;
@property (nonatomic, strong)UIButton *playBtn;
@property (nonatomic, strong)UILabel *greeLab;
@property (nonatomic, strong)NSArray *commentArr;

-(void)setName:(NSString *)name detail:(NSString *)detail time:(NSString *)time videoTime:(NSString *)video videoText:(NSString *)text arr:(NSArray *)arr judge:(BOOL) isBool;

@end
