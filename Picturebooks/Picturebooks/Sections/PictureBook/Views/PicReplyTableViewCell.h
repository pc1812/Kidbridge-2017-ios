//
//  PicReplyTableViewCell.h
//  PictureBook
//
//  Created by Yasin on 2017/7/17.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PicReplyTableViewCell : UITableViewCell

@property (nonatomic, strong)UILabel *nameLab;
@property (nonatomic, strong)UILabel *detailLab;
@property (nonatomic, strong)UILabel *timeLabOne;
@property (nonatomic, strong)UIView *viewOne;
@property (nonatomic, strong)UIButton *playBtn;
@property (nonatomic, assign)CGFloat height;

-(void)setName:(NSString *)name detail:(NSString *)detail videoTime:(NSString *)video videoText:(NSString *)videoText  judge:(NSInteger) index;

@end
