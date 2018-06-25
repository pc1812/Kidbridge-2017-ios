//
//  LameTools.h
//  Picturebooks
//
//  Created by 尹凯 on 2017/8/17.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "amrFileCodec.h"
#import "lame.h"

@interface LameTools : NSObject

/**
 caf文件转成MP3格式
 
 @param cafFilePath caf文件路径
 @param mp3FilePath mp3文件路径
 @return 返回布尔值
 */
+ (BOOL)cafTransToMP3WithCafFilePath:(NSString *)cafFilePath mp3FilePath:(NSString *)mp3FilePath;

//清除该路径下所有音频（录制的caf）
+ (void)clearSoundFile;

//清除该路径下所有音频（转码压缩后的）
+ (void)clearUploadFile;

@end
