//
//  Segment.h
//  FirstPage
//
//  Created by 尹凯 on 2017/8/14.
//  Copyright © 2017年 尹凯. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Segment : NSObject

@property (nonatomic, assign)NSInteger ID;
@property (nonatomic, copy)NSString *icon;//图片
@property (nonatomic, copy)NSString *text;//正文
@property (nonatomic, copy)NSString *audio;//音频资源


@end
