//
//  PreviewViewController.h
//  Picturebooks
//
//  Created by 尹凯 on 2017/8/18.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreviewViewController : UIViewController

@property (nonatomic, strong)NSMutableArray *imageArray;
@property (nonatomic, strong)NSMutableArray *messageArray;
@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSString *token;//绘本跟读token
@property (nonatomic, assign)NSInteger type;


/** 计时器 */
//@property (nonatomic,weak)  NSTimer *currentTimer;

@end
