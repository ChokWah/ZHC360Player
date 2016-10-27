//
//  DownloadViewController.h
//  下载工具
//
//  Created by 4DAGE_HUA on 16/9/8.
//  Copyright © 2016年 ZHC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoModel;
@interface DownloadViewController : UIViewController

/** 单例*/
+ (instancetype)defaultViewController;

/** 新增下载*/
- (BOOL)addTaskWithVideoModel:(VideoModel *)model;
@end

