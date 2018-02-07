//
//  Global.m
//  newrrjj
//
//  Created by lll on 16/12/2.
//  Copyright © 2016年 lll. All rights reserved.
//

#import "Global.h"

@implementation Global

//判断字符串是否为空
+(BOOL)isNullOrEmpty:(NSString*)str
{
    if (str == nil || str == NULL) {
        return YES;
    }
    if ([str isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        return YES;
    }
    return NO;
}

/**
 *十六进制转RGB
 */
+ (UIColor *)convertHexToRGB:(NSString *)hexString{
    NSString *str;
    if ([hexString hasPrefix:@"0x"] || [hexString hasPrefix:@"0X"]) {
        str=[[NSString alloc] initWithFormat:@"%@",hexString];
    }else {
        str=[[NSString alloc] initWithFormat:@"0x%@",hexString];
    }
    int rgb;
    sscanf([str cStringUsingEncoding:NSUTF8StringEncoding], "%i", &rgb);
    int red=rgb/(256*256)%256;
    int green=rgb/256%256;
    int blue=rgb%256;
    UIColor *color=[UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
    return color;
}

/**
 *十六进制转RGB
 */
+ (UIColor *)convertHexToRGB:(NSString *)hexString withAlpha:(CGFloat)alpha{
    NSString *str;
    if ([hexString hasPrefix:@"0x"] || [hexString hasPrefix:@"0X"]) {
        str=[[NSString alloc] initWithFormat:@"%@",hexString];
    }else {
        str=[[NSString alloc] initWithFormat:@"0x%@",hexString];
    }
    
    int rgb;
    sscanf([str cStringUsingEncoding:NSUTF8StringEncoding], "%i", &rgb);
    int red=rgb/(256*256)%256;
    int green=rgb/256%256;
    int blue=rgb%256;
    UIColor *color=[UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
    return color;
}

// 获取指定最大宽度",@"最大高度",@"字体大小的string的size
+ (CGSize)getSizeOfString:(NSString *)string maxWidth:(float)width maxHeight:(float)height withFontSize:(CGFloat)fontSize
{
    if (IOS7)
    {
        CGSize size =  [string boundingRectWithSize:CGSizeMake(width, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]} context:nil].size;
        return size;
    }
    else
    {
        CGSize size = [string sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(width,height) lineBreakMode:NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail];
        
        return size;
    }
}

+ (CGSize)getSizeWithLineSpaceString:(NSString *)string maxWidth:(float)width maxHeight:(float)height withFontSize:(CGFloat)fontSize
{
    if (IOS7)
    {
        //设置默认行距
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        
        CGSize size =  [string boundingRectWithSize:CGSizeMake(width, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize],NSParagraphStyleAttributeName:paragraphStyle} context:nil].size;
        
        return size;
    }
    else
    {
        CGSize size = [string sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(width,height) lineBreakMode:NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail];
        return size;
    }
}

#pragma mark ------- 横线
+(void)viewFrame:(CGRect)frame andTableViewCell:(UITableViewCell *)cell
{
    UIView *view=[[UIView alloc]initWithFrame:frame];
    view.backgroundColor=[Global convertHexToRGB:@"eeeeee"];
    [cell addSubview:view];
}

#pragma mark ------- 横线
+(void)viewFrame:(CGRect)frame andBackView:(UIView *)backView
{
    UIView *view=[[UIView alloc]initWithFrame:frame];
    view.backgroundColor=[Global convertHexToRGB:@"eeeeee"];
    [backView addSubview:view];
}

+(NSString *)equityConversion:(NSString *)conversion andIsBuyOrSail:(BOOL)stock{

    if (stock) {
        if (IS_IPHONE5()) {
            if ([conversion integerValue]/100000000>1) {
                return [NSString stringWithFormat:@"%.2f亿",[conversion floatValue]/100000000];
            }
            return [NSString stringWithFormat:@"%.0f万",[conversion floatValue]/10000];
        }
    }
    if ([conversion integerValue]/100000000>1) {
        return [NSString stringWithFormat:@"%.2f亿",[conversion floatValue]/100000000];
    }
    return [NSString stringWithFormat:@"%.2f万",[conversion floatValue]/10000];
}

#pragma mark--输入框左边的视图
+(UIView *)leftViewWithImageName:(NSString *)name {
    
    CGSize imageSize = [UIImage imageNamed:name].size;
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, (imageSize.width*20)/imageSize.height+15, 50.0f)];
    UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 15.0f,(imageSize.width*20)/imageSize.height, 20.0f)];
    leftImageView.image = [UIImage imageNamed:name];
    [leftView addSubview:leftImageView];
    return leftView;
}

