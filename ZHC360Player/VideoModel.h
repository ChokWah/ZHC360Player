//
//  VideoModel.h
//  ZHC360Player
//
//  Created by 4DAGE_HUA on 16/8/23.
//  Copyright © 2016年 4DAGE. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, VideoModelType) {
    VideoModelTypeOnline = 0,          // onlineVideo
    VideoModelTypeLocal         // localVideo
};

@interface VideoModel : NSObject

// Video 模型（在线和本地） ：名字，地址，图片地址，大小，在线还是本地

/**
 模型的名字
 */
@property (nonatomic ,copy) NSString *name;

/**
 模型的地址
 */
@property (nonatomic ,copy) NSString *adressUrlStr;

/**
 模型的图片地址
 */
@property (nonatomic ,copy) NSString *imageUrlStr;

/**
 模型的大小
 */
@property (nonatomic,assign) long long size;

/**
 模型的类型
 */
@property (nonatomic,assign) VideoModelType Type;

@property (nonatomic) BOOL isOnlineVideo;
//类方法 - 返回模型

+ (instancetype) cellModelWithDict:(NSDictionary *)dict;

@end
