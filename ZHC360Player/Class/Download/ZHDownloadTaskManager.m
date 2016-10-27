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

// 已下载长度(直接读取)
#define ZHGETCacheFileLength(name) [[[NSFileManager defaultManager] attributesOfItemAtPath:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES)lastObject] stringByAppendingPathComponent:name] error:nil][NSFileSize] integerValue]

// 保存每个任务的总大小（以名字为key）迁移到sqlite3里面
#define ZHDownloadFileLengthDictionaryPath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES)lastObject] stringByAppendingPathComponent:@"ZHDownloadFileLengthDictionaryPath.plist"]

// 缓存文件夹
#define ZHCacheFilePath(name) [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES)lastObject] stringByAppendingPathComponent:name]

// 根据名字获取沙盒文档的文件
#define ZHDocumentFilePath(name) [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)lastObject] stringByAppendingPathComponent:name]

// 最大下载数
#define MAXTasks 2

@implementation ZHDownloadTaskManager

#pragma mark - 单例
static ZHDownloadTaskManager *singletonManager;
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

#pragma mark - 懒加载
- (NSMutableDictionary *)tasksDictionary{
    
    if (!_tasksDictionary) {
        _tasksDictionary = [NSMutableDictionary dictionary];
    }
    return _tasksDictionary;
}

- (NSMutableArray *)tasksArray{
    
    if (!_tasksArray) {
        _tasksArray = [NSMutableArray array];
    }
    return _tasksArray;
}

/** 判断本地是否有，木有再新建一个 */
- (NSMutableDictionary *)fileTotalSizeDictionary{
    
    if (!_fileTotalSizeDictionary) {
        
        _fileTotalSizeDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:ZHDownloadFileLengthDictionaryPath];
        
        !_fileTotalSizeDictionary ? _fileTotalSizeDictionary = [NSMutableDictionary dictionary] : nil;
    }
    return _fileTotalSizeDictionary;
}

// 新增下载任务
- (void)addDownloadTask:(NSString *)urlString toFileName:(NSString *)fileName{
    
    // 第一次创建新的下载任务的时候，开启观察者（仅一次）
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self addObserver:self forKeyPath:@"tasksArray" options:NSKeyValueObservingOptionNew context:@"tasksArray"];
    });
    
    // 数据持久化检查
    if([self.fileTotalSizeDictionary.allKeys containsObject:fileName] && [[NSFileManager defaultManager] fileExistsAtPath:ZHDocumentFilePath(fileName)]){
        
        NSLog(@"已完成下载，本地已经存在");
        return;
    }
#warning 曾经下载过，没完成，当前任务列表也没有, 干脆直接重新下载算了

    
    // 新建任务添加到下载列表
    ZHDownload *task = [[ZHDownload alloc] initWithName:fileName andURLString:urlString];
    if(self.fileTotalSizeDictionary[fileName]){
        task.totalSize = [self.fileTotalSizeDictionary[fileName] unsignedIntegerValue];
    }
    
    @synchronized(self){
        
        [self.tasksDictionary setObject:task forKey:fileName.md5String];
        [self.tasksArray count] < MAXTasks ? [[self mutableArrayValueForKey:@"tasksArray"] addObject:task] : (task.taskState = ZHDownloadStateReadyDownload) ;
        task.index = [self.tasksArray indexOfObject:task];
    }
}

#pragma mark - 观察者方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"tasksArray"]) {
        
        ZHDownload *task = (ZHDownload *)[[change objectForKey:@"new"] firstObject];
        
        if (task) { /** 下载队列增加下载任务的时候 */
            
            [self startDownloadTaskModel:task];
            
        }else{      /** 下载队列减少任务的时候，从字典取出待下载任务加进来 */

            [self.tasksDictionary enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull key, ZHDownload  *_Nonnull obj, BOOL * _Nonnull stop) {
                
                if (obj.taskState == ZHDownloadStateReadyDownload) {
                    [self startDownloadTaskModel:obj];
                    *stop = YES;
                }
            }];
        }
        
    }else{ // 防止crash
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// 回调更新进度
- (long long )getDownloadDataSizeWithName:(NSString *)name{
    
    ZHDownload *task = [self.tasksDictionary objectForKey:name.md5String];
    return (task.tempDataSize/1024);
}


#pragma mark - 提供给控制器查询
// 查询是否存在任务
- (BOOL)didExistTask:(NSString *)name{
    
    if (self.tasksDictionary[name.md5String]) {
        return YES;
    }else{
        return NO;
    }
}

// 是否在下载中，需要更新
- (BOOL)didDownloadingTask{
    
    // 遍历数组，查看是否在下载
    for (ZHDownload *downloadTask in self.tasksArray) {
        
        if(downloadTask.taskState == ZHDownloadStateDownloading){
            return YES;
        }
    }
    return NO;
}

#pragma mark - 对任务操作，新建，删除，停止，恢复
// 新增下载任务
- (void)startDownloadTaskModel:(ZHDownload *)task{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //__weak typeof(self) weakSelf = self;
        task.taskState = ZHDownloadStateDownloading;
        [task downloadTask];
    });
}

// 完成下载，删除任务
- (void)completeWithTaskName:(NSString *)name{
    
    @synchronized(self){
        
        ZHDownload *task = [self.tasksDictionary objectForKey:name.md5String];
        [[self mutableArrayValueForKey:@"tasksArray"] removeObject:task];
        [self.tasksDictionary removeObjectForKey:name.md5String];
    }
}

//删除下载任务
- (void)removeDownloadTaskName:(NSString *)name{
    
    ZHDownload *tempTask = self.tasksDictionary[name.md5String];
    tempTask ? [tempTask cancelTask] : NSLog(@"No this Task");
    
    [self.tasksDictionary removeObjectForKey:name];
}

//暂停下载任务
- (void)suspendDownloadTaskName:(NSString *)name{
    
    ZHDownload *tempTask = self.tasksDictionary[name.md5String];
    if(tempTask && tempTask.taskState == ZHDownloadStateDownloading) {
        
        [tempTask suspendTask];
        tempTask.taskState = ZHDownloadStateSuspended;
        [self.tasksDictionary removeObjectForKey:name];
    }
}

//恢复下载任务
- (void)resumeDownloadTaskName:(NSString *)name{
    
    ZHDownload *tempTask = self.tasksDictionary[name.md5String];
    if(tempTask && tempTask.taskState == ZHDownloadStateSuspended) {
        
        [tempTask resumeTask];
        tempTask.taskState = ZHDownloadStateDownloading;
        [self.tasksDictionary setObject:tempTask forKey:name];
    }
}

//保存到本地
- (void)saveAllLength:(NSUInteger)allLength WithFileName:(NSString *)name{
    
    if (allLength == 0 || name == nil) {
        return;
    }
    
    [self.fileTotalSizeDictionary setObject:@(allLength) forKey:name];
    if (![self.fileTotalSizeDictionary writeToFile:ZHDownloadFileLengthDictionaryPath atomically:YES]) {
        NSLog(@"fail to archive dictionary object : %@",self.fileTotalSizeDictionary);
    }
}

- (void)dealloc{
    
    //父类方法已经默认调用，不用复写
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
