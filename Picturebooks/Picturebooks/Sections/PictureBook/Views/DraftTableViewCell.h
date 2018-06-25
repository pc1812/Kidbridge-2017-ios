//
//  DraftTableViewCell.h
//  Picturebooks
//
//  Created by 尹凯 on 2017/8/19.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DraftTableViewCellDelegate <NSObject>

- (void)playAudioRequestFrom:(NSUInteger)index;

@end

@interface DraftTableViewCell : UITableViewCell

@property (nonatomic, assign)NSInteger pageNum;
@property (nonatomic, weak)id<DraftTableViewCellDelegate>delegate;
@property (nonatomic, strong)UIImageView *headImageView;
@property (nonatomic, strong)UILabel *timeLabel;
@property (nonatomic, strong)UIButton *playBtn;

@end