#pragma mark--输入框左边的视图
+ (UIView *)leftViewLabelWithText:(NSString *)text {
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 80.0f, 50.0f)];
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 5.0f, 65.0f, 40.0f)];
    leftLabel.font = [UIFont systemFontOfSize:14];
    leftLabel.textColor = [Global convertHexToRGB:@"505050"];
    leftLabel.text = text;
    [leftView addSubview:leftLabel];
    return leftView;
}

//字符串中包含大写字母
+(BOOL)toLower:(NSString *)str{
    for (NSInteger i=0; i<str.length; i++) {
        if ([str characterAtIndex:i]>='A'&[str characterAtIndex:i]<='Z') {
            return YES;
        }
    }
    return NO;
}

//字符串中包含小写字母
+(BOOL)toUpper:(NSString *)str{
    for (NSInteger i=0; i<str.length; i++) {
        if ([str characterAtIndex:i]>='a'&[str characterAtIndex:i]<='z') {
            return YES;
        }
    }
    return NO;
}

//6-20个  由字母/数字组成的字符串   区分大小写
+(BOOL)validateBigAndSmallPassword:(NSString *)passWord {

    if ([Global toLower:passWord]&&[Global toUpper:passWord]&&(passWord.length>5||passWord.length<21)) {
        return YES;
    }
    return NO;
}

//6-20个由字母/数字组成的字符串的正则表达式
+(BOOL)validatePassword:(NSString *)passWord {
    NSString *passWordRegex = @"(?=.*[A-Za-z])(?=.*[0-9])[a-zA-Z0-9]{6,20}";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:passWord];
}

/**
 * 判断手机号是否有效
 */
+(BOOL)isValidatePhone:(NSString *)mobileString {
    if ([self isNullOrEmpty:mobileString]) {
        return NO;
    }
    NSMutableString *testString=[NSMutableString stringWithString:mobileString];
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc]
                                              initWithPattern:@"^((13[0-9])|(14[5,7])|(15[^4,\\D])|(17[0-9])|(18[0-9]))\\d{8}$"
                                              options:NSRegularExpressionCaseInsensitive
                                              error:nil];
    NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:testString
                                                                  options:NSMatchingReportProgress
                                                                    range:NSMakeRange(0, testString.length)];
    
    if(numberofMatch > 0)
    {
        return YES;
    } else {
        return NO;
    }
}

+(void)setUIAlertControllerMessageAligement:(UIAlertController *)alertController{
    UIView *subView1 = alertController.view.subviews[0];
    UIView *subView2 = subView1.subviews[0];
    UIView *subView3 = subView2.subviews[0];
    UIView *subView4 = subView3.subviews[0];
    UIView *subView5 = subView4.subviews[0];
    UILabel *title = subView5.subviews[0];
    UILabel *message = subView5.subviews[1];
    message.textAlignment = NSTextAlignmentLeft;
    title.textAlignment = NSTextAlignmentCenter;
}

/**
 * 身份证号
 */
+(BOOL)validateIdentityCard: (NSString *)identityCard {
    BOOL flag;
    if (identityCard.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:identityCard];
}

/**
 * 判断银行卡是否有效
 */
+ (BOOL)validateBankCardNumber:(NSString *)bankCardNumber {
    BOOL flag;
    if (bankCardNumber.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{15,30})";
    NSPredicate *bankCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [bankCardPredicate evaluateWithObject:bankCardNumber];
}

+(BOOL)contailNumberAndChar:(NSString *)charNumber{
    
    BOOL charStr = YES;
    
    for (NSInteger i=0; i<charNumber.length; i++) {
        NSString *numberStr = [charNumber substringWithRange:NSMakeRange(i, 1)];
        if ([numberStr isEqualToString:@"0"]||[numberStr isEqualToString:@"1"]||[numberStr isEqualToString:@"2"]||[numberStr isEqualToString:@"3"]||[numberStr isEqualToString:@"4"]||[numberStr isEqualToString:@"5"]||[numberStr isEqualToString:@"6"]||[numberStr isEqualToString:@"7"]||[numberStr isEqualToString:@"8"]||[numberStr isEqualToString:@"9"]||[numberStr isEqualToString:@"."]) {

        }else{
            return !charStr;
        }
    }
    return charStr;
}

