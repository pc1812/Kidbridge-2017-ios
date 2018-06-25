//
//  Global.h
//  newrrjj
//
//  Created by lll on 16/12/2.
//  Copyright © 2016年 lll. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Global : NSObject

//判断字符串是否为空
+(BOOL)isNullOrEmpty:(NSString*)str;

//颜色转换 十六进制转RGB
+ (UIColor *)convertHexToRGB:(NSString *)hexString;
+ (UIColor *)convertHexToRGB:(NSString *)hexString withAlpha:(CGFloat)alpha;

+ (NSString *)timeStamp;

+(NSString *)phoneModel;
+ (NSString *)ConvertStrToTime:(NSNumber *)timeStr;

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
// 获取指定最大宽度、最大高度、字体大小的string的size
+ (CGSize)getSizeOfString:(NSString *)string maxWidth:(float)width maxHeight:(float)height withFontSize:(CGFloat)fontSize;
+ (CGSize)getSizeWithLineSpaceString:(NSString *)string maxWidth:(float)width maxHeight:(float)height withFontSize:(CGFloat)fontSize;

//添加横线
+(void)viewFrame:(CGRect)frame andTableViewCell:(UITableViewCell *)cell;

//返回视图
+(UIView *)leftViewWithImageName:(NSString *)name ;
+ (UIView *)leftViewLabelWithText:(NSString *)text;


//6-20个由字母/数字组成的字符串的正则表达式
+(BOOL)validatePassword:(NSString *)passWord;

//6-20个由字母/数字组成的字符串的正则表达式 区分大小写
+(BOOL)validateBigAndSmallPassword:(NSString *)passWord;

//设置UIAlertController字体显示
+(void)setUIAlertControllerMessageAligement:(UIAlertController *)alertController;

 //字符串只包含数字和.
+(BOOL)contailNumberAndChar:(NSString *)charNumber;

//时间转换成时间戳
+ (NSString *)convertDateToNsstring:(NSString *)dateStr;

/**
 * 判断手机号是否有效
 */
+ (BOOL)isValidatePhone:(NSString *)mobileString;

+(BOOL)toLower:(NSString *)str;

+(BOOL)toUpper:(NSString *)str;

/**
 * 身份证号
 */
+(BOOL)validateIdentityCard: (NSString *)identityCard;

/**
 * 判断银行卡是否有效
 */
+ (BOOL)validateBankCardNumber:(NSString *)bankCardNumber;

/**
 * 是否包含关键字
 */
+(BOOL)containSepicKey:(NSString *)text;

/**
 * 是否包含关键字
 */
+(BOOL)containSecondSepicKey:(NSString *)text;

//返回总数
+(NSInteger )linkNumber:(NSString *)textViewStr;

+(NSString *)textWithMoney:(CGFloat)money andType:(NSInteger)type;

+(void)viewFrame:(CGRect)frame andBackView:(UIView *)backView;

+ (void)showWithView:(UIView *)showView withText:(NSString *)text;//显示字

+ (NSString*)weekdayStringFromDate:(NSDate*)inputDate ;

+(NSString *)equityConversion:(NSString *)conversion andIsBuyOrSail:(BOOL)stock;

//转换成  千  万
+(NSString *)Transformation:(NSString *)character andType:(NSString *)type;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

+(void)groupAnimation:(UIBezierPath *)path andLayer:(CALayer *)dotLayer;

//对图片尺寸进行压缩
+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize;


@end
