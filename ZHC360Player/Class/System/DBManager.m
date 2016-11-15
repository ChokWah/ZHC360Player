//
//  DBManager.m
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/10/19.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import "DBManager.h"
#import "VideoModel.h"
#import "ZHDownload.h"
#include <pthread.h>
/**
 * 数据库：DATA.sqlite
 * 表：downloadTable
 * 属性：一样的按照VideoModel
 */
#define DATABASEPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"DATA.sqlite"]

@implementation DBManager
#pragma mark - 单例
static DBManager *singletonManager;
+ (instancetype)shareDBManager{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonManager = [[DBManager alloc] init];
    });
    
    return singletonManager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonManager = [super allocWithZone:zone];
    });
    return singletonManager;
}

- (id)copyWithZone:(NSZone *)zone{
    
    return singletonManager;
}

#pragma mark - 创建数据库
- (BOOL)openOrCreateTableWithName:(NSString *)tableName{

    [self openDatabase];
        
    char *errMsg;
    NSString *sqlString = [NSString stringWithFormat: @"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, DOWNLOADPATH TEXT, PATH TEXT, IMAGEURLSTR TEXT, PROGRESSINFO TEXT, DATESTRING TEXT, TOTALSIZE INTEGER, TEMPDATASIZE INTEGER, ISDOWNLOADING TEXT, ISREADYDOWNLOAD TEXT, INDEXNUMBER INTEGER)",tableName];
    
    if (sqlite3_exec(_myDatebase, [sqlString UTF8String], NULL, NULL, &errMsg) != SQLITE_OK) {
        NSLog( @"Failed to create table %s",errMsg);
        return NO;
    }
    NSLog(@"成功建表");
    [self closeDatabase];
    return YES;
}

- (BOOL)openDatabase{

    if (sqlite3_open([DATABASEPath UTF8String], &_myDatebase) != SQLITE_OK) {
        NSLog( @"Failed to create database");
        return NO;
    }
    NSLog(@"***openOrCreate Database");
    return YES;
}

- (void)closeDatabase{
    
    if (sqlite3_close(_myDatebase) != SQLITE_OK) {
        NSAssert1(0, @"Failed to close database: '%s'.", sqlite3_errmsg(_myDatebase));
    }
    NSLog(@"***close Database");
}

#pragma mark - 表操作
- (BOOL)exec:(NSString *)sql{
    
    pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
    pthread_mutex_lock(&mutex);
    if (![self openDatabase]) {
        return NO;
    }
    
    char *errMsg = NULL;
    BOOL b = YES;
    if (sqlite3_exec(_myDatebase, [sql UTF8String], 0, NULL, &errMsg) != SQLITE_OK) {
        NSLog(@"EXEC ERROR:%s",errMsg);
        b = NO;
    }
    
    [self closeDatabase];
    pthread_mutex_unlock(&mutex);
    
    return b;
}

- (BOOL)insertData:(VideoModel *)model WithName:(NSString *)tableName{
    
    NSString *isDownloadingString = model.isDownloading ? @"YES" : @"NO";
    NSString *isReadyDownload = model.isReadyDownload ? @"YES" : @"NO";
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (NAME, DOWNLOADPATH, PATH, IMAGEURLSTR, PROGRESSINFO, DATESTRING, TOTALSIZE, TEMPDATASIZE, ISDOWNLOADING, ISREADYDOWNLOAD, INDEXNUMBER) VALUES ('%@','%@','%@','%@','%@','%@',%d,%d,'%@','%@',%d)",tableName, model.name, model.downloadPath, model.path, model.imageUrlStr, model.progressInfo, model.dateString, (int)model.totalSize, (int)model.tempDataSize, isDownloadingString, isReadyDownload, (int)model.index];
    
    return [self exec:sql];
}

- (BOOL)updateData:(VideoModel *)model WithName:(NSString *)tableName{
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET TOTALSIZE = %d, TEMPDATASIZE = %d, DATESTRING = '%@', PATH = '%@', PROGRESSINFO = '%@', ISDOWNLOADING = '%@' WHERE NAME = '%@'",tableName, (int)model.totalSize, (int)model.tempDataSize, model.dateString, model.path, model.progressInfo, model.isDownloading ? @"YES" : @"NO",model.name];
    NSLog(@"%@",sql);
    return [self exec:sql];
}

