//
//  ZHDownload.h
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/9/1.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ZHDownloadState) {
    
    ZHDownloadStateReadyDownload = 0,
    
    ZHDownloadStateDownloading,
    
    ZHDownloadStateCompleted,
    
    ZHDownloadStateSuspended,
    
    ZHDownloadStateFailed
};

@protocol ZHDownloadDelegate <NSObject>

- (void)ZHDownload:(ZHDownload *)task didCompleteWithInfo:(NSDictionary *)infoDict Error:(NSError *)error;

- (void)ZHDownload:(ZHDownload *)task didReceiveResponseWithInfo:(NSDictionary *)infoDict;

@end


@interface ZHDownload : NSObject<NSURLSessionDataDelegate>

//==============================属性=======================================
/** 任务名字*/
@property (nonatomic, copy)   NSString   *name;

/** 地址的字符串 */
@property (nonatomic, copy)   NSString   *urlString;

/** 文件总量大小, K为单位*/
@property (nonatomic, assign) NSUInteger totalSize;

/** 已下载数据大小, K为单位*/
@property (nonatomic, assign) NSUInteger tempDataSize;

/** 任务状态 */
@property (nonatomic, assign) ZHDownloadState taskState;

@property (nonatomic, weak)   id <ZHDownloadDelegate> delegate;

@property (assign, nonatomic) NSUInteger index;
//==============================方法=======================================
+ (instancetype)downloadModelWith:(NSDictionary *)dict;

/** 任务初始化 */
- (instancetype)initWithName:(NSString *)fileName andURLString:(NSString *)urlString;

/** 新建下载任务 */
- (void)downloadTask;

/** 删除下载 */
- (void)cancelTask;

/** 恢复下载 */
- (void)resumeTask;

/** 停止下载 */
- (void)suspendTask;

@end