+ (NSString*)weekdayStringFromDate:(NSDate*)inputDate {
    
//    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", nil];
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"SUN", @"MON", @"THE", @"WED", @"THU", @"FRI", @"SAT", nil];
//    NSGregorianCalendar
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    
    [calendar setTimeZone: timeZone];
//    NSWeekdayCalendarUnit
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:inputDate];
    
    return [weekdays objectAtIndex:theComponents.weekday];
}

//   2代表存  1代表取
+(NSString *)Transformation:(NSString *)character andType:(NSString *)type
{
    if ([character floatValue]<0) {
        return @"无限额";
    }

    if ([character integerValue]>=10000) {
        NSString *charStr = [NSString stringWithFormat:@"%.0f万",[character floatValue]/10000];
        if ([charStr isEqualToString:@"5万"]) {
            if ([type isEqualToString:@"2"]) {//取
                if (IS_IPHONE5()) {
                    return @"4.99万" ;
                }
                return @"49990元";
            }
           return @"5万";//存
        }
        return  charStr;
    }
    return [NSString stringWithFormat:@"%.0f元",[character floatValue]];
}

+(BOOL)containSepicKey:(NSString *)text{
    NSArray *limitArray=@[@"淘股神",@"淘股吧",@"摩尔",@"合作",@"雪球",@"牛仔网",@"投资脉搏",@"中金在线",@"QQ",@"qq",@"Qq",@"qQ",@"操盘侠",@"微信微博",@"联系",@"加群",@"进群",@"扣扣",@"加扣",@"扣扣群",@"联系电话",@"联系qq",@"公众号",@"群号",@"QQ群",@"Q群",@"残废人",@"独眼龙",@"瞎子",@"聋子",@"傻子",@"呆子",@"弱智",@"SB",@"TMD",@"鸡巴",@"我日",@"干你",@"我操",@"操你",@"操你妈",@"干你妈",@"傻逼",@"鸡巴",@"贱人",@"贱逼",@"骚逼",@"妈的",@"他妈的",@"中共",@"民主",@"共产党",@"民权",@"中国共产党",@"共党",@"反共",@"反党",@"反国家",@"反社会",@"反人类",@"烂公司",@"破平台",@"骗子",@"游行",@"集会",@"强奸",@"走私",@"强暴",@"轮奸",@"奸杀",@"杀死",@"摇头丸",@"白粉",@"冰毒",@"海洛因"];
    for (NSString *limit in limitArray) {
        if ([text containsString:limit ]) {
            return YES;
        }
    }
    return NO;
}

+(BOOL)containSecondSepicKey:(NSString *)text{
    NSArray *limitArray=@[@"淘股神",@"淘股吧",@"摩尔",@"合作",@"雪球",@"牛仔网",@"投资脉搏",@"中金在线",@"QQ",@"qq",@"Qq",@"qQ",@"操盘侠",@"微信",@"联系",@"微博",@"加群",@"进群",@"扣扣群",@"联系电话",@"联系qq",@"群号",@"公众号",@"毛泽东",@"刘少奇",@"胡锦涛",@"江泽民",@"杨尚昆",@"李先念",@"习近平",@"温家宝",@"周恩来",@"李克强",@"国务院",@"中纪委",@"共产主义",@"文化大革命",@"习大大",@"残废人",@"独眼龙",@"瞎子",@"聋子",@"傻子",@"呆子",@"弱智",@"SB",@"TMD",@"鸡巴",@"我日",@"打飞机",@"干你",@"我操",@"操你",@"操你妈",@"干你妈",@"傻逼",@"鸡巴",@"贱人",@"贱逼",@"骚逼",@"妈的",@"他妈的",@"绿茶婊",@"权势狗",@"中共",@"民主",@"共产党",@"民权",@"中国共产党",@"共党",@"反共",@"反党",@"反国家",@"反社会",@"反人类",@"烂公司",@"破平台",@"骗子",@"游行",@"集会",@"强奸",@"走私",@"强暴",@"轮奸",@"奸杀",@"杀死",@"摇头丸",@"白粉",@"冰毒",@"海洛因"];
    for (NSString *limit in limitArray) {
        if ([text containsString:limit ]) {
            return YES;
        }
    }
    return NO;
}

