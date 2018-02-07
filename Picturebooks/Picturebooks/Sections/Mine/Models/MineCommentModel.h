//
//  MineCommentModel.h
//  Picturebooks
//
//  Created by Yasin on 2017/8/19.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "YKBaseModel.h"
#import "MineUserModel.h"
#import "MineContentModel.h"
#import "MineReplyModel.h"

@interface MineCommentModel : YKBaseModel

@property (nonatomic, assign)NSInteger commentId;
@property (nonatomic, assign)NSInteger repaeatId;
@property (nonatomic, strong)NSString *time;
@property (nonatomic, strong)NSMutableArray *replyArr;//回复数据
@property (nonatomic, strong)MineContentModel *contentModel;
@property (nonatomic, strong)MineUserModel *userModel;
@property (nonatomic, strong)MineReplyModel *replyModel;

@end
