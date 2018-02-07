//
//  ForumDB.m
//  LifeServices
//
//  Created by Snail iOS on 16/4/1.
//  Copyright © 2016年 Snail iOS. All rights reserved.
//

#import "ForumDB.h"

@implementation ForumDB

// 保存纪录 评论

+(void)saveSystemInfo:(MinePuComModel *)comModel;
{
    
    FMDatabaseQueue *queue=[MyDBUtil getDatabasequeue];
    
    [queue inDatabase:^(FMDatabase *db) {
        
        if (![db tableExists:@"commenttable"])
        {
            [db executeUpdate:@"CREATE TABLE commenttable (id integer primary key,textName text,head text,nickname text,createTime text,pid integer,type integer)"];
        }
        
    
        
        NSString *userID =  [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
        if(![db columnExists:@"userid" inTableWithName:@"commenttable"]){
            [db executeUpdate:@"alter table commenttable add userid text"];
        }
//        if(![db columnExists:@"mainImage" inTableWithName:@"forumtable"]){
//            [db executeUpdate:@"alter table forumtable add mainImage text"];
//        }
//        [db executeUpdate:@"delete from forumtable"];
        
        [db executeUpdate:@"insert into commenttable (textName,head,nickname,createTime,pid,type,userid) values (?,?,?,?,?,?,?)",comModel.text,comModel.head,comModel.nickname,comModel.createTime,@(comModel.pid),@(comModel.type), userID];
        
//        for ( FhomeInfoModel *fhome in forumarray) {
//            [db executeUpdate:@"insert into forumtable (menuName,desc,mainImage,type,countNote) values (?,?,?,?,?)",fhome.menuName,fhome.desc,fhome.mainImage,@(fhome.type),@(fhome.countNote)
//             ];
//        }
        
    }];
}

// 保存纪录。推送
+(void)savePushInfo:(MinePushModel *)pushModel{
    FMDatabaseQueue *queue=[MyDBUtil getDatabasequeue];
    
    [queue inDatabase:^(FMDatabase *db) {
        
        if (![db tableExists:@"pushtable"])
        {
            [db executeUpdate:@"CREATE TABLE pushtable (id integer primary key,textName text,createTime text)"];
        }
        
        NSString *userID =  [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
        if(![db columnExists:@"userid" inTableWithName:@"pushtable"]){
            [db executeUpdate:@"alter table pushtable add userid text"];
        }

        
         [db executeUpdate:@"insert into pushtable (textName,createTime) values (?,?,?)",pushModel.text,pushModel.createTime, userID];
        }];

}

//取出。评论数据
+(NSMutableArray *)getselectforum:(NSString *)userStr
{
    FMDatabaseQueue *queue=[MyDBUtil getDatabasequeue];
    NSMutableArray *commentArray=[[NSMutableArray alloc]initWithCapacity:0];
    [queue inDatabase:^(FMDatabase *db) {
        
        if (![db tableExists:@"commenttable"])
        {
            [db executeUpdate:@"CREATE TABLE commenttable (id integer primary key,textName text,head text,nickname text,createTime text,pid integer,type integer, userid  text)"];
        }
        
        FMResultSet *resultSet=[db executeQuery:@"select  * from commenttable where userid=?",userStr];
        while ([resultSet next])
        {
            MinePuComModel *aModel=[[MinePuComModel alloc]init];
            aModel.text=[resultSet stringForColumn:@"textName"];
            aModel.head=[resultSet stringForColumn:@"head"];
            aModel.nickname=[resultSet stringForColumn:@"nickname"];
            aModel.createTime=[resultSet stringForColumn:@"createTime"];
            aModel.pid=[resultSet intForColumn:@"pid"];
            aModel.type=[resultSet intForColumn:@"type"];
            [commentArray insertObject:aModel atIndex:0];
        }
        [resultSet close];
//        for (NSString *type in select) {
//        }
    }];
    
    return commentArray;
}
//取出。评论数据
+(NSMutableArray *)getallforum
{
    FMDatabaseQueue *queue=[MyDBUtil getDatabasequeue];
    NSMutableArray *commentArray=[[NSMutableArray alloc]initWithCapacity:0];
    [queue inDatabase:^(FMDatabase *db) {
        if (![db tableExists:@"commenttable"])
        {
            [db executeUpdate:@"CREATE TABLE commenttable (id integer primary key,textName text,head text,nickname text,createTime text,pid integer,type integer)"];
        }
         FMResultSet *resultSet=[db executeQuery:@"select  * from commenttable"];
        
        while ([resultSet next])
        {
            MinePuComModel *aModel=[[MinePuComModel alloc]init];
            aModel.text=[resultSet stringForColumn:@"textName"];
            aModel.head=[resultSet stringForColumn:@"head"];
            aModel.nickname=[resultSet stringForColumn:@"nickname"];
            aModel.createTime=[resultSet stringForColumn:@"createTime"];
            aModel.pid=[resultSet intForColumn:@"pid"];
            aModel.type=[resultSet intForColumn:@"type"];
            [commentArray insertObject:aModel atIndex:0];
            
        }
        [resultSet close];
        
    }];
    
    return commentArray;
}
//取出。推送
+(NSMutableArray *)getallPush{
    FMDatabaseQueue *queue=[MyDBUtil getDatabasequeue];
    NSMutableArray *commentArray=[[NSMutableArray alloc]initWithCapacity:0];
    [queue inDatabase:^(FMDatabase *db) {
        if (![db tableExists:@"pushtable"])
        {
            [db executeUpdate:@"CREATE TABLE pushtable (id integer primary key,textName text,createTime text)"];
        }
        
        FMResultSet *resultSet=[db executeQuery:@"select  * from pushtable"];
        
        while ([resultSet next])
        {
            MinePushModel *aModel=[[MinePushModel alloc]init];
            aModel.text=[resultSet stringForColumn:@"textName"];
            aModel.createTime=[resultSet stringForColumn:@"createTime"];
            [commentArray insertObject:aModel atIndex:0];
            
        }
        [resultSet close];
        
    }];
    
    return commentArray;

}
//取出。推送
+(NSMutableArray *)getselectpush:(NSString *)userStr{
    FMDatabaseQueue *queue=[MyDBUtil getDatabasequeue];
    NSMutableArray *commentArray=[[NSMutableArray alloc]initWithCapacity:0];
    [queue inDatabase:^(FMDatabase *db) {
        if (![db tableExists:@"pushtable"])
        {
            [db executeUpdate:@"CREATE TABLE pushtable (id integer primary key,textName text,createTime text, userid text)"];
        }
        
        FMResultSet *resultSet=[db executeQuery:@"select  * from pushtable where userid=?",userStr];
        
        while ([resultSet next])
        {
            MinePushModel *aModel=[[MinePushModel alloc]init];
            aModel.text=[resultSet stringForColumn:@"textName"];
            aModel.createTime=[resultSet stringForColumn:@"createTime"];
            [commentArray insertObject:aModel atIndex:0];
            
        }
        [resultSet close];
        
    }];
    
    return commentArray;

}

//删除评论表
+ (void)deleteCommentTable{
     FMDatabaseQueue *queue=[MyDBUtil getDatabasequeue];
    [queue inDatabase:^(FMDatabase *db) {
       BOOL result = [db executeUpdate:@"drop table if exists commenttable"];
        if (result) {
            NSLog(@"删除成功");
        }else{
            NSLog(@"删除失败");
        }
        
    }];
}
//删除推送表
+ (void)deletePushTable{
    FMDatabaseQueue *queue=[MyDBUtil getDatabasequeue];
    [queue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:@"drop table if exists pushtable"];
        if (result) {
            NSLog(@"删除成功");
        }else{
            NSLog(@"删除失败");
        }
        
    }];

}
@end
