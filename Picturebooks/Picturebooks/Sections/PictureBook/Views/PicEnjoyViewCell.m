//
//  PicEnjoyViewCell.m
//  PictureBook
//
//  Created by Yasin on 2017/7/13.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "PicEnjoyViewCell.h"

@implementation PicEnjoyViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        CellLabelAlloc_K(_nameLab);
//        //CellLabelAlloc_K(_detailLab);
//        CellLabelAlloc_K(_greeLab);
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
//    _detailLab.frame = FRAMEMAKE_F( 10,CGRectGetMaxY(_nameLab.frame) + 15, receSize.width, receSize.height);
//    _photoImg.frame = FRAMEMAKE_F(10, CGRectGetMaxY(_detailLab.frame) + 15, SCREEN_WIDTH - 20, 270);
    
   //CGFloat height = [AppTools heightForContent:detail fontoOfText:12 spacingOfLabel:1];
    self.webView.delegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:detail]]];
    self.webView.frame = CGRectMake(10, 5, SCREEN_WIDTH - 20, SCREEN_HEIGHT * 2/3);
//    UIScrollView *tempView = (UIScrollView *)[self.webView.subviews objectAtIndex:0];
//    
//    tempView.scrollEnabled = NO;
    frame.size.height =  CGRectGetHeight(self.webView.frame) + 5;
    self.frame = frame;
  
}



- (void)webViewDidFinishLoad:(UIWebView *)webView{
  
//    CGFloat height = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
//    NSLog(@"-------webview%f", height);
//    CGRect frame = self.webView.frame;
//    frame.size.height = 300;
//    self.webView.frame = frame;
    
   // CGFloat height = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
    
    
   
  
    
    
   
}


@end
