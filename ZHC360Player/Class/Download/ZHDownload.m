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


@interface ZHDownload ()

/** 下载会话 */
@property (nonatomic, strong) NSURLSession *session;

/** 用于给Session下载的任务NSURLSessionDataTask */
@property (nonatomic, assign) NSURLSessionDataTask *dataTask;

/** 输出流 */
@property (nonatomic, strong) NSOutputStream *outputSteam;

@end

@implementation ZHDownload

+ (instancetype)downloadModelWith:(NSDictionary *)dict{
    
    ZHDownload *dwModel = [ZHDownload objectWithKeyValues:dict];
    return dwModel;
}

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

//- (NSURLSession *)session{
//    
//    if (!_session) {
//        
//        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
//        
//    }
//    return _session;
//}

- (NSURLSession *)getBackgroundSession:(NSString *)identifier {

    NSURLSession *backgroundSession = nil;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"background-NSURLSession-%@",identifier]];
    configuration.HTTPMaximumConnectionsPerHost = 5;
    configuration.discretionary = YES;
    configuration.sessionSendsLaunchEvents = YES;
    backgroundSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    return backgroundSession;
}

/** 下载 */
- (void)downloadTask{
    
    self.session = [self getBackgroundSession:self.name];
    [self.dataTask resume];
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    
    //把数据写进沙盒
    [self.outputSteam write:data.bytes maxLength:data.length];
    
    self.tempDataSize += data.length; //ZHGETCacheFileLength(self.name) / 1024;

    //NSLog(@"%@ 的进度：%ld / %ld",self.name, self.tempDataSize, self.totalSize);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    NSUInteger allLength = [httpResponse.allHeaderFields[@"Content-Length"] longLongValue] + ZHGETCacheFileLength(self.name);
    //开启读写流
    NSOutputStream *outputSteam = [NSOutputStream outputStreamToFileAtPath:ZHCacheFilePath(self.name) append:YES];
    self.outputSteam = outputSteam;
    self.totalSize = (allLength/1024);
    [self.outputSteam open];
    completionHandler(NSURLSessionResponseAllow);
    NSDictionary *dict = @{@"size" : [NSNumber numberWithUnsignedInteger:self.totalSize],
                           @"name" : self.name};
    if([self.delegate respondsToSelector:@selector(ZHDownload:didReceiveResponseWithInfo:)]){
        
        [self.delegate ZHDownload:self didReceiveResponseWithInfo:dict];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    
    NSString *filePath;
    NSMutableDictionary *completeDict = [NSMutableDictionary dictionary];
    [completeDict setObject:self.name forKey:@"name"];
    
    if (error) {
        self.taskState = ZHDownloadStateFailed;
        [completeDict setObject:error forKey:@"error"];
        NSLog(@"发生错误 ： %@",error);
        
    }else{
        
        filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)lastObject] stringByAppendingPathComponent:self.name];
        self.taskState = ZHDownloadStateCompleted;
        [ZHFILEMANAGER moveItemAtPath:ZHCacheFilePath(self.name) toPath:filePath error:nil];
        [completeDict setObject:filePath forKey:@"path"];
        [completeDict setObject:[NSString stringWithFormat:@"%.2f MB",(CGFloat)self.totalSize/1024/1024] forKey:@"size"];
    }
    
    if([self.delegate respondsToSelector:@selector(ZHDownload:didCompleteWithInfo:Error:)]){
        
        [self.delegate ZHDownload:self didCompleteWithInfo:completeDict Error:error];
    }
    self.dataTask = nil;
    [self.outputSteam close];
    self.outputSteam = nil;
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

- (void)dealloc{
    
    _session     = nil;
    _outputSteam = nil;
    _dataTask    = nil;
    NSLog(@"销毁ZHDownload任务");
}
@end
