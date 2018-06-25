//
//  GCPlaceholderTextView.h
//  GCLibrary
//
//  Created by Guillaume Campagna on 10-11-16.
//  Copyright 2010 LittleKiwi. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GCPlaceholderTextView : UITextView 

@property(nonatomic, copy) NSString *placeholder;
+(GCPlaceholderTextView *)initWithFrame:(CGRect )frame andText:(NSString *)text;


@end
