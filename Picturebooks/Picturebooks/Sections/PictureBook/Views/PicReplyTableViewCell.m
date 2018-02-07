//
//  PicReplyTableViewCell.m
//  PictureBook
//
//  Created by Yasin on 2017/7/17.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "PicReplyTableViewCell.h"


@implementation PicReplyTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CellLabelAlloc_K(_detailLab);
        CellLabelAlloc_K(_nameLab);
        
        self.viewOne = [UIView new];
        [self.contentView addSubview:self.viewOne];
        
        self.playBtn = [UIButton new];
        [self.viewOne addSubview:self.playBtn];
        self.timeLabOne = [UILabel new];
        [self.viewOne addSubview:self.timeLabOne];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


/** 封装一个文本详情,根据文本自动计算高度 */
- (void)setUpDetailLab:(NSString *)detail andName:(NSString *)name judge:(NSInteger) index
{
    _detailLab.textColor = RGBHex(0x999999);
    NSString *str = [NSString stringWithFormat:@"%@:%@",
                     name, detail];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
    if (index != -1) {
        [text addAttribute:NSForegroundColorAttributeName
                     value:[UIColor redColor]
                     range:NSMakeRange(0, name.length + 1)];
    } else {
        
        [text addAttribute:NSForegroundColorAttributeName
                     value:[Global convertHexToRGB:@"14d02f"]
                     range:NSMakeRange(0, name.length + 1)];
    }
    
    _detailLab.attributedText = text;
    _detailLab.numberOfLines = 0;
    _detailLab.font = [UIFont systemFontOfSize:12];
    CGSize receSize = [_detailLab boundingRectWithSize:CGSizeMake(SCREEN_WIDTH- 77, MAXFLOAT)];
    _detailLab.frame = FRAMEMAKE_F( 0, 0,receSize.width, receSize.height);
}


-(void)setName:(NSString *)name detail:(NSString *)detail videoTime:(NSString *)video videoText:(NSString *)videoText judge:(NSInteger) index{
    
     CGRect frame = [self frame];
    
    if ([Global isNullOrEmpty:videoText]) {
        
        // Jxd-start----------------------------
#pragma mark - Jxd-修改:对文本评价详情进行封装(根据文本动态计算高度)
        [self setUpDetailLab:detail andName:name judge:index];
        // 没有语音评价, Frame 设为CGRectZero
        self.viewOne.frame = CGRectZero;
        // Jxd-end-------------------------------
        
        
    } else if ([Global isNullOrEmpty:detail]) {
        
        LabelSet(_nameLab, name, [Global convertHexToRGB:@"14d02f"], 12, nameDic, nameSize);
        _nameLab.frame = FRAMEMAKE_F(0, 0, nameSize.width, nameSize.height);
        
        self.viewOne.frame = FRAMEMAKE_F(CGRectGetMaxX(_nameLab.frame) + 12, 0, 90, 30);
        self.viewOne.layer.cornerRadius = 10;
        self.viewOne.clipsToBounds = YES;
        self.viewOne.backgroundColor = [Global convertHexToRGB:@"14d02f"];
        
        UIImage *image = [UIImage imageNamed:@"c_pause"];
        
        //self.playBtn.frame = CGRectMake(10, (CGRectGetHeight( self.viewOne.frame) - image.size.width) / 2 , image.size.width  + 10, image.size.height);
        
         self.playBtn.frame = CGRectMake(0, 0 , 40 , 30);
        [self.playBtn setImage:image forState:UIControlStateNormal];
        [self.playBtn setImage:[UIImage imageNamed:@"c_play"] forState:UIControlStateSelected];
        
        self.playBtn.userInteractionEnabled = YES;
        LabelSet(self.timeLabOne, video, [UIColor whiteColor], 12, timeDics, timeSizes);
        self.timeLabOne.frame = FRAMEMAKE_F(90 - timeSizes.width - 10, (CGRectGetHeight(self.viewOne.frame) - timeSizes.height) / 2, timeSizes.width, timeSizes.height);
        
        // Jxd-start-----------------------------
#pragma mark - Jxd-添加:没有文本语音,Frame 设为CGRectZero
        self.detailLab.frame = CGRectZero;
        // Jxd-end-----------------------------
       
    }else{
        
        // Jxd-start----------------------------
#pragma mark - Jxd-修改:对文本评价详情进行封装(根据文本动态计算高度)
        [self setUpDetailLab:detail andName:name judge:index];
        // Jxd-end----------------------------
        
        self.viewOne.frame = FRAMEMAKE_F(40, CGRectGetMaxY(_detailLab.frame) + 5 , 90, 30);
        self.viewOne.layer.cornerRadius = 10;
        self.viewOne.clipsToBounds = YES;
        self.viewOne.backgroundColor = [Global convertHexToRGB:@"14d02f"];
        
        UIImage *image = [UIImage imageNamed:@"c_pause"];
        
        //self.playBtn.frame = CGRectMake(10, (CGRectGetHeight( self.viewOne.frame) - image.size.width) / 2 , image.size.width + 10 , image.size.height);
        
        self.playBtn.frame = CGRectMake(0, 0 , 40 , 30);

        [self.playBtn setImage:image forState:UIControlStateNormal];
        [self.playBtn setImage:[UIImage imageNamed:@"c_play"] forState:UIControlStateSelected];
        
        self.playBtn.userInteractionEnabled = YES;
        LabelSet(self.timeLabOne, video, [UIColor whiteColor], 12, timeDics, timeSizes);
        self.timeLabOne.frame = FRAMEMAKE_F(90 - timeSizes.width - 10, (CGRectGetHeight(self.viewOne.frame) - timeSizes.height) / 2, timeSizes.width, timeSizes.height);
        

    }
    if ([Global isNullOrEmpty:videoText]) {
        frame.size.height =  CGRectGetHeight(_detailLab.frame) + 8;
        
    }else if([Global isNullOrEmpty:detail]){
         frame.size.height =  30 + 8;
        
    }else{
          frame.size.height = 30 + CGRectGetHeight(_detailLab.frame) + 8;
    }
    
    self.frame = frame;
    
}

@end
