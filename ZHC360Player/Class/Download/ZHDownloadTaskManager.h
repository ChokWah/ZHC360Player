//
//  ZHDownloadTaskManager.h
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/8/31.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VideoModel;
@interface ZHDownloadTaskManager : NSObject

//====================方法====================
/** 单例，返回管理器的对象 */
+ (instancetype)shareTaskManager;

/** 完成下载，移除某一个任务 */
- (void)completeWithTaskName:(NSString *)name;

/** 根据名字移除任务 */
- (BOOL)removeDownloadTaskName:(NSString *)name;

/** 是否还有下载任务 */
- (BOOL)isTaskDownloading;

- (BOOL)addDownloadTaskWithModel:(VideoModel *)model;

- (long long)getDownloadDataSizeWithName:(NSString *)name;

@end
