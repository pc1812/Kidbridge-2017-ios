//
//  GCPlaceholderTextView.m
//  GCLibrary
//
//  Created by Guillaume Campagna on 10-11-16.
//  Copyright 2010 LittleKiwi. All rights reserved.
//

#import "GCPlaceholderTextView.h"

@interface GCPlaceholderTextView () 

@property (nonatomic, copy) UIColor* realTextColor;
@property (nonatomic, readonly) NSString* realText;

- (void) beginEditing:(NSNotification*) notification;
- (void) endEditing:(NSNotification*) notification;

@end

@implementation GCPlaceholderTextView
@synthesize realTextColor;
@synthesize placeholder;

#pragma mark -
#pragma mark Initialisation

- (id) initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginEditing:) name:UITextViewTextDidBeginEditingNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endEditing:) name:UITextViewTextDidEndEditingNotification object:self];
    
    self.realTextColor = [UIColor blackColor];
}

#pragma mark -
#pragma mark Setter/Getters

- (void) setPlaceholder:(NSString *)aPlaceholder
{
    if ([self.realText isEqualToString:placeholder])
    {
        self.text = aPlaceholder;
    }
    
    //[placeholder release];
    placeholder = aPlaceholder;
    
    [self endEditing:nil];
}

- (NSString *) text
{
    NSString* text = [super text];
    if ([text isEqualToString:self.placeholder]) return @"";
    return text;
}

- (void) setText:(NSString *)text
{
    if ([text isEqualToString:@""] || text == nil)
    {
        super.text = self.placeholder;
    }
    else
    {
        super.text = text;
    }
    
    if ([text isEqualToString:self.placeholder])
    {
        self.textColor = [UIColor lightGrayColor];
    }
    else
    {
        self.textColor = self.realTextColor;
    }
}

- (NSString *) realText
{
    return [super text];
}

- (void) beginEditing:(NSNotification*) notification
{
    if ([self.realText isEqualToString:self.placeholder])
    {
        super.text = nil;
        self.textColor = self.realTextColor;
    }
}

- (void) endEditing:(NSNotification*) notification
{
    if ([self.realText isEqualToString:@""] || self.realText == nil)
    {
        super.text = self.placeholder;
        self.textColor = [UIColor lightGrayColor];
    }
}


- (void) setTextColor:(UIColor *)textColor
{
    if ([self.realText isEqualToString:self.placeholder])
    {
        if ([textColor isEqual:[UIColor lightGrayColor]]) [super setTextColor:textColor];
        else self.realTextColor = textColor;
    }
    else
    {
        self.realTextColor = textColor;
        [super setTextColor:textColor];
    }
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
    //[realTextColor release];
    //[placeholder release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[super dealloc];
}

+(GCPlaceholderTextView *)initWithFrame:(CGRect )frame andText:(NSString *)text
{
    GCPlaceholderTextView *placeTextView = [[GCPlaceholderTextView alloc]initWithFrame:frame];
    placeTextView.placeholder = text;
    
//    placeTextView.layer.borderColor =[UIColor colorWithRed:235/255.0f green:235/255.0f blue:241/255.0f alpha:1].CGColor;
//    placeTextView.layer.borderWidth = 1;

    placeTextView.autocorrectionType = UITextAutocorrectionTypeNo;  //取消纠错
    placeTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;  //取消首字母大写


//    placeTextView.returnKeyType = UIReturnKeyDone; // 完成
    
    placeTextView.layer.borderColor = [UIColor colorWithRed:235/255.0f green:235/255.0f blue:241/255.0f alpha:1].CGColor;
    placeTextView.layer.borderWidth = 1;
    if ([text isEqualToString:@"感谢您对人人积金的关注，您的意见是我们前进的动力！"]) {
        placeTextView.font = [UIFont systemFontOfSize:12];
    }else
    placeTextView.font=[UIFont systemFontOfSize:15];
//    [placeTextView setReturnKeyType:UIReturnKeyDone];
    return placeTextView;
}




@end
