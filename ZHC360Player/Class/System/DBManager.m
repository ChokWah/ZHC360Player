//
//  DBManager.m
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/10/19.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import "DBManager.h"
#import "VideoModel.h"

/**
 * 数据库：DATA.sqlite
 * 表：DATA
 * 属性：
 */
#define DATABASEPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"DATA.sqlite"]

@implementation DBManager
#pragma mark - 单例
static DBManager *singletonManager;
+ (instancetype)shareTaskManager{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonManager = [[DBManager alloc] init];
        singletonManager.myDateBaseName = @"DATA";
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
- (BOOL)createDatabase{
    
    [self openDatabase];
        
    char *errMsg;
    const char *sql = "CREATE TABLE IF NOT EXISTS DATA (id INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, DOWNLOADPATH TEXT, PATH TEXT, IMAGEURLSTR TEXT, PROGRESSINFO TEXT, DATESTRING TEXT, TOTALSIZE INTEGER, TEMPDATASIZE INTEGER, ISDOWNLOADING TEXT, ISEDITING TEXT, INDEXNUMBER INTEGER)";
    
    if (sqlite3_exec(_myDatebase, sql, NULL, NULL, &errMsg) != SQLITE_OK) {
        NSLog( @"Failed to create table %s",errMsg);
        return NO;
    }
    
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
    return b;
}

- (BOOL)insertData:(VideoModel *)model atIndex:(NSInteger)tempIndex{
    
    NSString *isDownloadingString = model.isDownloading ? @"YES" : @"NO";
    NSString *isEditingString = model.isEditing ? @"YES" : @"NO";
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO DATA (NAME, DOWNLOADPATH, PATH, IMAGEURLSTR, PROGRESSINFO, DATESTRING, TOTALSIZE, TEMPDATASIZE, ISDOWNLOADING, ISEDITING, INDEXNUMBER) VALUES ('%@','%@','%@','%@','%@','%@',%d,%d,'%@','%@',%d)",model.name, model.downloadPath, model.path, model.imageUrlStr, model.progressInfo, model.dateString, (int)model.totalSize, (int)model.tempDataSize, isDownloadingString, isEditingString, (int)tempIndex];
    
    return [self exec:sql];
}

- (BOOL)updateData:(VideoModel *)model{
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE DATA SET TOTALSIZE = %d, TEMPDATASIZE = %d, DATESTRING = '%@', PATH = '%@', PROGRESSINFO = '%@', ISDOWNLOADING = '%@' WHERE INDEXNUMBER = %d",(int)model.totalSize, (int)model.tempDataSize, model.dateString, model.path, model.progressInfo, model.isDownloading ? @"YES" : @"NO", (int)model.index];
    NSLog(@"%@",sql);
    return [self exec:sql];
}

- (NSArray *)queryData{
    
    if (![self openDatabase]) {
        return nil;
    }
    
    NSMutableArray *rusultArray = [NSMutableArray array];
    const char *sql = "select * from data";
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
                                   @"isEditing"    : [NSNumber numberWithBool:isedit],
                                   @"index"        : [NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 11)],
                                   };
            NSLog(@"Record: %@ ",dict);
            [rusultArray addObject:dict];
        }
        
        sqlite3_finalize(statement);
    }
    [self closeDatabase];
    return rusultArray;
}



- (void)dealloc{
    _myDatebase = nil;
}

@end
