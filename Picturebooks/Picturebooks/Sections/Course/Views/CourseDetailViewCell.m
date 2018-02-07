//
//  CourseDetailViewCell.m
//  Picturebooks
//
//  Created by Yasin on 2017/7/20.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "CourseDetailViewCell.h"

@implementation CourseDetailViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CellLabelAlloc_K(_nameLab);
        //CellLabelAlloc_K(_detailLab);
        CellLabelAlloc_K(_greeLab);
        //CellImage_K(_photoImg);
        self.webView = [[UIWebView alloc] init];
        [self addSubview:self.webView];
    }
    return self;
}

-(void)setName:(NSString *)name detail:(NSString *)detail{
    CGRect frame = [self frame];
    
    _greeLab.frame = FRAMEMAKE_F(10, 30, 2, 20);
    _greeLab.backgroundColor = RGBHex(0X13D02F);
    
    _nameLab.text = name;
    _nameLab.textColor = [UIColor blackColor];
    _nameLab.font = [UIFont systemFontOfSize:16 weight:2];
    NSDictionary *conDic = StringFont_DicK(_nameLab.font);
    CGSize conSize = [_nameLab.text sizeWithAttributes:conDic];
    _nameLab.frame = FRAMEMAKE_F(CGRectGetMaxX(_greeLab.frame) + 13, CGRectGetMinY(_greeLab.frame), conSize.width, conSize.height);
    
//    _detailLab.text = detail;
//    _detailLab.textColor = [UIColor blackColor];
//    _detailLab.numberOfLines = 0;
//    _detailLab.font = [UIFont systemFontOfSize:14];
//    CGSize receSize = [_detailLab boundingRectWithSize:CGSizeMake(SCREEN_WIDTH- 20, 0)];
//    _detailLab.frame = FRAMEMAKE_F( 10,CGRectGetMaxY(_nameLab.frame) + 18, receSize.width, receSize.height);
//    
//    _photoImg.frame = FRAMEMAKE_F(10, CGRectGetMaxY( _detailLab.frame) + 15, SCREEN_WIDTH - 20, 190);
    
    self.webView.delegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:detail]]];
    self.webView.frame = CGRectMake(10, CGRectGetMaxY(_nameLab.frame) + 15, SCREEN_WIDTH - 20, 300);
    
    frame.size.height =  CGRectGetMaxY(_nameLab.frame) + 20 + CGRectGetHeight(self.webView.frame);
    
    self.frame = frame;
}

@end
