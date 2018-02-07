//
//  FollowCollectionViewCell.h
//  FirstPage
//
//  Created by 尹凯 on 2017/7/14.
//  Copyright © 2017年 尹凯. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Segment.h"

@protocol FollowCollectionViewCellDelegate <NSObject>

//原文播放按钮触发代理方法
- (void)playAudioWithURLString:(NSString *)URLString index:(NSUInteger)index;
//跟读录音按钮触发代理方
- (void)recordStatus:(NSInteger)status;// 0 代表取消录制   1 代表开始录制

@end

@interface FollowCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong)UILabel *pageLabel;
@property (nonatomic, strong)UILabel *content;
@property (nonatomic, strong)UIScrollView *contentScroll;
@property (nonatomic, strong)UIButton *playButton;
@property (nonatomic, strong)UIButton *recordButton;
@property (nonatomic, strong)UIView *line;
@property (nonatomic, strong)UIView *scrollBar;
@property (nonatomic, weak)NSTimer *timerOf60Second;
@property (nonatomic, assign)NSInteger pageNum;
@property (nonatomic, assign)NSInteger totalPage;
@property (nonatomic, strong)Segment *segment;
@property (nonatomic, strong)NSString *soundUrl;
@property (nonatomic, strong)NSString *name;
@property (nonatomic, weak)id<FollowCollectionViewCellDelegate>delegate;

@end
