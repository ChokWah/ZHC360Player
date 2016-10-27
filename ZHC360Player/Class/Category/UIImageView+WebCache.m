//
//  UIImageView+WebCache.m
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/8/23.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import "UIImageView+WebCache.h"

@implementation UIImageView (WebCache)



- (void)zh_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder{
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    if ([request URL] == nil) {
        
        //[self cancelTask];
        self.image = placeholder;
        return;
    }
    
    //判断NSURLSessionDataTask 的string 跟 url string 是否一样
    
    //检查在 downloader.否有缓存
}





#warning TODO :这里的下载应该封装一个下载管理器，管理所有的下载，用NSOperation管理
- (void)zh_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(ZHWebImageCompletionBlock)completedBlock{
    
    __weak typeof(self) weakSelf = self;
    
    [self setPlaceholderImage:placeholder];
    
//    NSURLSession *session = [NSURLSession sharedSession];
//    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
//        
//        NSString *path = [docDirectionary stringByAppendingPathComponent:response.suggestedFilename];
//        
//        [fileManager copyItemAtURL:location toURL:[NSURL URLWithString:path] error:nil];
//        NSLog(@"复制文件到沙盒文档：%@",path);
//        weakSelf.image = [UIImage imageWithContentsOfFile:path];
//        completedBlock(nil,nil,ZHImageCacheTypeDisk,[NSURL URLWithString:path]);
//        
//    }];
//    // 启动任务
//    [task resume];
    
}

- (void)setPlaceholderImage:(UIImage *)placeholder{
    
    if ([NSThread isMainThread]) {
        self.image = placeholder;
    } else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.image = placeholder;
            
        });
    }
}

@end
