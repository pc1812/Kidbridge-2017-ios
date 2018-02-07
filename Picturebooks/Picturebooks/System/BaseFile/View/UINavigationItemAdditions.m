//
//  UINavigationItemAdditions.m
//  iTravel
//
//  Created by lll on 13-6-8.
//  Copyright (c) 2013年 lll. All rights reserved.
//

#import "UINavigationItemAdditions.h"

@implementation UINavigationItem (Navigation)

+ (UILabel *)titleViewForTitle:(NSString *)title{
    UILabel *titleView = [[UILabel alloc] init];
    titleView.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.textColor = [UIColor whiteColor];
    titleView.text = [NSString stringWithFormat:@"%@",title];
    [titleView sizeToFit];
    return titleView;
}

@end
