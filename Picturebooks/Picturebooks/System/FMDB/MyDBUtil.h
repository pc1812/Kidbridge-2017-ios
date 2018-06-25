//
//  MyDBUtil.h
//  Collector
//
//  Created by kunhong on 14-10-23.
//  Copyright (c) 2014年 kunhong. All rights reserved.
//
//数据库操作

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabaseQueue.h"

@interface MyDBUtil : NSObject
+(FMDatabase *)getDatabase;
+(FMDatabaseQueue *)getDatabasequeue;

@end
