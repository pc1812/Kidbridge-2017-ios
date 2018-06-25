//
//  LameTools.m
//  Picturebooks
//
//  Created by 尹凯 on 2017/8/17.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "LameTools.h"


@implementation LameTools

/**
 caf文件转成MP3格式
 
 @param cafFilePath caf文件路径
 @param mp3FilePath mp3文件路径
 @return 返回布尔值
 */
+ (BOOL)cafTransToMP3WithCafFilePath:(NSString *)cafFilePath mp3FilePath:(NSString *)mp3FilePath{
    @try {
        int read, write;
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");//被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");//生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        // 初始化lame编码器
        lame_t lame = lame_init();
        // 设置lame mp3编码的采样率 / 声道数 / 比特率
        lame_set_in_samplerate(lame, 8000);
        lame_set_num_channels(lame,2);
        lame_set_out_samplerate(lame, 8000);
        lame_set_brate(lame, 8);
        // MP3音频质量.0~9.其中0是最好,非常慢,9是最差.
        lame_set_quality(lame, 0);
        
        // 设置mp3的编码方式
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            size_t size = (size_t)(2 * sizeof(short int));
            read = fread(pcm_buffer, size, PCM_SIZE, pcm);
            if (read == 0) {
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            } else {
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            }
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        return 0;
    }
    @finally {
        // 转码完成
        return 1;
    }
}

//清除该路径下所有音频（录制的caf）
+ (void)clearSoundFile{
    NSString *path = [DocumentDirectory stringByAppendingPathComponent:@"SoundFile"];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        //-(NSArray *)subpathsAtPath:(NSString *)path,用来获取指定目录下的子项（文件或文件夹）列表
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles) {
            //如有需要，加入条件，过滤掉不想删除的文件
            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
}

//清除该路径下所有音频（转码压缩后的）
+ (void)clearUploadFile{
    NSString *path = [DocumentDirectory stringByAppendingPathComponent:@"UploadFile"];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        //-(NSArray *)subpathsAtPath:(NSString *)path,用来获取指定目录下的子项（文件或文件夹）列表
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles) {
            //如有需要，加入条件，过滤掉不想删除的文件
            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
}

//清除该路径下所有音频（音频评论）
+ (void)clearCommentSoundFile{
    NSString *path = [DocumentDirectory stringByAppendingPathComponent:@"UploadFile"];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        //-(NSArray *)subpathsAtPath:(NSString *)path,用来获取指定目录下的子项（文件或文件夹）列表
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles) {
            //如有需要，加入条件，过滤掉不想删除的文件
            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
}

@end
