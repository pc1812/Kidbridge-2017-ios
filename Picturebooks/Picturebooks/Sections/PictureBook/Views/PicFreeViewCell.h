//
//  PicFreeViewCell.h
//  PictureBook
//
//  Created by Yasin on 2017/7/12.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PicFreeViewCell : UITableViewCell

@property(nonatomic, strong)UILabel *nameLab;
@property(nonatomic, strong)UILabel *detailLab;
@property (nonatomic, strong)UILabel *greeLab;

-(void)setName:(NSString *)name detail:(NSString *)detail;

@end
