//
//  ZHDownloadTaskManager.m
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/8/31.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import "ZHDownloadTaskManager.h"
#import "ZHDownload.h"
#import "NSString+Hash.h"
#import "VideoModel.h"


// 最大下载数
#define MAXTasks 2

@interface ZHDownloadTaskManager()<ZHDownloadDelegate>

//====================属性====================

/** 正在下载列表 */
@property (nonatomic, strong) NSMutableArray <ZHDownload *> *tasksArray;

// name : downloadIndex | 从1开始
@property (nonatomic, strong) NSMutableDictionary *downloadIndexDict;


@end

@implementation ZHDownloadTaskManager

static ZHDownloadTaskManager *singletonManager;

#pragma mark - 单例,懒加载
+ (instancetype)shareTaskManager{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        singletonManager = [[ZHDownloadTaskManager alloc] init];
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

- (NSMutableArray *)tasksArray{
    
    if (!_tasksArray) {
        _tasksArray = [NSMutableArray array];
    }
    return _tasksArray;
}

- (void)taskArrayKVO{
    
    // 第一次创建新的下载任务的时候，开启观察者（仅一次）
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self addObserver:self forKeyPath:@"tasksArray" options:NSKeyValueObservingOptionNew context:@"tasksArray"];
    });
}

- (BOOL)isTaskDownloading{
    
    return self.tasksArray.count;
}

- (NSMutableDictionary *)downloadIndexDict{
    
    if (!_downloadIndexDict) {
        _downloadIndexDict = [NSMutableDictionary dictionary];
    }
    return _downloadIndexDict;
}

#pragma mark - 增加下载任务
- (BOOL)addDownloadTaskWithModel:(VideoModel *)model{
    
    [self taskArrayKVO];
    
    @synchronized(self){
        
        if ([ZHFILEMANAGER fileExistsAtPath:ZHCacheFilePath(model.name)]) {
            [ZHFILEMANAGER removeItemAtPath:ZHCacheFilePath(model.name) error:nil];
        }
        if (self.tasksArray.count >=  MAXTasks) {
            return NO;
        }
        
        ZHDownload *download = [[ZHDownload alloc] initWithName:model.name andURLString:model.downloadPath];
        download.index = model.index;
        [[self mutableArrayValueForKey:@"tasksArray"] addObject:download];
        [self.downloadIndexDict setObject:@(self.tasksArray.count) forKey:download.name];
        download.delegate = self;
    }
    return YES;
}

#pragma mark - 观察者方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"tasksArray"]) {
        
        ZHDownload *task = (ZHDownload *)[[change objectForKey:@"new"] firstObject];
        
        if (task) { // 下载队列增加下载任务的时候
            
            task.index = [self.tasksArray indexOfObject:task];
            [self startDownloadTaskModel:task];
            task.taskState = ZHDownloadStateDownloading;
            
        }else{      // 下载队列减少任务的时候，取出未下载，或者被停止的任务
 
            MAXTasks > self.tasksArray.count ? [[NSNotificationCenter defaultCenter] postNotificationName:@"readyDownload" object:[NSNumber numberWithUnsignedInteger:MAXTasks - self.tasksArray.count] userInfo:nil] : nil;
        }
        
    }else{ // 防止crash
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// 回调更新进度
- (long long)getDownloadDataSizeWithName:(NSString *)name{
    
    //NSUInteger tempSize =  ZHGETCacheFileLength(name);
    
    ZHDownload *dw = [self getDownloadModelWith:name];
    return (dw.tempDataSize / 1024);
}

// 根据名字取出任务模型
- (ZHDownload *)getDownloadModelWith:(NSString *)name{
    
    if(![self.downloadIndexDict.allKeys containsObject:name]){
        return nil;
    }
    @synchronized (self) {
        
        NSUInteger index = [[self.downloadIndexDict objectForKey:name] unsignedIntegerValue];
        if(self.tasksArray.count >= index){
            
            ZHDownload *dw = [self.tasksArray objectAtIndex:index-1];
            return dw;
        }
    }
    return nil;
}
#pragma mark - ZHDownload代理方法
- (void)ZHDownload:(ZHDownload *)task didCompleteWithInfo:(NSDictionary *)infoDict Error:(NSError *)error{
 
    [[NSNotificationCenter defaultCenter] postNotificationName:@"complement" object:error userInfo:infoDict];
    
    if (error) {
        [ZHFILEMANAGER removeItemAtPath:ZHCacheFilePath(infoDict[@"name"]) error:nil];
    }
    
    [[self mutableArrayValueForKey:@"tasksArray"] removeObject:task];
    [self.downloadIndexDict.allKeys containsObject:task.name] ? [self.downloadIndexDict removeObjectForKey:task.name] : nil;
}

- (void)ZHDownload:(ZHDownload *)task didReceiveResponseWithInfo:(NSDictionary *)infoDict{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"response" object:nil userInfo:infoDict];
}

#pragma mark - 对任务操作，新建，删除，停止，恢复
// 开始下载
- (void)startDownloadTaskModel:(ZHDownload *)task{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //__weak typeof(self) weakSelf = self;
        [task downloadTask];
    });
}

// 完成下载，删除任务
- (void)completeWithTaskName:(NSString *)name{
    
    [self deleteTaskName:name];
}

// 根据名字移除任务
- (BOOL)removeDownloadTaskName:(NSString *)name{
    
    BOOL isSuccess = [self deleteTaskName:name];
    if (isSuccess) {
        [ZHFILEMANAGER removeItemAtPath:ZHCacheFilePath(name) error:nil];
    }
    return isSuccess;
}

- (BOOL)deleteTaskName:(NSString *)name{
        
    if (self.tasksArray.count == 0) {
        return NO;
    }
    
    ZHDownload *dw = [self getDownloadModelWith:name];
    
    if (dw) {
        
        [dw cancelTask];
        NSLog(@"移除缓存成功");
        return YES;
    }
    return NO;
}

- (void)dealloc{
    
    //父类方法已经默认调用，不用复写
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
