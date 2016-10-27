//
//  VideoModel.m
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/8/23.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import "VideoModel.h"

//@interface VideoModel ()
//
//@property (nonatomic) NSString *privateType;
//
//@end

@implementation VideoModel

+ (instancetype)cellModelWithDict:(NSDictionary *)dict{
    
//    VideoModel *cellModel = [[self alloc]init];
//    [cellModel setValuesForKeysWithDictionary:dict];
    
    VideoModel *cellModel = [VideoModel objectWithKeyValues:dict];

    
    return cellModel;
}

//- (id)valueForUndefinedKey:(NSString *)key{
//    
//    return nil;
//}

- (NSString *)progressInfo{
    
    if (!_progressInfo) {
        
        _progressInfo = @"0.00";
        
    }else if(self.totalSize == 0){
        
        _progressInfo = @"等待下载";
    
    }else{
        
        //self.isDownloading = YES;
        float progress = (((float)self.tempDataSize/1024) / ((float)self.totalSize/1024)) ;
        _progressInfo = [NSString stringWithFormat:@"%.02f / %.02fMB     %.0f%%",(float)self.tempDataSize/1024, (float)self.totalSize/1024, progress * 100];
    }
    
    return _progressInfo;
}

@end
