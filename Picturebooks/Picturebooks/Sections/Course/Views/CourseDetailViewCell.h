//
//  CourseDetailViewCell.h
//  Picturebooks
//
//  Created by Yasin on 2017/7/20.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourseDetailViewCell : UITableViewCell<UIWebViewDelegate>

@property(nonatomic,strong)UILabel *nameLab;
@property(nonatomic,strong)UILabel *detailLab;
@property(nonatomic,strong)UIImageView *photoImg;
@property (nonatomic, strong)UILabel *greeLab;
@property (nonatomic, strong)UIWebView *webView;
-(void)setName:(NSString *)name detail:(NSString *)detail;

@end
