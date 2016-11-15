//
//  DBManager.h
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/10/19.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class VideoModel;
@class ZHDownload;

@interface DBManager : NSObject

@property (assign, nonatomic)sqlite3  *myDatebase;

/** 单例 */
+ (instancetype)shareDBManager;

/** 创建数据库 */
- (BOOL)openOrCreateTableWithName:(NSString *)tableName;

/** 打开数据库 */
- (BOOL)openDatabase;

/** 关闭数据库*/
- (void)closeDatabase;

/** 插入VideoModel数据 */
- (BOOL)insertData:(VideoModel *)model WithName:(NSString *)tableName;

/** 更新VideoModel数据 */
- (BOOL)updateData:(VideoModel *)model WithName:(NSString *)tableName;

/** 插入ZHDownload数据*/
//- (BOOL)insertTask:(ZHDownload *)task WithTableName:(NSString *)tableName;

/** 更新ZHDownload数据*/
//- (BOOL)updateTask:(ZHDownload *)task WithName:(NSString *)tableName;

- (NSArray *)queryDataName:(NSString *)name WithtableName:(NSString *)tablename;

/** 查询数据 (全部数据)*/
- (NSArray *)queryDataWithName:(NSString *)tableName;

@end
