//
//  EdgeLabel.m
//  Picturebooks
//
//  Created by 吉晓东 on 2018/3/17.
//  Copyright © 2018年 ZhiyuanNetwork. All rights reserved.
//

#import "EdgeLabel.h"

@implementation EdgeLabel

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _contentInset = contentInset;
    NSString *tempString = self.text;
    self.text = @"";
    self.text = tempString;
}
-(void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.contentInset)];
}

@end
