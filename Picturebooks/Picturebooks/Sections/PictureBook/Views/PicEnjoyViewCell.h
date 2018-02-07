//
//  PicEnjoyViewCell.h
//  PictureBook
//
//  Created by Yasin on 2017/7/13.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PicEnjoyViewCell : UITableViewCell<UIWebViewDelegate>

@property(nonatomic,strong)UILabel *nameLab;
@property(nonatomic,strong)UILabel *detailLab;
@property(nonatomic,strong)UIImageView *photoImg;
@property (nonatomic, strong)UILabel *greeLab;
@property (nonatomic, strong)UIWebView *webView;
-(void)setName:(NSString *)name detail:(NSString *)detail;

@end
