//
//  DownloadModel.m
//  下载工具
//
//  Created by 4DAGE_HUA on 16/10/13.
//  Copyright © 2016年 ZHC. All rights reserved.
//

#import "DownloadModel.h"
#import "VideoModel.h"

@implementation DownloadModel

- (NSString *)sectionTitil{
    
    if(self.sectionType == DownloadSectionTypeDownload){
        return [NSString stringWithFormat:@"正在下载(%lu)",self.cellModelsArray.count];
    }else{
        return [NSString stringWithFormat:@"下载完成(%lu)",self.cellModelsArray.count];
    }
}

- (NSMutableArray *)cellModelsArray{
    
    if (!_cellModelsArray) {
        _cellModelsArray = [NSMutableArray array];
    }
    return _cellModelsArray;
}

- (BOOL)didEmptyAfterRemoveObjectInCellModelsArray:(VideoModel *)model{

    [self.cellModelsArray removeObject:model];
    
    if (self.cellModelsArray.count == 0) {
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)didEmptyAfterRemoveObjectInCellModelsArrayIndex:(NSUInteger)row{
    
    [self.cellModelsArray removeObjectAtIndex:row];
    
    if (self.cellModelsArray.count == 0) {
        return YES;
    }else{
        return NO;
    }
}
@end