//返回总数
+(NSInteger )linkNumber:(NSString *)textViewStr {
    
    NSMutableArray *mumberArray=[NSMutableArray array];
    unichar c;
    NSInteger k=0;
    for (int i=0; i<textViewStr.length; i++) {
        c=[textViewStr characterAtIndex:i];
        if (isdigit(c)) {
            k++;
            if (k>=7) {
                [mumberArray addObject:[NSString stringWithFormat:@"%ld",(long)k]];
            }
        }else
            k=0;
    }
    return mumberArray.count;
}

+ (BOOL)isPureNumandCharacters:(NSString *)string
{
    BOOL flag;
    if (string.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d){0-9}$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:string];
}

+(NSString *)textWithMoney:(CGFloat)money andType:(NSInteger)type{
    
    NSString *moneyStr=[NSString stringWithFormat:@"%.2f",money];

    if ([moneyStr integerValue]>=10000) {
        CGFloat total = money / 10000;
        if (type==1) {
            if (IS_IPHONE5()) {
                return  [NSString stringWithFormat:@"%.0f万", total];
            }
        }
        return  [NSString stringWithFormat:@"%.2f万", total];
    } else {
        if (type==1) {
            if (IS_IPHONE5()) {
                return  [NSString stringWithFormat:@"%.0f", money];
            }
        }
        return [NSString stringWithFormat:@"%.2f", money];
    }
}

+ (void)showWithView:(UIView *)showView withText:(NSString *)text//显示字
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    MBProgressHUD *progressHUD = [[MBProgressHUD alloc] initWithView:window];
    [window addSubview:progressHUD];
    progressHUD.removeFromSuperViewOnHide = YES;
    progressHUD.mode = MBProgressHUDModeText;
    progressHUD.labelText = text;
    progressHUD.labelFont = [UIFont systemFontOfSize:13];
    progressHUD.backgroundColor = [UIColor clearColor];
    [progressHUD show:YES];
    [progressHUD hide:YES afterDelay:1.0];
}

+ (NSString *)timeStamp
{
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter stringFromDate:datenow];
    NSString *timeSp = [NSString stringWithFormat:@"%.0f", (double)[datenow timeIntervalSince1970]*1000];
    
    return timeSp;
}

+(NSString *)phoneModel{
    //手机系统版本
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    // 当前应用软件版本  比如：1.0.1
    NSString *appCurVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *osVerStr = [NSString stringWithFormat:@"%@_%@",phoneVersion,appCurVersion];
    return osVerStr;
}

//时间戳  转换成时间
+ (NSString *)ConvertStrToTime:(NSNumber *)timeStr{
    NSTimeInterval time=[timeStr doubleValue];
    NSDate *createDate=[NSDate dateWithTimeIntervalSince1970:time/1000];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString*timeString=[formatter stringFromDate:createDate];

    return timeString;
}

//时间转换成时间戳
+ (NSString *)convertDateToNsstring:(NSString *)dateStr{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* date = [formatter dateFromString:[NSString stringWithFormat:@"%@",dateStr]];
    NSString *timeSp = [NSString stringWithFormat:@"%.0f", (double)[date timeIntervalSince1970]];

    return timeSp;
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

//取消searchbar背景色
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark --组合动画
+(void)groupAnimation:(UIBezierPath *)path andLayer:(CALayer *)dotLayer {

    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = path.CGPath;
    animation.rotationMode = kCAAnimationRotateAuto;
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"alpha"];
    alphaAnimation.duration = 0.5f;
    alphaAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    alphaAnimation.toValue = [NSNumber numberWithFloat:0.1];
    alphaAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CAAnimationGroup *groups = [CAAnimationGroup animation];
    groups.animations = @[animation,alphaAnimation];
    groups.duration = 0.8f;
    groups.removedOnCompletion = NO;
    groups.fillMode = kCAFillModeForwards;
    [groups setValue:@"groupsAnimation" forKey:@"animationName"];
    [dotLayer addAnimation:groups forKey:nil];
 
}

+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
