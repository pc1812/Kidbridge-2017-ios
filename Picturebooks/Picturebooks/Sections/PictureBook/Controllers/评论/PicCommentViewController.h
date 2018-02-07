//
//  PicCommentViewController.h
//  PictureBook
//
//  Created by Yasin on 2017/7/14.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "PBBaseViewController.h"

typedef NS_ENUM(NSUInteger, PicCommentType){
    PicCommentAppreciation = 0,/**< 绘本赏析评论 */
    PicCommentRepeat = 1,/**< 绘本跟读评论 */
    CoCommentAppreciation = 2,/**< 课程跟读评论 */
    MineCoCommentAppreciation = 3,/**< 我的课程跟读评论 */
};

@interface PicCommentViewController : PBBaseViewController

@property (nonatomic, assign)PicCommentType picCommentType;
@property (nonatomic, assign)NSInteger readID;
@property (nonatomic, assign)NSInteger quote;

@end