//- (BOOL)insertTask:(ZHDownload *)task WithTableName:(NSString *)tableName{
//    
//    NSString *isDownloadingString =  task.taskState == ZHDownloadStateDownloading ? @"YES" : @"NO";
//    
//    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (NAME, DOWNLOADPATH, PATH, IMAGEURLSTR, PROGRESSINFO, DATESTRING, TOTALSIZE, TEMPDATASIZE, ISDOWNLOADING, ISREADYDOWNLOAD, INDEXNUMBER) VALUES ('%@','%@','%@','%@','%@','%@',%d,%d,'%@','%@',%d)",tableName, task.name, task.urlString, nil, nil, nil, nil, (int)task.totalSize, 0, isDownloadingString, nil, (int)task.index];
//    
//    return [self exec:sql];
//    
//}
//
//- (BOOL)updateTask:(ZHDownload *)task WithName:(NSString *)tableName{
//    
//    NSString *isDownload = task.taskState == ZHDownloadStateDownloading ? @"YES" : @"NO";
//    
//    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET  TOTALSIZE = %d, ISDOWNLOADING = '%@', INDEXNUMBER = %d WHERE NAME = '%@'",tableName, (int)task.totalSize, isDownload, (int)task.index, task.name];
//    NSLog(@"%@",sql);
//    return [self exec:sql];
//}

- (NSArray *)queryDataWithName:(NSString *)tableName{
    
    pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
    pthread_mutex_lock(&mutex);
    if (![self openDatabase]) {
        return nil;
    }
    
    NSMutableArray *rusultArray = [NSMutableArray array];
    const char *sql = [[NSString stringWithFormat:@"select * from %@",tableName] UTF8String];
    sqlite3_stmt *statement =nil;
    
    if (sqlite3_prepare_v2(_myDatebase, sql, -1, &statement, NULL) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            BOOL isdownload = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 9)] isEqualToString:@"YES"];
            BOOL isedit     = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 10)] isEqualToString:@"YES"];
            
            NSDictionary *dict = @{
                                   @"name"         : [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)],
                                   @"downloadPath" : [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)],
                                   @"path"         : [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)],
                                   @"imageUrlStr"  : [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)],
                                   @"progressInfo" : [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)],
                                   @"dateString"   : [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)],
                                   @"totalSize"    : [NSNumber numberWithInt:sqlite3_column_int(statement, 7)],
                                   @"tempDataSize" : [NSNumber numberWithInt:sqlite3_column_int(statement, 8)],
                                   @"isDownloading": [NSNumber numberWithBool:isdownload],
                                   @"isReadyDownload": [NSNumber numberWithBool:isedit],
                                   @"index"        : [NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 11)],
                                   };
            NSLog(@"Record: %@ ",dict);
            [rusultArray addObject:dict];
        }
        sqlite3_reset(statement);
        sqlite3_finalize(statement);
    }
    [self closeDatabase];
    pthread_mutex_unlock(&mutex);
    return rusultArray;
}


- (NSArray *)queryDataName:(NSString *)name WithtableName:(NSString *)tablename{
    
    pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
    pthread_mutex_lock(&mutex);
    if (![self openDatabase]) {
        return nil;
    }
    
    NSMutableArray *rusultArray = [NSMutableArray array];
    const char *sql = [[NSString stringWithFormat:@"select * from %@ where name = '%@'",tablename, name] UTF8String];
    sqlite3_stmt *statement =nil;
    if (sqlite3_prepare_v2(_myDatebase, sql, -1, &statement, NULL) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            BOOL isdownload = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 9)] isEqualToString:@"YES"];
            BOOL isedit     = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 10)] isEqualToString:@"YES"];
            
            NSDictionary *dict = @{
                                   @"name"         : [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)],
                                   @"downloadPath" : [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)],
                                   @"path"         : [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)],
                                   @"imageUrlStr"  : [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)],
                                   @"progressInfo" : [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)],
                                   @"dateString"   : [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)],
                                   @"totalSize"    : [NSNumber numberWithInt:sqlite3_column_int(statement, 7)],
                                   @"tempDataSize" : [NSNumber numberWithInt:sqlite3_column_int(statement, 8)],
                                   @"isDownloading": [NSNumber numberWithBool:isdownload],
                                   @"isReadyDownload": [NSNumber numberWithBool:isedit],
                                   @"index"        : [NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 11)],
                                   };
            NSLog(@"Record: %@ ",dict);
            [rusultArray addObject:dict];
        }
        sqlite3_reset(statement);
        sqlite3_finalize(statement);
    }
    [self closeDatabase];
    pthread_mutex_unlock(&mutex);
    return rusultArray;
}

- (void)dealloc{
    _myDatebase = nil;
}

@end
