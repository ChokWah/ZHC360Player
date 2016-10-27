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
@interface DBManager : NSObject

@property (assign, nonatomic)sqlite3  *myDatebase;

@property (strong, nonatomic)NSString *myDateBaseName;

/** 单例 */
+ (instancetype)shareTaskManager;

/** 创建数据库 */
- (BOOL)createDatabase;

/** 打开数据库 */
- (BOOL)openDatabase;

/** 关闭数据库*/
- (void)closeDatabase;

/** 插入数据 */
- (BOOL)insertData:(VideoModel *)model atIndex:(NSInteger)tempIndex;

/** 更新数据 */
- (BOOL)updateData:(VideoModel *)model;

/** 查询数据 (全部数据)*/
- (NSArray *)queryData;

@end
