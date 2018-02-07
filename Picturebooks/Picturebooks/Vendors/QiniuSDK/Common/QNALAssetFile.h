//
//  QNALAssetFile.h
//  QiniuSDK
//
//  Created by bailong on 15/7/25.
//  Copyright (c) 2015年 Qiniu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QNFileDelegate.h"

#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED)
@class ALAsset;
@interface QNALAssetFile : NSObject <QNFileDelegate>

- (instancetype)init:(ALAsset *)asset
               error:(NSError *__autoreleasing *)error;
@end
#endif
