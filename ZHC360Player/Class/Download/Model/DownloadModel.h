//
//  DownloadModel.h
//  下载工具
//
//  Created by 4DAGE_HUA on 16/10/13.
//  Copyright © 2016年 ZHC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DownloadSectionType) {
    
    DownloadSectionTypeDownload = 0,
    
    DownloadSectionTypeLocation,
};

@class VideoModel;

@interface DownloadModel : NSObject

/** section的标题*/
@property (strong, nonatomic) NSString *sectionTitil;

/** section的类型*/
@property (assign, nonatomic) DownloadSectionType sectionType;

/** 对应section内的数据：VideoModel的数组*/
@property (strong, nonatomic) NSMutableArray<VideoModel *> *cellModelsArray;

/** 用于判断删除数组里的模型后是否为空Section*/
- (BOOL) didEmptyAfterRemoveObjectInCellModelsArray:(VideoModel *)model;

- (BOOL) didEmptyAfterRemoveObjectInCellModelsArrayIndex:(NSUInteger)row;
@end
