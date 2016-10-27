//
//  VideoModel.m
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/8/23.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import "VideoModel.h"

@interface VideoModel ()

@property (nonatomic) NSString *privateType;
@end

@implementation VideoModel

+ (instancetype)cellModelWithDict:(NSDictionary *)dict{
    
    VideoModel *cellModel = [[self alloc]init];
#warning 这里暂时用ValueForKey, 如果改成网络版，需要使用MJExtension的setKeyValue封装方法，不用分类直接读json或者字典
    [cellModel setValuesForKeysWithDictionary:dict];
    return cellModel;
}


- (void)setIsOnlineVideo:(BOOL)isOnlineVideo{
    
    isOnlineVideo ? (self.Type = VideoModelTypeOnline): (self.Type = VideoModelTypeLocal);
}

//- (void)setType:(VideoModelType)Type{
//    
//    NSString *temp;
//    Type ? (temp = nil) : (temp = @"bendi");
//    [self willChangeValueForKey:@"VideoModelType"];
//    [self setPrivateType:temp];
//    [self didChangeValueForKey:@"VideoModelType"];
//}
//
//- (VideoModelType)Type{
//    
//    [self willChangeValueForKey:@"VideoModelType"];
//    NSString *tempValue = [self privateType];
//    [self didChangeValueForKey:@"VideoModelType"];
//    return (tempValue == nil) ? VideoModelTypeOnline : VideoModelTypeLocal;
//}
@end
