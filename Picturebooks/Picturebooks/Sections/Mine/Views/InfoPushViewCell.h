//
//  InfoPushViewCell.h
//  PictureBook
//
//  Created by Yasin on 2017/7/15.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoPushViewCell : UITableViewCell

@property(nonatomic,strong)UILabel *detailLab;
@property(nonatomic,strong)UIImageView *photoImg;

-(void)setDetail:(NSString *)detail;

@end
