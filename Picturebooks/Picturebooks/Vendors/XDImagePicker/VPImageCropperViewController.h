//
//  VPImageCropperViewController.h
//  VPolor
//
//  Created by jixiaodong on 17/12/20.
//  Copyright © 2017年 zhiyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^submitBlock)(UIViewController *viewController , UIImage *image);
typedef void(^cancelBlock)(UIViewController *viewController);

@interface VPImageCropperViewController : UIViewController
@property (nonatomic, copy) submitBlock submitblock;
@property (nonatomic, copy) cancelBlock cancelblock;
@property (nonatomic, assign) CGRect cropFrame;

- (id)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio;

@end































