//
//  ZHDownload.m
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/9/1.
//  Copyright © 2016年 4DAGE. All rights reserved.
//  这个类单独管理下载任务，检查是否有缓存

#import "ZHDownload.h"
#import <CoreGraphics/CoreGraphics.h>
#import "NSString+Hash.h"
#import "ZHDownloadTaskManager.h"

//已下载长度
#define ZHGETCacheFileLength(name) [[[NSFileManager defaultManager] attributesOfItemAtPath:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES)lastObject] stringByAppendingPathComponent:name] error:nil][NSFileSize] integerValue]

//缓存文件夹
#define ZHCacheFilePath(name) [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES)lastObject] stringByAppendingPathComponent:name]

//管理器的单例
#define ZHDownloadmanager [ZHDownloadTaskManager shareTaskManager]


@interface ZHDownload ()

/** 下载会话 */
@property (nonatomic, strong) NSURLSession *session;

/** 用于给Session下载的任务NSURLSessionDataTask */
@property (nonatomic, assign) NSURLSessionDataTask *dataTask;

/** 输出流 */
@property (nonatomic, strong) NSOutputStream *outputSteam;

@end

@implementation ZHDownload

#pragma mark - 懒加载类属性
- (instancetype)initWithName:(NSString *)fileName andURLString:(NSString *)urlString{
    
    if (self = [super init]) {
        
        _taskState = ZHDownloadStateReadyDownload;
        _name = fileName;
        _urlString = urlString;
    }
    return self;
}

- (NSURLSessionDataTask *)dataTask{
    
    if (!_dataTask) {
        
        NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
        //设置request请求头 ： Range:bytes=xxx-xxx
        [mutableRequest setValue:[NSString stringWithFormat:@"bytes=%ld-",ZHGETCacheFileLength(self.name)] forHTTPHeaderField:@"Range"];
        // 创建一个Data任务
        _dataTask = [self.session dataTaskWithRequest:mutableRequest];
        NSLog(@"_dataTask 懒加载");

    }
    return _dataTask;
}

- (NSOutputStream *)outputSteam{
    
    if (!_outputSteam) {
        NSLog(@"_outputSteam 懒加载");
        _outputSteam = [[NSOutputStream alloc]initToFileAtPath:ZHCacheFilePath(self.name) append:YES];
    }
    return _outputSteam;
}

- (NSURLSession *)getBackgroundSession:(NSString *)identifier {

    NSURLSession *backgroundSession = nil;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"background-NSURLSession-%@",identifier]];
    configuration.HTTPMaximumConnectionsPerHost = 5;
    configuration.discretionary = YES;
    backgroundSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    return backgroundSession;
}

/** 下载 */
- (void)downloadTask{
    
    NSLog(@"新建下载任务");
    self.session = [self getBackgroundSession:self.name];
    [self.dataTask resume];
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    
    //把数据写进沙盒
    [self.outputSteam write:data.bytes maxLength:data.length];
    
    self.tempDataSize = ZHGETCacheFileLength(self.name);
    
    //NSLog(@"%@ 的进度：%ld / %ld",self.name, self.tempDataSize, self.totalSize);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    NSUInteger allLength = [httpResponse.allHeaderFields[@"Content-Length"] longLongValue] + ZHGETCacheFileLength(self.name);
    
    self.totalSize == 0 ? [ZHDownloadmanager saveAllLength:(allLength/1024) WithFileName:self.name] : nil;
   
    //开启读写流
    NSOutputStream *outputSteam = [NSOutputStream outputStreamToFileAtPath:ZHCacheFilePath(self.name) append:YES];
    self.outputSteam = outputSteam;
    self.totalSize = (allLength/1024);
    [self.outputSteam open];
    completionHandler(NSURLSessionResponseAllow);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"response" object:[NSNumber numberWithInteger:self.index] userInfo:@{ @"size" : [NSNumber numberWithUnsignedInteger:self.totalSize]}];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    
    NSString *filePath;
    NSMutableDictionary *completeDict = [NSMutableDictionary dictionary];
    
    if (error) {
        self.taskState = ZHDownloadStateFailed;
        [completeDict setObject:error forKey:@"error"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"complement" object:self.name userInfo:completeDict];
        NSLog(@"发生错误 ： %@",error);
        
    }else{
        
        filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)lastObject] stringByAppendingPathComponent:self.name];
        self.taskState = ZHDownloadStateCompleted;
        [[NSFileManager defaultManager] moveItemAtPath:ZHCacheFilePath(self.name) toPath:filePath error:nil];
        [completeDict setObject:filePath forKey:@"path"];
        [completeDict setObject:self.name forKey:@"name"];
        [completeDict setObject:[NSString stringWithFormat:@"%.2f MB",(CGFloat)self.totalSize/2014/1024] forKey:@"size"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"complement" object:[NSNumber numberWithInteger: self.index] userInfo:completeDict];
    }
    
    self.dataTask = nil;
    [self.outputSteam close];
    self.outputSteam = nil;
    
#warning 这里需要做本地视频截图操作，并添加到显示的控制器里
}

#pragma mark - 对任务的操作 : 需要记录model的下载状态
- (void)suspendTask{
    
    //设置任务的各种属性变化
    
    [self.dataTask suspend];
    self.taskState = ZHDownloadStateSuspended;
}

- (void)cancelTask{
    
    //设置任务的各种属性变化
    
    [self.dataTask cancel];
}

- (void)resumeTask{
    
    //设置任务的各种属性变化
    
    [self.dataTask resume];
    self.taskState = ZHDownloadStateDownloading;
}


@end
