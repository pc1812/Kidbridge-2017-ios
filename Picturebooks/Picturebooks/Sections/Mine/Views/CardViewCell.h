//
//  CardViewCell.h
//  Picturebooks
//
//  Created by Yasin on 2017/7/21.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LGVoicePlayState) {
    LGVoicePlayStateNormal,/**< 未播放状态 */
    LGVoicePlayStateDownloading,/**< 正在下载中 */
    LGVoicePlayStatePlaying,/**< 正在播放 */
    LGVoicePlayStateCancel,/**< 播放被取消 */
};

@class CardViewCell;

@protocol CardViewCellDelagate <NSObject>

- (void)voiceMessageTaped:(CardViewCell *)cell;

@end

@interface CardViewCell : UITableViewCell

@property(nonatomic,strong)UIImageView *photoImg;
@property(nonatomic,strong)UILabel *nameLab;
@property(nonatomic,strong)UIView *viewOne;
@property(nonatomic,strong)UILabel *videoLab;

@property(nonatomic,strong)UIButton *playBtn;
@property(nonatomic,strong)UIButton *infoBtn;
@property(nonatomic,strong)UILabel *timeLab;
@property (nonatomic, assign) LGVoicePlayState voicePlayState;
@property (nonatomic, assign) id<CardViewCellDelagate>delegate;

-(void)setName:(NSString *)name time:(NSString *)time;

@end
