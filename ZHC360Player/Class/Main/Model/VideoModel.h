//
//  VideoModel.h
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/8/23.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoModel : NSObject

/** 名字 */
@property (nonatomic, copy) NSString *name;

/** 下载地址 */
@property (nonatomic, copy) NSString *downloadPath;

/** 本地路径*/
@property (nonatomic, copy) NSString *path;

/** 缩略图地址 */
@property (nonatomic, copy) NSString *imageUrlStr;

/** 进度信息*/
@property (nonatomic, copy) NSString *progressInfo;

/** 下载完成时间*/
@property (nonatomic, copy) NSString *dateString;

/** 文件总量大小，单位是B*/
@property (nonatomic, assign) NSUInteger totalSize;

/** 已下载数据大小，单位是B*/
@property (nonatomic, assign) NSUInteger tempDataSize;

/** 是否处于下载状态*/
@property (nonatomic, assign) BOOL isDownloading;

/** 是否处于查看操作状态*/
@property (nonatomic, assign) BOOL isReadyDownload;

/** 顺序index*/
@property (nonatomic, assign) NSUInteger index;

//类方法 - 返回模型
+ (instancetype) cellModelWithDict:(NSDictionary *)dict;

@end
