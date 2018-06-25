//
//  UIBarButtonItemAdditions.h
//  CityGuide
//
//  Created by lll on 13-6-8.
//  Copyright (c) 2013年 lll. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem(Additions)

+ (UIBarButtonItem *)leftBarButtonItemWithImage:(UIImage *)image
                                    highlighted:(UIImage *)highlightedImage
                                         target:(id)target
                                       selector:(SEL)selector;

+ (UIBarButtonItem *)rightBarButtonItemWithImage:(UIImage *)image
                                     highlighted:(UIImage *)highlightedImage
                                          target:(id)target
                                        selector:(SEL)selector;

+ (UIBarButtonItem *) leftBarButtonItemWithTitle:(NSString *)title
                                          target:(id)target
                                        selector:(SEL)selector;

+ (UIBarButtonItem *)rightBarButtonItemWithTitle:(NSString *)title
                                          target:(id)target
                                        selector:(SEL)selector;

@end
