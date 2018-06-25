//
//  MyDBUtil.m
//  Collector
//
//  Created by kunhong on 14-10-23.
//  Copyright (c) 2014年 kunhong. All rights reserved.
//

#import "MyDBUtil.h"

@implementation MyDBUtil

static FMDatabase *db=nil;
static FMDatabaseQueue *dbqueue=nil;


+(NSString *)dataFilePath
{
    //找到沙盒路径
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //找到沙盒中document 文件夹的路径
    NSString *documentPath=[paths objectAtIndex:0];
    //追加一个文件名。
    NSString *desPath=[documentPath stringByAppendingPathComponent:@"c.sqlite"];
    NSLog(@"-----%@", desPath);
    return desPath;
}
+(FMDatabase *)getDatabase
{
    if (!db)
    {
        db=[FMDatabase databaseWithPath:[MyDBUtil dataFilePath]];
    }
    return  db;
}

+(FMDatabaseQueue *)getDatabasequeue
{
    if (!dbqueue)
    {
        dbqueue=[FMDatabaseQueue databaseQueueWithPath:[MyDBUtil dataFilePath]];
    }
    return dbqueue;
}


@end

/*
// 得到 数据库该表下的数据条数
FMResultSet *rs = [db executeQuery:@"SELECT COUNT(id) FROM selecthistorytable"];
int topiccount=0;
if ([rs next])
{
    topiccount=[rs intForColumnIndex:0];
}
 */
/*
 
 NSString *sqlstr1=[NSString stringWithFormat:@"select  * from selecthistorytable order by id  asc limit %d",1];   // asc 升序排列   desc 降序排列
 FMResultSet *resultSet=[db executeQuery:sqlstr1];
 LWCSelectModel *amodel=[[LWCSelectModel alloc]init];
 while ([resultSet next])
 {
 amodel.selestr=[resultSet stringForColumn:@"sele_str"];
 
 }
 [db executeUpdate:@"delete from selecthistorytable where sele_str = ?",amodel.selestr];
 [resultSet close];
 
 */
//[db executeUpdate:@"alter table [tablename] add [lev] int default 0"];  //数据库升级

/*
 //创建一个名为User的表，有两个字段分别为string类型的Name，integer类型的 Age
 [db executeUpdate:@"CREATE TABLE sys3 (id integer primary key, info_uid text,info_type text,info_message text,info_id text,info_imageurl text,info_time time)"];
 */
// 模拟器路径  用户／资源库／developer／ coresimulator



/*
 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
 NSString *documentPath = [paths objectAtIndex:0];
 NSString *desPath = [documentPath stringByAppendingPathComponent:@"a.sqlite"];
 //定义一个文件管理
 NSFileManager *fileManager = [NSFileManager defaultManager];
 
 //先删除数据库
 [fileManager removeItemAtPath:desPath error:nil];
 */



