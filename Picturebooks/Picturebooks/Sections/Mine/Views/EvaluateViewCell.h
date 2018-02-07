//
//  EvaluateViewCell.h
//  Picturebooks
//
//  Created by Yasin on 2017/7/21.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EvaluateViewCell;

@protocol EvaluateViewCellDelagate <NSObject>

- (void)cellClick:(int)row;

@end

@interface EvaluateViewCell : UITableViewCell

@property(nonatomic,strong)UIImageView *photoImg;
@property(nonatomic,strong)UILabel *nameLab;
@property(nonatomic,strong)UIView *viewOne;
@property(nonatomic,strong)UILabel *videoLab;
@property (nonatomic,strong)UIButton *playBtn;
@property (nonatomic,strong)UILabel *timeLab;
@property (nonatomic, strong) NSArray *commentArr;
@property (nonatomic, assign) id<EvaluateViewCellDelagate>delegate;

-(void)setName:(NSString *)name time:(NSString *)time arr:(NSArray *)arr;

@end
