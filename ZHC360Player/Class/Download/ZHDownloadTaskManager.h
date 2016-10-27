//
//  ZHDownloadTaskManager.h
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/8/31.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZHDownloadTaskManager : NSObject

//====================属性====================

/** 正在下载列表 */
@property (nonatomic, strong) NSMutableArray  *tasksArray;

/** 对应正在下载列表 (以链接的md5的string为key)*/
@property (nonatomic, strong) NSMutableDictionary *tasksDictionary;

/** 本地化保存所有任务的文件大小（以名字为key）*/ // 迁移到sqlite3里面
@property (nonatomic, strong) NSMutableDictionary *fileTotalSizeDictionary;

//====================方法====================
/** 单例，返回管理器的对象 */
+ (instancetype)shareTaskManager;

/** 完成下载，移除某一个任务 */
- (void)completeWithTaskName:(NSString *)name;

/** 移除某一个任务 */
- (void)removeDownloadTaskName:(NSString *)name;

/** 暂停某一个任务 */
- (void)suspendDownloadTaskName:(NSString *)name;

/** 恢复某一个任务 */
- (void)resumeDownloadTaskName:(NSString *)name;

/** 下载方法 */
- (void)addDownloadTask:(NSString *)urlString toFileName:(NSString *)fileName;

/** 是否存在此任务 */
- (BOOL)didExistTask:(NSString *)name;

/** 是否存在下载中任务 */
- (BOOL)didDownloadingTask;

/** 把本地持久化数据恢复到vc跟管理器 */ // 迁移到sqlite3里面
 - (void)saveAllLength:(NSUInteger)allLength WithFileName:(NSString *)name;

// 迁移到sqlite3里面
 - (long long )getDownloadDataSizeWithName:(NSString *)name;

@end
